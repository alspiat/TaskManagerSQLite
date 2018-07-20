//
//  SQLManager.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "SQLiteManager.h"
#import <sqlite3.h>

static SQLiteManager *sharedInstance = nil;

@implementation SQLiteManager

+ (SQLiteManager*)sharedManager {
    if (!sharedInstance) {
        sharedInstance = [[self alloc] init];
        [sharedInstance createDatabase];
    }
    return sharedInstance;
}

- (void)createDatabase {
    
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = dirPaths[0];
    
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"tasksData.db"]];
    NSLog(@"DB path: %@", databasePath);
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath] == NO) {
        NSString *sql = @"CREATE TABLE IF NOT EXISTS task (id INTEGER NOT NULL, title TEXT NOT NULL, details TEXT, iconName TEXT NOT NULL, expirationDate DATE NOT NULL, isDone BOOL DEFAULT NO)";
        [self executeSQLQuery:sql withCallback:nil context:nil];
    }
}

// MARK: - Callback functions to sqlite exec

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

// MARK: - CRUD methods

- (void)executeSQLQuery: (NSString *) sql withCallback: (void *)callbackFunction context:(id)contextObject {
    
    sqlite3 *db = NULL;
    int resultCode = SQLITE_OK;
    char *errorMsg = NULL;
    
    resultCode = sqlite3_open([databasePath UTF8String], &db);
    
    if (resultCode != SQLITE_OK) {
        NSLog(@"Error in opening database: %s", sqlite3_errmsg(db));
        sqlite3_close(db);
        
        return;
    }
    
    resultCode = sqlite3_exec(db, [sql UTF8String], callbackFunction, (__bridge void *)(contextObject), &errorMsg);
    
    if (resultCode != SQLITE_OK) {
        NSLog(@"Error %@", sql);
        sqlite3_free(errorMsg);
    }
    sqlite3_close(db);
}

- (NSArray *)selectMultipleRows: (NSString*) sql {
    NSMutableArray *contextObject = [[NSMutableArray alloc] init];
    
    [self executeSQLQuery:sql withCallback:multipleRowCallback context:contextObject];
    return [contextObject copy];
}

- (NSDictionary *)selectOneRow: (NSString*) sql {
    NSMutableDictionary *contextObject = [[NSMutableDictionary alloc] init];
    
    [self executeSQLQuery:sql withCallback:oneRowCallback context:contextObject];
    return [contextObject copy];
}

- (void)insertRow: (NSString*) sql {
    [self executeSQLQuery:sql withCallback:NULL context:NULL];
}

- (void)deleteRow: (NSString*) sql {
    [self executeSQLQuery:sql withCallback:NULL context:NULL];
}

- (void)updateRow: (NSString*) sql {
    [self executeSQLQuery:sql withCallback:NULL context:NULL];
}

@end

