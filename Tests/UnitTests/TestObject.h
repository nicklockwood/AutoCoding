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
@property (nonatomic, readonly) NSInteger readonlyIntegerWithUnsupportedIvar;
@property (nonatomic, readonly) NSInteger readonlyIntegerWithSupportedIvar;
@property (nonatomic, readonly) NSInteger readonlyIntegerWithPrivateSetter;
@property (nonatomic, strong) id nilProperty;

- (void)setUpReadonlyAndPrivateData;
- (BOOL)privateDataIsEqual:(TestObject *)object;

@end
