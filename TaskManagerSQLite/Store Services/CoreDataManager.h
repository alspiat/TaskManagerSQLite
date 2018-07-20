//
//  CoreDataManager.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Task;
@class NSManagedObjectContext;

@interface TaskCoreDataService : NSObject

@property (nonatomic, strong) NSManagedObjectContext *context;

+ (TaskCoreDataService*)sharedManager;

- (NSArray<Task *> *)getAllTasks;
- (void)addTask:(Task *)task;
- (void)deleteAll;

@end
