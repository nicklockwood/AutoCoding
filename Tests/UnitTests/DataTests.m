//
//  DataTests.m
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 Charcoal Design. All rights reserved.
//

#import "DataTests.h"
#import "TestObject.h"
#import "NSObject+AutoCoding.h"


@implementation DataTests

- (void)testOutputEqualsInput
{
    //create object
    TestObject *input = [[TestObject alloc] init];
    input.publicString = @"Hello World";
    input.publicInteger = 5;
    [input setUpReadonlyAndPrivateData];
    
    //save object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:input];
    
    //load object
    TestObject *output = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //check eligible values are saved
    NSAssert([output.publicString isEqual:input.publicString], @"Public string failed");
    NSAssert(output.publicInteger == input.publicInteger, @"Public integer failed");
    NSAssert(output.readonlyIntegerWithPrivateSetter == input.readonlyIntegerWithPrivateSetter, @"Readonly integer with private setter failed");
    NSAssert([output privateDataIsEqual:input], @"Private integer failed");
    
    //check ineligible values are not saved
    NSAssert(output.readonlyInteger != input.readonlyInteger, @"Readonly integer failed");
}

@end
