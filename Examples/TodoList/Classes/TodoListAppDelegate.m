//
//  TodoListAppDelegate.m
//  TodoList
//
//  Created by Nick Lockwood on 08/04/2010.
//  Copyright Charcoal Design 2010. All rights reserved.
//

#import "TodoListAppDelegate.h"
#import "TodoListViewController.h"

@implementation TodoListAppDelegate

- (void)applicationDidFinishLaunching:(__unused UIApplication *)application
{    
    // Override point for customization after app launch    
    [self.window addSubview:self.viewController.view];
    [self.window makeKeyAndVisible];
}

@end
