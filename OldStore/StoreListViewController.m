//
//  StoreListViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/5/30.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "StoreListViewController.h"
#import "DatabaseManager.h"

@interface StoreListViewController ()

@end

@implementation StoreListViewController

@synthesize databaseManager = _databaseManager;
@synthesize storeList = _storeList;

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
    // always one section.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of shops.
    NSInteger shopNumber = [ self.storeList count ];
    return shopNumber;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"ShopListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ( cell == nil ) {
        cell = [[ UITableViewCell alloc ] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *store = [ self.storeList objectAtIndex: indexPath.row ];
    NSString *storeName = [ store valueForKey: @"name" ];
    NSString *storeAddress = [ store valueForKey: @"address" ];
    NSNumber *storeDistance = [store valueForKey:@"distance"];
    
    UILabel *nameLabel = (UILabel *)[ cell viewWithTag: 1 ];
    nameLabel.text = storeName;
    
    UILabel *addressLabel = (UILabel *)[ cell viewWithTag: 2 ];
    addressLabel.text = storeAddress;
    
    if ( storeDistance != nil ) {
        UILabel *distanceLabel =  (UILabel *)[ cell viewWithTag: 3 ];
        distanceLabel.text = [ NSString stringWithFormat:@"%f", [storeDistance floatValue] ];
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
