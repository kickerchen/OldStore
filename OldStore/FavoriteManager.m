//
//  FavoriteManager.m
//  OldStore
//
//  Created by KICKERCHEN on 13/6/22.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import "FavoriteManager.h"

@implementation FavoriteManager

- (void)addStore:(NSInteger)storeID
{
    if ( ![ self isFavorite: storeID ] ) {
        
        unsigned unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [ [NSCalendar currentCalendar] components: unitFlag fromDate: [NSDate date] ];
        NSString *updateDate = [ NSString stringWithFormat: @"%d-%d-%d %d:%d:%d", [components year], [components month], [components day], [components hour], [components minute], [components second] ];
        
        NSString *idString = [ NSString stringWithFormat: @"%d", storeID ];
        [ [NSUserDefaults standardUserDefaults] setObject: @{ @"id": idString,
                                                              @"like": @YES,
                                                              @"update": updateDate } forKey: idString ];
    }
}

- (void)removeStore:(NSInteger)storeID
{
    if ( [ self isFavorite: storeID ] ) {
        NSString *idString = [ NSString stringWithFormat: @"%d", storeID ];
        [ [NSUserDefaults standardUserDefaults] removeObjectForKey: idString ];
    }
}

- (BOOL)isFavorite:(NSInteger)storeID
{
    NSString *idString = [ NSString stringWithFormat: @"%d", storeID ];
    NSDictionary *userData = [ [NSUserDefaults standardUserDefaults] objectForKey: idString ];
    return ( userData ) ? (BOOL)[ userData objectForKey: @"like" ] : NO;
}

@end
