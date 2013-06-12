//
//  FeatureContentViewController.h
//  OldStore
//
//  Created by KICKERCHEN on 13/5/30.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

// Class forwarding.
@class DatabaseManager;

@interface FeatureContentViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource>

typedef enum featureItems {
    regionsFeatureItem = 0,
    categoriesFeatureItem = 1,
    agesFeatureItem = 2
} FeatureItem;

@property FeatureItem featureItem;
@property (strong, nonatomic) DatabaseManager *databaseManager;

@end
