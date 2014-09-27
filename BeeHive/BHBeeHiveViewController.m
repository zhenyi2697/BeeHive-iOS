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
#import "BHLocationTableViewCell.h"
#import "BHLocationStat.h"
#import "BHLocation.h"
#import "BHUtils.h"


//SDWebImage Library
#import <SDWebImage/UIImageView+WebCache.h>

@interface BHBeeHiveViewController ()
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UIImageView *animatedCheckinImage;

@property (nonatomic) int contributedNumber;
@property (strong, nonatomic) BHProgressView *progressView;
@property (nonatomic) float progression;
@property (nonatomic, strong) CLLocation *currentLocation;

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@end


@implementation BHBeeHiveViewController
@synthesize locationManager = _locationManager;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) animateTheCheckinImage {
    [_animatedCheckinImage setAlpha:0.0];
    [UIView animateWithDuration:7.0
                          delay:0.0
                        options:(UIViewAnimationOptionTransitionFlipFromLeft | UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat)
                     animations:^(void) {
                         [_animatedCheckinImage setAlpha:1.0];
                     }
                     completion:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    // Hide NavigationBar
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    // Update progressView
    [self prepareProgressionView];
    self.progressView.progress = self.progression;
    
    // Label animation
    [self animateTheCheckinImage];
    
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
    self.progressView.animate = @YES;
    
    [self.view addSubview:self.progressView];
    
    // configure tableView
    _tableView.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:148.0/255.0f blue:30.0f/255.0f alpha:1.0f]; //orange BeeHive -> UIColor
    
    // button color
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    // tab button color
    self.tabBarController.tabBar.tintColor = [UIColor orangeColor];
    // tab bar transparency 
//    self.tabBarController.tabBar.translucent=YES;
    // navigation bar transparency
//    self.navigationController.navigationBar.translucent = NO;
    
    // register to a notification UIApplicationWillEnterForegroundNotification to force animation to restart
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(animateTheCheckinImage)
                                                 name:UIApplicationWillEnterForegroundNotification object:nil];
    
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return @"Current mission";
    } else {
        return @"Plan B";
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    if (section == 0) {
        return 1;
    } else {
        return 1;
    }}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    BHLocationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"missionCell"];
    
//    // Configure the cell here
//    BHDataController *dataController = [BHDataController sharedDataController];
//    BHLocation *loc = [bd.locations objectAtIndex:indexPath.row];
//    
//    BHLocationStat *locStat = [dataController.locationStats objectForKey:loc.locId];
//    cell.textLabel.text = loc.name;
//    
//    // Determine label color
//    cell.textLabel.textColor = [BHUtils titleColorForLocationStat:locStat];
//    
//    cell.detailTextLabel.text = [NSString stringWithFormat:@"Oc: %@%% of %@ Line: %@ Go: %@", locStat.occupancyPercent, locStat.maxCapacity, locStat.queue, locStat.bestTime];
//    //    NSLog(@"cell >> %@", locStat.queue);
//    
//    cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
//    
//    // Using SDWebImage to load image
//    [cell.imageView setImageWithURL:[NSURL URLWithString:loc.photoUrl]
//                   placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
    
    cell.backgroundColor = [UIColor colorWithRed:247.0f/255.0f green:148.0/255.0f blue:30.0f/255.0f alpha:1.0f]; //orange BeeHive -> UIColor

    return cell;

}

#pragma mark - Row selected

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.section == 0) {
        
    } else {
    
    }
    
    // Deselect
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
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

#pragma mark - IBActions

- (IBAction)checkinButtonClicked:(UIButton *)sender {
    [self performSegueWithIdentifier:@"checkinSegue" sender:self];
    
}


- (IBAction)rateButtonPressed:(UIButton *)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"itms-apps://itunes.apple.com/app/id869869380"]];
    
}

- (IBAction)shareButtonPressed:(UIButton *)sender {
//    // Check if the Facebook app is installed and we can present the share dialog
//    FBLinkShareParams *params = [[FBLinkShareParams alloc] init];
//    params.link = [NSURL URLWithString:@"https://developers.facebook.com/docs/ios/share/"];
//    
//    // If the Facebook app is installed and we can present the share dialog
//    if ([FBDialogs canPresentShareDialogWithParams:params]) {
//        // Present the share dialog
//    } else {
//        // Present the feed dialog
//    }
    
    
    
    
}


- (IBAction)enhanceButtonPressed:(UIButton *)sender {
    // write an email
    
}




@end
