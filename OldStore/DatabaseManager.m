//
//  DatabaseManager.m
//  OldStore
//
//  Created by KICKERCHEN on 13/5/31.
//  Copyright (c) 2013年 KICKERCHEN. All rights reserved.
//

#import <sqlite3.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "DatabaseManager.h"

@interface DatabaseManager()
@property (nonatomic) sqlite3 *database;
@end

@implementation DatabaseManager

@synthesize databaseFilePath, locationManager;

#pragma mark -
#pragma mark Instance methods for CRUD.

- (id)initWithFileName:(NSString *)fileName ofType:(NSString *)typeName {
    
    if (self = [super init]) {
        // Check if database file exists. If not, copy from project bundle.
        NSString *libraryPath = [NSSearchPathForDirectoriesInDomains( NSLibraryDirectory, NSUserDomainMask, YES ) lastObject];
        NSString *filePath = [[fileName stringByAppendingString:@"." ] stringByAppendingString:typeName];
        NSString *targetPath = [libraryPath stringByAppendingPathComponent:filePath]; // Target path on device.
    
        if ( ![[NSFileManager defaultManager] fileExistsAtPath:targetPath] ) {
            NSString *sourcePath = [[NSBundle mainBundle] pathForResource:fileName ofType:typeName]; // Bundle path.
            NSError *error = nil;
        
            if ( ![[NSFileManager defaultManager] copyItemAtPath: sourcePath toPath: targetPath error: &error] ) {
                NSLog(@"[OldStore.sql] Copy from bundle error: %@", error);
            }
        }
        
        self.databaseFilePath = targetPath;
    }
    return self;
}

- (void)openDB {
    sqlite3 *dbConnection = nil;
    int iRet = sqlite3_open([self.databaseFilePath UTF8String], &dbConnection);
    if ( iRet != SQLITE_OK ) {
        NSLog( @"[SQLITE] Unable to open database! sqlite3_open() returned: %d", iRet );
    } else {
        _database = dbConnection;
    }
}

- (void)closeDB {
    if ( _database != nil ) {
        int iRet = sqlite3_close(_database);        
        if ( iRet != SQLITE_OK ) 
            NSLog( @"[SQLITE] Unable to close database! sqlite3_close() returned: %d", iRet );
    }
}

#pragma mark -
#pragma mark SQL Methods

- (NSArray *)sendSQL:(NSString *)sqlQuery
{
    NSMutableArray *results = nil;
    sqlite3_stmt *statment = nil;
    
    [self openDB];
    
    int ret = sqlite3_prepare_v2( _database, [ sqlQuery UTF8String ], -1, &statment, NULL );
    if ( ret != SQLITE_OK ) {
        NSLog( @"[SQLITE][sendSQL Sql query error returned: %d.\n]", ret );
    } else {
        results = [ [ NSMutableArray alloc ] init ];
        while ( sqlite3_step( statment ) == SQLITE_ROW ) {
            NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
            int count = sqlite3_column_count( statment );
            for ( int i = 0; i < count; ++i ) {
                int type = sqlite3_column_type( statment, i );
                id column = nil;
                switch ( type ) {
                    case SQLITE_INTEGER: // 1
                        column = [ NSNumber numberWithInt: sqlite3_column_int( statment, i ) ];
                        break;

                    case SQLITE_FLOAT:  // 2
                        column = [ NSNumber numberWithDouble: sqlite3_column_double( statment, i ) ];
                        break;
                        
                    case SQLITE_TEXT: // 3
                        column = [ NSString stringWithCString: (char *)sqlite3_column_text( statment, i ) encoding:NSUTF8StringEncoding ];
                        break;
                        
                    case SQLITE_BLOB: // 4
                        column = [ NSData dataWithBytes: sqlite3_column_blob( statment, i ) length: sqlite3_column_bytes( statment, i ) ];                        
                        break;
                        
                    case SQLITE_NULL: // 5
                        column = [ NSNull null ];
                        break;
                        
                    default:
                        NSLog( @"[SQLITE][sendSQL] Unknown data type.\n" );
                        break;
                }
                if ( column != nil )
                    [ record setObject: column forKey: [NSString stringWithCString: sqlite3_column_name( statment, i ) encoding: NSUTF8StringEncoding] ];
            }
            [ results addObject: record ];
        }
    }
    
    if ( statment )
        sqlite3_finalize( statment );
        
    [self closeDB];
    return results;
}

