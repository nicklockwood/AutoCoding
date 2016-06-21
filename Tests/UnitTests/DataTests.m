//
//  DataTests.m
//
//  Created by Nick Lockwood on 12/01/2012.
//  Copyright (c) 2012 Charcoal Design. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestObject.h"
#import "AutoCoding.h"

@interface DataTests : XCTestCase

@end


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
    XCTAssertEqualObjects(output.publicString, input.publicString);
    XCTAssertEqual(output.publicInteger, input.publicInteger);
    XCTAssertEqual(output.readonlyIntegerWithSupportedIvar, input.readonlyIntegerWithSupportedIvar);
    XCTAssertEqualObjects(output, input);
    XCTAssertEqualObjects(output.dynamicProperty, input.dynamicProperty);
    
    //check ineligible values are not saved
    XCTAssertNotEqual(output.publicUncodable, input.publicUncodable);
    XCTAssertFalse([output privateUncodableIsEqual:input]);
    XCTAssertNotEqual(output.readonlyIntegerWithUnsupportedIvar, input.readonlyIntegerWithUnsupportedIvar);
    XCTAssertNotEqual(output.readonlyIntegerWithPrivateSetter, input.readonlyIntegerWithPrivateSetter);
    XCTAssertNotEqualObjects(output.readonlyDynamicProperty, input.readonlyDynamicProperty);
}

- (void)testNullObjectRetention
{
    TestObject *input = [[TestObject alloc] init];
    [input setValue:[NSNull null] forKey:@"publicString"];

    //save object
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:input];

    //load object
    TestObject *output = [NSKeyedUnarchiver unarchiveObjectWithData:data];
    XCTAssertEqualObjects(output.publicString, [NSNull null]);

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
    @catch (__unused NSException *exception)
    {
        didCrash = YES;
    }
    @finally
    {
        XCTAssertTrue(didCrash);
    }
}

@end
