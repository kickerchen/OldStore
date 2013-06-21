//
//  StoreViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/14.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <MessageUI/MessageUI.h>

#import "OldStoreAppDelegate.h"
#import "StoreViewController.h"
#import "DatabaseManager.h"
#import "WebViewController.h"
#import "SVWebViewController.h"
#import "Common.h"

// tableView cell id constants
static NSString *kNameKey = @"name";
static NSString *kSinceKey = @"since";
static NSString *kAboutYearKey = @"is_about_year";
static NSString *kThumbnailKey = @"thumbnail";
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

static NSString *kMediaSectionNameKey = @"name";
static NSString *kMediaSectionTitleKey = @"title";
static NSString *kMediaSectionURLKey = @"url";

static NSString *kInfoCellID = @"InfoCellID";
static NSString *kMediaCellID = @"MediaCellID";
static NSString *kIntroCellID = @"IntroCellID";

static float kDefaultCellHeight = 34.0;
static float kThumbnailWidth = 80.0;

typedef enum {
    SectionTypeInfo = 1,
    SectionTypeMedia = 2,
    SectionTypeIntro = 3
} SectionType;

@interface MyLabel : UILabel

@end

@implementation MyLabel

- (void)drawTextInRect:(CGRect)rect
{
    UIEdgeInsets insets = { 0, 5, 0, 5 };
    return [ super drawTextInRect:UIEdgeInsetsInsetRect( rect, insets ) ];
}

@end

@interface StoreViewController () <UIAlertViewDelegate, MFMailComposeViewControllerDelegate>
@property (nonatomic, strong) NSDictionary *storeDetails; // store information returned by SQL
@property (nonatomic, strong) NSMutableArray *dataSourceArray; // used for view construction
@property (nonatomic, strong) NSMutableArray *sectionStack; // used for section type identification
@property (nonatomic, strong) NSMutableArray *infoKeyStack; // used for keeping track each cell's key on info section
@property (nonatomic, strong) OldStoreAppDelegate *appDelegate;
@property UITableView *tableView;
@end

@implementation StoreViewController

@synthesize databaseManager, storeId;

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Get app delegate to access global array for download image
    self.appDelegate = (OldStoreAppDelegate *)[ [UIApplication sharedApplication] delegate ];
    
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
    self.infoKeyStack = [ NSMutableArray array ];
    NSMutableDictionary *section1 = [[NSMutableDictionary alloc] init];
    
    // Check if there's any snapshot about the store.
    query = [ NSString stringWithFormat: @"SELECT id, store_id, strftime(%@,created_at) AS created_at, asset_file_name FROM assets WHERE store_id = %d", @"'%Y-%m-%d-%H-%M-%S'", self.storeId ];
    NSArray *urls = [ self.databaseManager sendSQL: query ];
    if ( [ urls count ] > 0 ) {
        // Set to data source to create relevant view for putting thumbnails later.
        NSArray *thumbnailURLs = [ self genThumbnailURLs: urls ];
        [ section1 setObject: thumbnailURLs forKey: kThumbnailKey ];
        [ self.infoKeyStack addObject: kThumbnailKey ];
    }
    
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
    
    [ self.dataSourceArray addObject: section1 ]; // for view construction
    
    self.sectionStack = [NSMutableArray array];
    [ self.sectionStack addObject: [ NSNumber numberWithInt: SectionTypeInfo ] ]; // for section type identification
    
    // Data source section 2 (media section) - section 2 is a NSArray
    NSString *mediaRawData = [ self.storeDetails valueForKey: kMediaKey ];
    if ( ![ mediaRawData isEqualToString: @"" ] ) {
        NSError *jsonError = nil;
        NSArray *section2 = [ NSJSONSerialization JSONObjectWithData: [mediaRawData dataUsingEncoding: NSUTF8StringEncoding] options: NSJSONReadingMutableContainers error: &jsonError ];
        [ self.dataSourceArray addObject: section2 ]; // for view construction
        [ self.sectionStack addObject: [ NSNumber numberWithInt: SectionTypeMedia ] ]; // for section type identification
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
        [ self.dataSourceArray addObject: intro ]; // for view construction
        [ self.sectionStack addObject: [ NSNumber numberWithInt: SectionTypeIntro ] ]; // for section type identification
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
    //nameLabel.userInteractionEnabled = YES;
    //UIPanGestureRecognizer *gesture = [ [UIPanGestureRecognizer alloc] initWithTarget: self action: @selector( labelDragged: ) ];
    //[ nameLabel addGestureRecognizer: gesture ];
    [ self.view addSubview: nameLabel ];
    
    // Create label - Since, if exists.
    NSString *sinceYear = [ self getYearString ];
    if ( ![sinceYear isEqualToString: @""] ) {
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
    }
    
    // Create table view
    UITableView *tableView = [ [UITableView alloc] initWithFrame: CGRectMake( 0, 50, self.view.bounds.size.width, self.view.bounds.size.height - STATUS_BAR_HEIGHT - NAV_BAR_HEIGHT - TAB_BAR_HEIGHT - 50 ) style: UITableViewStyleGrouped ];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundView.alpha = 0.0;
    tableView.backgroundColor = [ UIColor clearColor ];
    tableView.scrollEnabled = YES;
    [ tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kInfoCellID];
    [ tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kMediaCellID ];
    [ tableView registerClass:[ UITableViewCell class ] forCellReuseIdentifier: kIntroCellID ];
    self.tableView = tableView;
    [ self.view addSubview: tableView ];
    
    // Create button - google search
    
    // Create button - report error
}

