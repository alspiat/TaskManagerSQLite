//
//  TaskServiceProvider.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/19/18.
//  Copyright © 2018 Алексей. All rights reserved.

#import <Foundation/Foundation.h>
#import "TaskServiceProtocol.h"
#import "StoreType.h"

@interface TaskServiceProvider : NSObject

@property (assign, nonatomic) StoreType storeType;

+ (TaskServiceProvider*)sharedProvider;

- (int) getMaxLastTaskID;
- (void) clearStores;
- (void) synchronizeWithPriority: (StoreType) priorityStore;
- (id<TaskServiceProtocol>) getCurrentService;

@end
