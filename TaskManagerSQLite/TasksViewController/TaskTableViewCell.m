//
//  TaskTableViewCell.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "TaskTableViewCell.h"
#import "Task.h"
#import "UIColor+ApplicationColors.h"
#import "Constants.h"

NSString * const taskCellIdentifier = @"TaskTableViewCellIdentifier";

@interface TaskTableViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

@end

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
    customColorView.backgroundColor = [UIColor appSelectedCellColor];
    self.selectedBackgroundView = customColorView;
    
    self.iconImageView.image = [UIImage imageNamed:task.iconName];
    [self.iconImageView.layer setCornerRadius:self.iconImageView.bounds.size.height * iconCornerRadiusFactor];
    self.iconImageView.layer.masksToBounds = YES;
    
    self.titleLabel.text = task.title;
    self.dateLabel.text = [NSDateFormatter localizedStringFromDate:task.expirationDate dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle];
    NSDateComponents *components = [NSCalendar.currentCalendar components:NSCalendarUnitDay
                                                        fromDate:NSDate.date
                                                          toDate:task.expirationDate
                                                         options:0];
    if (task.isDone) {
        [self.iconImageView.layer setBorderWidth:iconBorderWidth];
        [self.iconImageView.layer setBorderColor:[UIColor appTaskIsDoneBorderColor].CGColor];
    } else if (components.day < 7) {
        [self.iconImageView.layer setBorderWidth:iconBorderWidth];
        [self.iconImageView.layer setBorderColor:[UIColor appTaskIsPriorityBorderColor].CGColor];
    } else {
        [self.iconImageView.layer setBorderWidth:iconBorderWidthZero];
    }
    
}

@end
