//
//  BHMapViewController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/17/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHMapViewController.h"
#import "BHBuildingAnnotation.h"
#import "BHPlotExampleViewController.h"
#import "BHDataController.h"

@interface BHMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation BHMapViewController
@synthesize mapView = _mapView, annotations = _annotations;


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


//MKMapViewDelegate 方法
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    // Don't overwrite current location annotation
    if([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil;
    }
    
    MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"MapVC"];

    if (!aView) {
        aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"MapVC"];
        aView.canShowCallout = YES;// DON'T FORGET THIS LINE OF CODE !!
        
        // create left view
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        imageView.image = [UIImage imageNamed:@"gatech.jpg"];
        aView.leftCalloutAccessoryView = imageView;

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

//- (void)updateMapViewAnnotations
//{
//    [self.mapView removeAnnotations:self.mapView.annotations];
//    BHBuildingAnnotation *bha = [[BHBuildingAnnotation alloc] init];
//    NSArray *annotations = [NSArray arrayWithObjects:bha, nil];
//    [self.mapView addAnnotations:annotations];
//    [self.mapView showAnnotations:annotations animated:YES];
//}

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
    
    //center to georgia tech
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.02;
    span.longitudeDelta=0.02;
    
    region.span=span;
    CLLocationCoordinate2D centerLocation;
    centerLocation.latitude = 33.777179;
    centerLocation.longitude = -84.399627;
    region.center= centerLocation;
    [self.mapView setRegion:region animated:YES];
    [self.mapView setCenterCoordinate:centerLocation animated:YES];

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
