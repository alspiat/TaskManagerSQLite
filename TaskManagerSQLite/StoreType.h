//
//  StoreType.h
//  TaskManagerSQLite
//
//  Created by Aliaksei Piatyha on 7/23/18.
//  Copyright © 2018 Алексей. All rights reserved.
//

#ifndef StoreType_h
#define StoreType_h

static NSString * const SettingsStoreType = @"SettingStoreType";

typedef NS_ENUM(NSInteger, StoreType) {
    StoreTypeSQLite,
    StoreTypeCoreData
};

#endif /* StoreType_h */
