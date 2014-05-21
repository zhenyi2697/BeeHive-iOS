//
//  BHDataController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-07.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHDataController.h"
#import "BHLocationStat.h"
#import "BHLocation.h"
#import "BHBuilding.h"
#import "BHBuildingAnnotation.h"
#import "BHLocationAnnotation.h"
#import "BHMapViewController.h"
#import "BHListViewController.h"
#import "BHDailyStat.h"
#import "BHHourlyStat.h"
#import "BHLocationHourlyStat.h"
#import "BHQueueRequest.h"
#import "BHQueueResponse.h"

#import "TWMessageBarManager.h"

#define BASE_URL @"http://api.letsbeehive.com"

@implementation BHDataController

@synthesize buildingList = _buildingList, locationList = _locationList;
@synthesize buildingStats = _buildingStats, locationStats = _locationStats, locationHourlyStats = _locationHourlyStats;
@synthesize connectionLost = _connectionLost;

+ (id)sharedDataController {
    static BHDataController *sharedDataController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataController = [[self alloc] init];
    });
    return sharedDataController;
}

-(void)fetchBuildingsForViewController:(id)viewController
{
    BOOL isForMapViewController = NO;
    BHMapViewController *mapViewController;
    BHListViewController *listViewController;

    
    if ([viewController isKindOfClass:[BHMapViewController class]]) {
        isForMapViewController = YES;
        mapViewController = (BHMapViewController *)viewController;
        mapViewController.navigationItem.title = @"Loading buildings ...";
    } else if ([viewController isKindOfClass:[BHListViewController class]]) {
        listViewController = (BHListViewController *)viewController;
        listViewController.navigationItem.title = @"Loading buildings ...";
    }
    
    // Building mapping
    RKObjectMapping *mapping = [RKObjectMapping mappingForClass:[BHBuilding class]];
    [mapping addAttributeMappingsFromDictionary:@{
                                                  @"id" : @"bdId",
                                                  @"name": @"name",
                                                  @"description": @"description",
                                                  @"url_photo" : @"photoUrl",
                                                  @"longitude" : @"longitude",
                                                  @"latitude" : @"latitude"
                                                  }];
    
    // Location mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[BHLocation class]];
    [locationMapping addAttributeMappingsFromDictionary:@{
                                                          @"id" : @"locId",
                                                          @"name": @"name",
                                                          @"description": @"description",
                                                          @"url_photo" : @"photoUrl",
                                                          @"longitude" : @"longitude",
                                                          @"latitude" : @"latitude"
                                                          }];
    
    // !IMPORTANT!
    // Should add this line to accept plain text response from server
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    
    // Define the relationship mapping
    [mapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"locations"
                                                                            toKeyPath:@"locations"
                                                                          withMapping:locationMapping]];
    
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:mapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/static", BASE_URL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        // Don't forget to set this
        self.connectionLost = NO;
        
        self.buildingList = [result array];
        
        NSMutableArray *locationList = [[NSMutableArray alloc] init];  // location list for self
        NSMutableArray *annotations;  //building annotations for mapview
        NSMutableArray *locationAnnotations;  //location annotations for mapview
        
        if (isForMapViewController) {
            annotations = [NSMutableArray arrayWithCapacity:[self.buildingList count]];
            locationAnnotations = [[NSMutableArray alloc] init];
        }
        
        for (BHBuilding *bd in self.buildingList) {
            
            if (isForMapViewController) {
                [annotations addObject:[BHBuildingAnnotation annotationForBuilding:bd]];
            }
            
            for (BHLocation *loc in bd.locations) {
                [locationList addObject:loc];
                if (isForMapViewController) {
                    [locationAnnotations addObject:[BHLocationAnnotation annotationForLocation:loc]];
                }
            }
        }
        
        self.locationList = locationList;
        if (isForMapViewController) {
            mapViewController.buildingAnnotations = annotations;
            mapViewController.locationAnnotations = locationAnnotations;
            mapViewController.annotations = annotations;
//            mapViewController.navigationItem.leftBarButtonItem = mapViewController.refreshButton;
//            [mapViewController updateMapView];
        } else {
            [listViewController.tableView reloadData];
            [listViewController.refreshControl endRefreshing];
        }
        
        // Now, can fetch location real time stats
        [self fetchLocationStatForViewController:viewController];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
        
        self.connectionLost = YES;
        
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No network connection"
                                                        message:@"You must be connected to the internet to use this app."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        // Reset Refresh Button
        if (isForMapViewController) {
            mapViewController.navigationItem.leftBarButtonItem = mapViewController.refreshButton;
            mapViewController.navigationItem.title = @"Campus Map";
        } else {
            listViewController.navigationItem.leftBarButtonItem = listViewController.refreshButton;
            listViewController.navigationItem.title = @"Locations";
        }

    }];
    
    if (isForMapViewController) {
        UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        [spinner startAnimating];
        mapViewController.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    }

    [operation start];

}

