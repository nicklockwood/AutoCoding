//
//  AutoCoding_XCTests.m
//  AutoCoding XCTests
//
//  Created by Alex Gray on 9/23/14.
//
//

#import <Cocoa/Cocoa.h>
#import <XCTest/XCTest.h>
#import "TestObject.h"
#import "AutoCoding.h"

@interface AutoCoding_XCTests : XCTestCase

@end

@implementation AutoCoding_XCTests

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
    XCTAssert([output.publicString isEqual:input.publicString], @"Public string test failed");
    XCTAssert(output.publicInteger == input.publicInteger, @"Public integer test failed");
    XCTAssert(output.readonlyIntegerWithSupportedIvar == input.readonlyIntegerWithSupportedIvar, @"Readonly integer with KVC-compliant ivar test failed");
    XCTAssert([output privateDataIsEqual:input], @"Private integer test failed");
    XCTAssert([output.dynamicProperty isEqualToString:input.dynamicProperty], @"Dynamic string test failed");
    
    //check ineligible values are not saved
    XCTAssert(output.publicUncodable != input.publicUncodable, @"Public uncodable test failed");
    XCTAssert(![output privateUncodableIsEqual:input], @"Private uncodable test failed");
    XCTAssert(output.readonlyIntegerWithUnsupportedIvar != input.readonlyIntegerWithUnsupportedIvar, @"Readonly integer without KVC-compliant ivar test failed");
    XCTAssert(output.readonlyIntegerWithPrivateSetter != input.readonlyIntegerWithPrivateSetter, @"Readonly integer with private setter test failed");
    XCTAssert(![output.readonlyDynamicProperty isEqualToString:input.readonlyDynamicProperty], @"Readonly dynamic string test failed");
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
        XCTAssert(didCrash, @"Decoding invalid object type failed");
    }
}

@end
