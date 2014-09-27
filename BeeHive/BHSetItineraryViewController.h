//
//  BHSetItineraryViewController.h
//  BeeHive
//
//  Created by Louis CHEN on 7/20/14.
//  Copyright (c) 2014 Louis CHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

@class BHLocation;

@interface BHSetItineraryViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (nonatomic,strong) NSArray *annotations;  // of id <MKAnnotation>
@property (nonatomic,strong) NSArray *locationAnnotations;  // of BHLocationAnnotation
@property (nonatomic,strong) NSArray *buildingAnnotations;  // of BHBuildingAnnotation
@property (nonatomic,strong) NSMutableArray *filteredAnnotations;  //filtered location annotations

@property (strong,nonatomic) BHLocation *toLocation;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *currentLocation;

- (void)updateMapView;

@end
