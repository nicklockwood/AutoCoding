//
//  AutoCoding.m
//
//  Version 1.3
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


@implementation NSObject (AutoCoding)

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

+ (NSArray *)codableKeys
{
    @synchronized([NSObject class])
    {
        static NSMutableDictionary *keysByClass = nil;
        if (keysByClass == nil)
        {
            keysByClass = [[NSMutableDictionary alloc] init];
        }
        
        NSString *className = NSStringFromClass(self);
        NSMutableArray *codableKeys = [keysByClass objectForKey:className];
        if (codableKeys == nil)
        {
            //deprecated
            if ([self instancesRespondToSelector:@selector(uncodableKeys)])
            {
                NSLog(@"AutoCoding Warning: uncodableKeys instance method is no longer supported. Use class method instead.");
            }
     
            codableKeys = [NSMutableArray array];
            unsigned int propertyCount;
            objc_property_t *properties = class_copyPropertyList(self, &propertyCount);
            for (int i = 0; i < propertyCount; i++)
            {
                //get property
                objc_property_t property = properties[i];
                const char *propertyName = property_getName(property);
                NSString *key = [NSString stringWithCString:propertyName encoding:NSUTF8StringEncoding];
                
                //see if there is a backing ivar
                char *ivar = property_copyAttributeValue(property, "V");
                if (ivar)
                {
                    //check if read-only
                    char *readonly = property_copyAttributeValue(property, "R");
                    if (readonly)
                    {
                        //check if ivar has KVC-compliant name
                        NSString *ivarName = [NSString stringWithFormat:@"%s", ivar];
                        if ([ivarName isEqualToString:key] ||
                            [ivarName isEqualToString:[@"_" stringByAppendingString:key]])
                        {
                            //no setter, but setValue:forKey: will still work
                            [codableKeys addObject:key];
                        }
                        free(readonly);
                    }
                    else if (![[self uncodableKeys] containsObject:key])
                    {
                        //there is a setter method so setValue:forKey: will work
                        [codableKeys addObject:key];
                    }
                    free(ivar);
                }
            }
            free(properties);
            [keysByClass setObject:[NSArray arrayWithArray:codableKeys] forKey:className];
        }
        return codableKeys;
    }
}

+ (NSArray *)uncodableKeys
{
    return nil;
}

- (NSArray *)codableKeys
{
    @synchronized([NSObject class])
    {
        static NSMutableDictionary *keysByClass = nil;
        if (keysByClass == nil)
        {
            keysByClass = [[NSMutableDictionary alloc] init];
        }

        NSString *className = NSStringFromClass([self class]);
        NSArray *codableKeys = [keysByClass objectForKey:className];
        if (codableKeys == nil)
        {
            NSMutableSet *set = [NSMutableSet set];
            Class class = [self class];
            while (class != [NSObject class])
            {
                [set addObjectsFromArray:[class codableKeys]];
                class = [class superclass];
            }
            codableKeys = [set allObjects];
            [keysByClass setObject:codableKeys forKey:className];
        }
        return codableKeys;
    }
}

- (NSDictionary *)dictionaryRepresentation
{
    return [self dictionaryWithValuesForKeys:[self codableKeys]];
}

- (void)setWithCoder:(NSCoder *)aDecoder
{
    for (NSString *key in [self codableKeys])
    {
        id object = [aDecoder decodeObjectForKey:key];
        if (object) [self setValue:object forKey:key];
    }
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    [self setWithCoder:aDecoder];
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    for (NSString *key in [self codableKeys])
    {
        id object = [self valueForKey:key];
        if (object) [aCoder encodeObject:object forKey:key];
    }
}

- (instancetype)copyWithZone:(NSZone *)zone
{
    Class class = [self class];
    NSObject *copy = [[class allocWithZone:zone] init];
    for (NSString *key in [self codableKeys])
    {
        id object = [self valueForKey:key];
        if (object) [copy setValue:object forKey:key];
    }
    return copy;
}

@end
