//
//  FavoriteViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/27.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "FavoriteViewController.h"
#import "StoreViewController.h"
#import "FavoriteManager.h"
#import "DatabaseManager.h"
#import "Common.h"

@interface FavoriteViewController () <UITableViewDelegate, UITableViewDataSource>
@property FavoriteManager *favMgr;
@property NSArray *storeList;
@end

@implementation FavoriteViewController

@synthesize dbMgr;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set background image of view.
    self.view.backgroundColor = [ UIColor colorWithPatternImage: [UIImage imageNamed:@"Paper_texture_v5_by_bashcorpo.jpeg"] ];
    // Initialize favorite manager
    self.favMgr = [[FavoriteManager alloc] init];
}

- (void)viewWillAppear:(BOOL)animated
{
    // Get favorite store id and query for relevant information.
    NSArray *favorites = [self.favMgr getFavorites];
    int count = [favorites count];
    if ( count > 0 ) {
        NSMutableArray *storeIds = [NSMutableArray array];
        for (int i = 0; i < count; ++i) {
            id obj = [favorites objectAtIndex:i];
            [ storeIds addObject: [obj valueForKey: @"id"] ];
        }
        
        self.storeList = [self.dbMgr getShopByShopIds:storeIds];
        
        UITableView *tableView = [ [UITableView alloc] initWithFrame:self.view.frame style:UITableViewStylePlain ];
        tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        tableView.delegate = self;
        tableView.dataSource = self;
        [tableView reloadData];
        [tableView registerClass: [UITableViewCell class] forCellReuseIdentifier: @"FavoriteCell"];
        [self.view addSubview: tableView];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    NSArray *subviews = [self.view subviews];
    int count = [subviews count];
    for (int i = 0; i < count; ++i) {
        [[subviews objectAtIndex:i] removeFromSuperview];
    } 
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.storeList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FavoriteCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    if ( cell == nil ) {
        cell = [[ UITableViewCell alloc ] initWithStyle: UITableViewCellStyleDefault reuseIdentifier: CellIdentifier];
    }
    
    // Configure the cell...
    NSDictionary *store = [ self.storeList objectAtIndex: indexPath.row ];
    NSString *storeName = [ store valueForKey: @"name" ];
    NSString *storeAddress = [ store valueForKey: @"address" ];
    NSNumber *storeDistance = [store valueForKey: @"distance"];
    
    UILabel *nameLabel, *addressLabel, *distanceLabel;
    if ( cell.contentView.subviews.count < 3 ) { // If 3 subviews have been created, just change text and reuse for performance.
        [ cell setBackgroundColor: [ UIColor clearColor ] ];
        [ cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator ];
        
        // Name label setting.
        nameLabel = [[UILabel alloc] initWithFrame: CGRectMake( 5, 12, 240, 20 )];
        nameLabel.textColor = RGBA( 0x8B0000, 1.0 );
        nameLabel.font = [UIFont systemFontOfSize:18.0];
        nameLabel.backgroundColor = [ UIColor clearColor ];
        [ cell.contentView addSubview: nameLabel ];
        
        // Address label setting.
        addressLabel = [[UILabel alloc] initWithFrame: CGRectMake( 5, 33, 240, 20 )];
        addressLabel.textColor = RGBA( 0x3B3B3B, 1.0 );
        addressLabel.font = [UIFont systemFontOfSize:12.0];
        addressLabel.backgroundColor = [ UIColor clearColor ];
        [ cell.contentView addSubview: addressLabel ];
        
        // Distance label setting.
        distanceLabel =  [[UILabel alloc] initWithFrame: CGRectMake( 235, 22, 60, 18)];
        distanceLabel.textAlignment = NSTextAlignmentRight;
        distanceLabel.textColor = RGBA( 0x3B3B3B, 1.0 );
        distanceLabel.font = [ UIFont systemFontOfSize: 14.0 ];
        distanceLabel.backgroundColor = [ UIColor clearColor ];
        [ cell.contentView addSubview: distanceLabel ];
        
    } else { // Reuse labels.
        nameLabel = ( UILabel * )[ cell.contentView.subviews objectAtIndex: 0 ];
        addressLabel = ( UILabel * )[ cell.contentView.subviews objectAtIndex: 1 ];
        distanceLabel = ( UILabel * )[ cell.contentView.subviews objectAtIndex: 2 ];
    }
    
    // Update label text.
    nameLabel.text = storeName;
    addressLabel.text = storeAddress;
    if ( storeDistance != nil )
        distanceLabel.text = [ NSString stringWithFormat:@"%.1f km", [storeDistance floatValue] ];;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 64;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    
    StoreViewController *detailViewController = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
    
    // Set title of nav bar.
    [ detailViewController setTitle: NSLocalizedString( @"Store Info", nil ) ];
    
    // Set relevant data members.
    NSDictionary *store = [ self.storeList objectAtIndex: indexPath.row ];
    detailViewController.storeId = [ [ store valueForKey: @"id" ] integerValue ];
    detailViewController.databaseManager = self.dbMgr;
    
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController: detailViewController animated:YES];    
}

@end
