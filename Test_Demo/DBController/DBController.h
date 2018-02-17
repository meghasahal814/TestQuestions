//
//  DBController.h
//  Test_Demo
//
//  Created by Aparna Chauhan on 17/02/18.
//  Copyright © 2018 Megha Sahal. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "TrackingInfo.h"

@interface DBController : NSObject
{
    sqlite3 *mySqliteDB;
    NSString *databasePath;
}

+ (instancetype) sharedInstance;
- (void) initDatabase;
- (BOOL) saveTrackingDetail:(TrackingInfo *)info;

@end
