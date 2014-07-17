//
//  BHCheckinListViewController.m
//  BeeHive
//
//  Created by Louis CHEN on 6/30/14.
//  Copyright (c) 2014 Louis CHEN. All rights reserved.
//

#import "BHCheckinListViewController.h"
#import "BHBuilding.h" // with lat long
#import "BHLocation.h" // with lat long 
#import "BHLocationStat.h"
#import "BHDataController.h"
#import "BHLocationTableViewCell.h"
#import "BHUtils.h"
#import "BHContributionViewController.h"
#import "BHBeeHiveViewController.h"

//RefreshControl Library
#import "ODRefreshControl.h"

//SDWebImage Library
#import <SDWebImage/UIImageView+WebCache.h>

@interface BHCheckinListViewController ()
@property int i;
@end

@implementation BHCheckinListViewController
@synthesize tableView = _tableView;
@synthesize refreshControl = _refreshControl;
//@synthesize locationSearchBar = _locationSearchBar;
@synthesize filteredLocations = _filteredLocations, filteredBuildings = _filteredBuildings;
@synthesize toto; //incoming segue identifier
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;


-(ODRefreshControl *)refreshControl
{
    if (!_refreshControl) {
        _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    }
    return _refreshControl;
}

-(NSMutableArray *)filteredLocations
{
    if (!_filteredLocations) {
        _filteredLocations = [NSMutableArray arrayWithCapacity:0];
    }
    return _filteredLocations;
}

-(NSMutableArray *)filteredBuildings
{
    if (!_filteredBuildings) {
        _filteredBuildings = [NSMutableArray arrayWithCapacity:0];
    }
    return _filteredBuildings;
}

#pragma mark - View

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Unhide NavigationBar
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    
    NSLog(@"*** %@ ***", toto);
    
    //Refresh Control
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
    
}

- (void)viewWillAppear:(BOOL)animated
{
    BHDataController *dataController = [BHDataController sharedDataController];
    [dataController fetchLocationStatForViewController:self];
    
    self.tabBarController.tabBar.translucent = NO;
    
    // Location manager start scanning
    [self startLocationServices];
}

- (void)viewDidAppear
{
    //    [self.tableView reloadData];
}

