//
//  Constants.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/17/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef Constants_h
#define Constants_h

static NSString * const SettingsStoreType = @"SettingStoreType";

typedef NS_ENUM(NSInteger, StoreType) {
    StoreTypeSQLite = 0,
    StoreTypeCoreData = 1
};

#endif /* Constants_h */
