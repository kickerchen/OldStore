//
//  AppDelegate.m
//  OldStore
//
//  Created by KICKERCHEN on 13/5/29.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "OldStoreAppDelegate.h"
#import "DatabaseManager.h"
#import "MapViewController.h"
#import "FeatureViewController.h"
#import "Common.h"

@interface OldStoreAppDelegate()

@property MapViewController *mapViewController;
@property FeatureViewController *featureViewController;

@end

@implementation OldStoreAppDelegate

@synthesize mapViewController, featureViewController, databaseManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    // Splash animation effect.
    UIImageView *splash;
    
    if ( IS_IPHONE_5 ) {
        splash = [ [UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 568) ];
        splash.image = [UIImage imageNamed:@"Default-568h@2x.png"];
    } else if ( IS_RETINA ) {
        splash = [ [UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) ];
        splash.image = [UIImage imageNamed:@"Default@2x.png"];
    } else {
        splash = [ [UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) ];
        splash.image = [UIImage imageNamed:@"Default.png"];
    }    
    
    [ self.window.rootViewController.view addSubview: splash ];
    [ self.window.rootViewController.view bringSubviewToFront: splash ];
    
    [ UIView beginAnimations: @"FadeOut" context: nil ];
    [ UIView setAnimationDuration: 2.0 ];
    [ UIView setAnimationDelegate: splash ];
    [ UIView setAnimationDidStopSelector: @selector(removeFromSuperview) ];
    splash.alpha = 0.0;
    [ UIView commitAnimations ];
    
    // Show initially hidden status bar.
    [ [ UIApplication sharedApplication ] setStatusBarHidden: NO withAnimation: UIStatusBarAnimationFade ];
    [ [ UIApplication sharedApplication ] setStatusBarStyle: UIStatusBarStyleBlackTranslucent animated: YES ];
    
    // Initialize SQLite database.
    self.databaseManager = [[DatabaseManager alloc] initWithFileName:@"OldStore" ofType:@"sql"];
    
    // Get root view controller.
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    tabBarController.delegate = self;

    /////////////////////////////////////////
    // Setup map view controller.
    //
    UINavigationController *mapNavController = [ tabBarController.viewControllers objectAtIndex: 0 ];
    self.mapViewController = [ mapNavController.viewControllers objectAtIndex: 0 ];
    self.mapViewController.databaseManager = self.databaseManager;
    
    // Set nav bar title and background.
    [ mapNavController.navigationBar setTintColor: [ UIColor redColor ] ];
    [ mapNavController.navigationBar setBackgroundImage: [ UIImage imageNamed: @"navbar.jpg" ] forBarMetrics: UIBarMetricsDefault ];
    [ mapNavController.navigationBar.topItem setTitle: NSLocalizedString( @"Nearby", nil ) ];
    
    // Setup location manager with desired accracy and distance filter.
    self.mapViewController.locationManager = [ [CLLocationManager alloc] init ];
    self.mapViewController.locationManager.delegate = mapViewController;
    self.mapViewController.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.mapViewController.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters;
    self.databaseManager.locationManager = self.mapViewController.locationManager;

    [ self.mapViewController.locationManager startUpdatingLocation ];
    
    /////////////////////////////////////////
    // Setup feature view controller.
    //
    UINavigationController *featureNavController = [ tabBarController.viewControllers objectAtIndex: 1 ];
    self.featureViewController = [ featureNavController.viewControllers objectAtIndex: 0 ];
    self.featureViewController.databaseManager = self.databaseManager;
    
    // Set nav bar tint color(for back button), title and background.
    [ featureNavController.navigationBar setTintColor: [ UIColor redColor ] ];
    [ featureNavController.navigationBar setBackgroundImage: [ UIImage imageNamed: @"navbar.jpg" ] forBarMetrics: UIBarMetricsDefault ];
    [ featureNavController.navigationBar.topItem setTitle: NSLocalizedString( @"Featured", nil ) ];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    if ( [ CLLocationManager significantLocationChangeMonitoringAvailable ] ) {
        [ self.mapViewController.locationManager stopUpdatingLocation ];
        [ self.mapViewController.locationManager startMonitoringSignificantLocationChanges ];
    }
	else {
		NSLog(@"Significant location change monitoring is not available.");
	}    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if ( [CLLocationManager significantLocationChangeMonitoringAvailable ] ) {
        [ self.mapViewController.locationManager stopMonitoringSignificantLocationChanges ];
        [ self.mapViewController.locationManager startUpdatingLocation ];
    }
	else {
		NSLog(@"Significant location change monitoring is not available.");
	}
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    
    // For applications that do not support background execution or are linked against iOS 3.x or earlier, this method is always called when the user quits the application. For applications that support background execution, this method is generally not called when the user quits the application because the application simply moves to the background in that case.
}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    // Prevent from turning to the first page if user re-click the same tab.
    return ( viewController == tabBarController.selectedViewController ) ? NO : YES;
}

@end
