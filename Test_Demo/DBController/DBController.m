//
//  DBController.m
//  Test_Demo
//
//  Created by Aparna Chauhan on 17/02/18.
//  Copyright © 2018 Megha Sahal. All rights reserved.
//

#import "DBController.h"
#import "TrackingInfo.h"

@implementation DBController

+ (instancetype)sharedInstance
{
    static DBController *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[DBController alloc] init];
    });
    return sharedInstance;
}

- (void) initDatabase
{
    
    NSString *docsDir;
    NSArray *dirPaths;
    
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = [dirPaths objectAtIndex:0];
    
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent:@"tracking.db"]];
    
    NSFileManager *filemgr = [NSFileManager defaultManager];
    
    // create the database table
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        [self createTable];
    }
    
}

-(void) createTable
{
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &mySqliteDB) == SQLITE_OK)
    {
        char *errMsg;
        NSString *sql_stmt = @"CREATE TABLE IF NOT EXISTS TRACKING ( id INTEGER PRIMARY KEY AUTOINCREMENT,time TEXT,latitute TEXT,longitude TEXT,currentTimeInterval TEXT,nextTimeInterval TEXT)";
        
        if (sqlite3_exec(mySqliteDB, [sql_stmt UTF8String], NULL, NULL, &errMsg) != SQLITE_OK)
        {
            NSLog(@"Failed to create table");
        }
        else
        {
            NSLog(@"Employees table created successfully");
        }
        
        sqlite3_close(mySqliteDB);
        
    } else {
        NSLog(@"Failed to open/create database");
    }
}

//save our data
- (BOOL) saveTrackingDetail:(TrackingInfo *)info
{
    BOOL success = false;
    sqlite3_stmt *statement = NULL;
    const char *dbpath = [databasePath UTF8String];
    
    if (sqlite3_open(dbpath, &mySqliteDB) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:
                               @"INSERT INTO TRACKING (time, latitute, longitude, currentTimeInterval, nextTimeInterval) VALUES (\"%@\", \"%@\", \"%@\", \"%@\", \"%@\")",
                               info.time,
                               info.latitude,
                               info.longitude,
                               info.currentTimeInterval,
                               info.nextTimeInterval];
        
        NSLog(@"value:%@",insertSQL);
        
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(mySqliteDB, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            success = true;
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(mySqliteDB);
        
    }
    
    return success;
}


@end
