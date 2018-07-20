//
//  TaskServiceSQLite.h
//  TaskManagerSQLite
//
//  Created by Алексей on 12.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskServiceProtocol.h"

static NSString * const slAddChangesKey = @"SQLiteAddChanges";
static NSString * const slUpdateChangesKey = @"SQLiteUpdateChanges";
static NSString * const slDeleteChangesKey = @"SQLiteDeleteChanges";

@interface TaskServiceSQLite : NSObject <TaskServiceProtocol>

@property (assign, nonatomic) BOOL isSavingChanges;

@property (strong, nonatomic) NSMutableArray *addChanges;
@property (strong, nonatomic) NSMutableArray *updateChanges;
@property (strong, nonatomic) NSMutableArray *deleteChanges;

- (Task *)getTaskWithID: (int) id;
- (void)deleteTaskWithID: (int) id;
- (void)cleanChanges;

@end