- (void)viewDidAppear:(BOOL)animated
{
    [ super viewDidAppear: animated ];
    [ self.tableView reloadData ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark Auxiliary methods

- (void)setSectionStringData: (NSMutableDictionary *)section withKey: (NSString *)key
{
    NSString *data = [ self.storeDetails valueForKey: key ];
    if ( ![data isEqualToString: @""] ) {
        [ section setObject: data forKey: key ];
        [ self.infoKeyStack addObject: key ];
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

- (NSArray *)genThumbnailURLs: (NSArray *)assets
{
    NSMutableArray *thumbnails = [ NSMutableArray array ];
    int count = [ assets count ];
    for ( int i = 0; i < count ; ++i ) {
        NSDictionary *asset = [ assets objectAtIndex: i ];
        NSArray *fileName = [ [ asset objectForKey: @"asset_file_name" ] componentsSeparatedByString: @"." ];
        NSString *url = [ NSString stringWithFormat: @"https://s3-ap-northeast-1.amazonaws.com/oldstore/%@/small/%@-%@.%@",
                         [ asset objectForKey: @"id" ],
                         [ asset objectForKey: @"store_id" ],
                         [ asset objectForKey: @"created_at" ],
                         [ fileName objectAtIndex: fileName.count - 1 ] ];
        [ thumbnails addObject: url ];
    }
    return thumbnails;
}
- (void)processImageDataWithURLString: (NSString *)urlString andBlock: (void(^)(NSData *imageData))processImage
{
    NSURL *url = [ NSURL URLWithString: urlString ];
    
    //dispatch_queue_t callerQueue = dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 );
    dispatch_queue_t callerQueue = dispatch_queue_create( "upadte cell", NULL );
    //dispatch_queue_t downloadQueue = dispatch_queue_create( "download thumbnail", NULL );
    dispatch_async( dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0 ),
    ^{
        NSData *imageData = [ NSData dataWithContentsOfURL: url ];
        
        dispatch_async( callerQueue, ^{processImage( imageData );} );
    });
}

- (UITableViewCell *)parseInfoSectionForCell: (UITableView *)tableView with: (UITableViewCell *)cell atIndexPath: (NSIndexPath *)indexPath
{    
    [ cell setSelectionStyle: UITableViewCellSelectionStyleNone ];
    
    NSString *key = [ self.infoKeyStack objectAtIndex: indexPath.row ]; // get the of this cell

    // thumbnails: create a scroll view and put image view in it
    if ( [ key isEqualToString: kThumbnailKey ] ) { 
        
        NSArray *urls = [ [ self.dataSourceArray objectAtIndex: indexPath.row ] valueForKey: kThumbnailKey ];
        int count = [ urls count ];
        UIScrollView *scrollView = [ [ UIScrollView alloc ] initWithFrame: CGRectMake( 0, 0, cell.contentView.frame.size.width-2, kThumbnailWidth + 20 ) ];
        [ scrollView setContentSize: CGSizeMake( 10 + 90 * count, kThumbnailWidth + 20 ) ];
        for ( int i = 0; i < count; ++i ) {
            UIImageView *thumbnail = [ [UIImageView alloc] initWithFrame: CGRectMake( 10+(10+kThumbnailWidth)*i, 10, kThumbnailWidth, kThumbnailWidth ) ];
            [ thumbnail.layer setBorderWidth: 2.0 ];
            [ thumbnail.layer setBorderColor: [ RGBA(0xD3D3D3, 1.0) CGColor ] ];
            [ thumbnail.layer setCornerRadius: 10.0 ];
            [ thumbnail setContentMode: UIViewContentModeScaleAspectFill ];
            [ thumbnail setClipsToBounds: YES ];
            
            NSString *url = [ urls objectAtIndex: i ];
            UIImage *image = [self.appDelegate.images valueForKey: url];
            if ( image ) {
                [ thumbnail setImage: image ];
            } else {
                [ self processImageDataWithURLString: url andBlock: ^(NSData *imageData) {
                    if ( imageData ) {
                        UIImage *image = [ [UIImage alloc] initWithData: imageData ];
                        [ self.appDelegate.images setObject: image forKey: url ]; // keep in global image array
                        [ thumbnail setImage: image ];
                        [ self.tableView reloadData ];
                    }
                }];
            }

            [ scrollView addSubview: thumbnail ];
        }
        [ cell.contentView addSubview: scrollView ];
    } else {
        // create image view to show relevant icon
        UIImageView *imageView = [[UIImageView alloc] initWithFrame: CGRectMake( 10, 9, 15, 15)];
        [ imageView setContentMode: UIViewContentModeScaleAspectFill ];
        //[ imageView setClipsToBounds: YES ];
        UIImage *image = nil;
        if ( kAddressKey == key ) {
            image = [ UIImage imageNamed: @"06-map-pin" ];
            [ imageView setContentMode: UIViewContentModeCenter ];
            [ cell setSelectionStyle: UITableViewCellSelectionStyleBlue ];
            [ cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator ];
        } else if ( kTelKey == key ) {
            image = [ UIImage imageNamed: @"75-phone" ];
            [ cell setSelectionStyle: UITableViewCellSelectionStyleBlue ];
            [ cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator ];
        } else if ( kFaxKey == key ) {
            image = [ UIImage imageNamed: @"185-printer" ];
        } else if ( kEmailKey == key ) {
            image = [ UIImage imageNamed: @"email" ];
            [ cell setSelectionStyle: UITableViewCellSelectionStyleBlue ];
            [ cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator ];
        } else if ( kBizHourKey == key ) {
            image = [ UIImage imageNamed: @"19-clock" ];
        } else if ( kWebKey == key ) {
            image = [ UIImage imageNamed: @"38-house" ];
            [ cell setSelectionStyle: UITableViewCellSelectionStyleBlue ];
            [ cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator ];
        } else if ( kBlogKey == key ) {
            image = [ UIImage imageNamed: @"blogger" ];
            [ cell setSelectionStyle: UITableViewCellSelectionStyleBlue ];
            [ cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator ];
        } else if ( kFBKey == key ) {
            image = [ UIImage imageNamed: @"208-facebook" ];
            [ cell setSelectionStyle: UITableViewCellSelectionStyleBlue ];
            [ cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator ];
        } else if ( kProductKey == key ) {
            image = [ UIImage imageNamed: @"02-star" ];
        }
        
        [ imageView setImage: image ];
        [ cell.contentView addSubview: imageView ];
        
        // create a label with content of info
        NSString *info = [ [ self.dataSourceArray objectAtIndex: indexPath.section ] valueForKey: key ];
        UILabel *infoLabel = [[UILabel alloc] initWithFrame: CGRectMake( 34, 0, cell.contentView.frame.size.width - 70,         cell.contentView.frame.size.height )];
        
        //infoLabel.textColor = RGBA( 0x8B0000, 1.0 );
        infoLabel.font = [UIFont systemFontOfSize: 14.0];
        infoLabel.backgroundColor = [ UIColor clearColor ];
        infoLabel.numberOfLines = 0;
        infoLabel.text = info;
        [ cell.contentView addSubview: infoLabel ];
    }
    
    return cell;
}

#pragma mark -
#pragma mark Selector methods

- (void)labelDragged:(UIPanGestureRecognizer *)gesture
{
    UILabel *label = (UILabel *)gesture.view;
    CGPoint transition = [ gesture translationInView: label ];
    
    // move label
    label.center = CGPointMake( label.center.x, label.center.y + transition.y );
    
    // reset transition
    [ gesture setTranslation: CGPointZero inView: label ];
}

#pragma mark -
#pragma mark UITableViewDelegate methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger sectionNumber = [ self.dataSourceArray count ];
    return sectionNumber;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSNumber *sectionType = (NSNumber *)[self.sectionStack objectAtIndex: section];
    switch ( [ sectionType intValue ] ) {
        case SectionTypeInfo:
            return [ [self.dataSourceArray objectAtIndex: section] count ];
            break;
            
        case SectionTypeMedia:
            return [ [self.dataSourceArray objectAtIndex: section] count ];
            break;
            
        case SectionTypeIntro:
            return 1;
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSNumber *sectionType = (NSNumber *)[self.sectionStack objectAtIndex: section];    
    switch ( [ sectionType intValue ] ) {
        case SectionTypeMedia:
            return NSLocalizedString( @"Media Report", nil );
            break;
            
        case SectionTypeIntro:
            return NSLocalizedString( @"Introduction", nil );
            break;
            
        default:
            return nil;
            break;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = kDefaultCellHeight;
    //UITableViewCell *cell = [tableView cellForRowAtIndexPath: indexPath];
    
    //CGSize textSize = [ cell.textLabel.text sizeWithFont: cell.textLabel.font constrainedToSize: CGSizeMake( 280.0f, MAXFLOAT ) ];
    //height = textSize.height + 20.0;
    
    int sectionType = [(NSNumber *)[self.sectionStack objectAtIndex: indexPath.section] intValue];
    if ( SectionTypeInfo == sectionType ) { // Info section
        NSString *key = [ self.infoKeyStack objectAtIndex: indexPath.row ];
        if ( [ key isEqualToString: kThumbnailKey ] ) {
            height = kThumbnailWidth + 20;
        } else {
            NSDictionary *info = [ self.dataSourceArray objectAtIndex: indexPath.section ];
            NSString *text = [ info valueForKey: key ];
            CGSize textSize = [ text sizeWithFont: [UIFont systemFontOfSize: 14.0] constrainedToSize: CGSizeMake( 280.0f, MAXFLOAT ) ];
            height = textSize.height + 20.0;
        }
        
    } else if ( SectionTypeMedia == sectionType ) { // Media section
        NSDictionary *media = [ self.dataSourceArray objectAtIndex: indexPath.section ];
        NSString *name = [ [ media valueForKey: kMediaSectionNameKey ] objectAtIndex: 0 ];
        NSString *title = [ [ media valueForKey: kMediaSectionTitleKey ] objectAtIndex: 0 ];
        NSString *mediaText = [ NSString stringWithFormat: @"%@: %@", name, title ];
        CGSize textSize = [ mediaText sizeWithFont: [UIFont systemFontOfSize: 14.0] constrainedToSize: CGSizeMake( 280.0f, MAXFLOAT ) ];
        height = textSize.height + 20.0;

    } else if ( SectionTypeIntro == sectionType ) { // Intro section
        NSString *text = [ self.dataSourceArray objectAtIndex: indexPath.section ];
        CGSize textSize = [ text sizeWithFont: [UIFont systemFontOfSize: 14.0] constrainedToSize: CGSizeMake( 280.0f, MAXFLOAT ) ];
        height = textSize.height + 20.0;
    }
    
    return height;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    int sectionType = [(NSNumber *)[self.sectionStack objectAtIndex: indexPath.section] intValue];
    UITableViewCell *cell = nil;
    
    // content-related setting
    id sectionData = [ self.dataSourceArray objectAtIndex: indexPath.section ];
    if ( SectionTypeInfo == sectionType ) { // Handle info section
        cell = [tableView dequeueReusableCellWithIdentifier:kInfoCellID forIndexPath:indexPath];
        if ( cell.contentView.tag == sectionType )
            return cell; // This cell has been handled so tag is set as section type. Just return to improve performance.
        
        cell = [ self parseInfoSectionForCell: tableView with: cell atIndexPath: indexPath ];
        [ cell.contentView setTag: SectionTypeInfo ]; 
        
    } else if ( SectionTypeMedia == sectionType ) { // Handle media section
        cell = [tableView dequeueReusableCellWithIdentifier:kMediaCellID forIndexPath:indexPath];
        if ( cell.contentView.tag == sectionType ) 
            return cell; // This cell has been handled so tag is set as section type. Just return to improve performance.
        
        NSDictionary *media = [ (NSArray *)sectionData objectAtIndex: indexPath.row ];
        // name, title, url
        NSString *mediaText = [ NSString stringWithFormat: @"%@: %@",
                                [ media valueForKey: kMediaSectionNameKey ],
                                [ media valueForKey: kMediaSectionTitleKey ] ];
        [ cell.textLabel setText: mediaText];
        [ cell setAccessoryType: UITableViewCellAccessoryDisclosureIndicator ];
        [ cell.contentView setTag: SectionTypeMedia ];
        
    } else if ( SectionTypeIntro == sectionType ) { // Handle intro section
        cell = [tableView dequeueReusableCellWithIdentifier:kIntroCellID forIndexPath:indexPath];
        if ( cell.contentView.tag == sectionType )
            return cell; // This cell has been handled so tag is set as section type. Just return to improve performance.

        [ cell setSelectionStyle: UITableViewCellSelectionStyleNone ];
        [ cell.textLabel setText: (NSString *)sectionData ];
        [ cell.contentView setTag: SectionTypeIntro ];
    }
    
    [ cell setBackgroundColor: RGBA( 0xfdf7ea, 0.3 ) ];
    [ cell.textLabel setFont: [ UIFont systemFontOfSize: 14.0 ] ];
    [ cell.textLabel setNumberOfLines: 0 ];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [ [ tableView cellForRowAtIndexPath: indexPath ] setSelected: NO ]; // reset the selected cell
    
    NSNumber *sectionType = (NSNumber *)[ self.sectionStack objectAtIndex: indexPath.section ];
    if ( SectionTypeInfo == [sectionType intValue] ) {
        NSString *key = [ self.infoKeyStack objectAtIndex: indexPath.row ];
        NSDictionary *storeInfo = [ self.dataSourceArray objectAtIndex: indexPath.section ];
        
        if ( [key isEqualToString: kAddressKey] ) { // open apple map
            
            NSString *queryString = [ NSString stringWithFormat: @"http://maps.apple.com/maps?q=%@,%@", [self.storeDetails valueForKey: @"lat"], [self.storeDetails valueForKey: @"lng"] ];
            [ [ UIApplication sharedApplication ] openURL: [ NSURL URLWithString: queryString ] ];
            
        } else if ( [key isEqualToString: kTelKey] ) { // make a call
            
            NSString *tel = [ storeInfo valueForKey: kTelKey ];
            UIAlertView *alert = [ [UIAlertView alloc] initWithTitle: NSLocalizedString( @"Make phone call?", nil )
                                                             message: tel
                                                            delegate: self
                                                   cancelButtonTitle: NSLocalizedString( @"Cancel", nil )
                                                   otherButtonTitles:NSLocalizedString( @"Ok", nil ), nil ];
            [alert show];
        
        } else if ( [key isEqualToString: kEmailKey] ) { // send e-mail
            
            if ( NO == [ MFMailComposeViewController canSendMail ] ) {
                UIAlertView *mailAlert = [ [UIAlertView alloc] initWithTitle: NSLocalizedString( @"Failure", nil )
                                                                     message: NSLocalizedString( @"Your device cannot send E-mail now", nil )
                                                                    delegate: self
                                                           cancelButtonTitle: NSLocalizedString( @"Ok", nil )
                                                           otherButtonTitles: nil, nil ];
                [ mailAlert show ];
            } else {
                MFMailComposeViewController *mailer = [[MFMailComposeViewController alloc] init];
                mailer.mailComposeDelegate = self;
                //[ mailer setSubject: @"subject"];
                [ mailer setToRecipients: @[ [storeInfo valueForKey: kEmailKey] ]];
                //[ mailer setMessageBody: @"msgBody" isHTML: NO ];
                [ self presentViewController: mailer animated: YES completion: NULL ];
            }
            
        } else if ( [key isEqualToString: kWebKey] || [key isEqualToString: kBlogKey] || [key isEqualToString: kFBKey] ) {
            
            WebViewController *browser = [ [WebViewController alloc] initWithNibName: @"WebViewController" bundle: nil ];
            browser.urlString = [ storeInfo valueForKey: key ];
            
            // Use the following marked code to implement a full-screen browser instead of opening url explicitly.
            //UITabBarController *tabBar = (UITabBarController *)[[ [ UIApplication sharedApplication ] keyWindow ] rootViewController ];
            //[ [ tabBar view ] addSubview: browser.view ];
            [ [ UIApplication sharedApplication ] openURL: [ NSURL URLWithString: browser.urlString ] ];
            
        }
        
    } else if ( SectionTypeMedia == [sectionType intValue] ) {
        
        NSDictionary *media = [ [ self.dataSourceArray objectAtIndex: indexPath.section ] objectAtIndex: indexPath.row ];
        NSString *url = [ media valueForKey: kMediaSectionURLKey ];
        SVWebViewController *browser = [ [SVWebViewController alloc] initWithAddress: url ];
        [ self.navigationController pushViewController: browser animated: YES ];
        
    }
}

#pragma mark -
#pragma mark UIAlertViewDelegate methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ( 1 == buttonIndex ) {
        NSString *tel = [ [ self.dataSourceArray objectAtIndex: 0 ] valueForKey: kTelKey ];
        [ [UIApplication sharedApplication] openURL: [NSURL URLWithString: [ NSString stringWithFormat: @"tel:%@", tel ]] ];
    }    
}

#pragma mark -
#pragma mark MFMailComposerViewControllerDelegate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    [ self dismissViewControllerAnimated: YES completion: NULL ];
}

@end
