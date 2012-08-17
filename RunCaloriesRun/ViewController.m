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
}
- (IBAction)startButtonPressed;
- (IBAction)stopButtonPressed;
@property (weak, nonatomic) IBOutlet UIButton *startButton;

@property (weak, nonatomic) IBOutlet UITextField *weightInput;
@property (weak, nonatomic) IBOutlet UILabel *totalCaloriesOutput;

@property (weak, nonatomic) IBOutlet UILabel *caloriesPerSecondOutput;
@property (strong) CLLocationManager *locationManager;
-(void)updateLabelsWithCaloriesPerSecond:(double)caloriesPerSecond;
-(double)calculateCaloriesPerSecondWithDistanceInMeter:(double)distanceInMeters andSpeedInMinutes:(double)speedInMinutes andAltitudeChange:(double)altitudeChange;
@end

@implementation ViewController 
@synthesize startButton = _startButton;
@synthesize weightInput = _weightInput;
@synthesize totalCaloriesOutput = _totalCaloriesOutput;
@synthesize caloriesPerSecondOutput = _caloriesPerSecondOutput;
- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.locationManager = [CLLocationManager new];
    [self.locationManager setDelegate:self];
    [self.locationManager setDesiredAccuracy:kCLLocationAccuracyBest];
    [self.weightInput setDelegate:self];
}


- (void)viewDidUnload
{
    [self setCaloriesPerSecondOutput:nil];
    [self setTotalCaloriesOutput:nil];
    [self setWeightInput:nil];
    [self setStartButton:nil];
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
}

- (void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation {

    double distanceInMeters = [newLocation distanceFromLocation:oldLocation];
    double speedInMinutes = (newLocation.speed)*60;
    double altitudeChange = fabs(newLocation.altitude - oldLocation.altitude);
    
    double caloriesPerSecond = [self calculateCaloriesPerSecondWithDistanceInMeter:distanceInMeters andSpeedInMinutes:speedInMinutes andAltitudeChange:altitudeChange];
    
    _totalCalories += caloriesPerSecond;
    
    [self updateLabelsWithCaloriesPerSecond:caloriesPerSecond];
}

-(double)calculateCaloriesPerSecondWithDistanceInMeter:(double)distanceInMeters andSpeedInMinutes:(double)speedInMinutes andAltitudeChange:(double)altitudeChange
{
    if (!distanceInMeters) {
     return 0.0;
    }
     
     
    double grade = (altitudeChange / distanceInMeters )*100;

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
    
    if (_weight > 0) {
        [self.locationManager startUpdatingLocation];
        [self updateLabelsWithCaloriesPerSecond:0.0];
    }
}

- (IBAction)stopButtonPressed {
    [self.locationManager stopUpdatingLocation];
}
@end
