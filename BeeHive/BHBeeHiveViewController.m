//
//  BHBeeHiveViewController.m
//  BeeHive
//
//  Created by Louis CHEN on 6/19/14.
//  Copyright (c) 2014 Louis CHEN All rights reserved.
//

#import "BHBeeHiveViewController.h"
#import "BHListViewController.h"
#import "BHDataController.h"
#import "BHProgressView.h"
#import "BHCheckinListViewController.h"


//SDWebImage Library
#import <SDWebImage/UIImageView+WebCache.h>

@interface BHBeeHiveViewController ()
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (nonatomic) int contributedNumber;
@property (strong, nonatomic) BHProgressView *progressView;
@property (nonatomic) float progression;
@property (weak, nonatomic) IBOutlet UIImageView *animatedCheckinImage;
@property (nonatomic, strong) CLLocation *currentLocation;

@end


@implementation BHBeeHiveViewController
@synthesize locationManager = _locationManager;

- (IBAction)checkinButtonClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:@"checkinSegue" sender:self];
    
}
- (IBAction)navigateToDestination:(UIButton *)sender {
//    CLLocationCoordinate2D coord;
//    coord.longitude = (CLLocationDegrees)[self.toLocation.longitude doubleValue];
//    coord.latitude = (CLLocationDegrees)[self.toLocation.latitude doubleValue];
//    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate: coord addressDictionary: nil];
//    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
//    destination.name = self.toLocation.name;
//    NSArray* items = [[NSArray alloc] initWithObjects: destination, nil];
//    NSDictionary* options = [[NSDictionary alloc] initWithObjectsAndKeys:
//                             MKLaunchOptionsDirectionsModeDriving,
//                             MKLaunchOptionsDirectionsModeKey, nil];
//    [MKMapItem openMapsWithItems: items launchOptions: options];

}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide NavigationBar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Update progressView
    [self prepareProgressionView];
    self.progressView.progress = self.progression;
    
    // Label animation
    [_animatedCheckinImage setAlpha:0.0];
    [UIView animateWithDuration:7.0
                          delay:0.0
                        options:(UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat)
                     animations:^(void) {
                         [_animatedCheckinImage setAlpha:1.0];
                     }
                     completion:nil];
    
    // Stop location services (#### to be moved) 
//    [self stopLocationServices];
}

- (void)viewWillDisappear:(BOOL)animated{
    [_animatedCheckinImage setAlpha:0.0];
}


- (void) prepareProgressionView {
    // Load saved value
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"contributionCounter"];
    self.contributedNumber = (int) [savedValue integerValue];
    
    //=======
    NSString *level = [[BHDataController computeLevelInfo: self.contributedNumber] objectAtIndex: 0];
    NSString *contributionText;
    self.progression = [[[BHDataController computeLevelInfo: self.contributedNumber] objectAtIndex: 1] floatValue];
    //    float progression = 0.4; // default value for tests
    
    if (self.contributedNumber == 0) {
        contributionText = @"You have not yet contributed.";
    } else {
        contributionText = [NSString stringWithFormat:@"%d Points", self.contributedNumber * 10];
    }
    
    self.levelLabel.text = [NSString stringWithFormat:@"%@ - %@", level, contributionText];
}



- (void)viewDidLoad
{
    [super viewDidLoad];

    // Do any additional setup after loading the view.
//    [self prepareProgressionView];
    
    // Progress view - flat, orange, animated
    self.progressView = [[BHProgressView alloc] initWithFrame:CGRectMake(20, 190, self.view.frame.size.width-40, 20)];
    self.progressView.color = [UIColor colorWithRed:247.0f/255.0f green:148.0/255.0f blue:30.0/255 alpha:1.0f];
    self.progressView.flat = @YES;
    self.progressView.showBackgroundInnerShadow = @NO;
    //    progression = (self.contributedNumber - levelBase) / (levelTop - levelBase);
//    self.progressView.progress = self.progression;
    self.progressView.animate = @YES;
    
    [self.view addSubview:self.progressView];
    
    // button color
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    // tab button color
    self.tabBarController.tabBar.tintColor = [UIColor orangeColor];
    // tab bar transparency 
    self.tabBarController.tabBar.translucent=YES;
    // navigation bar transparency
    self.navigationController.navigationBar.translucent = NO;
    
}


#pragma mark - Location services

- (void) startLocationServices {
    // Location manager
    if (self.locationManager == nil) {
        self.locationManager = [[CLLocationManager alloc] init];
    }
    self.locationManager.delegate = self;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
}

- (void) stopLocationServices {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
}

// locationManager didUpdateLocations
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    NSLog(@"haha lat%f - lon%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
}

     
#pragma mark - Navigation
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController]. Pass the selected object to the new view controller.
    // if segue.identifier == truc ...
    // ... such as: if ([[segue identifier] isEqualToString:@"showLocationDetailFromListView"])    BHListViewController *destination = (BHListViewController*) segue.destinationViewController;
    
    BHCheckinListViewController *checkinViewController = [segue destinationViewController];
    checkinViewController.toto = @"Check-in";
    
    // Location manager start scanning
//    [self startLocationServices];
    // map data
//    checkinViewController.currentLocation = self.currentLocation;
//    checkinViewController.locationManager = self.locationManager;
//    [self stopLocationServices];
}

@end
