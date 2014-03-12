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

@implementation BHDataController

@synthesize buildingList = _buildingList, locationList = _locationList;

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
    } else if ([viewController isKindOfClass:[BHListViewController class]]) {
        listViewController = (BHListViewController *)viewController;
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
    
    NSURL *url = [NSURL URLWithString:@"http://api.letsbeehive.tk/zones/listall"];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    RKObjectRequestOperation *operation = [[RKObjectRequestOperation alloc] initWithRequest:request responseDescriptors:@[responseDescriptor]];
    [operation setCompletionBlockWithSuccess:^(RKObjectRequestOperation *operation, RKMappingResult *result) {
        
        self.buildingList = [result array];
        
        NSMutableArray *locationList = [[NSMutableArray alloc] init];
        NSMutableArray *annotations;
        NSMutableArray *locationAnnotations;
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
                [locationAnnotations addObject:[BHLocationAnnotation annotationForLocation:loc]];
            }
        }
        
        self.locationList = locationList;
        if (isForMapViewController) {
            mapViewController.buildingAnnotations = annotations;
            mapViewController.locationAnnotations = locationAnnotations;
            mapViewController.annotations = annotations;
            mapViewController.navigationItem.leftBarButtonItem = mapViewController.refreshButton;
        }
        
    } failure:nil];
    
    
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
    } else if ([viewController isKindOfClass:[BHListViewController class]]) {
        listViewController = (BHListViewController *)viewController;
    }
    
    // Location mapping
    RKObjectMapping *locationMapping = [RKObjectMapping mappingForClass:[BHLocationStat class]];
    [locationMapping addAttributeMappingsFromDictionary:@{
                                                          @"id" : @"locId",
                                                          @"occupancy": @"occupancy",
                                                          @"best_time": @"bestTime",
                                                          }];
    
    // !IMPORTANT!
    // Should add this line to accept plain text response from server
    [RKMIMETypeSerialization registerClass:[RKNSJSONSerialization class] forMIMEType:@"text/html"];
    RKResponseDescriptor *responseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:locationMapping method:RKRequestMethodAny pathPattern:nil keyPath:nil statusCodes:nil];
    
    NSURL *url = [NSURL URLWithString:@"http://api.letsbeehive.tk/locations/stats"];
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
        
        if (isForMapViewController) {// update mapview
            mapViewController.annotations = mapViewController.buildingAnnotations;
            mapViewController.navigationItem.leftBarButtonItem = mapViewController.refreshButton;
        } else {
            [listViewController.tableView reloadData];
            [listViewController.refreshControl endRefreshing];
        }
        
    } failure:nil];
    
    [operation start];

}

@end
