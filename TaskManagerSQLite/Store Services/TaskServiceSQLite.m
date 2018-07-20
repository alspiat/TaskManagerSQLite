//
//  TaskServiceSQLite.m
//  TaskManagerSQLite
//
//  Created by Алексей on 12.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "TaskServiceSQLite.h"
#import "SQLiteManager.h"
#import "Task.h"

@interface TaskServiceSQLite ()

@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation TaskServiceSQLite

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initChanges];
    }
    return self;
}

- (void)initChanges {
    _isSavingChanges = YES;
    _userDefaults = NSUserDefaults.standardUserDefaults;
    
    _addChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:slAddChangesKey]];
    _deleteChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:slDeleteChangesKey]];
    _updateChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:slUpdateChangesKey]];
}

- (void)cleanChanges {
    [self.addChanges removeAllObjects];
    [self.deleteChanges removeAllObjects];
    [self.updateChanges removeAllObjects];
    
    [self.userDefaults setObject:self.addChanges forKey:slAddChangesKey];
    [self.userDefaults setObject:self.deleteChanges forKey:slDeleteChangesKey];
    [self.userDefaults setObject:self.updateChanges forKey:slUpdateChangesKey];
}

- (NSMutableArray<Task*> *)getAllTasks {
    NSString *sql = @"SELECT id, title, details, iconName, expirationDate, isDone FROM task ORDER BY id";
    NSArray *results = [SQLiteManager.sharedManager selectMultipleRows:sql];
    
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

- (Task *)getTaskWithID:(int)id {
    NSString *sql = [NSString stringWithFormat:@"SELECT id, title, details, iconName, expirationDate, isDone FROM task WHERE id = %d", id];
    NSDictionary *taskItem = [SQLiteManager.sharedManager selectOneRow:sql];
    
    Task *task = [[Task alloc] init];
    
    task.id = id;
    task.title = taskItem[@"title"];
    task.details = taskItem[@"details"];
    task.iconName = taskItem[@"iconName"];
    task.isDone = ((NSString*)taskItem[@"isDone"]).boolValue;
    task.expirationDate = [NSDate dateWithTimeIntervalSince1970:((NSString*)taskItem[@"expirationDate"]).doubleValue];
    
    return task;
}

- (void)addTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO task (id, title, details, iconName, expirationDate, isDone) VALUES ('%d', '%@', '%@', '%@', %f, %d)", task.id, task.title, task.details, task.iconName, task.expirationDate.timeIntervalSince1970, task.isDone ? 1 : 0];
    
    [SQLiteManager.sharedManager insertRow:sql];
    
    if (self.isSavingChanges) {
        [self.addChanges addObject:[NSNumber numberWithInt:task.id]];
        [self.userDefaults setObject:self.addChanges forKey:slAddChangesKey];
    }
}

- (void)deleteTask: (Task*) task {
    [self deleteTaskWithID:task.id];
}

- (void)deleteTaskWithID: (int) id {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM task WHERE id = %d", id];
    [SQLiteManager.sharedManager deleteRow:sql];
    
    if (self.isSavingChanges) {
        [self.deleteChanges addObject:[NSNumber numberWithInt:id]];
        [self.userDefaults setObject:self.deleteChanges forKey:slDeleteChangesKey];
    }
}

- (void)updateTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"UPDATE task SET title = '%@', details = '%@', iconName = '%@', expirationDate = %f, isDone = %d WHERE id = %d", task.title, task.details, task.iconName, task.expirationDate.timeIntervalSince1970, task.isDone ? 1 : 0, task.id];
    [SQLiteManager.sharedManager updateRow:sql];
    
    if (self.isSavingChanges) {
        [self.updateChanges addObject:[NSNumber numberWithInt:task.id]];
        [self.userDefaults setObject:self.updateChanges forKey:slUpdateChangesKey];
    }
}

- (void)deleteAllTasks {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM task"];
    [SQLiteManager.sharedManager deleteRow:sql];
    
    [self cleanChanges];
}

- (int)getLastTaskID {
    NSString *sql = @"SELECT MAX(id) AS id FROM task";
    NSDictionary *result = [SQLiteManager.sharedManager selectOneRow:sql];
    
    if (![result[@"id"] isMemberOfClass:NSNull.class]) {
        return ((NSString*)result[@"id"]).intValue;
    }
    
    return 0;
}

@end
