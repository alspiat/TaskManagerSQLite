//
//  AddTaskTableViewController.h
//  TaskManagerSQLite
//
//  Created by Алексей on 10.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@interface AddTaskTableViewController : UITableViewController

@property (strong, nonatomic) Task* task;

@end
