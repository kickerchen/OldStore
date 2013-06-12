//
//  StoreListViewController.h
//  OldStore
//
//  Created by KICKERCHEN on 13/5/30.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DatabaseManager;

@interface StoreListViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

@property (strong, nonatomic) NSArray *storeList;
@property (strong, nonatomic) DatabaseManager *databaseManager;

@end
