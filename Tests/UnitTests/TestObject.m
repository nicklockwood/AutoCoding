//
//  TestObject.m
//  UnitTests
//
//  Created by Nick Lockwood on 22/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "TestObject.h"


@interface TestObject ()

@property (nonatomic, assign) NSInteger readonlyIntegerWithPrivateSetter;
@property (nonatomic, assign) NSInteger privateInteger;

@end


@implementation TestObject

@synthesize publicString = _publicString;
@synthesize publicInteger = _publicInteger;
@synthesize readonlyIntegerWithUnsupportedIvar = _readonlyIntegerWithUnsupportedIvar123;
@synthesize readonlyIntegerWithSupportedIvar = _readonlyIntegerWithSupportedIvar;
@synthesize readonlyIntegerWithPrivateSetter = _readonlyIntegerWithPrivateSetter123;
@synthesize privateInteger = _privateInteger;
@synthesize nilProperty = _nilProperty;

- (void)setUpReadonlyAndPrivateData
{
    _readonlyIntegerWithUnsupportedIvar123 = 7;
    _readonlyIntegerWithPrivateSetter123 = 8;
    _privateInteger = 9;
}

- (BOOL)privateDataIsEqual:(TestObject *)object
{
    return _privateInteger == object.privateInteger;
}

@end
