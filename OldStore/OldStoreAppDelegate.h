//
//  AppDelegate.h
//  OldStore
//
//  Created by KICKERCHEN on 13/5/29.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatabaseManager;

@interface OldStoreAppDelegate : UIResponder <UIApplicationDelegate, UITabBarControllerDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) DatabaseManager *databaseManager;

@end