-(void)fetchLocationStatForViewController:(UIViewController *)viewController
{
    BOOL isForMapViewController = NO;
    BHMapViewController *mapViewController;
    BHListViewController *listViewController;
    
    if ([viewController isKindOfClass:[BHMapViewController class]]) {
        isForMapViewController = YES;
        mapViewController = (BHMapViewController *)viewController;
        mapViewController.navigationItem.title = @"Loading statistics ...";
    } else if ([viewController isKindOfClass:[BHListViewController class]]) {
        listViewController = (BHListViewController *)viewController;
//        listViewController.navigationItem.title = @"Loading statistics ...";
    }
    
    // Location mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[BHLocationStat class]];
    [locationMapping addAttributeMappingsFromDictionary:@{
                                                          @"id" : @"locId",
                                                          @"occupancy": @"occupancy",
                                                          @"best_time": @"bestTime",
                                                          @"max_capacity": @"maxCapacity",
                                                          @"queue": @"queue",
                                                          @"occupancy_raw":@"occupancyRaw",
                                                          @"occupancy_percent":@"occupancyPercent",
                                                          @"threshold_min": @"thresholdMin",
                                                          @"threshold_max": @"thresholdMax"
                                                          }];
    
    // !IMPORTANT!
    // Should add this line to accept plain text response from server
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:locationMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/dynamic/now", BASE_URL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        NSArray *locationStats = [result array];
        NSMutableDictionary *statDic = [[NSMutableDictionary alloc] initWithCapacity:[locationStats count]];
        for (BHLocationStat *locStat in locationStats) {
            [statDic setObject:locStat forKey:locStat.locId];
        }
        
        self.locationStats = statDic;
        
        // Should update location annotation's statistic object
        for (BHLocationAnnotation *locAnnotation in mapViewController.locationAnnotations) {
            locAnnotation.locationStat = [statDic objectForKey:locAnnotation.location.locId];
        }
        
        // calculate average occupancy for each building for displaying color pins on map
        NSMutableDictionary *bdStats = [[NSMutableDictionary alloc] initWithCapacity:[self.buildingList count]];
        for (BHBuilding *bd in self.buildingList) {
            int avg = 0;
            for (BHLocation *loc in bd.locations) {
                BHLocationStat *locStat = [statDic objectForKey:loc.locId];
                avg = avg + [locStat.occupancyPercent integerValue];
            }
            avg = avg / [bd.locations count];
            [bdStats setValue:[NSString stringWithFormat:@"%d", avg] forKey:bd.bdId];
        }
        self.buildingStats = bdStats;
        
        if (isForMapViewController) {// update mapview
            mapViewController.annotations = mapViewController.buildingAnnotations; //set annotations to buildingAnnotations
            mapViewController.navigationItem.leftBarButtonItem = mapViewController.refreshButton;
            mapViewController.navigationItem.title = @"Campus Map";
            [mapViewController updateMapView];

        } else {
            [listViewController.tableView reloadData];
            [listViewController.refreshControl endRefreshing];
            [listViewController.tableView reloadData];
            listViewController.navigationItem.leftBarButtonItem = listViewController.refreshButton;
//            listViewController.navigationItem.title = @"Locations";
        }
        

        
    }failure:^(RKObjectRequestOperation *operation, NSError *error) {
        
        NSLog(@"Failed with error: %@ silently", [error localizedDescription]);
        
        self.connectionLost = YES;
        
        // Reset Refresh Button
        if (isForMapViewController) {
            mapViewController.navigationItem.leftBarButtonItem = mapViewController.refreshButton;
            mapViewController.navigationItem.title = @"Campus Map";
        } else {
            listViewController.navigationItem.leftBarButtonItem = listViewController.refreshButton;
//            listViewController.navigationItem.title = @"Locations";
        }
        
    }];
    
    [operation start];

}

