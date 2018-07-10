//
//  IconCollectionViewCell.h
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IconCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *iconImageView;

- (void) configureWithImage: (UIImage*) image;

@end
