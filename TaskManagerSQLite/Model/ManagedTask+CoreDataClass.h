//
//  ManagedTask+CoreDataClass.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

static NSString * const TaskEntityName = @"ManagedTask";

NS_ASSUME_NONNULL_BEGIN

@interface ManagedTask : NSManagedObject

@end

NS_ASSUME_NONNULL_END

#import "ManagedTask+CoreDataProperties.h"
