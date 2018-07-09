//
//  Task.h
//  TaskManagerSQLite
//
//  Created by Алексей on 08.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Task : NSObject

@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *details;
@property (nonatomic, assign) BOOL isDone;
@property (nonatomic, copy) NSDate *expirationDate;

@end