- (NSArray *)getCity {
    NSMutableArray *cities = nil;
    sqlite3_stmt *statement = nil;
    NSString *query = [ NSString stringWithFormat:@"SELECT * FROM cities" ];
    
    [self openDB];
    
    if ( sqlite3_prepare_v2( _database, [ query UTF8String ], -1, &statement, NULL ) != SQLITE_OK ) {
        NSLog( @"[SQLITE][getCity] Sql query error returned" );
    } else {        
        cities = [NSMutableArray array];
        while ( sqlite3_step( statement ) == SQLITE_ROW ) {                      
            NSNumber *cityId = [ NSNumber numberWithInt: sqlite3_column_int( statement, 0 ) ];
            NSString *cityName = [ NSString stringWithCString: (char *)sqlite3_column_text( statement, 1 ) encoding: NSUTF8StringEncoding ];
            [ cities addObject: @{ @"id": cityId, @"name": cityName } ];
        }        
    }
    
    if ( statement )
        sqlite3_finalize( statement );

    [self closeDB];    
    return cities; // output: [ { id: city1_id, name: city1_name}, {id: city2_id, name: city2_name}, ... ]
}

- (NSArray *)getRegionByCityId: (NSInteger)cityId
{
    
    [self openDB];
    NSMutableArray *regions = nil;
    
    // Query 1: query region id by city id(input).
    sqlite3_stmt *statement = nil;    
    NSString *queryRegionId = [ NSString stringWithFormat:@"SELECT store_geotags.geotag_id FROM stores INNER JOIN store_geotags ON stores.city_id=%d WHERE stores.id=store_geotags.store_id GROUP BY store_geotags.geotag_id", cityId ];
    
    if ( sqlite3_prepare_v2( _database, [ queryRegionId UTF8String ], -1, &statement, NULL ) != SQLITE_OK ) {
        NSLog( @"[SQLITE][getCity] Sql query 1 returned error" );
    } else {
        regions = [NSMutableArray array];
        while ( sqlite3_step( statement ) == SQLITE_ROW ) {
            
            // Query 2: query region name by region id.
            NSString *regionName;
            NSNumber *regionId = [ NSNumber numberWithInt: sqlite3_column_int( statement, 0 ) ];
            sqlite3_stmt *statement2 = nil;
            NSString *queryRegionName = [NSString stringWithFormat: @"SELECT id, name FROM geotags WHERE id=%@", regionId];
            if ( sqlite3_prepare_v2( _database, [ queryRegionName UTF8String ], -1, &statement2, NULL ) != SQLITE_OK ) {
                NSLog( @"[SQLITE][getRegionByCityId] Sql query 2 returned error" );
            } else {
                if ( sqlite3_step( statement2 ) == SQLITE_ROW )
                    regionName = [ NSString stringWithCString: (char *)sqlite3_column_text( statement2, 1 ) encoding:NSUTF8StringEncoding ];
            }
            
            [ regions addObject: @{ @"id": regionId, @"name": regionName } ];
            if ( statement2 ) sqlite3_finalize( statement2 );
        }
    }
    
    if ( statement ) sqlite3_finalize( statement );
    [self closeDB];
    return regions; // // output: [ { id: region1_id, name: region1_name }, { id: region2_id, name: region2_name }, ... ]
}

