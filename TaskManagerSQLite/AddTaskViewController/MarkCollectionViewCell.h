//
//  MarkCollectionViewCell.h
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MarkCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *markImageView;

- (void) configureWithImage: (UIImage*) image;

@end
