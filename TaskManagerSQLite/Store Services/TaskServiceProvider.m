//
//  TaskService.m
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/19/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "TaskServiceProvider.h"
#import "TaskServiceSQLite.h"
#import "TaskServiceCoreData.h"
#import "Task.h"

static TaskServiceProvider *sharedService = nil;

@interface TaskServiceProvider()

@property (strong, nonatomic) TaskServiceCoreData *coreDataService;
@property (strong, nonatomic) TaskServiceSQLite *sqliteService;

@end

@implementation TaskServiceProvider

+ (TaskServiceProvider*)sharedProvider {
    if (!sharedService) {
        sharedService = [[self alloc] init];
    }
    return sharedService;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        _coreDataService = [[TaskServiceCoreData alloc] init];
        _sqliteService = [[TaskServiceSQLite alloc] init];
    }
    return self;
}

-(id<TaskServiceProtocol>) getCurrentService {
    switch (self.storeType) {
        case StoreTypeSQLite:
            return self.sqliteService;
            break;
        case StoreTypeCoreData:
            return self.coreDataService;
            break;
    }
}

- (void)synchronizeWithPriority: (StoreType) priorityStore {
    
    self.sqliteService.isSavingChanges = NO;
    self.coreDataService.isSavingChanges = NO;
    
    // Add Changes
    
    [self.coreDataService.addChanges removeObjectsInArray:self.coreDataService.deleteChanges];
    [self.sqliteService.addChanges removeObjectsInArray:self.sqliteService.deleteChanges];
    
    for (NSNumber *idNumber in self.coreDataService.addChanges) {
        Task *task = [self.coreDataService getTaskWithID:idNumber.intValue];
        [self.sqliteService addTask:task];
    }
    
    for (NSNumber *idNumber in self.sqliteService.addChanges) {
        Task *task = [self.sqliteService getTaskWithID:idNumber.intValue];
        [self.coreDataService addTask:task];
    }
    
    if (priorityStore == StoreTypeSQLite) {
        [self.coreDataService.updateChanges removeObjectsInArray:self.sqliteService.updateChanges];
    } else if (priorityStore == StoreTypeCoreData) {
        [self.sqliteService.updateChanges removeObjectsInArray:self.coreDataService.updateChanges];
    }
    
    // Update changes
    
    [self.coreDataService.updateChanges removeObjectsInArray:self.coreDataService.deleteChanges];
    [self.sqliteService.updateChanges removeObjectsInArray:self.sqliteService.deleteChanges];
    
    for (NSNumber *idNumber in self.coreDataService.updateChanges) {
        Task *task = [self.coreDataService getTaskWithID:idNumber.intValue];
        [self.sqliteService updateTask:task];
    }
    
    for (NSNumber *idNumber in self.sqliteService.updateChanges) {
        Task *task = [self.sqliteService getTaskWithID:idNumber.intValue];
        [self.coreDataService updateTask:task];
    }
    
    // Delete changes
    
    for (NSNumber *idNumber in self.coreDataService.deleteChanges) {
        [self.sqliteService deleteTaskWithID:idNumber.intValue];
    }
    
    for (NSNumber *idNumber in self.sqliteService.deleteChanges) {
        [self.coreDataService deleteTaskWithID:idNumber.intValue];
    }
   
    [self.coreDataService cleanChanges];
    [self.sqliteService cleanChanges];
    
    self.sqliteService.isSavingChanges = YES;
    self.coreDataService.isSavingChanges = YES;
}

- (int)getMaxLastTaskID {
    int coreDataLastId = [self.coreDataService getLastTaskID];
    int sqliteLastId = [self.sqliteService getLastTaskID];
    
    return coreDataLastId > sqliteLastId ? coreDataLastId : sqliteLastId;
}

- (void)clearStores {
    [self.coreDataService deleteAllTasks];
    [self.sqliteService deleteAllTasks];
}

@end
