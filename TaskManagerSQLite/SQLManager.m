//
//  DBManager.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "SQLManager.h"
#import "Task.h"

static SQLManager *sharedInstance = nil;
static sqlite3 *database = nil;

@implementation SQLManager

+ (SQLManager*)sharedManager {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
    }
    return sharedInstance;
}

- (BOOL)initDatabase {
    
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"tasksData.db"]];
    NSLog(@"DB path: %@", databasePath);
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO) {
        const char *dbpath = [databasePath UTF8String];
        if (sqlite3_open(dbpath, &database) == SQLITE_OK) {
            char *errorMsg;
            const char *sql_stmt =
            "CREATE TABLE IF NOT EXISTS task (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL UNIQUE, title TEXT NOT NULL, details TEXT, iconName TEXT NOT NULL, expirationDate DATE NOT NULL, isDone BOOL DEFAULT NO)";
            
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errorMsg) != SQLITE_OK) {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        } else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

static int multipleRowCallback (void *_queryValues, int columnCount, char **values, char **columnNames) {
    NSMutableArray *queryValues = (__bridge NSMutableArray *)_queryValues;
    NSMutableDictionary *individualQueryValues = [NSMutableDictionary dictionary];
    for (int i = 0; i < columnCount; i++) {
        [individualQueryValues setObject:values[i] ? [NSString stringWithUTF8String:values[i]] : [NSNull null] forKey:[NSString stringWithUTF8String:columnNames[i]]];
    }
    
    [queryValues addObject:[NSMutableDictionary dictionaryWithDictionary:individualQueryValues]];
    return 0;
}

static int oneRowCallback (void *_queryValues, int columnCount, char **values, char **columnNames) {
    NSMutableDictionary *queryValues = (__bridge NSMutableDictionary *)_queryValues;
    for (int i = 0; i < columnCount; i++) {
        [queryValues setObject:values[i] ? [NSString stringWithUTF8String:values[i]] : [NSNull null] forKey:[NSString stringWithUTF8String:columnNames[i]]];
    }
    return 0;
}

- (BOOL)executeSQLQuery: (NSString *) sql withCallback: (void *)callbackFunction context:(id)contextObject {
    
    sqlite3 *db = NULL;
    int resultCode = SQLITE_OK;
    char *errorMsg = NULL;
    
    resultCode = sqlite3_open([databasePath UTF8String], &db);
    
    if (resultCode != SQLITE_OK) {
        NSLog(@"Error in opening database: %s", sqlite3_errmsg(db));
        
        sqlite3_close(db);
        
        return NO;
    }
    
    resultCode = sqlite3_exec(db, [sql UTF8String], callbackFunction, (__bridge void *)(contextObject), &errorMsg);
    
    if (resultCode != SQLITE_OK) {
        NSLog(@"Error %@", sql);
        sqlite3_free(errorMsg);
        
        sqlite3_close(db);
        
        return NO;
    }
    
    sqlite3_close(db);
    
    return YES;
}

- (NSArray *)selectAllTasks {
    NSString *sql = @"SELECT * FROM task";
    NSMutableArray *contextObject = [[NSMutableArray alloc] init];
    
    if ([self executeSQLQuery:sql withCallback:multipleRowCallback context:contextObject]) {
        return contextObject;
    }
    
    return nil;
}

- (NSDictionary *)selectLastRowID {
    NSString *sql = @"SELECT MAX(id) AS id FROM task";
    NSMutableDictionary *contextObject = [[NSMutableDictionary alloc] init];
    
    if ([self executeSQLQuery:sql withCallback:oneRowCallback context:contextObject]) {
        return contextObject;
    }
    
    return nil;
}

- (BOOL)insertNewTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO task (title, details, iconName, expirationDate, isDone) VALUES ('%@', '%@', '%@', %f, %d)", task.title, task.details, task.iconName, task.expirationDate.timeIntervalSince1970, task.isDone ? 1 : 0];
    
    return [self executeSQLQuery:sql withCallback:NULL context:NULL];
}

- (BOOL)deleteTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"DELETE FROM task WHERE id = %d", task.id];
     return [self executeSQLQuery:sql withCallback:NULL context:NULL];
}

- (BOOL)updateTask: (Task*) task {
    NSString *sql = [NSString stringWithFormat:@"UPDATE task SET title = '%@', details = '%@', iconName = '%@', expirationDate = %f, isDone = %d WHERE id = %d", task.title, task.details, task.iconName, task.expirationDate.timeIntervalSince1970, task.isDone ? 1 : 0, task.id];
    return [self executeSQLQuery:sql withCallback:NULL context:NULL];
}

- (BOOL)swapTaskID: (int) id1 toTaskID: (int) id2 {
    NSString *sql = [NSString stringWithFormat:@"UPDATE task SET id = %d WHERE id = %d", id2, id1];
    return [self executeSQLQuery:sql withCallback:NULL context:NULL];
}

@end

