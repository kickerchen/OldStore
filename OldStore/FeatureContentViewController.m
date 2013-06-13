//
//  FeatureContentViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/5/30.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "FeatureContentViewController.h"
#import "StoreListViewController.h"
#import "DatabaseManager.h"

@interface FeatureContentViewController ()
@property (nonatomic) NSMutableArray *queryData;
@end

@implementation FeatureContentViewController

@synthesize featureItem = _featureItem;
@synthesize databaseManager = _databaseManager;
@synthesize queryData = _queryData;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.queryData = [[NSMutableArray alloc] init];
    
    switch ( _featureItem ) {
        case regionsFeatureItem: {
            
            NSArray *cityList = [self.databaseManager getCity];            
            // For each city, query its regions.
            for ( int i = 0; i < [cityList count]; ++i ) {
                NSString *cityName = [ [ cityList objectAtIndex: i ] valueForKey: @"name" ];
                NSMutableDictionary *regionsInACity = [[NSMutableDictionary alloc] init];
                [ regionsInACity setObject: cityName forKey: @"cityName" ];
                [ regionsInACity setObject: [self.databaseManager getRegionByCityId: i+1] forKey: @"regions" ]; // city id begins from 1.
                [ self.queryData addObject: regionsInACity ];
            }
            break;
        }
            
        default:
            break;
    }
    
    // Set background image of table view.
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Paper_texture_v5_by_bashcorpo.jpeg"]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    if ( _featureItem == regionsFeatureItem ) {
        return [self.queryData count];
    } else {
        return 0;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if( _featureItem == regionsFeatureItem ) {
        NSArray *regionsInACity = [ [ self.queryData objectAtIndex: section ] valueForKey: @"regions" ];
        return [regionsInACity count] + 1;
    } else {
        return [self.queryData count];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    // Set title only for feature: regions
    if ( _featureItem == regionsFeatureItem ) {
        return [ [ self.queryData objectAtIndex: section ] valueForKey: @"cityName" ];
    }
    
    return nil;
}

- (UIView *) tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if ( _featureItem == regionsFeatureItem ) {

        UIView *headerView = [ [UIView alloc] initWithFrame: CGRectMake( 0, 0, tableView.bounds.size.width, 30 ) ];
        [ headerView setBackgroundColor: [ UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 0.25 ] ];
    
        UILabel *label = [ [UILabel alloc] initWithFrame: CGRectMake( 5, 3, tableView.bounds.size.width-10, 18) ];
        label.text = [ [ self.queryData objectAtIndex: section ] valueForKey: @"cityName" ];
        label.textColor = [ UIColor colorWithRed: 1.0 green: 1.0 blue: 1.0 alpha: 0.75 ];
        label.backgroundColor = [ UIColor clearColor ];
        [ headerView addSubview: label ];
        return headerView;
    }
    
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeatureContentCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    if ( cell == nil ) {
        cell = [ [UITableViewCell alloc] initWithStyle: UITableViewCellStyleSubtitle reuseIdentifier: CellIdentifier ];
    }
    
    // Configure the cell...
    UILabel *label = (UILabel *)[ cell viewWithTag: 1 ];
    label.textColor = [ UIColor colorWithRed: 0.0 green: 0.0 blue: 0.0 alpha: 1.0 ];
    label.font = [ UIFont boldSystemFontOfSize:16 ];
    
    switch ( _featureItem ) {
        case regionsFeatureItem: {
            NSArray *regionsInACity = [ [ self.queryData objectAtIndex: indexPath.section ] valueForKey: @"regions" ];
            if ( indexPath.row == [ regionsInACity count ] ) { // Last row is to show all stores in that city.
                NSString *cityName = [ [ self.queryData objectAtIndex: indexPath.section ] valueForKey: @"cityName" ];
                label.text = [ NSString stringWithFormat: @"All stores in %@", cityName ];
            } else {        
                label.text = [ [ regionsInACity objectAtIndex: indexPath.row ] valueForKey: @"name" ];
            }
            break;
        }
            
        case categoriesFeatureItem:
            cell.textLabel.text = @"All stores in souvenir";
            break;
            
        case agesFeatureItem:
            cell.textLabel.text = @"All stores in 30 years";
            break;
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [[segue identifier] isEqualToString:@"ShowStoreList"] ) {
        StoreListViewController *storeListViewController = [segue destinationViewController];
        storeListViewController.databaseManager = self.databaseManager;
        NSIndexPath *indexPath = [ self.tableView indexPathForSelectedRow ];
        
        // Set title of navigation bar.
        UITableViewCell *selectedCell = [ self.tableView cellForRowAtIndexPath:indexPath ];
        UILabel *title = (UILabel *)[ selectedCell viewWithTag: 1 ];
        storeListViewController.title = title.text;
        
        switch ( self.featureItem ) {
            case regionsFeatureItem: {
                NSArray *regionInACity = [ [ self.queryData objectAtIndex: indexPath.section ] valueForKey: @"regions" ];                
                if ( indexPath.row == [ regionInACity count] ) { // Get all stores in that city.
                    
                    storeListViewController.storeList = [ self.databaseManager getShopByCityId: indexPath.section + 1 ]; // City id begins from 1.
                    
                } else { // Get all stores in the selected region.
                    
                    NSNumber *regionId = [ [ regionInACity objectAtIndex: indexPath.row ] valueForKey: @"id" ];
                    storeListViewController.storeList  = [ self.databaseManager getShopByGeotag: [ regionId integerValue ] ];
                }
                break;
            }
                
            default:
                break;
        }        
    }
}

@end