//
//  IconCollectionViewCell.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "IconCollectionViewCell.h"

@interface IconCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation IconCollectionViewCell

- (void)configureWithImage:(UIImage *)image {
    [self.iconImageView.layer setCornerRadius:self.bounds.size.height * 0.5];
    [self.iconImageView.layer setBorderColor:[UIColor colorWithRed:102.0/255.0 green:106.0/255.0 blue:118.0/255.0 alpha:1].CGColor];
    self.iconImageView.layer.masksToBounds = YES;
    self.iconImageView.image = image;
}

- (void)setIsSelected:(BOOL)isSelected {
    if (isSelected) {
        [self.iconImageView.layer setBorderWidth:3];
    } else {
        [self.iconImageView.layer setBorderWidth:0];
    }
}

@end
