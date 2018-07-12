//
//  TaskDAO.m
//  TaskManagerSQLite
//
//  Created by Алексей on 12.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "TaskDAO.h"
#import "Task.h"
#import "SQLManager.h"

@implementation TaskDAO

- (NSArray<Task*> *)getAllTasks {
    NSString *sql = @"SELECT id, title, details, iconName, expirationDate, isDone FROM task";
    NSArray *results = [SQLManager.sharedManager selectMultipleRows:sql];
    
    NSMutableArray *tasks = [[NSMutableArray alloc] init];
    
    if (results) {
        
        for (NSDictionary *taskItem in results) {
            Task *task = [[Task alloc] init];
            
            task.id = ((NSString*)taskItem[@"id"]).intValue;
            task.title = taskItem[@"title"];
            task.details = taskItem[@"details"];
            task.iconName = taskItem[@"iconName"];
            task.isDone = ((NSString*)taskItem[@"isDone"]).boolValue;
            task.expirationDate = [NSDate dateWithTimeIntervalSince1970:((NSString*)taskItem[@"expirationDate"]).doubleValue];
            
            [tasks addObject:task];
        }
        
    }
    
    return tasks;
}

- (int)getLastTaskID {
    NSString *sql = @"SELECT MAX(id) AS id FROM task";
    NSDictionary *result = [SQLManager.sharedManager selectOneRow:sql];
    
    if (result) {
        return ((NSString*)result[@"id"]).intValue;
    }
    
    return -1;
}

- (int)addTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO task (title, details, iconName, expirationDate, isDone) VALUES ('%@', '%@', '%@', %f, %d)", task.title, task.details, task.iconName, task.expirationDate.timeIntervalSince1970, task.isDone ? 1 : 0];
    
    if ([SQLManager.sharedManager insertRow:sql]) {
        return [self getLastTaskID];
    }
    
    return -1;
}

- (BOOL)deleteTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM task WHERE id = %d", task.id];
    return [SQLManager.sharedManager deleteRow:sql];
}

- (BOOL)updateTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"UPDATE task SET title = '%@', details = '%@', iconName = '%@', expirationDate = %f, isDone = %d WHERE id = %d", task.title, task.details, task.iconName, task.expirationDate.timeIntervalSince1970, task.isDone ? 1 : 0, task.id];
    return [SQLManager.sharedManager updateRow:sql];
}

- (BOOL)swapTask: (Task*) task1 toTask: (Task*) task2 {
    NSString *sql1 = [NSString stringWithFormat:@"UPDATE task SET id = %d WHERE id = %d", -1, task1.id];
    NSString *sql2 = [NSString stringWithFormat:@"UPDATE task SET id = %d WHERE id = %d", task1.id, task2.id];
    NSString *sql3 = [NSString stringWithFormat:@"UPDATE task SET id = %d WHERE id = %d", task2.id, -1];
    
    return ([[SQLManager sharedManager] updateRow:sql1] && [[SQLManager sharedManager] updateRow:sql2] && [[SQLManager sharedManager] updateRow:sql3]);
}

@end
