//
//  MarkCollectionViewCell.m
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "MarkCollectionViewCell.h"

@implementation MarkCollectionViewCell

- (void)configureWithImage:(UIImage *)image {
    [self.markImageView.layer setCornerRadius:self.bounds.size.height * 0.5];
    self.markImageView.layer.masksToBounds = YES;
    self.markImageView.image = image;
}

@end
