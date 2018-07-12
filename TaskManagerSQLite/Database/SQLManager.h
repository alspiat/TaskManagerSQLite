//
//  DBManager.h
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SQLManager : NSObject {
    NSString *databasePath;
}

+ (SQLManager*)sharedManager;
- (BOOL)initDatabase;

- (NSArray *)selectMultipleRows: (NSString*) sql;
- (NSDictionary *)selectOneRow: (NSString*) sql;

- (BOOL)insertRow: (NSString*) sql;
- (BOOL)deleteRow: (NSString*) sql;
- (BOOL)updateRow: (NSString*) sql;

@end
