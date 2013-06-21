//
//  FirstViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/5/29.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "MapViewController.h"
#import "StoreViewController.h"
#import "DatabaseManager.h"
#import "Common.h"

@interface StoreAnnotation : NSObject <MKAnnotation>
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property NSInteger storeID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;
@end

@implementation StoreAnnotation 

@synthesize coordinate, title, subtitle;
- (id)initWithLocation: (CLLocationCoordinate2D)coord
{
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    
    return self;
}

@end

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView, locationManager, databaseManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UINavigationItem *item = [ self.navigationController.navigationBar.items objectAtIndex: 0 ];
    UIBarButtonItem *btn = [ item leftBarButtonItem ];
    btn.tintColor = [ UIColor redColor ];
    
    UIImage *locImage = [ UIImage imageNamed: @"22-location-arrow" ];
    // Use original rendering mode on iOS 7.
    if ( IS_IOS_7 )
        locImage = [ locImage imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal ]; // iOS 7 specific method.
    
    [ btn setImage: locImage ];

    self.mapView.delegate = self;
    self.mapView.showsUserLocation = YES;
    
    NSArray *stores = [ self.databaseManager sendSQL: @"SELECT id, name, address, lat, lng FROM stores" ];
    
    NSMutableArray *annotationArray = [[NSMutableArray alloc] init];
    
    int count = [stores count];
    for ( int i = 0; i < count; ++i) {
        NSDictionary *record = [ stores objectAtIndex: i ];
        
        CLLocationCoordinate2D coord;
        coord.latitude =  [ (NSNumber *)[ record valueForKey: @"lat" ] doubleValue ];
        coord.longitude = [ (NSNumber *)[ record valueForKey: @"lng" ] doubleValue ];
        StoreAnnotation *annotation = [[StoreAnnotation alloc] initWithLocation: coord];
        
        NSString *name = (NSString *)[ record valueForKey: @"name" ];
        NSString *subtitle = (NSString *)[ record valueForKey: @"address" ];

        annotation.storeID = [ [ record valueForKey: @"id" ] integerValue ];
        annotation.title = name;
        annotation.subtitle = subtitle;
        
        [ annotationArray addObject: annotation ];
    }
    
    [ self.mapView addAnnotations: annotationArray ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma mark CLLocationManagerDelegate

- (void) locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [ locations lastObject ];
    NSDate *eventDate = location.timestamp;
    NSTimeInterval howRecent = [ eventDate timeIntervalSinceNow ];
    if ( abs(howRecent) < 15.0 ) {
        MKCoordinateRegion userLocation = MKCoordinateRegionMakeWithDistance( location.coordinate, kCLLocationAccuracyKilometer, kCLLocationAccuracyKilometer );
        [ self.mapView setRegion: userLocation animated: YES ];
        NSLog( @"User location: latitude %+.6f, longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude );
    }
}

#pragma mark -
#pragma mark MKMapViewDelegate

- (void) showStore:(UIButton *)sender
{
    // Show store details
    // Navigation logic may go here. Create and push another view controller.
    
    StoreViewController *detailViewController = [[StoreViewController alloc] initWithNibName:@"StoreViewController" bundle:nil];
    
    // Set title of nav bar.
    [ detailViewController setTitle: NSLocalizedString( @"Store Info", nil ) ];
    
    // Set relevant data members.
    detailViewController.storeId = sender.tag;
    detailViewController.databaseManager = self.databaseManager;
    
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController: detailViewController animated:YES];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ( [ annotation isKindOfClass: [ StoreAnnotation class ] ] ) {
        static NSString *storeIdentifier = @"StorePinAnnotationView";
        MKPinAnnotationView* storePinView = ( MKPinAnnotationView * )[ self.mapView dequeueReusableAnnotationViewWithIdentifier: storeIdentifier ];
        
        if ( !storePinView ) {
            storePinView = [ [ MKPinAnnotationView alloc ] initWithAnnotation: annotation reuseIdentifier: storeIdentifier ];
            storePinView.pinColor = MKPinAnnotationColorRed;
            storePinView.canShowCallout = YES;
            
            UIButton *rightButton = [ UIButton buttonWithType: UIButtonTypeDetailDisclosure ];
            [ rightButton addTarget: self
                             action: @selector( showStore: )
                   forControlEvents: UIControlEventTouchUpInside ];
            storePinView.rightCalloutAccessoryView = rightButton;            
        } else {
            storePinView.annotation = annotation;
        }
        
        // Keep store id in tag of the button.
        storePinView.rightCalloutAccessoryView.tag = ((StoreAnnotation *)annotation).storeID;
        
        return storePinView;
    }
    
    return nil;
}

#pragma mark -
#pragma mark MapViewController

- (IBAction)locateTheUser:(UIBarButtonItem *)sender {
    // Use CLLocationManager to get current coordinate and setCenterCoordinate to pan the map view.
    CLLocation *location = [ self.locationManager location ];
    CLLocationCoordinate2D coord;
    coord.latitude = location.coordinate.latitude;
    coord.longitude = location.coordinate.longitude;
    [ self.mapView setCenterCoordinate:coord animated:YES ];
}
@end
