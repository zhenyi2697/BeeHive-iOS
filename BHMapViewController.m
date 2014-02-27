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

@interface BHMapViewController () <MKMapViewDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end

@implementation BHMapViewController
@synthesize mapView = _mapView;

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
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        imageView.image = [UIImage imageNamed:@"gatech.jpg"];
        aView.leftCalloutAccessoryView = imageView;
        aView.rightCalloutAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
        
        UIButton *showDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [aView.rightCalloutAccessoryView addSubview:showDetailButton];
        [showDetailButton addTarget:self action:@selector(showBuildingDetailFromMapView) forControlEvents:UIControlEventTouchUpInside];
    }

    aView.annotation = annotation;
    
//    [(UIImageView *)aView.leftCalloutAccessoryView setImage:nil];
    
    return aView;
}

- (void) updateMapViewAnnotations
{
    [self.mapView removeAnnotations:self.mapView.annotations];
    BHBuildingAnnotation *bha = [[BHBuildingAnnotation alloc] init];
    NSArray *annotations = [NSArray arrayWithObjects:bha, nil];
    [self.mapView addAnnotations:annotations];
    [self.mapView showAnnotations:annotations animated:YES];
}

// delegate method
- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    self.mapView.delegate = self;
    [self updateMapViewAnnotations];
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
//    self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
    
    MKCoordinateRegion region;
    MKCoordinateSpan span;
    span.latitudeDelta=0.02;
    span.longitudeDelta=0.02;
    
    region.span=span;
    region.center=self.mapView.userLocation.location.coordinate;
    [self.mapView setRegion:region animated:YES];
    [self.mapView setCenterCoordinate:self.mapView.userLocation.location.coordinate animated:YES];
    
	// Do any additional setup after loading the view.
}

- (void)viewDidAppear:(BOOL)animated
{
    self.mapView.centerCoordinate = self.mapView.userLocation.location.coordinate;
}

//- (void)mapView:(MKMapView *)mapView didUpdateUserLocation: (MKUserLocation *)userLocation
//{
//    _mapView.centerCoordinate = userLocation.location.coordinate;
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
