//
//  FirstViewController.m
//  OldStore
//
//  Created by KICKERCHEN on 13/5/29.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "MapViewController.h"
#import "StoreAnnotation.h"
#import "DatabaseManager.h"

@interface MapViewController ()

@end

@implementation MapViewController

@synthesize mapView, locationManager, databaseManager;

- (void)viewDidLoad
{
    [super viewDidLoad];

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
        //[ annotation setTitle: name ];
        //[ annotation setSubtitle: (NSString *)[ record valueForKey: @"address" ] ];
        annotation.title = name;
        annotation.subtitle = subtitle;
        
        //[ self.mapView addAnnotation: annotation ];
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

- (void) showStore:(id)sender
{
    // Show store details
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
