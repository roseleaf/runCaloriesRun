//
//  ViewController.m
//  RunCaloriesRun
//
//  Created by Rose CW on 8/16/12.
//  Copyright (c) 2012 Rose CW. All rights reserved.
//

#import "ViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface ViewController () <CLLocationManagerDelegate, UITextFieldDelegate>
{
    double _weight;
    double _totalCalories;
    double _totalDistance;
}
- (IBAction)startButtonPressed;
- (IBAction)stopButtonPressed;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UITextField *weightInput;
@property (weak, nonatomic) IBOutlet UILabel *totalCaloriesOutput;
@property (weak, nonatomic) IBOutlet UILabel *totalDistanceOutput;

@property (weak, nonatomic) IBOutlet UILabel *caloriesPerSecondOutput;
@property (strong) CLLocationManager *locationManager;
-(void)updateLabelsWithCaloriesPerSecond:(double)caloriesPerSecond;
-(double)calculateCaloriesPerSecondWithDistanceInMeter:(double)distanceInMeters andSpeedInMinutes:(double)speedInMinutes andAltitudeChange:(double)altitudeChange;
@end

@implementation ViewController 
@synthesize startButton = _startButton;
@synthesize weightInput = _weightInput;
@synthesize totalCaloriesOutput = _totalCaloriesOutput;
@synthesize totalDistanceOutput = _totalDistanceOutput;
@synthesize caloriesPerSecondOutput = _caloriesPerSecondOutput;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [CLLocationManager new];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = 10.0;
    self.weightInput.delegate = self;
    
    
}


- (void)viewDidUnload
{
    [self setCaloriesPerSecondOutput:nil];
    [self setTotalCaloriesOutput:nil];
    [self setWeightInput:nil];
    [self setStartButton:nil];
    [self setTotalDistanceOutput:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}

- (void)updateLabelsWithCaloriesPerSecond:(double)caloriesPerSecond {
    
    self.caloriesPerSecondOutput.text = [NSString stringWithFormat:@"%f", caloriesPerSecond];
    self.totalCaloriesOutput.text = [NSString stringWithFormat:@"%f", _totalCalories];
    self.totalDistanceOutput.text = [NSString stringWithFormat:@"%f", _totalDistance];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    double distanceInMeters = [newLocation distanceFromLocation:oldLocation];
    double speedInMinutes = (newLocation.speed)*60;
    double seconds = [newLocation.timestamp timeIntervalSince1970] - [oldLocation.timestamp timeIntervalSince1970];
    if (newLocation.horizontalAccuracy > 5.0) {
        return;
    }
    
    if (speedInMinutes < 0.0) {
        speedInMinutes = 0.0;
    }
    
    if (distanceInMeters < 0.0) {
        distanceInMeters = 0.0;
    }
    
    // We even burn lots of calories going downhill! Not really right.
    double altitudeChange = fabs(newLocation.altitude - oldLocation.altitude);
    
    double caloriesPerSecond = [self calculateCaloriesPerSecondWithDistanceInMeter:distanceInMeters andSpeedInMinutes:speedInMinutes andAltitudeChange:altitudeChange];
    
    _totalCalories += caloriesPerSecond * seconds;
    _totalDistance += distanceInMeters;
    
    [self updateLabelsWithCaloriesPerSecond:caloriesPerSecond];
}

-(double)calculateCaloriesPerSecondWithDistanceInMeter:(double)distanceInMeters andSpeedInMinutes:(double)speedInMinutes andAltitudeChange:(double)altitudeChange
{
    if (!distanceInMeters || !speedInMinutes) {
     return 0.0;
    }
    
     
    double grade = (altitudeChange / distanceInMeters );

    double VO2 = 3.5 + (speedInMinutes * 0.2) + (speedInMinutes * grade * 0.9);
    double METS = VO2 / 3.5;
    double caloriesPerSecond = (METS * _weight)/(60*60);

    return caloriesPerSecond;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self.weightInput resignFirstResponder];
    return NO;
}


- (IBAction)startButtonPressed {
    _weight = [self.weightInput.text doubleValue];
    _totalCalories = 0.0;
    _totalDistance = 0.0;
    
    if (_weight > 0) {
        [self.weightInput resignFirstResponder];
        [self.locationManager startUpdatingLocation];
        [self updateLabelsWithCaloriesPerSecond:0.0];
    }
}

- (IBAction)stopButtonPressed {
    [self.locationManager stopUpdatingLocation];
}
@end
