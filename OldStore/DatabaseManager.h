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

- (id)initWithFileName: (NSString *)fileName ofType: (NSString *)typeName;
//- (void)openDB;  //private method
//- (void)closeDB;  //private method
- (NSArray *)getCity;
- (NSArray *)getRegionByCityId: (NSInteger)cityId;
- (NSArray *)getShopByGeotag: (NSInteger)geoTagId currentPosition: (CLLocation *)currentPosition;
- (NSArray *)getShopByCityId: (NSInteger)cityId currentPosition: (CLLocation *)currentPosition;
- (NSArray *)sendSQL: (NSString *)sqlQuery;

@end
