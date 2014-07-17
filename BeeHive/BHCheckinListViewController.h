//
//  BHCheckinListViewController.h
//  BeeHive
//
//  Created by Louis CHEN on 6/30/14.
//  Copyright (c) 2014 Louis CHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

//RefreshControl Library
#import "ODRefreshControl.h"


@interface BHCheckinListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate>
@property (nonatomic, strong) IBOutlet UITableView *tableView;
@property (nonatomic, strong) ODRefreshControl *refreshControl;
@property (strong, nonatomic) NSMutableArray *filteredLocations;
@property (strong, nonatomic) NSMutableArray *filteredBuildings;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

@property NSString *toto;

@end

