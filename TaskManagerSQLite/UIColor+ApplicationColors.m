//
//  UIColor+ApplicationColors.m
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/20/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import "UIColor+ApplicationColors.h"

@implementation UIColor (ApplicationColors)

+ (UIColor *)appDeleteRowActionColor {
    return [UIColor colorWithRed:211.0/255.0 green:70.0/255.0 blue:73.0/255.0 alpha:1];
}

+ (UIColor *)appDoneRowActionColor {
    return [UIColor colorWithRed:36.0/255.0 green:110.0/255.0 blue:95.0/255.0 alpha:1];
}

+ (UIColor *)appSelectedCellColor {
    return [UIColor colorWithRed:82.0/255.0 green:89.0/255.0 blue:107.0/255.0 alpha:1.0];
}

+ (UIColor *)appTaskIsDoneBorderColor {
    return [UIColor colorWithRed:37.0/255.0 green:225.0/255.0 blue:175.0/255.0 alpha:1];
}

+ (UIColor *)appTaskIsPriorityBorderColor {
    return [UIColor colorWithRed:249.0/255.0 green:83.0/255.0 blue:87.0/255.0 alpha:1];
}

+ (UIColor *)appDatePickerTextColor {
    return [UIColor colorWithRed:183.0/255.0 green:189.0/255.0 blue:201.0/255.0 alpha:1.0];
}

+ (UIColor *)appIconIsSelectedBorderColor {
    return [UIColor colorWithRed:102.0/255.0 green:106.0/255.0 blue:118.0/255.0 alpha:1];
}


@end
