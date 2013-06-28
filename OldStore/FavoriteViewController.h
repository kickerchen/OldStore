//
//  FavoriteViewController.h
//  OldStore
//
//  Created by KICKERCHEN on 13/6/27.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatabaseManager;

@interface FavoriteViewController : UIViewController
@property (nonatomic, strong) DatabaseManager *dbMgr;
@end
