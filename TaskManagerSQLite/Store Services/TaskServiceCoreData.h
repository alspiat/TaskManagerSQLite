//
//  TaskServiceCoreData.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskServiceProtocol.h"

@interface TaskServiceCoreData : NSObject <TaskServiceProtocol>

@property (assign, nonatomic) BOOL isSavingChanges;

@property (strong, nonatomic) NSMutableArray *additionChanges;
@property (strong, nonatomic) NSMutableArray *updatingChanges;
@property (strong, nonatomic) NSMutableArray *deletingChanges;

- (void)cleanChanges;

@end
