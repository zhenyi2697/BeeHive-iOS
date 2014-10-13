//
//  BHSetArrivalTimeViewController.m
//  BeeHive
//
//  Created by Louis CHEN on 7/8/14.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHSetArrivalTimeViewController.h"
#import "BHSetItineraryViewController.h"
#import "BHLocation.h"


@interface BHSetArrivalTimeViewController ()
@property (nonatomic, strong) NSDate *dateTime;

@end

@implementation BHSetArrivalTimeViewController
@synthesize location = _location;

- (IBAction)datePicker:(UIDatePicker *)sender {
    _dateTime = sender.date;
}

- (IBAction)dateSlider:(UISlider *)sender {
//    _dateTime = sender.value;
}

- (IBAction)setNotification:(UIButton *)sender {
    UILocalNotification *localNotification = [[UILocalNotification alloc] init];
    localNotification.fireDate = _dateTime;
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"hh:mm"];
    localNotification.alertBody = [NSString stringWithFormat:@"It's %@, time to go to %@!", [dateFormatter stringFromDate:_dateTime], [_location name]];
    localNotification.soundName = UILocalNotificationDefaultSoundName;
    localNotification.applicationIconBadgeNumber = 1;
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
}


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if ([[segue identifier] isEqualToString:@"goItinerarySegue"]) {
        BHSetItineraryViewController *setItineraryViewControler = [segue destinationViewController];
        setItineraryViewControler.toLocation = self.location;
        
    }
}


@end
