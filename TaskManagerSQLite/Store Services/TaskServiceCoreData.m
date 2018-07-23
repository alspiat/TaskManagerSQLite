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

static NSString * const cdAddionChangesKey = @"CoreDataAdditionChanges";
static NSString * const cdUpdatingChangesKey = @"CoreDataUpdatingChanges";
static NSString * const cdDeletingChangesKey = @"CoreDataDeletingChanges";

@interface TaskServiceCoreData()

@property (strong, nonatomic) AppDelegate *appDelegate;
@property (strong, nonatomic) NSManagedObjectContext *context;
@property (strong, nonatomic) NSUserDefaults *userDefaults;

@end

@implementation TaskServiceCoreData

- (instancetype)init
{
    self = [super init];
    if (self) {
        _appDelegate = ((AppDelegate *)UIApplication.sharedApplication.delegate);
        _context = self.appDelegate.persistentContainer.viewContext;
        _userDefaults = NSUserDefaults.standardUserDefaults;
        
        [self initChanges];
    }
    return self;
}

- (void)initChanges {
    _isSavingChanges = YES;
    
    _additionChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:cdAddionChangesKey]];
    _deletingChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:cdDeletingChangesKey]];
    _updatingChanges = [[NSMutableArray alloc] initWithArray:[self.userDefaults arrayForKey:cdUpdatingChangesKey]];
}

- (void)cleanChanges {
    [self.additionChanges removeAllObjects];
    [self.deletingChanges removeAllObjects];
    [self.updatingChanges removeAllObjects];
    
    [self.userDefaults setObject:self.additionChanges forKey:cdAddionChangesKey];
    [self.userDefaults setObject:self.deletingChanges forKey:cdDeletingChangesKey];
    [self.userDefaults setObject:self.updatingChanges forKey:cdUpdatingChangesKey];
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
    
    [self.appDelegate saveContext];
    
    if (self.isSavingChanges) {
        [self.additionChanges addObject:[NSNumber numberWithInt:task.id]];
        [self.userDefaults setObject:self.additionChanges forKey:cdAddionChangesKey];
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
    
    [self.appDelegate saveContext];
    
    if (self.isSavingChanges) {
        [self.updatingChanges addObject:[NSNumber numberWithInt:task.id]];
        [self.userDefaults setObject:self.updatingChanges forKey:cdUpdatingChangesKey];
    }
}

- (void)deleteAllTasks {
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:TaskEntityName];
    NSArray<ManagedTask *> *managedTaskArray = [self.context executeFetchRequest:fetchRequest error:nil];
    
    for (ManagedTask *managedTask in managedTaskArray) {
        [self.context deleteObject:managedTask];
    }
    
    [self.appDelegate saveContext];
    
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
    [self.appDelegate saveContext];
    
    if (self.isSavingChanges) {
        [self.deletingChanges addObject:[NSNumber numberWithInt:id]];
        [self.userDefaults setObject:self.deletingChanges forKey:cdDeletingChangesKey];
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
