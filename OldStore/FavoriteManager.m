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
        // get time stamp
        unsigned unitFlag = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
        NSDateComponents *components = [ [NSCalendar currentCalendar] components: unitFlag fromDate: [NSDate date] ];
        NSString *updateDate = [ NSString stringWithFormat: @"%d-%d-%d %d:%d:%d", [components year], [components month], [components day], [components hour], [components minute], [components second] ];
        // get user default data; if no, create a new dictionary
        NSString *idString = [ NSString stringWithFormat: @"%d", storeID ];
        NSDictionary *userData = [[NSUserDefaults standardUserDefaults] objectForKey: @"favorites"];
        NSMutableDictionary *favorites = (userData) ? [ NSMutableDictionary dictionaryWithDictionary: userData ] : [ NSMutableDictionary dictionary ];
        // set data and store in user default
        [ favorites setObject: @{ @"id": idString, @"like": @YES, @"update": updateDate } forKey: idString ];
        [ [NSUserDefaults standardUserDefaults] setObject: favorites forKey: @"favorites" ];
    }
}

- (void)removeStore:(NSInteger)storeID
{
    if ( [ self isFavorite: storeID ] ) {
        NSString *idString = [ NSString stringWithFormat: @"%d", storeID ];
        NSMutableDictionary *fav = [ NSMutableDictionary dictionaryWithDictionary:[[NSUserDefaults standardUserDefaults] objectForKey: @"favorites"] ];
        [ fav removeObjectForKey: idString ];
        [ [NSUserDefaults standardUserDefaults] setObject: fav forKey: @"favorites" ];
    }
}

- (BOOL)isFavorite:(NSInteger)storeID
{
    NSString *idString = [ NSString stringWithFormat: @"%d", storeID ];
    NSDictionary *favorites = [ [NSUserDefaults standardUserDefaults] objectForKey: @"favorites" ];
    NSDictionary *storeData = [ favorites objectForKey:idString ];
    return ( storeData ) ? (BOOL)[ storeData objectForKey: @"like" ] : NO;
}

- (NSArray *)getFavorites
{
    NSMutableArray *favorites = nil;
    NSDictionary *userData = [ [NSUserDefaults standardUserDefaults]objectForKey:@"favorites" ];
    if (userData) {
        favorites = [NSMutableArray array];
        NSEnumerator *enumerator = [userData objectEnumerator];        
        for (NSDictionary *store in enumerator) {
            [favorites addObject: store];
        }
    }
    return favorites;
}

@end
