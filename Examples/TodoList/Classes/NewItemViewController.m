//
//  NewItemViewController.m
//  TodoList
//
//  Created by Nick Lockwood on 15/04/2010.
//  Copyright 2010 Charcoal Design. All rights reserved.
//

#import "NewItemViewController.h"
#import "TodoList.h"
#import "TodoItem.h"

@interface NewItemViewController()

@property (nonatomic, strong) TodoItem *item;

@end


@implementation NewItemViewController

- (void)textViewDidEndEditing:(UITextView *)textView
{	
	if (self.item == nil)
    {
		//create a new TodoItem and add to list
		self.item = [TodoItem itemWithLabel:textView.text];
		[[TodoList sharedList].items addObject:self.item];	
	}
    else
    {
		//update the TodoItem
		self.item.label = textView.text;
	}
	
	//save the TodoList
	[[TodoList sharedList] save];
}

@end
