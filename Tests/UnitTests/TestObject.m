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

@synthesize publicString;
@synthesize publicInteger;
@synthesize readonlyInteger;
@synthesize readonlyIntegerWithPrivateSetter;
@synthesize privateInteger;

- (void)setUpReadonlyAndPrivateData
{
    readonlyInteger = 7;
    readonlyIntegerWithPrivateSetter = 8;
    privateInteger = 9;
}

- (BOOL)privateDataIsEqual:(TestObject *)object
{
    return privateInteger == object.privateInteger;
}

@end
