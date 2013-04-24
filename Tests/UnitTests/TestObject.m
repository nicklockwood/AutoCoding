//
//  TestObject.m
//  UnitTests
//
//  Created by Nick Lockwood on 22/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestObject.h"
#import "AutoCoding.h"


@interface TestObject ()

@property (nonatomic, assign) NSInteger readonlyIntegerWithPrivateSetter;
@property (nonatomic, assign) NSInteger privateInteger;
@property (nonatomic, assign) NSInteger privateUncodable;

@end


@implementation TestObject

@synthesize readonlyIntegerWithUnsupportedIvar = _readonlyIntegerWithUnsupportedIvar123;
@synthesize readonlyIntegerWithPrivateSetter = _readonlyIntegerWithPrivateSetter123;

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
    return [[self dictionaryRepresentation] isEqualToDictionary:[object dictionaryRepresentation]];
}

@end
