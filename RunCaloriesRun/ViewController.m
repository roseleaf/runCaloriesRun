//
//  ViewController.m
//  RunCaloriesRun
//
//  Created by Rose CW on 8/16/12.
//  Copyright (c) 2012 Rose CW. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate>
@property (strong) CLLocationManager *locationManager;
@property (strong) NSNumber *weight;
-(double)calculateCaloriesPerSecondWithDistanceInMeter:(double)distanceInMeters andSpeedInMinutes:(double)speedInMinutes andAltitudeChange:(double)altitudeChange;
@end

@implementation ViewController 
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.locationManager startUpdatingLocation];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    double distanceInMeters = [newLocation distanceFromLocation:oldLocation];
    double speedInMinutes = (newLocation.speed)*60;
    double altitudeChange = fabs(newLocation.altitude - oldLocation.altitude);
    
    double caloriesPerSecond = [self calculateCaloriesPerSecondWithDistanceInMeter:distanceInMeters andSpeedInMinutes:speedInMinutes andAltitudeChange:altitudeChange];
    
    NSLog(@"This is it: %f", caloriesPerSecond);
}

-(double)calculateCaloriesPerSecondWithDistanceInMeter:(double)distanceInMeters andSpeedInMinutes:(double)speedInMinutes andAltitudeChange:(double)altitudeChange
{
    if (!distanceInMeters) {
     return 0.0;
    }
     
     
    double grade = (altitudeChange / distanceInMeters )*100;

    double VO2 = 3.5 + (speedInMinutes * 0.2) + (speedInMinutes * grade * 0.9);
    double METS = VO2 / 3.5;
    double caloriesPerSecond = (METS * [self.weight doubleValue])/(60*60);

    return caloriesPerSecond;
}


@end
