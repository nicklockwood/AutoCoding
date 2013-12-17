//
//  TodoListViewController.m
//  TodoList
//
//  Created by Nick Lockwood on 08/04/2010.
//  Copyright Charcoal Design 2010. All rights reserved.
//

#import "TodoListViewController.h"
#import "NewItemViewController.h"
#import "TodoItem.h"
#import "TodoList.h"


@implementation TodoListViewController

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	[self.tableView reloadData];
}

- (IBAction)toggleEditing:(id)sender
{	
	[self.tableView setEditing:!self.tableView.editing animated:YES];
	[sender setTitle:(self.tableView.editing)? @"Done" : @"Edit"];
}

- (IBAction)createNewItem
{	
	UIViewController *viewController = [[NewItemViewController alloc] init];
	[self.navigationController pushViewController:viewController animated:YES];
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{	
	TodoItem *item = [TodoList sharedList].items[(NSUInteger)indexPath.row];
	item.checked = !item.checked;
	[tableView reloadRowsAtIndexPaths:@[indexPath]withRowAnimation:UITableViewRowAnimationNone];
    [[TodoList sharedList] save];
}

- (UITableViewCellEditingStyle)tableView:(__unused UITableView *)tableView editingStyleForRowAtIndexPath:(__unused NSIndexPath *)indexPath
{	
	return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(__unused UITableView *)tableView commitEditingStyle:(__unused UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{	
	[[TodoList sharedList].items removeObjectAtIndex:(NSUInteger)indexPath.row];
	[[TodoList sharedList] save];
	[self.tableView reloadData];
}

#pragma mark -
#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(__unused UITableView *)table numberOfRowsInSection:(__unused NSInteger)section
{	
	return (NSInteger)[[TodoList sharedList].items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{	
	static NSString *cellType = @"Cell";
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellType];
	if (cell == nil)
    {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellType];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
	}
	
	TodoItem *item = [TodoList sharedList].items[(NSUInteger)indexPath.row];
	cell.textLabel.text = item.label;
	cell.accessoryType = item.checked? UITableViewCellAccessoryCheckmark: UITableViewCellAccessoryNone;

	return cell;
}

@end
