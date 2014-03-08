//
//  BHMapViewController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/17/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHMapViewController.h"
#import "BHBuildingAnnotation.h"
#import "BHLocationAnnotation.h"
#import "BHPlotExampleViewController.h"
#import "BHDataController.h"

@interface BHMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL isInLocationMode;
@end

@implementation BHMapViewController
@synthesize mapView = _mapView, annotations = _annotations;
@synthesize isInLocationMode;
@synthesize refreshButton = _refreshButton;

//以下几个方法一般都要写
-(void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

// delegate method
- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    _mapView.delegate = self;
    
//    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
    [self updateMapView];
}


-(void)showBuildingDetailFromMapView
{
    [self performSegueWithIdentifier: @"showBuildingDetailFromMapView" sender:self];
}

-(void)zoomInToBuilding:(BHBuildingAnnotation *)annotation
{

//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//    [UIView setAnimationDuration: 0.8];
//    [UIView setAnimationBeginsFromCurrentState:YES];
    
    [UIView animateWithDuration:0.8
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         MKCoordinateRegion region;
                         MKCoordinateSpan span;
                         span.latitudeDelta = 0.005;
                         span.longitudeDelta = 0.005;
                         region.span=span;
                         region.center= annotation.coordinate;
                         [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
                         [self.mapView setRegion:region animated:YES];
                     }
                     completion:^(BOOL finished){
                         if(finished) {
//                             [self showLocationAnnotations];
                         }
                     }];
    
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta = 0.005;
//    span.longitudeDelta = 0.005;
//    region.span=span;
//    region.center= annotation.coordinate;
//    [self.mapView setCenterCoordinate:annotation.coordinate animated:YES];
//    [self.mapView setRegion:region animated:YES];
//    
//    [UIView commitAnimations];

}

-(void)centerToGT
{
    
//    [UIView beginAnimations:nil context:NULL];
//    [UIView setAnimationCurve:UIViewAnimationCurveLinear];
//    [UIView setAnimationDuration: 0.6];
//    [UIView setAnimationBeginsFromCurrentState:YES];
//    
//    //center to georgia tech
//    MKCoordinateRegion region;
//    MKCoordinateSpan span;
//    span.latitudeDelta=0.02;
//    span.longitudeDelta=0.02;
//    
//    region.span=span;
//    CLLocationCoordinate2D centerLocation;
//    centerLocation.latitude = 33.777179;
//    centerLocation.longitude = -84.399627;
//    region.center= centerLocation;
//    [self.mapView setCenterCoordinate:centerLocation animated:YES];
//    [self.mapView setRegion:region animated:YES];
//    
//    [UIView commitAnimations];
    
    [UIView animateWithDuration:0.8
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         MKCoordinateRegion region;
                         MKCoordinateSpan span;
                         span.latitudeDelta = 0.02;
                         span.longitudeDelta = 0.02;
                         region.span=span;
                         CLLocationCoordinate2D centerLocation;
                         centerLocation.latitude = 33.777179;
                         centerLocation.longitude = -84.399627;
                         region.center= centerLocation;
                         [self.mapView setCenterCoordinate:centerLocation animated:YES];
                         [self.mapView setRegion:region animated:YES];
                     }
                     completion:^(BOOL finished){
                         if(finished) {
//                             [self showBuildingAnnotations];
                         }
                     }];


}

//MKMapViewDelegate 方法
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    // Don't overwrite current location annotation
    if([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil;
    } else if ([annotation isKindOfClass:[BHBuildingAnnotation class]]) {
        MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BdAnno"];
        
        if (!aView) {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BdAnno"];
        }

        return aView;
    } else if ([annotation isKindOfClass:[BHLocationAnnotation class]]) {
        MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"LocAnno"];
        
        if (!aView) {
            aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"LocAnno"];
            aView.canShowCallout = YES;// DON'T FORGET THIS LINE OF CODE !!
            
            // create left view
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
            imageView.image = [UIImage imageNamed:@"gatech.jpg"];
            aView.leftCalloutAccessoryView = imageView;
            
            // create right view
            aView.rightCalloutAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
            UIButton *showDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [aView.rightCalloutAccessoryView addSubview:showDetailButton];
            [showDetailButton addTarget:self action:@selector(showBuildingDetailFromMapView) forControlEvents:UIControlEventTouchUpInside];
        }
        
        aView.annotation = annotation;
        
        return aView;

    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[BHBuildingAnnotation class]]) {
        NSLog(@"Clicked building annotation");
        //center to center point
        [self zoomInToBuilding:view.annotation];
        
    } else if ([view.annotation isKindOfClass:[BHLocationAnnotation class]]){
        NSLog(@"Clicked location annotation");
    }
}

- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[BHBuildingAnnotation class]]) {
//        [self centerToGT];
    }
}

- (void)showBuildingAnnotations
{
    BHDataController *sharedDataController = [BHDataController sharedDataController];
    NSArray *bdList = sharedDataController.buildingList;
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[bdList count]];
    for (BHBuilding *bd in bdList) {
        [annotations addObject:[BHBuildingAnnotation annotationForBuilding:bd]];
    }
    self.annotations = annotations;
}

-(void)showLocationAnnotations
{
    BHDataController *sharedDataController = [BHDataController sharedDataController];
    NSArray *locList = sharedDataController.locationList;
    NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[locList count]];
    for (BHLocation *loc in locList) {
        [annotations addObject:[BHLocationAnnotation annotationForLocation:loc]];
    }
    self.annotations = annotations;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"region changed");
    NSLog(@"%f", mapView.region.span.latitudeDelta);
    double spanDelta = mapView.region.span.latitudeDelta;
    
    if (spanDelta < 0.01) {
        if (!isInLocationMode) {
            [self showLocationAnnotations];
        }
        isInLocationMode = YES;
    } else {
        if (isInLocationMode) {
            [self showBuildingAnnotations];
        }
        isInLocationMode = NO;
    }
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Update annotations if is not been set
    // annotations should be set in AppDelegate when REST request finished loading
    if (!self.annotations) {
        BHDataController *sharedDataController = [BHDataController sharedDataController];
        NSArray *bdList = sharedDataController.buildingList;
        NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[bdList count]];
        for (BHBuilding *bd in bdList) {
            [annotations addObject:[BHBuildingAnnotation annotationForBuilding:bd]];
        }
        self.annotations = annotations;
    }
    
    [self centerToGT];
}

- (void)viewDidAppear:(BOOL)animated
{
//    self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
}

// triggered when user location changed
//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation
//{
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showBuildingDetailFromMapView"]) {
        BHPlotExampleViewController *photoViewController = (BHPlotExampleViewController *)segue.destinationViewController;
    }
}

@end
