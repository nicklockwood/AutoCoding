//
//  AutoCoding.m
//
//  Version 2.0.3
//
//  Created by Nick Lockwood on 19/11/2011.
//  Copyright (c) 2011 Charcoal Design
//
//  Distributed under the permissive zlib License
//  Get the latest version from here:
//
//  https://github.com/nicklockwood/AutoCoding
//
//  This software is provided 'as-is', without any express or implied
//  warranty.  In no event will the authors be held liable for any damages
//  arising from the use of this software.
//
//  Permission is granted to anyone to use this software for any purpose,
//  including commercial applications, and to alter it and redistribute it
//  freely, subject to the following restrictions:
//
//  1. The origin of this software must not be misrepresented; you must not
//  claim that you wrote the original software. If you use this software
//  in a product, an acknowledgment in the product documentation would be
//  appreciated but is not required.
//
//  2. Altered source versions must be plainly marked as such, and must not be
//  misrepresented as being the original software.
//
//  3. This notice may not be removed or altered from any source distribution.
//

#import "AutoCoding.h"
#import <objc/runtime.h>


static void AC_swizzleInstanceMethod(Class c, SEL original, SEL replacement)
{
    Method a = class_getInstanceMethod(c, original);
    Method b = class_getInstanceMethod(c, replacement);
    if (class_addMethod(c, original, method_getImplementation(b), method_getTypeEncoding(b)))
    {
        class_replaceMethod(c, replacement, method_getImplementation(a), method_getTypeEncoding(a));
    }
    else
    {
        method_exchangeImplementations(a, b);
    }
}

@interface NSObject (AutoCoding_NSCopying)

- (id)copyWithZone:(NSZone *)zone;

@end

@implementation NSObject (AutoCoding)

+ (BOOL)supportsSecureCoding
{
    return YES;
}

+ (void)load
{
    AC_swizzleInstanceMethod(self, @selector(methodSignatureForSelector:), @selector(methodSignatureForSelector_AC:));
    AC_swizzleInstanceMethod(self, @selector(forwardInvocation:), @selector(forwardInvocation_AC:));
    AC_swizzleInstanceMethod(self, @selector(respondsToSelector:), @selector(respondsToSelector_AC:));
}

- (instancetype)copyWithZone_AC:(NSZone *)zone __attribute__((ns_returns_retained))
{
    NSObject *copy = [[[self class] allocWithZone:zone] init];
    for (NSString *key in [self codableProperties])
    {
        id object = [self valueForKey:key];
        if (object) [copy setValue:object forKey:key];
    }
    return copy;
}

- (NSMethodSignature *)methodSignatureForSelector_AC:(SEL)selector
{
    @synchronized([self class])
    {
        //look up method signature
        NSMethodSignature *signature = [self methodSignatureForSelector_AC:selector];
        if (!signature && selector == @selector(copyWithZone:))
        {
            return [NSMethodSignature signatureWithObjCTypes:"@@:@"];
        }
        return signature;
    }
}

- (void)forwardInvocation_AC:(NSInvocation *)invocation
{
    if ([invocation selector] == @selector(copyWithZone:))
    {
        [invocation setSelector:@selector(copyWithZone_AC:)];
        [invocation invokeWithTarget:self];
    }
    else
    {
        [self forwardInvocation_AC:invocation];
    }
}

- (BOOL)respondsToSelector_AC:(SEL)selector
{
    if (selector == @selector(copyWithZone:))
    {
        return YES;
    }
    return [self respondsToSelector_AC:selector];
}

+ (instancetype)objectWithContentsOfFile:(NSString *)filePath
{
    //load the file
    NSData *data = [NSData dataWithContentsOfFile:filePath];
    
    //attempt to deserialise data as a plist
    id object = nil;
    if (data)
    {
        NSPropertyListFormat format;
        if ([NSPropertyListSerialization respondsToSelector:@selector(propertyListWithData:options:format:error:)])
        {
            object = [NSPropertyListSerialization propertyListWithData:data options:NSPropertyListImmutable format:&format error:NULL];
        }
        else
        {
            object = [NSPropertyListSerialization propertyListFromData:data mutabilityOption:NSPropertyListImmutable format:&format errorDescription:NULL];
        }
		
		//success?
		if (object)
		{
			//check if object is an NSCoded unarchive
			if ([object respondsToSelector:@selector(objectForKey:)] && [object objectForKey:@"$archiver"])
			{
				object = [NSKeyedUnarchiver unarchiveObjectWithData:data];
			}
		}
		else
		{
			//return raw data
			object = data;
		}
    }
    
	//return object
	return object;
}

- (BOOL)writeToFile:(NSString *)filePath atomically:(BOOL)useAuxiliaryFile
{
    //note: NSData, NSDictionary and NSArray already implement this method
    //and do not save using NSCoding, however the objectWithContentsOfFile
    //method will correctly recover these objects anyway
    
    //archive object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    return [data writeToFile:filePath atomically:useAuxiliaryFile];
}

