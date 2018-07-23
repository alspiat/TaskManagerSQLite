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

@property (strong, nonatomic) NSMutableArray *additionChanges;
@property (strong, nonatomic) NSMutableArray *updatingChanges;
@property (strong, nonatomic) NSMutableArray *deletingChanges;

@required

- (NSMutableArray<Task *> *)getAllTasks;
- (Task *)getTaskWithID: (int) id;
- (int)getLastTaskID;

- (void)addTask: (Task*) task;
- (void)updateTask: (Task*) task;

- (void)deleteTask: (Task*) task;
- (void)deleteAllTasks;
- (void)deleteTaskWithID: (int) id;

@end


