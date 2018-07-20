//
//  TaskServiceCoreData.m
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "TaskServiceCoreData.h"
#import "Task.h"
#import "AppDelegate.h"
#import "ManagedTask+CoreDataClass.h"

@interface TaskServiceCoreData()

@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation TaskServiceCoreData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _context = ((AppDelegate *)UIApplication.sharedApplication.delegate).persistentContainer.viewContext;
        _userDefaults = NSUserDefaults.standardUserDefaults;
        
        [self initChanges];
    }
    return self;
}

- (void)initChanges {
    _isSavingChanges = YES;
    
    _addChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:cdAddChangesKey]];
    _deleteChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:cdDeleteChangesKey]];
    _updateChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:cdUpdateChangesKey]];
}

- (void)cleanChanges {
    [self.addChanges removeAllObjects];
    [self.deleteChanges removeAllObjects];
    [self.updateChanges removeAllObjects];
    
    [self.userDefaults setObject:self.addChanges forKey:cdAddChangesKey];
    [self.userDefaults setObject:self.deleteChanges forKey:cdDeleteChangesKey];
    [self.userDefaults setObject:self.updateChanges forKey:cdUpdateChangesKey];
}

- (NSMutableArray<Task *> *)getAllTasks {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TaskEntityName];
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:YES]];
    
    NSArray<ManagedTask *> *managedTaskArray = [self.context executeFetchRequest:fetchRequest error:nil];
    
    NSMutableArray<Task *> *tasks = [[NSMutableArray alloc] init];
    
    for (ManagedTask *managedTask in managedTaskArray) {
        Task *task = [[Task alloc] init];
        
        task.id = managedTask.id;
        task.title = managedTask.title;
        task.details = managedTask.details;
        task.iconName = managedTask.iconName;
        task.isDone = managedTask.isDone;
        task.expirationDate = managedTask.expirationDate;
        
        [tasks addObject:task];
    }
    
    return tasks;
}

- (Task *)getTaskWithID:(int)id {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TaskEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %d", id];
    NSArray<ManagedTask *> *managedTaskArray = [self.context executeFetchRequest:fetchRequest error:nil];
    
    Task *task = [[Task alloc] init];
    
    task.id = id;
    task.title = managedTaskArray.firstObject.title;
    task.details = managedTaskArray.firstObject.details;
    task.iconName = managedTaskArray.firstObject.iconName;
    task.isDone = managedTaskArray.firstObject.isDone;
    task.expirationDate = managedTaskArray.firstObject.expirationDate;
    
    return task;
}

- (void)addTask:(Task *)task {
    ManagedTask *managedTask = [NSEntityDescription insertNewObjectForEntityForName:TaskEntityName inManagedObjectContext:self.context];

    managedTask.id = task.id;
    managedTask.title = task.title;
    managedTask.details = task.details;
    managedTask.iconName = task.iconName;
    managedTask.isDone = task.isDone;
    managedTask.expirationDate = task.expirationDate;
    
    [self.context save:nil];
    
    if (self.isSavingChanges) {
        [self.addChanges addObject:[NSNumber numberWithInt:task.id]];
        [self.userDefaults setObject:self.addChanges forKey:cdAddChangesKey];
    }
}

- (void)updateTask:(Task *)task {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TaskEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %d", task.id];
    
    NSArray<ManagedTask *> *managedTaskArray = [self.context executeFetchRequest:fetchRequest error:nil];
    
    if (!managedTaskArray.firstObject) {
        return;
    }

    managedTaskArray.firstObject.id = task.id;
    managedTaskArray.firstObject.title = task.title;
    managedTaskArray.firstObject.details = task.details;
    managedTaskArray.firstObject.iconName = task.iconName;
    managedTaskArray.firstObject.isDone = task.isDone;
    managedTaskArray.firstObject.expirationDate = task.expirationDate;
    
    [self.context save:nil];
    
    if (self.isSavingChanges) {
        [self.updateChanges addObject:[NSNumber numberWithInt:task.id]];
        [self.userDefaults setObject:self.updateChanges forKey:cdUpdateChangesKey];
    }
}

- (void)deleteAllTasks {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TaskEntityName];
    NSArray<ManagedTask *> *managedTaskArray = [self.context executeFetchRequest:fetchRequest error:nil];
    
    for (ManagedTask *managedTask in managedTaskArray) {
        [self.context deleteObject:managedTask];
    }
    
    [self.context save:nil];
    
    [self cleanChanges];
}

- (void)deleteTask:(Task *)task {
    [self deleteTaskWithID:task.id];
}

- (void)deleteTaskWithID:(int)id {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TaskEntityName];
    fetchRequest.predicate = [NSPredicate predicateWithFormat:@"id = %d", id];
    
    NSArray<ManagedTask *> *managedTaskArray = [self.context executeFetchRequest:fetchRequest error:nil];
    
    if (!managedTaskArray.firstObject) {
        return;
    }
    
    [self.context deleteObject:managedTaskArray.firstObject];
    [self.context save:nil];
    
    if (self.isSavingChanges) {
        [self.deleteChanges addObject:[NSNumber numberWithInt:id]];
        [self.userDefaults setObject:self.deleteChanges forKey:cdDeleteChangesKey];
    }
}

- (int)getLastTaskID {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TaskEntityName];
    fetchRequest.fetchLimit = 1;
    fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"id" ascending:NO]];
    NSArray<ManagedTask *> *managedTaskArray = [self.context executeFetchRequest:fetchRequest error:nil];
    
    if (managedTaskArray) {
        return managedTaskArray.lastObject.id;
    }
    
    return 0;
}

@end
