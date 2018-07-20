//
//  ManagedTask+CoreDataProperties.m
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//
//

#import "ManagedTask+CoreDataProperties.h"

@implementation ManagedTask (CoreDataProperties)

+ (NSFetchRequest<ManagedTask *> *)fetchRequest {
	return [NSFetchRequest fetchRequestWithEntityName:@"ManagedTask"];
}

@dynamic details;
@dynamic expirationDate;
@dynamic iconName;
@dynamic id;
@dynamic isDone;
@dynamic title;

@end