- (NSArray *)getShopByCityId: (NSInteger)cityId
{
    [self openDB];
    NSMutableArray *shops = nil;
    NSString *query;
    CLLocation *currentPosition = [ locationManager location ];
    
    if ( currentPosition != nil ) {
        query = [ NSString stringWithFormat: @"SELECT id, name, address, ( 110.54*110.54*(lat-%f)*(lat-%f) + 101.69588*101.69588*(lng-%f)*(lng-%f) ) AS distance FROM stores WHERE city_id=%d ORDER BY distance", currentPosition.coordinate.latitude, currentPosition.coordinate.latitude, currentPosition.coordinate.longitude, currentPosition.coordinate.longitude, cityId ];
    } else {
        query = [ NSString stringWithFormat: @"SELECT id, name, address FROM stores WHERE city_id=%d ORDER BY id", cityId ];
    }
    
    sqlite3_stmt *statement = nil;
    int returnValue = sqlite3_prepare_v2( _database, [ query UTF8String], -1, &statement, NULL );
    if ( returnValue != SQLITE_OK ) {
        NSLog( @"[SQLITE][getShopByCityId] Sql query returned error");
    } else {
        shops = [[NSMutableArray alloc] init];
        while ( sqlite3_step( statement ) == SQLITE_ROW ) {
            NSMutableDictionary *record = [[NSMutableDictionary alloc] init];            
            NSNumber *shopId = [ NSNumber numberWithInt: sqlite3_column_int( statement, 0 ) ];
            NSString *shopName = [ NSString stringWithCString: (char *)sqlite3_column_text( statement, 1 ) encoding:NSUTF8StringEncoding ];
            NSString *shopAddress = [ NSString stringWithCString: (char *)sqlite3_column_text( statement, 2 ) encoding:NSUTF8StringEncoding ];
            [ record setObject: shopId forKey: @"id" ];
            [ record setObject: shopName forKey: @"name" ];
            [ record setObject: shopAddress forKey: @"address" ];
            
            if ( currentPosition != nil ) {
                NSAssert( sqlite3_column_type( statement, 3 ) == SQLITE_FLOAT, @"[getShopByCityId] Column type shall be float" );
                NSNumber *shopDistance = [ NSNumber numberWithDouble: sqrt(sqlite3_column_double( statement, 3 )) ];
                [ record setObject: shopDistance forKey: @"distance" ];
            }

            [ shops addObject: record ];
        }
    }
    
    if ( statement != nil ) sqlite3_finalize( statement );    
    [self closeDB];
    return shops;
}

- (NSArray *)getShopByGeotag: (NSInteger)geoTagId
{
    [self openDB];
    NSMutableArray *shops = nil;
    NSString *query;
    CLLocation *currentPosition = [ locationManager location ];
    
    if ( currentPosition != nil ) {
        query = [ NSString stringWithFormat: @"SELECT store_id, name, address, ( 110.54*110.54*(lat-%f)*(lat-%f) + 101.69588*101.69588*(lng-%f)*(lng-%f) ) AS distance FROM stores INNER JOIN store_geotags ON store_geotags.geotag_id=%d WHERE stores.id=store_geotags.store_id ORDER BY distance", currentPosition.coordinate.latitude, currentPosition.coordinate.latitude, currentPosition.coordinate.longitude, currentPosition.coordinate.longitude, geoTagId ];
    } else {
        query = [ NSString stringWithFormat: @"SELECT store_id, name, address FROM stores INNER JOIN store_geotags ON store_geotags.geotag_id=%d WHERE stores.id=store_geotags.store_id ORDER BY store_id", geoTagId ];
    }
    
    sqlite3_stmt *statement = nil;
    if ( sqlite3_prepare_v2( _database, [ query UTF8String], -1, &statement, NULL ) != SQLITE_OK ) {
        NSLog( @"[SQLITE][getShopByGeotag] Sql query returned error");
    } else {
        shops = [[NSMutableArray alloc] init];
        while ( sqlite3_step( statement ) == SQLITE_ROW ) {
            NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
            NSNumber *shopId = [ NSNumber numberWithInt: sqlite3_column_int( statement, 0 ) ];
            NSString *shopName = [ NSString stringWithCString: (char *)sqlite3_column_text( statement, 1 ) encoding:NSUTF8StringEncoding ];

            NSString *shopAddress = [ NSString stringWithCString: (char *)sqlite3_column_text( statement, 2 ) encoding:NSUTF8StringEncoding ];
            [ record setObject: shopId forKey: @"id" ];
            [ record setObject: shopName forKey: @"name" ];
            [ record setObject: shopAddress forKey: @"address" ];
            
            if ( currentPosition != nil ) {
                NSAssert( sqlite3_column_type( statement, 3 ) == SQLITE_FLOAT, @"[getShopByGeotag] Column type shall be float" );
                NSNumber *shopDistance = [ NSNumber numberWithDouble: sqrt(sqlite3_column_double( statement, 3 )) ];
                [ record setObject: shopDistance forKey: @"distance" ];
            }
            
            [ shops addObject: record ];
        }
    }
    
    if ( statement != nil ) sqlite3_finalize( statement );
    [self closeDB];
    return shops;
}

