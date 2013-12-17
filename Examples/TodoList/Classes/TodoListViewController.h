//
//  TodoList1ViewController.h
//  TodoList1
//
//  Created by Nick Lockwood on 08/04/2010.
//  Copyright Charcoal Design 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TodoListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) IBOutlet UITableView *tableView;

- (IBAction)toggleEditing:(id)sender;
- (IBAction)createNewItem;

@end

