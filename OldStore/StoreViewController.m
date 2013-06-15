//
//  StoreViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/14.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "StoreViewController.h"
#import "DatabaseManager.h"
#import "Common.h"

// tableView cell id constants
static NSString *kNameKey = @"name";
static NSString *kSinceKey = @"since";
static NSString *kAboutYearKey = @"is_about_year";
static NSString *kAddressKey = @"address";
static NSString *kTelKey = @"tel";
static NSString *kFaxKey = @"fax";
static NSString *kEmailKey = @"email";
static NSString *kBizHourKey = @"biz_hour";
static NSString *kCloseDayKey = @"close_day";
static NSString *kWebKey = @"web";
static NSString *kBlogKey = @"blog";
static NSString *kFBKey = @"fb";
static NSString *kProductKey = @"product";
static NSString *kMediaKey = @"media";
static NSString *kIntroKey = @"intro";

static NSString *kInfoCellID = @"InfoCellID";
static NSString *kMediaCellID = @"MediaCellID";
static NSString *kIntroCellID = @"IntroCellID";

@interface MyLabel : UILabel

@end

@implementation MyLabel

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = { 0, 5, 0, 5 };
    return [ super drawTextInRect:UIEdgeInsetsInsetRect( rect, insets ) ];
}

@end

@interface StoreViewController ()
@property (nonatomic, strong) NSDictionary *storeDetails;
@property (nonatomic, strong) NSMutableArray *dataSourceArray;
@end

@implementation StoreViewController

@synthesize databaseManager, storeId;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set background image of view.
    UIImage *bg = [UIImage imageNamed:@"Paper_texture_v5_by_bashcorpo.jpeg"];
    if ( IS_IOS_7 ) 
        [ bg imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal ];

    self.view.backgroundColor = [ UIColor colorWithPatternImage: bg ];
    
    // SQL query: get shop by shop id
    NSString *query = [ NSString stringWithFormat: @"SELECT * FROM stores WHERE id = %d", self.storeId ];
    NSArray *store = [ self.databaseManager sendSQL: query ];
    self.storeDetails = [ store objectAtIndex: 0 ];

    // Data source section 1 (basic info)- section 1 is a NSDictionary: title, image, address, phone, fax, email, biz_hr, close_day, website, official_blog, fb, product
    self.dataSourceArray = [ NSMutableArray array ];
    NSMutableDictionary *section1 = [[NSMutableDictionary alloc] init];    
    [ self setSectionStringData: section1 withKey: kAddressKey ];
    [ self setSectionStringData: section1 withKey: kTelKey ];
    [ self setSectionStringData: section1 withKey: kFaxKey ];
    [ self setSectionStringData: section1 withKey: kEmailKey ];
    [ self setSectionStringData: section1 withKey: kBizHourKey ];
    [ self setSectionStringData: section1 withKey: kCloseDayKey ];
    [ self setSectionStringData: section1 withKey: kWebKey ];
    [ self setSectionStringData: section1 withKey: kBlogKey ];
    [ self setSectionStringData: section1 withKey: kFBKey ];
    [ self setSectionStringData: section1 withKey: kProductKey ];
    
    [ self.dataSourceArray addObject: section1 ];
    
    // Data source section 2 (media section) - section 2 is a NSArray
    NSString *mediaRawData = [ self.storeDetails valueForKey: kMediaKey ];
    if ( ![ mediaRawData isEqualToString: @"" ] ) {
        NSError *jsonError = nil;
        NSArray *section2 = [ NSJSONSerialization JSONObjectWithData: [mediaRawData dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &jsonError ];
        [ self.dataSourceArray addObject: section2 ];
    }
    /*
     -    NSString *introData = [ self.storeDetails valueForKey: @"intro" ];
     -    BOOL isNull = [ introData isEqualToString: @"" ];
     -
     -    NSString *mediaData = [ self.storeDetails valueForKey: @"media" ];
     -    BOOL isMediaNull = [ mediaData isEqualToString: @"" ];
     -    NSError *jsonError = nil;
     -    id jsonObject = [ NSJSONSerialization JSONObjectWithData: [mediaData dataUsingEncoding:NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &jsonError ];
     -
     -    NSDictionary *media = (NSDictionary *)[jsonObject objectAtIndex:0];
     -
     -
     -        NSLog( @"name: %@\n", [ media valueForKey: @"name" ] );
     -        NSLog( @"title: %@\n", [ media valueForKey: @"title" ] );
     -        NSLog( @"url: %@\n", [ media valueForKey: @"url" ] );
     -
     -             //distanceLabel.transform = CGAffineTransformMakeRotation( M_PI * 10.0 / 180.0 );
     -     */
    
    // Data source section 3 (intro section) - section 3 is a NSDictionary
    NSString *intro = [ self.storeDetails valueForKey: kIntroKey ];
    if ( ![ intro isEqualToString: @"" ] ) {
        NSMutableDictionary *section3 = [ [NSMutableDictionary alloc] init ];
        [ section3 setObject: intro forKey: kIntroKey ];
        [ self.dataSourceArray addObject: section3 ];
    }
    
    /////////////////////////////////////////////
    //          Create relevant views          //
    /////////////////////////////////////////////
    
    // Create label - Store name.
    UILabel *nameLabel = [ [ UILabel alloc ] initWithFrame: CGRectMake( 15, 20, 270, 22 ) ];
    nameLabel.text = [ self.storeDetails valueForKey: kNameKey ];
    nameLabel.backgroundColor = [ UIColor clearColor ];
    nameLabel.font = [ UIFont systemFontOfSize: 20.0 ];
    nameLabel.textColor = [ UIColor redColor ];
    [ self.view addSubview: nameLabel ];
    
    // Create label - Since.
    NSString *sinceYear = [ self getYearString ];
    MyLabel *sinceLabel = [[MyLabel alloc] initWithFrame: CGRectMake( 270, 15, 41, 30 )];
    sinceLabel.backgroundColor = [ UIColor clearColor ];
    sinceLabel.textColor = RGBA( 0, 0.85 );
    sinceLabel.text = sinceYear;
    sinceLabel.font = [ UIFont boldSystemFontOfSize: 11.0 ];
    sinceLabel.numberOfLines = 0;
    sinceLabel.layer.borderWidth = 1.0;
    sinceLabel.layer.borderColor = [(UIColor *)RGBA( 0, 0.85 ) CGColor];
    sinceLabel.layer.cornerRadius = 4.0;
    sinceLabel.transform = CGAffineTransformMakeRotation( M_PI * 10.0 / 180.0 );
    
    [ self.view addSubview: sinceLabel ];
    
    // Create table view
    UITableView *tableView = [ [UITableView alloc] initWithFrame: CGRectMake( 0, 50, self.view.bounds.size.width, self.view.bounds.size.height ) style: UITableViewStyleGrouped ];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundView.alpha = 0.0;
    tableView.backgroundColor = [ UIColor clearColor ];
    [ tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kInfoCellID];
    [ tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kMediaCellID];
    [ tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kIntroCellID];
    
    [ self.view addSubview: tableView ];
    
    // Create button - google search
    
    // Create button - report error
}

