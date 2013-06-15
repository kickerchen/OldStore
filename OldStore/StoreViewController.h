//
//  StoreViewController.h
//  OldStore
//
//  Created by KICKERCHEN on 13/6/14.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatabaseManager;

@interface StoreViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) DatabaseManager *databaseManager;
@property (nonatomic) NSInteger storeId;

@end
