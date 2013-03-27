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

@synthesize readonlyIntegerWithUnsupportedIvar = _readonlyIntegerWithUnsupportedIvar123;
@synthesize readonlyIntegerWithPrivateSetter = _readonlyIntegerWithPrivateSetter123;

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