- (void)setSectionStringData: (NSMutableDictionary *)section withKey: (NSString *)key
{
    NSString *data = [ self.storeDetails valueForKey: key ];
    if ( ![data isEqualToString: @""] ) {
        [ section setObject: data forKey: key ];
    }
}

- (NSString *)getYearString
{
    NSNumber *year = [ self.storeDetails valueForKey: kSinceKey ];
    NSNumber *isAboutYear = [ self.storeDetails valueForKey: kAboutYearKey ];
    
    if ( [ year isKindOfClass:[NSNull class] ] || [ isAboutYear isKindOfClass:[NSNull class] ] )
        return @"";
    
    // Actual year.
    if ( [ isAboutYear boolValue ] == NO )
        return [ NSString stringWithFormat: @"Since %@", year ];
    
    // Rough year, eg. 1953 => 1950s
    NSInteger yr = floor( [year floatValue] / 10.0 ) * 10;
    return [ NSString stringWithFormat: @"Since %ds", yr ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionNumber = [ self.dataSourceArray count ];
    return sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger cellNumber = [ [self.dataSourceArray objectAtIndex: section] count ];
    return cellNumber;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ( 0 == section )
        return nil;
    
    id data = [ self.dataSourceArray objectAtIndex: section ];
    if ( [data isKindOfClass: [NSArray class]] )  // media section
        return NSLocalizedString( @"Media Report", nil );
    
    return NSLocalizedString( @"Introduction", nil );
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    cell = [tableView dequeueReusableCellWithIdentifier:kInfoCellID forIndexPath:indexPath];
    [ cell setBackgroundColor: RGBA( 0xfdf7ea, 0.3 ) ];
    
    return cell;
}

@end
