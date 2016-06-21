//
//  TestObject.m
//  UnitTests
//
//  Created by Nick Lockwood on 22/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestObject.h"
#import "AutoCoding.h"
#import <objc/runtime.h>


#pragma clang diagnostic ignored "-Wdirect-ivar-access"


@interface TestObject ()

@property (nonatomic, assign) NSInteger readonlyIntegerWithPrivateSetter;
@property (nonatomic, assign) NSInteger privateInteger;
@property (nonatomic, assign) NSInteger privateUncodable;

@end


@implementation TestObject

@synthesize readonlyIntegerWithUnsupportedIvar = _readonlyIntegerWithUnsupportedIvar123;
@synthesize readonlyIntegerWithPrivateSetter = _readonlyIntegerWithPrivateSetter123;
@dynamic dynamicProperty;
@dynamic readonlyDynamicProperty;

+ (NSArray *)uncodableProperties
{
    return @[@"privateUncodable", @"publicUncodable"];
}

- (void)setUpReadonlyAndPrivateData
{
    _readonlyIntegerWithUnsupportedIvar123 = 7;
    _readonlyIntegerWithPrivateSetter123 = 8;
    _privateInteger = 9;
    _privateUncodable = 5;
    objc_setAssociatedObject(self, @selector(readonlyDynamicProperty), @"foo", OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)privateDataIsEqual:(TestObject *)object
{
    return _privateInteger == object.privateInteger;
}

- (BOOL)privateUncodableIsEqual:(TestObject *)object
{
    return _privateUncodable == object.privateUncodable;
}

- (BOOL)isEqual:(id)object
{
    if (object_getClass(object) != [self class])
    {
        return NO;
    }
    return [[self dictionaryRepresentation] isEqualToDictionary:[(NSObject *)object dictionaryRepresentation]];
}

- (NSString *)dynamicProperty
{
    return objc_getAssociatedObject(self, _cmd);
}

- (void)setDynamicProperty:(NSString *)prop
{
    objc_setAssociatedObject(self, @selector(dynamicProperty), prop, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)readonlyDynamicProperty
{
    return objc_getAssociatedObject(self, _cmd);
}

@end