- (void)viewWillDisappear:(BOOL)animated
{
    self.tabBarController.tabBar.translucent = YES;
    [self stopLocationServices];
    self.i = 0;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
//    NSLog(@"count bd = %i", [self.filteredBuildings count]);
    // Return the number of sections.
    return [self.filteredBuildings count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    BHBuilding *bd = [self.filteredBuildings objectAtIndex:section];
//    NSLog(@"%@", bd.name);
    return bd.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    BHBuilding *bd = [self.filteredBuildings objectAtIndex:section];
//    NSLog(@"count loc = %i", [bd.locations count]);
    return [bd.locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    @try {
    BHLocationTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"checkinCell"];
    
    // Configure the cell here
    BHDataController *dataController = [BHDataController sharedDataController];
    BHBuilding *bd = [self.filteredBuildings objectAtIndex:indexPath.section];
    BHLocation *loc = [bd.locations objectAtIndex:indexPath.row];
    
    BHLocationStat *locStat = [dataController.locationStats objectForKey:loc.locId];
    cell.textLabel.text = loc.name;
    
    // Determine label color
    cell.textLabel.textColor = [BHUtils titleColorForLocationStat:locStat];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Oc: %@%% of %@ Line: %@ Go: %@", locStat.occupancyPercent, locStat.maxCapacity, locStat.queue, locStat.bestTime];
//    NSLog(@"cell >> %@", locStat.queue);
    
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    
    // Using SDWebImage to load image
    [cell.imageView setImageWithURL:[NSURL URLWithString:loc.photoUrl]
                   placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
    return cell;
//    }@catch(NSException * e){
//        NSLog(@"Exception %@",[e callStackSymbols]);
//    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to candy detail
    [self performSegueWithIdentifier:@"contributionViewSegue" sender:tableView];
    
}

#pragma mark - Refresh

// Refresh when dropping down
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    BHDataController *dataController = [BHDataController sharedDataController];
    
    if (dataController.connectionLost) {
        //Fetch building List for mapView
        [dataController fetchBuildingsForViewController:self];
    }
    
    //Fetch locations statistic for mapView
    [dataController fetchLocationStatForViewController:self];

//    NSLog(@"refresh lat%f - lon%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    // filter
    [self filterByLocationsNearTo:self.currentLocation];
}

- (IBAction)refreshList:(id)sender {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

    BHDataController *dataController = [BHDataController sharedDataController];
    
    if (dataController.connectionLost) {
        //Fetch building List
        [dataController fetchBuildingsForViewController:self];
    }
    
    //Fetch locations statistic
    [dataController fetchLocationStatForViewController:self];
    
//    NSLog(@"refresh lat%f - lon%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    // filter
    [self filterByLocationsNearTo:self.currentLocation];
}


#pragma mark - Content Filtering

- (void) filterByLocationsNearTo: (CLLocation *)location {
    NSLog(@"Start filtering");
    // Update the filtered array based on the search text and scope. Remove all objects from the filtered search array
    [self.filteredLocations removeAllObjects];
    [self.filteredBuildings removeAllObjects];
    
    // get buildingList
    BHDataController *dataController = [BHDataController sharedDataController];
    NSArray *buildingList = dataController.buildingList;
    
    for (BHBuilding *bud in buildingList) {
        BOOL addBuilding = NO;
        // copy the reference building objet, prepare it to the add or not add trial
        BHBuilding *newBud = [[BHBuilding alloc] init];
        newBud.name = bud.name;
        newBud.description = bud.description;
        
        // find matching locations, here, no use for a case to add entire buildings
        NSMutableArray *newLocList = [[NSMutableArray alloc] init];
        for (BHLocation *loc in bud.locations) {
            if ([self isMyLocation:location CloseEnoughtoLat:[loc.latitude doubleValue] Long:[loc.longitude doubleValue]]) { // if location is close enough
                [newLocList addObject:loc]; // then add the location
                addBuilding = YES; // and always add the parent building of an eligible location: answer to trial = YES
            }
        }

        if (addBuilding) { // here we populate filteredBuildings with eligible data
            newBud.locations = newLocList;
            [self.filteredBuildings addObject:newBud];
        }
        
    }
    [[self tableView] reloadData];
//    NSLog(@"filt bd : %@", self.filteredBuildings);
}

- (BOOL) isMyLocation:(CLLocation *)locA CloseEnoughtoLat: (double) latB Long:(double) lonB {
    CLLocation *locB = [[CLLocation alloc] initWithLatitude:latB longitude:lonB];
    CLLocationDistance distance = [locA distanceFromLocation:locB];
    
    if (distance < 200) { // filtering precision
        NSLog(@"YES - dist %f ", distance);
        return YES;
    } else {
        return NO;
    }
    // stop updating location
    [self.locationManager stopUpdatingLocation];
}


#pragma mark - Location manager

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

//locationManager didUpdateLocations
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    self.i++;
    NSLog(@"lat%f - lon%f, %i", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude, self.i);
    if (self.i > 3) {
        [self filterByLocationsNearTo:self.currentLocation]; // filterByLocationsNearTo current location
    }

}


#pragma mark - Segue navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
//    @try{
    if ([[segue identifier] isEqualToString:@"contributionViewSegue"]) {
        
        BHContributionViewController *contribViewController = [segue destinationViewController];
        BHDataController *dataController = [BHDataController sharedDataController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        BHBuilding *bd = [self.filteredBuildings objectAtIndex:indexPath.section];
        
        // Set values to pass
        contribViewController.location = [bd.locations objectAtIndex:indexPath.row];
        contribViewController.locationStat = [dataController.locationStats objectForKey:contribViewController.location.locId];
        
        NSLog(@"pass >> %@", contribViewController.locationStat.queue);
        
        /*
         //        UINavigationController *navigationController = [segue destinationViewController];
         BHContributionViewController *contribViewController = [segue destinationViewController]; // [[navigationController viewControllers] objectAtIndex:0];
         contribViewController.location = self.location;
         contribViewController.locationStat = self.locationStat;
         */
    }
//    }@catch(NSException * e){
//        NSLog(@"Exception %@",[e callStackSymbols]);
//    }
}


@end
