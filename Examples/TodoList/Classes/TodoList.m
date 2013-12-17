//
//  TodoList.m
//  TodoList
//
//  Created by Nick Lockwood on 15/04/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//

#import "TodoList.h"
#import "TodoItem.h"
#import "AutoCoding.h"


@implementation TodoList

+ (NSString *)documentsDirectory
{	
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
}

+ (TodoList *)sharedList
{	
    static TodoList *sharedList = nil;
	if (sharedList == nil)
    {
        //attempt to load saved file
        NSString *path = [[self documentsDirectory] stringByAppendingPathComponent:@"TodoList.plist"];
        sharedList = [TodoList objectWithContentsOfFile:path];
                      
        //if that fails, create a new, empty list
		if (sharedList == nil)
        {
            sharedList = [[TodoList alloc] init];
		}
	}
	return sharedList;
}

- (id)init
{
    if ((self = [super init]))
    {
        _items = [NSMutableArray array];
    }
    return self;
}

- (void)save
{
	NSString *path = [[[self class] documentsDirectory] stringByAppendingPathComponent:@"TodoList.plist"];
    [self writeToFile:path atomically:YES];
}

@end
