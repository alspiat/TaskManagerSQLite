//
//  TaskTableViewCell.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "TaskTableViewCell.h"

@implementation TaskTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.backgroundColor = UIColor.clearColor;
}

- (void)configureCellWithTask:(Task *)task {
    self.iconImageView.image = [UIImage imageNamed:task.iconName];
    [self.iconImageView.layer setCornerRadius:self.iconImageView.bounds.size.height * 0.5];
    self.iconImageView.layer.masksToBounds = YES;
    
    self.titleLabel.text = task.title;
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:task.expirationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitDay
                                                        fromDate:NSDate.date
                                                          toDate:task.expirationDate
                                                         options:0];
    if (task.isDone) {
        self.backgroundColor = [UIColor colorWithRed:0 green:203.0/255.0 blue:123.0/255.0 alpha:1];
    } else if (components.day < 7) {
        self.backgroundColor = [UIColor colorWithRed:224.0/255.0 green:110.0/255.0 blue:109.0/255.0 alpha:1];
    }
    
}

@end
