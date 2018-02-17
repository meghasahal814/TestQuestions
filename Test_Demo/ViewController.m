//
//  ViewController.m
//  Test_Demo
//
//  Created by Aparna Chauhan on 17/02/18.
//  Copyright © 2018 Megha Sahal. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TrackingInfo.h"
#import "DBController.h"

@interface ViewController ()<CLLocationManagerDelegate>
{
    CLLocationManager *locationManager;
    CLLocationCoordinate2D coordinates;
    double currentSpeed,previousSpeed;
    NSTimer *captureIntervalTimer;
    NSMutableArray *ary_IntervalRange;
    int currentInterval, speedRange;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
        [locationManager requestWhenInUseAuthorization];
    
    [locationManager startUpdatingLocation];
    
    ary_IntervalRange = [[NSMutableArray alloc]initWithObjects:@"30",@"60",@"120",@"300", nil];
    previousSpeed = 0.0;
    currentInterval = -1;
    speedRange = 0;
    
}

- (IBAction)trackingSwitch:(UISwitch *)sender
{
    if (sender.on)
    {
        if (captureIntervalTimer != nil)
        {
            [captureIntervalTimer invalidate];
            captureIntervalTimer = nil;
        }
        
        [locationManager startUpdatingLocation];
    }
    else
    {
        [locationManager stopUpdatingLocation];
    }
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = locations.lastObject;
    double speed = location.speed*3.6;
    coordinates = location.coordinate;
    [self callTimer:speed];
}

-(void)callTimer:(double)speedValue
{
    BOOL isIntervalChange = NO;
    
    if (speedValue>=80 && speedRange != 80)
    {
        currentInterval = 0;
        
        speedRange = 80;
        isIntervalChange = YES;
    }
    else if (speedValue<80 && speedValue>=60 && speedRange != 60)
    {
        if (speedRange>60 && currentInterval<[ary_IntervalRange count])
        {
            currentInterval = currentInterval+1;
        }
        else
        {
            currentInterval = 1;
        }
        speedRange = 60;
        isIntervalChange = YES;
    }
    else if (speedValue<60 && speedValue>=30 && speedRange != 30)
    {
        if (speedRange>30 && currentInterval<[ary_IntervalRange count])
        {
            currentInterval = currentInterval+1;
        }
        else
        {
            currentInterval = 2;
        }
        speedRange = 30;
        isIntervalChange = YES;
    }
    else if (speedValue<30 && speedRange != 29)
    {
        speedRange = 29;
        isIntervalChange = YES;
        currentInterval = 3;
    }
    
    if (isIntervalChange)
    {
        if (captureIntervalTimer != nil)
        {
            [captureIntervalTimer invalidate];
            captureIntervalTimer = nil;
        }
        
        int interval = [[ary_IntervalRange objectAtIndex:currentInterval] intValue];
        
        captureIntervalTimer = [NSTimer scheduledTimerWithTimeInterval:interval repeats:YES block:^(NSTimer * _Nonnull timer)
                                {
                                    [self captureLocation:timer.timeInterval];
                                }];
    }
}

-(void)captureLocation:(int)intervelValue
{
    TrackingInfo *obj = [[TrackingInfo alloc]init];
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    formatter.dateFormat = @"dd/MM/yyyy-HH:mm:ss";
    NSString *str_Date = [formatter stringFromDate:[NSDate date]];
    obj.time = str_Date;
    obj.latitude = [NSString stringWithFormat:@"%.2f",coordinates.latitude];
    obj.longitude = [NSString stringWithFormat:@"%.2f",coordinates.longitude];
    obj.currentTimeInterval = [NSString stringWithFormat:@"%d",intervelValue];
    obj.nextTimeInterval = [NSString stringWithFormat:@"%@",[ary_IntervalRange objectAtIndex:currentInterval]];
    
    [[DBController sharedInstance] initDatabase];
    
    if ([[DBController sharedInstance]saveTrackingDetail:obj])
    {
        NSLog(@"Saved in db");
    }
   
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath = [documentsDirectory stringByAppendingPathComponent:@"TrackedLocation"];
    
    NSError *error;
    NSString *str_Location = [NSString stringWithFormat:@"Latitude:%f Longitude:%f",coordinates.latitude,coordinates.longitude];
    
    BOOL status = [str_Location writeToFile:filePath atomically:YES encoding:NSUTF8StringEncoding error:&error];
    
    if (status)
    {
        NSLog(@"saved as file");
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
