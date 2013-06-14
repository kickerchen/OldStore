//
//  StoreViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/14.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "StoreViewController.h"
#import "DatabaseManager.h"

// tableView cell id constants
static NSString *kMediaKey = @"media";
static NSString *kIntroKey = @"intro";

static NSString *kInfoCellID = @"InfoCellID";
static NSString *kMediaCellID = @"MediaCellID";
static NSString *kIntroCellID = @"IntroCellID";

@interface StoreViewController ()
@property NSDictionary *storeDetails;
@end

@implementation StoreViewController

@synthesize databaseManager, storeId;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set background image of table view.
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Paper_texture_v5_by_bashcorpo.jpeg"]];
    
    // SQL query: get shop by shop id
    NSString *query = [ NSString stringWithFormat: @"SELECT * FROM stores WHERE id = %d", self.storeId ];
    NSArray *store = [ self.databaseManager sendSQL: query ];
    self.storeDetails = [ store objectAtIndex: 0 ];
    
    /*
    NSString *introData = [ self.storeDetails valueForKey: @"intro" ];
    BOOL isNull = [ introData isEqualToString: @"" ];

    NSString *mediaData = [ self.storeDetails valueForKey: @"media" ];
    BOOL isMediaNull = [ mediaData isEqualToString: @"" ];
    NSError *jsonError = nil;
    id jsonObject = [ NSJSONSerialization JSONObjectWithData: [mediaData dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &jsonError ];

    NSDictionary *media = (NSDictionary *)[jsonObject objectAtIndex:0];


        NSLog( @"name: %@\n", [ media valueForKey: @"name" ] );
        NSLog( @"title: %@\n", [ media valueForKey: @"title" ] );
        NSLog( @"url: %@\n", [ media valueForKey: @"url" ] );
     
             //distanceLabel.transform = CGAffineTransformMakeRotation( M_PI * 10.0 / 180.0 );
     */


    // Data source - basic info (title, image, address, phone, fax, email, biz_hr, close_day, website, official_blog, fb, product )
    
    // Data source - media section
    
    // Data source - intro section
    
    // Register cell IDs for later when we are asked for UITableViewCells
    [ self.tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kInfoCellID];
    [ self.tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kMediaCellID];
    [ self.tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kIntroCellID];    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    BOOL isMediaNull = [ [ self.storeDetails valueForKey: kMediaKey ] isEqualToString: @"" ];
    BOOL isIntroNull = [ [ self.storeDetails valueForKey: kIntroKey ] isEqualToString: @"" ];
    
    if ( isMediaNull == NO && isIntroNull == NO ) {
        return 3;
    } else if ( isMediaNull == NO || isIntroNull == NO ) {
        return 2;
    } else {
        return 1;
    }
}

@end
