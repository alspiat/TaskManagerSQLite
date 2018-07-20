//
//  TaskServiceCoreData.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskServiceProtocol.h"

static NSString * const cdAddChangesKey = @"CoreDataAddChanges";
static NSString * const cdUpdateChangesKey = @"CoreDataUpdateChanges";
static NSString * const cdDeleteChangesKey = @"CoreDataDeleteChanges";

@interface TaskServiceCoreData : NSObject <TaskServiceProtocol>

@property (assign, nonatomic) BOOL isSavingChanges;

@property (strong, nonatomic) NSMutableArray *addChanges;
@property (strong, nonatomic) NSMutableArray *updateChanges;
@property (strong, nonatomic) NSMutableArray *deleteChanges;

- (Task *)getTaskWithID: (int) id;
- (void)deleteTaskWithID: (int) id;
- (void)cleanChanges;

@end
