//
//  DataTests.m
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 Charcoal Design. All rights reserved.
//

#import "DataTests.h"
#import "TestObject.h"
#import "AutoCoding.h"


@implementation DataTests

- (void)testOutputEqualsInput
{
    //create object
    TestObject *input = [[TestObject alloc] init];
    input.publicString = @"Hello World";
    input.publicInteger = 5;
    input.publicUncodable = 7;
    input.dynamicProperty = @"Foobar";
    [input setUpReadonlyAndPrivateData];
    
    //save object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:input];
    
    //load object
    TestObject *output = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    
    //check eligible values are saved
    NSAssert([output.publicString isEqual:input.publicString], @"Public string test failed");
    NSAssert(output.publicInteger == input.publicInteger, @"Public integer test failed");
    NSAssert(output.readonlyIntegerWithSupportedIvar == input.readonlyIntegerWithSupportedIvar, @"Readonly integer with KVC-compliant ivar test failed");
    NSAssert([output privateDataIsEqual:input], @"Private integer test failed");
    NSAssert([output.dynamicProperty isEqualToString:input.dynamicProperty], @"Dynamic string test failed");
    
    //check ineligible values are not saved
    NSAssert(output.publicUncodable != input.publicUncodable, @"Public uncodable test failed");
    NSAssert(![output privateUncodableIsEqual:input], @"Private uncodable test failed");
    NSAssert(output.readonlyIntegerWithUnsupportedIvar != input.readonlyIntegerWithUnsupportedIvar, @"Readonly integer without KVC-compliant ivar test failed");
    NSAssert(output.readonlyIntegerWithPrivateSetter != input.readonlyIntegerWithPrivateSetter, @"Readonly integer with private setter test failed");
    NSAssert(![output.readonlyDynamicProperty isEqualToString:input.readonlyDynamicProperty], @"Readonly dynamic string test failed");
}

- (void)testSecureCoding
{
    //create object
    TestObject *input = [[TestObject alloc] init];
    input.publicString = (NSString *)@5; //deliberate type mismatch
    
    //save object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:input];
    
    BOOL didCrash = NO;
    @try
    {
        //load object (should crash)
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        [unarchiver setRequiresSecureCoding:YES];
        [unarchiver decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    }
    @catch (NSException *exception)
    {
        didCrash = YES;
    }
    @finally
    {
        NSAssert(didCrash, @"Decoding invalid object type failed");
    }
}

@end
