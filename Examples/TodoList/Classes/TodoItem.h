//
//  TodoItem.h
//  TodoList
//
//  Created by Nick Lockwood on 08/04/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface TodoItem : NSObject

+ (TodoItem *)itemWithLabel:(NSString *)label;

@property (nonatomic, strong) NSString *label;
@property (nonatomic, assign) BOOL checked;

@end
