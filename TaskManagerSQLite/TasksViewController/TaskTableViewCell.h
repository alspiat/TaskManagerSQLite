//
//  TaskTableViewCell.h
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const taskCellIdentifier;

@class Task;

@interface TaskTableViewCell : UITableViewCell

- (void) configureCellWithTask: (Task*) task;

@end
