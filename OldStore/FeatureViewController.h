//
//  FeatureViewController.h
//  OldStore
//
//  Created by KICKERCHEN on 13/5/29.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

// Class forwarding.
@class DatabaseManager;

@interface FeatureViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UITabBarControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableViewCell *regionsCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *categoriesCell;
@property (strong, nonatomic) IBOutlet UITableViewCell *agesCell;
@property (strong, nonatomic) DatabaseManager *databaseManager;

@end