- (NSArray *)getShopByShopIds: (NSArray *)ids
{
    [self openDB];
    NSMutableArray *shops = nil;
    CLLocation *currentPosition = [ locationManager location ];    
    int count = [ids count];
    
    if ( count > 0 ) {
        NSString *sqlQuery = nil;
        if ( currentPosition != nil ) {
            sqlQuery = [ NSString stringWithFormat:@"SELECT id, name, address, ( 110.54*110.54*(lat-%f)*(lat-%f) + 101.69588*101.69588*(lng-%f)*(lng-%f) ) AS distance FROM stores WHERE id = %@", currentPosition.coordinate.latitude, currentPosition.coordinate.latitude, currentPosition.coordinate.longitude, currentPosition.coordinate.longitude, [ids objectAtIndex:0] ];
            for (int i = 1; i < count; ++i) {
                sqlQuery = [ sqlQuery stringByAppendingString:[NSString stringWithFormat:@" OR id = %@", [ids objectAtIndex:i]] ];
            }
            sqlQuery = [ sqlQuery stringByAppendingString:@" ORDER BY distance" ];
        } else {
            sqlQuery = [ NSString stringWithFormat:@"SELECT id, name, address FROM stores WHERE id = %@", [ids objectAtIndex:0] ];
            for (int i = 1; i < count; ++i) {
                [ sqlQuery stringByAppendingString:[NSString stringWithFormat:@" OR id = %@", [ids objectAtIndex:i]] ];
            }
        }
    
        sqlite3_stmt *statement = nil;
        int returnValue = sqlite3_prepare_v2( _database, [ sqlQuery UTF8String], -1, &statement, NULL );
        if ( returnValue != SQLITE_OK ) {
            NSLog( @"[SQLITE][getShopByShopId] Sql query returned error");
        } else {
            shops = [[NSMutableArray alloc] init];
            while ( sqlite3_step( statement ) == SQLITE_ROW ) {
                NSMutableDictionary *record = [[NSMutableDictionary alloc] init];
                NSNumber *shopId = [ NSNumber numberWithInt: sqlite3_column_int( statement, 0 ) ];
                NSString *shopName = [ NSString stringWithCString: (char *)sqlite3_column_text( statement, 1 ) encoding:NSUTF8StringEncoding ];
                NSString *shopAddress = [ NSString stringWithCString: (char *)sqlite3_column_text( statement, 2 ) encoding:NSUTF8StringEncoding ];
                [ record setObject: shopId forKey: @"id" ];
                [ record setObject: shopName forKey: @"name" ];
                [ record setObject: shopAddress forKey: @"address" ];
            
                if ( currentPosition != nil ) {
                    NSNumber *shopDistance = [ NSNumber numberWithDouble: sqrt(sqlite3_column_double( statement, 3 )) ];
                    [ record setObject: shopDistance forKey: @"distance" ];
                }
            
                [ shops addObject: record ];
            }
        }
    
        if ( statement != nil ) sqlite3_finalize( statement );
    }
    
    [self closeDB];
    return shops;
}

@end
