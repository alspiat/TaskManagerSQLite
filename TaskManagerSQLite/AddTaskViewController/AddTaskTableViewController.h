//
//  AddTaskTableViewController.h
//  TaskManagerSQLite
//
//  Created by Алексей on 10.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Task;

@protocol AddTaskViewControllerDelegate <NSObject>

@required

-(void)saveNewTask: (Task*) task;
-(void)updateTask: (Task*) task;

@end

@interface AddTaskTableViewController : UITableViewController

@property (strong, nonatomic) Task* task;
@property (nonatomic, weak) id<AddTaskViewControllerDelegate> delegate;

@end
