//
//  TaskServiceProtocol.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;

@protocol TaskServiceProtocol <NSObject>

@required

- (NSMutableArray<Task *> *)getAllTasks;
- (int)getLastTaskID;

- (void)addTask: (Task*) task;
- (void)updateTask: (Task*) task;

- (void)deleteTask: (Task*) task;
- (void)deleteAllTasks;

@end


