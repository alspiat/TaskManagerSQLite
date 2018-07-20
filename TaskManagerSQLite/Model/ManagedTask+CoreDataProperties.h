//
//  ManagedTask+CoreDataProperties.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//
//

#import "ManagedTask+CoreDataClass.h"


NS_ASSUME_NONNULL_BEGIN

@interface ManagedTask (CoreDataProperties)

+ (NSFetchRequest<ManagedTask *> *)fetchRequest;

@property (nullable, nonatomic, copy) NSString *details;
@property (nullable, nonatomic, copy) NSDate *expirationDate;
@property (nullable, nonatomic, copy) NSString *iconName;
@property (nonatomic) int32_t id;
@property (nonatomic) BOOL isDone;
@property (nullable, nonatomic, copy) NSString *title;

@end

NS_ASSUME_NONNULL_END
