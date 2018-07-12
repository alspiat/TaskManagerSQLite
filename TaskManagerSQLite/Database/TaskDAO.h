//
//  TaskDAO.h
//  TaskManagerSQLite
//
//  Created by Алексей on 12.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;

@interface TaskDAO : NSObject

- (NSArray<Task*> *)getAllTasks;

- (int)addTask: (Task*) task;
- (BOOL)deleteTask: (Task*) task;
- (BOOL)updateTask: (Task*) task;
- (BOOL)swapTask: (Task*) task1 toTask: (Task*) task2;

@end
