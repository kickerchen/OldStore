//
//  Common.h
//  OldStore
//
//  Created by KICKERCHEN on 13/6/14.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#define WIDTH_IPAD 1024
#define WIDTH_IPHONE_5 568
#define WIDTH_IPHONE_4 480
#define HEIGHT_IPAD 768
#define HEIGHT_IPHONE 320

#define IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

//width is height!
#define IS_IPHONE_5 ( [ [ UIScreen mainScreen ] bounds ].size.height == WIDTH_IPHONE_5 )
#define IS_IPHONE_4 ( [ [ UIScreen mainScreen ] bounds ].size.height == WIDTH_IPHONE_4 )

#define IS_RETINA ([[UIScreen mainScreen] scale] == 2.0f)

#define IS_GPS_ON ( [ CLLocationManager locationServicesEnabled ] == YES )

#define RGBA(rgbValue,a) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]

#define IS_IOS_7 ( [[[UIDevice currentDevice] systemVersion] isEqualToString: @"7.0"] == YES )