-(void)fetchAllLocationHourlyStats
{
    // Building mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[BHLocationHourlyStat class]];
    [locationMapping addAttributeMappingsFromDictionary:@{
                                                     @"id" : @"locId"
                                                     }];
    
    // Daily stat mapping
    RKObjectMapping *dayMapping = [RKObjectMapping mappingForClass:[BHDailyStat class]];
    [dayMapping addAttributeMappingsFromDictionary:@{
                                                     @"day" : @"day"
                                                     }];
    
    // Hourly stat mapping
    RKObjectMapping *hourMapping = [RKObjectMapping mappingForClass:[BHHourlyStat class]];
    [hourMapping addAttributeMappingsFromDictionary:@{
                                                      @"hour" : @"hour",
                                                      @"clients": @"clients"
                                                      }];
    
    // Define the relationship mapping
    [dayMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"hours"
                                                                               toKeyPath:@"hours"
                                                                             withMapping:hourMapping]];
    
    [locationMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"stat"
                                                                               toKeyPath:@"weeklyStat"
                                                                             withMapping:dayMapping]];
    
    // !IMPORTANT!
    // Should add this line to accept plain text response from server
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:locationMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/dynamic/daily", BASE_URL];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        // Don't forget to set this
        self.connectionLost = NO;
        NSArray *locationHourlyStats = [result array];
        
        NSMutableDictionary *statDic = [[NSMutableDictionary alloc] initWithCapacity:[locationHourlyStats count]];
        for (BHLocationHourlyStat *locStat in locationHourlyStats) {
            [statDic setObject:locStat.weeklyStat forKey:locStat.locId];
        }
        self.locationHourlyStats = statDic;
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
        
        self.connectionLost = YES;
        
    }];
    
    [operation start];
    
}

-(void)fetchStatForLocation:(BHLocationDetailViewController *)locationDetailViewController
{
    // Daily stat mapping
    RKObjectMapping *dayMapping = [RKObjectMapping mappingForClass:[BHDailyStat class]];
    [dayMapping addAttributeMappingsFromDictionary:@{
                                                  @"day" : @"day"
                                                  }];
    
    // Hourly stat mapping
    RKObjectMapping *hourMapping = [RKObjectMapping mappingForClass:[BHHourlyStat class]];
    [hourMapping addAttributeMappingsFromDictionary:@{
                                                          @"hour" : @"hour",
                                                          @"clients": @"clients"
                                                          }];
    
    // !IMPORTANT!
    // Should add this line to accept plain text response from server
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    
    // Define the relationship mapping
    [dayMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"hours"
                                                                            toKeyPath:@"hours"
                                                                          withMapping:hourMapping]];
    
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:dayMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    NSString *urlString = [NSString stringWithFormat:@"%@/dynamic/daily/%@", BASE_URL, locationDetailViewController.location.locId];
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        // Don't forget to set this
        self.connectionLost = NO;
        NSArray *weeklyStat = [result array];
        
        // set weeklyStat for locationDetailViewController and also reinit plot
        locationDetailViewController.weeklyStat = weeklyStat;
        [locationDetailViewController initDailyPlot];
        [locationDetailViewController initHourlyStatPlotForDay:[locationDetailViewController currentWeeday]];
        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Failed with error: %@", [error localizedDescription]);
        
        self.connectionLost = YES;
        
    }];
    
    [operation start];

}

-(void)postQueueLength:(NSString *)length forLocation:(NSString *)locationId
{
    // Daily stat mapping
    RKObjectMapping *queueRequestMapping = [RKObjectMapping mappingForClass:[BHQueueRequest class]];
    [queueRequestMapping addAttributeMappingsFromDictionary:@{
                                                     @"id_location" : @"locId",
                                                     @"reported": @"queueLengthId"
                                                     }];
    
    RKObjectMapping *queueResponseMapping = [RKObjectMapping mappingForClass:[BHQueueResponse class]];
    [queueResponseMapping addAttributeMappingsFromDictionary:@{
                                                              @"success" : @"result",
                                                              }];
    
    RKRequestDescriptor *requestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:[queueRequestMapping inverseMapping] objectClass:[BHQueueRequest class] rootKeyPath:nil  method:RKRequestMethodAny];
    
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:queueResponseMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    NSURL *url = [NSURL URLWithString:BASE_URL];
    RKObjectManager *manager  = [RKObjectManager managerWithBaseURL:url];
    [manager addRequestDescriptor:requestDescriptor];
    [manager addResponseDescriptor:responseDescriptor];
    
    BHQueueRequest *request = [[BHQueueRequest alloc] init];
    request.locId = locationId;
    request.queueLengthId = length;
    
    [manager postObject:request path:@"/queue" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
//        [JDStatusBarNotification showWithStatus:@"Queue information sent !"];
//        [JDStatusBarNotification showActivityIndicator:NO indicatorStyle:UIActivityIndicatorViewStyleGray];
//        [JDStatusBarNotification dismissAfter:2];

        
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        NSLog(@"Error");
    }];
    
}

@end