+ (NSDictionary *)codableProperties
{
    @synchronized([NSObject class])
    {
        static NSMutableDictionary *keysByClass = nil;
        if (keysByClass == nil)
        {
            keysByClass = [[NSMutableDictionary alloc] init];
        }
        
        NSString *className = NSStringFromClass(self);
        NSMutableDictionary *codableProperties = [keysByClass objectForKey:className];
        if (codableProperties == nil)
        {
            //deprecated
            if ([self respondsToSelector:@selector(codableKeys)] ||
                [self instancesRespondToSelector:@selector(codableKeys)])
            {
                NSLog(@"AutoCoding Warning: codableKeys method is no longer supported. Use codableProperties instead.");
            }
            if ([self respondsToSelector:@selector(uncodableKeys)] ||
                [self instancesRespondToSelector:@selector(uncodableKeys)])
            {
                NSLog(@"AutoCoding Warning: uncodableKeys method is no longer supported. Use uncodableProperties instead.");
            }
            
            codableProperties = [NSMutableDictionary dictionary];
            unsigned int propertyCount;
            objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
            for (unsigned int i = 0; i < propertyCount; i++)
            {
                //get property name
                objc_property_t property = properties[i];
                const char *propertyName = property_getName(property);
                NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
                
                //check if codable
                if (![[self uncodableProperties] containsObject:key])
                {
                    //get property type
                    Class class = nil;
                    char *typeEncoding = property_copyAttributeValue(property, "T");
                    switch (typeEncoding[0])
                    {
                        case '@':
                        {
                            if (strlen(typeEncoding) >= 3)
                            {
                                char *className = strndup(typeEncoding + 2, strlen(typeEncoding) - 3);
                                NSString *name = [NSString stringWithUTF8String:className];
                                NSRange range = [name rangeOfString:@"<"];
                                if (range.location != NSNotFound)
                                {
                                    name = [name substringToIndex:range.location];
                                }
                                class = NSClassFromString(name) ?: [NSObject class];
                                free(className);
                            }
                            break;
                        }
                        case 'c':
                        case 'i':
                        case 's':
                        case 'l':
                        case 'q':
                        case 'C':
                        case 'I':
                        case 'S':
                        case 'f':
                        case 'd':
                        case 'B':
                        {
                            class = [NSNumber class];
                            break;
                        }
                        case '{':
                        {
                            class = [NSValue class];
                            break;
                        }
                    }
                    free(typeEncoding);
                    
                    if (class)
                    {
                        //see if there is a backing ivar
                        char *ivar = property_copyAttributeValue(property, "V");
                        if (ivar)
                        {
                            char *readonly = property_copyAttributeValue(property, "R");
                            if (readonly)
                            {
                                //check if ivar has KVC-compliant name
                                NSString *ivarName = [NSString stringWithFormat:@"%s", ivar];
                                if ([ivarName isEqualToString:key] ||
                                    [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
                                {
                                    //no setter, but setValue:forKey: will still work
                                    codableProperties[key] = class;
                                }
                                free(readonly);
                            }
                            else
                            {
                                //there is a setter method so setValue:forKey: will work
                                codableProperties[key] = class;
                            }
                            free(ivar);
                        }
                    }
                }
            }
            free(properties);
            [keysByClass setObject:[NSDictionary dictionaryWithDictionary:codableProperties] forKey:className];
        }
        return codableProperties;
    }
}

+ (NSArray *)uncodableProperties
{
    return nil;
}

- (NSDictionary *)codableProperties
{
    @synchronized([NSObject class])
    {
        static NSMutableDictionary *propertiesByClass = nil;
        if (propertiesByClass == nil)
        {
            propertiesByClass = [[NSMutableDictionary alloc] init];
        }
        
        NSString *className = NSStringFromClass([self class]);
        NSDictionary *codableProperties = propertiesByClass[className];
        if (codableProperties == nil)
        {
            NSMutableDictionary *properties = [NSMutableDictionary dictionary];
            Class class = [self class];
            while (class != [NSObject class])
            {
                [properties addEntriesFromDictionary:[class codableProperties]];
                class = [class superclass];
            }
            codableProperties = [properties copy];
            [propertiesByClass setObject:codableProperties forKey:className];
        }
        return codableProperties;
    }
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryWithValuesForKeys:[[self codableProperties] allKeys]];
}

- (void)setWithCoder:(NSCoder *)aDecoder
{
    BOOL secureAvailable = [aDecoder respondsToSelector:@selector(decodeObjectOfClass:forKey:)];
    BOOL secureSupported = [[self class] supportsSecureCoding];
    NSDictionary *properties = [self codableProperties];
    for (NSString *key in properties)
    {
        id object = nil;
        Class class = properties[key];
        if (secureAvailable && secureSupported)
        {
            object = [aDecoder decodeObjectOfClass:class forKey:key];
        }
        else
        {
            object = [aDecoder decodeObjectForKey:key];
        }
        if (object)
        {
            if (secureSupported && ![object isKindOfClass:class])
            {
                [NSException raise:@"AutocodingException" format:@"Expected '%@' to be a %@, but was actually a %@", key, class, [object class]];
            }
            [self setValue:object forKey:key];
        }
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    [self setWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in [self codableProperties])
    {
        id object = [self valueForKey:key];
        if (object) [aCoder encodeObject:object forKey:key];
    }
}

@end