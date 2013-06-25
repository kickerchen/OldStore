//
//  FavoriteManager.h
//  OldStore
//
//  Created by KICKERCHEN on 13/6/22.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FavoriteManager : NSObject

- (void)addStore: (NSInteger)storeID;
- (void)removeStore: (NSInteger)storeID;
- (BOOL)isFavorite: (NSInteger)storeID;

@end
