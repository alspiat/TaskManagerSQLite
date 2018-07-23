//
//  TaskServiceSQLite.h
//  TaskManagerSQLite
//
//  Created by Алексей on 12.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TaskServiceProtocol.h"

@interface TaskServiceSQLite : NSObject <TaskServiceProtocol>

@property (assign, nonatomic) BOOL isSavingChanges;

@property (strong, nonatomic) NSMutableArray *additionChanges;
@property (strong, nonatomic) NSMutableArray *updatingChanges;
@property (strong, nonatomic) NSMutableArray *deletingChanges;

- (void)cleanChanges;

@end

