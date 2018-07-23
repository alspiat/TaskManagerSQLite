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

- (void)synchronizeAdditionFromService: (id<TaskServiceProtocol>) modifiedService withService: (id<TaskServiceProtocol>) updatableService {
    
    [modifiedService.additionChanges removeObjectsInArray:modifiedService.deletingChanges];
    
    for (NSNumber *idNumber in modifiedService.additionChanges) {
        Task *task = [modifiedService getTaskWithID:idNumber.intValue];
        [updatableService addTask:task];
    }
}

- (void)synchronizeUpdatingFromService: (id<TaskServiceProtocol>) modifiedService withService: (id<TaskServiceProtocol>) updatableService {
    
    [modifiedService.updatingChanges removeObjectsInArray:modifiedService.deletingChanges];
    
    for (NSNumber *idNumber in modifiedService.updatingChanges) {
        Task *task = [modifiedService getTaskWithID:idNumber.intValue];
        [updatableService updateTask:task];
    }
}

- (void)synchronizeDeletingFromService: (id<TaskServiceProtocol>) modifiedService withService: (id<TaskServiceProtocol>) updatableService {
    for (NSNumber *idNumber in modifiedService.deletingChanges) {
        [updatableService deleteTaskWithID:idNumber.intValue];
    }
}

- (void)synchronizeWithPriority: (StoreType) priorityStore {
    
    self.sqliteService.isSavingChanges = NO;
    self.coreDataService.isSavingChanges = NO;
    
    
    // Add Changes
    
    [self.coreDataService.additionChanges removeObjectsInArray:self.coreDataService.deletingChanges];
    [self.sqliteService.additionChanges removeObjectsInArray:self.sqliteService.deletingChanges];
    
    [self synchronizeAdditionFromService:self.coreDataService withService:self.sqliteService];
    [self synchronizeAdditionFromService:self.sqliteService withService:self.coreDataService];
    
    // Update changes
    
    // To resolve collisions
    if (priorityStore == StoreTypeSQLite) {
        [self.coreDataService.updatingChanges removeObjectsInArray:self.sqliteService.updatingChanges];
    } else if (priorityStore == StoreTypeCoreData) {
        [self.sqliteService.updatingChanges removeObjectsInArray:self.coreDataService.updatingChanges];
    }
    
    [self synchronizeUpdatingFromService:self.coreDataService withService:self.sqliteService];
    [self synchronizeUpdatingFromService:self.sqliteService withService:self.coreDataService];
    
    // Delete changes
    
    [self synchronizeDeletingFromService:self.coreDataService withService:self.sqliteService];
    [self synchronizeDeletingFromService:self.sqliteService withService:self.coreDataService];
    
    // Finish
   
    [self.coreDataService cleanChanges];
    [self.sqliteService cleanChanges];
    
    self.sqliteService.isSavingChanges = YES;
    self.coreDataService.isSavingChanges = YES;
    
    [NSNotificationCenter.defaultCenter postNotificationName:storeDidUpdateNotification object:nil];
}

- (int)getMaxLastTaskID {
    int coreDataLastId = [self.coreDataService getLastTaskID];
    int sqliteLastId = [self.sqliteService getLastTaskID];
    
    return coreDataLastId > sqliteLastId ? coreDataLastId : sqliteLastId;
}

- (void)clearStores {
    [self.coreDataService deleteAllTasks];
    [self.sqliteService deleteAllTasks];
    
    [NSNotificationCenter.defaultCenter postNotificationName:storeDidUpdateNotification object:nil];
}

- (void)setStoreType:(StoreType)storeType {
    _storeType = storeType;
    [NSNotificationCenter.defaultCenter postNotificationName:storeDidUpdateNotification object:nil];
}

@end
