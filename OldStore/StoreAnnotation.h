//
//  StoreAnnotation.h
//  OldStore
//
//  Created by KICKERCHEN on 13/6/10.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface StoreAnnotation : NSObject <MKAnnotation> {
    CLLocationCoordinate2D coordinate;
    NSString *title;
    NSString *subtitle;
}

@property (nonatomic, assign) CLLocationCoordinate2D coordinate;
@property (nonatomic) NSInteger storeID;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *subtitle;

- (id)initWithLocation: (CLLocationCoordinate2D)coord;

@end
