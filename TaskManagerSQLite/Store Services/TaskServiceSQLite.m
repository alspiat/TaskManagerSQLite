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

static NSString * const slAdditionChangesKey = @"SQLiteAdditionChanges";
static NSString * const slUpdatingChangesKey = @"SQLiteUpdatingChanges";
static NSString * const slDeletingChangesKey = @"SQLiteDeletingChanges";

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
    
    _additionChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:slAdditionChangesKey]];
    _deletingChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:slDeletingChangesKey]];
    _updatingChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:slUpdatingChangesKey]];
}

- (void)cleanChanges {
    [self.additionChanges removeAllObjects];
    [self.deletingChanges removeAllObjects];
    [self.updatingChanges removeAllObjects];
    
    [self.userDefaults setObject:self.additionChanges forKey:slAdditionChangesKey];
    [self.userDefaults setObject:self.deletingChanges forKey:slDeletingChangesKey];
    [self.userDefaults setObject:self.updatingChanges forKey:slUpdatingChangesKey];
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
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO task (id, title, details, iconName, expirationDate, isDone) VALUES ('%d', '%@', '%@', '%@', %f, %d)", task.id, task.title, task.details, task.iconName, task.expirationDate.timeIntervalSince1970, task.isDone];
    
    NSLog(@"ADD TASK SQL: %@", sql);
    [SQLiteManager.sharedManager insertRow:sql];
    
    if (self.isSavingChanges) {
        [self.additionChanges addObject:[NSNumber numberWithInt:task.id]];
        [self.userDefaults setObject:self.additionChanges forKey:slAdditionChangesKey];
    }
}

- (void)deleteTask: (Task*) task {
    [self deleteTaskWithID:task.id];
}

- (void)deleteTaskWithID: (int) id {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM task WHERE id = %d", id];
    [SQLiteManager.sharedManager deleteRow:sql];
    
    if (self.isSavingChanges) {
        [self.deletingChanges addObject:[NSNumber numberWithInt:id]];
        [self.userDefaults setObject:self.deletingChanges forKey:slDeletingChangesKey];
    }
}

- (void)updateTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"UPDATE task SET title = '%@', details = '%@', iconName = '%@', expirationDate = %f, isDone = %d WHERE id = %d", task.title, task.details, task.iconName, task.expirationDate.timeIntervalSince1970, task.isDone, task.id];
    [SQLiteManager.sharedManager updateRow:sql];
    
    if (self.isSavingChanges) {
        [self.updatingChanges addObject:[NSNumber numberWithInt:task.id]];
        [self.userDefaults setObject:self.updatingChanges forKey:slUpdatingChangesKey];
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
