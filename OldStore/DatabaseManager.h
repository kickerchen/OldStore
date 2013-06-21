//
//  DatabaseManager.h
//  OldStore
//
//  Created by KICKERCHEN on 13/5/31.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface DatabaseManager : NSObject

@property (strong, nonatomic) NSString *databaseFilePath;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (id)initWithFileName: (NSString *)fileName ofType: (NSString *)typeName;
- (NSArray *)getCity;
- (NSArray *)getRegionByCityId: (NSInteger)cityId;
- (NSArray *)getShopByGeotag: (NSInteger)geoTagId;
- (NSArray *)getShopByCityId: (NSInteger)cityId;
- (NSArray *)sendSQL: (NSString *)sqlQuery;

@end
