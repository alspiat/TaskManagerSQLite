//
//  DBManager.h
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@class Task;

@interface SQLManager : NSObject {
    NSString *databasePath;
}

+ (SQLManager*)sharedManager;
- (BOOL)initDatabase;

- (NSArray *)selectAllTasks;
- (NSDictionary *)selectLastRowID;
- (void)insertNewTask: (Task*) task;
- (void)deleteTask: (Task*) task;
- (void)swapTaskID: (int) id1 toTaskID: (int) id2;
- (void)updateTask: (Task*) task;

@end
