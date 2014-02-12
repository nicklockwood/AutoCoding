//
//  TestObject.h
//  UnitTests
//
//  Created by Nick Lockwood on 22/03/2012.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestObject : NSObject

@property (nonatomic, strong) NSString *publicString;
@property (nonatomic, assign) NSInteger publicInteger;
@property (nonatomic, assign) NSInteger publicUncodable;
@property (nonatomic, readonly) NSInteger readonlyIntegerWithUnsupportedIvar;
@property (nonatomic, readonly) NSInteger readonlyIntegerWithSupportedIvar;
@property (nonatomic, readonly) NSInteger readonlyIntegerWithPrivateSetter;
@property (nonatomic, strong) id nilProperty;
@property (nonatomic, assign) Class classProperty;
@property (nonatomic, assign) NSString *dynamicProperty;
@property (nonatomic, readonly) NSString *readonlyDynamicProperty;

- (void)setUpReadonlyAndPrivateData;
- (BOOL)privateDataIsEqual:(TestObject *)object;
- (BOOL)privateUncodableIsEqual:(TestObject *)object;

@end
