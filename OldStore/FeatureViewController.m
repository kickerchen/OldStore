//
//  FeatureViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/5/29.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "FeatureViewController.h"
#import "FeatureContentViewController.h"

@interface FeatureViewController ()

@end

@implementation FeatureViewController

@synthesize regionsCell = _regionsCell;
@synthesize categoriesCell = _categoriesCell;
@synthesize agesCell = _agesCell;
@synthesize databaseManager = _databaseManager;

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
    
    self.regionsCell.textLabel.text = NSLocalizedString(@"List by regions", nil);
    self.categoriesCell.textLabel.text = NSLocalizedString(@"List by categories", nil);
    self.agesCell.textLabel.text = NSLocalizedString(@"List by ages", nil);
    
    // Set background image of table view.
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"Paper_texture_v5_by_bashcorpo.jpeg"]];
}

- (void)viewDidAppear:(BOOL)animated
{
/*    UIImageView *bgImageView = [ [ UIImageView alloc ] initWithImage:[ UIImage imageNamed:@"Paper_texture_v5_by_bashcorpo.jpeg" ] ];
    bgImageView.frame = [[UIScreen mainScreen] applicationFrame];
    NSArray *subViews = [self.parentViewController.view subviews];
    [[subViews objectAtIndex: 0] addSubview: bgImageView];
    [[subViews objectAtIndex: 0] sendSubviewToBack: bgImageView];
 */
    [super viewDidAppear:animated];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view delegate

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ( [[segue identifier] isEqualToString:@"ShowRegions"] ) {
        
        FeatureContentViewController *featureContentViewController = [segue destinationViewController];
        featureContentViewController.featureItem = regionsFeatureItem;
        featureContentViewController.databaseManager = self.databaseManager;
        [featureContentViewController setTitle: NSLocalizedString( @"Regions", nil )];
        
    } else if ( [[segue identifier] isEqualToString:@"ShowCategories"] ) {
        
        FeatureContentViewController *featureContentViewController = [segue destinationViewController];
        featureContentViewController.featureItem = categoriesFeatureItem;
        featureContentViewController.databaseManager = self.databaseManager;
        [featureContentViewController setTitle: NSLocalizedString( @"Categories", nil)];
        
    } else if ( [[segue identifier] isEqualToString:@"ShowAges"] ) {
        
        FeatureContentViewController *featureContentViewController = [segue destinationViewController];
        featureContentViewController.featureItem = agesFeatureItem;
        featureContentViewController.databaseManager = self.databaseManager;
        [featureContentViewController setTitle: NSLocalizedString( @"Ages", nil )];
    }
}

@end
