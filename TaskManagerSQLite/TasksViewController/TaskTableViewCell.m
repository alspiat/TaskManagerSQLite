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
}

- (void)configureCellWithTask:(Task *)task {
    UIView *customColorView = [[UIView alloc] init];
    customColorView.backgroundColor = [UIColor colorWithRed:82.0/255.0 green:89.0/255.0 blue:107.0/255.0 alpha:1.0];
    self.selectedBackgroundView = customColorView;
    
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
        [self.iconImageView.layer setBorderWidth:3.0];
        [self.iconImageView.layer setBorderColor:[UIColor colorWithRed:37.0/255.0 green:225.0/255.0 blue:175.0/255.0 alpha:1].CGColor];
    } else if (components.day < 7) {
        [self.iconImageView.layer setBorderWidth:3.0];
        [self.iconImageView.layer setBorderColor:[UIColor colorWithRed:249.0/255.0 green:83.0/255.0 blue:87.0/255.0 alpha:1].CGColor];
    } else {
        [self.iconImageView.layer setBorderWidth:0];
    }
    
}

@end
