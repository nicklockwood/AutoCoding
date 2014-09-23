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

@interface TestObject ()

@property (nonatomic) NSInteger readonlyIntegerWithPrivateSetter,
                                privateInteger,
                                privateUncodable;

@end


@implementation TestObject

@synthesize readonlyIntegerWithUnsupportedIvar = _readonlyIntegerWithUnsupportedIvar123,
            readonlyIntegerWithPrivateSetter   = _readonlyIntegerWithPrivateSetter123,
            privateUncodable  = _privateUncodable_uncodable,
            publicUncodable   = _publicUncodable_uncodable,
            dynamicProperty,
            readonlyDynamicProperty;

- (void)setUpReadonlyAndPrivateData
{
    _readonlyIntegerWithUnsupportedIvar123 = 7;
    _readonlyIntegerWithPrivateSetter123 = 8;
    _privateInteger = 9;
    _privateUncodable_uncodable = 5;
    objc_setAssociatedObject(self, @selector(readonlyDynamicProperty), @"foo", OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (BOOL)privateDataIsEqual:(TestObject *)object
{
    return _privateInteger == object.privateInteger;
}

- (BOOL)privateUncodableIsEqual:(TestObject *)object
{
    return _privateUncodable_uncodable == object.privateUncodable;
}

- (BOOL)isEqual:(id)object
{
    return [[self dictionaryRepresentation] isEqualToDictionary:[object dictionaryRepresentation]];
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
