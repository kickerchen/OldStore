//
//  StoreAnnotation.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/10.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "StoreAnnotation.h"

@implementation StoreAnnotation

@synthesize coordinate, title, subtitle;

#pragma mark -
#pragma mark MKAnnotation delegate

- (id)initWithLocation: (CLLocationCoordinate2D)coord
{
    self = [super init];
    if (self) {
        coordinate = coord;
    }
    
    return self;
}

@end