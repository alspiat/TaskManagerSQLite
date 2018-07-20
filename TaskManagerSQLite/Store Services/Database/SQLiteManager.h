//
//  SQLManager.h
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLiteManager : NSObject {
    NSString *databasePath;
}

+ (SQLiteManager*)sharedManager;
- (void)createDatabase;

- (NSArray *)selectMultipleRows: (NSString*) sql;
- (NSDictionary *)selectOneRow: (NSString*) sql;

- (void)insertRow: (NSString*) sql;
- (void)deleteRow: (NSString*) sql;
- (void)updateRow: (NSString*) sql;

@end
