//
//  IconCollectionViewCell.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "IconCollectionViewCell.h"
#import "UIColor+ApplicationColors.h"
#import "Constants.h"

NSString * const iconCellIdentfier = @"IconCollectionViewCellIdentifier";

@interface IconCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

@end

@implementation IconCollectionViewCell

- (void)configureWithImage:(UIImage *)image {
    [self.iconImageView.layer setCornerRadius:self.bounds.size.height * iconCornerRadiusFactor];
    [self.iconImageView.layer setBorderColor:[UIColor appIconIsSelectedBorderColor].CGColor];
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
