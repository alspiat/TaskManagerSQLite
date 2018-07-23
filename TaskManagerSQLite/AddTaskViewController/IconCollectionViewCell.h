//
//  IconCollectionViewCell.h
//  TaskManagerSQLite
//
//  Created by Алексей on 09.07.2018.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <UIKit/UIKit.h>

extern NSString * const iconCellIdentfier;

@interface IconCollectionViewCell : UICollectionViewCell

- (void) configureWithImage: (UIImage*) image;
- (void) setIsSelected: (BOOL) isSelected;

@end
