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
#import "BHDataController.h"

//SDWebImage Library
#import <SDWebImage/UIImageView+WebCache.h>

@interface BHMapViewController () <MKMapViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL isInLocationMode;
@property (strong, nonatomic) BHBuildingAnnotation *selectedAnnotation;
- (IBAction)searchLocation:(id)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@end

@implementation BHMapViewController
@synthesize mapView = _mapView, annotations = _annotations, locationAnnotations = _locationAnnotations, buildingAnnotations = _buildingAnnotations;
@synthesize isInLocationMode =_isInLocationMode;
@synthesize refreshButton = _refreshButton;
@synthesize selectedAnnotation = _selectedAnnotation;

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

// Selector functions
-(void)showLocationDetailFromMapView
{
    [self performSegueWithIdentifier: @"showBuildingDetailFromMapView" sender:self];
}

-(void)showLocationsForBuilding
{
    [self zoomInToBuilding:self.selectedAnnotation];
}

-(void)zoomInToBuilding:(BHBuildingAnnotation *)annotation
{
    
    [UIView animateWithDuration:0.8
                          delay:0.0
                        options: UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         MKCoordinateRegion region;
                         MKCoordinateSpan span;
                         span.latitudeDelta = 0.003;
                         span.longitudeDelta = 0.003;
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
    

}

-(void)centerToGT
{
    
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
//        MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BdAnno"];
        
//        if (!aView) {
            MKAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BdAnno"];
            aView.canShowCallout = YES;// DON'T FORGET THIS LINE OF CODE !!
        
        // Using SDWebImage to load image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [imageView setImageWithURL:[NSURL URLWithString:((BHBuildingAnnotation *)annotation).building.photoUrl] placeholderImage:[UIImage imageNamed:@"beehive_icon.png"]];
        aView.leftCalloutAccessoryView = imageView;
            
            // create right view
            aView.rightCalloutAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
            UIButton *showDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [aView.rightCalloutAccessoryView addSubview:showDetailButton];
            [showDetailButton addTarget:self action:@selector(showLocationsForBuilding) forControlEvents:UIControlEventTouchUpInside];
//        }

        return aView;
        
    } else if ([annotation isKindOfClass:[BHLocationAnnotation class]]) {
//        MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"LocAnno"];
//        if (!aView) {
            MKAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"LocAnno"];
            aView.canShowCallout = YES;// DON'T FORGET THIS LINE OF CODE !!
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 45, 45)];
        [imageView setImageWithURL:[NSURL URLWithString:((BHLocationAnnotation *)annotation).location.photoUrl] placeholderImage:[UIImage imageNamed:@"beehive_icon.png"]];
        aView.leftCalloutAccessoryView = imageView;
            
            // create right view
            aView.rightCalloutAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
            UIButton *showDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
            [aView.rightCalloutAccessoryView addSubview:showDetailButton];
            [showDetailButton addTarget:self action:@selector(showLocationDetailFromMapView) forControlEvents:UIControlEventTouchUpInside];
//        }
        
        aView.annotation = annotation;
        
        return aView;

    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    if ([view.annotation isKindOfClass:[BHBuildingAnnotation class]]) {
//        NSLog(@"Clicked building annotation");
        //center to center point
        
//        [self zoomInToBuilding:view.annotation];
        self.selectedAnnotation = view.annotation;
        
    } else if ([view.annotation isKindOfClass:[BHLocationAnnotation class]]){
//        NSLog(@"Clicked location annotation");
    }
}

//- (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
//{
//    if ([view.annotation isKindOfClass:[BHBuildingAnnotation class]]) {
////        [self centerToGT];
//    }
//}

- (void)showBuildingAnnotations
{
    self.annotations = self.buildingAnnotations;
}

-(void)showLocationAnnotations
{
    self.annotations = self.locationAnnotations;
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{

    double spanDelta = mapView.region.span.latitudeDelta;
    
    if (spanDelta < 0.01) {
        if (!self.isInLocationMode) {
            [self showLocationAnnotations];
        }
        self.isInLocationMode = YES;
    } else {
        if (self.isInLocationMode) {
            [self showBuildingAnnotations];
        }
        self.isInLocationMode = NO;
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
    
    self.locationSearchBar.delegate = self;
    
    // Update annotations if is not been set
    // annotations should have been set in AppDelegate when REST request finished loading
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

    }
}

- (IBAction)refreshMap:(UIBarButtonItem *)sender {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];
    
    BHDataController *dataController = [BHDataController sharedDataController];
    
    if (dataController.connectionLost) {
        //Fetch building List for mapView
        [dataController fetchBuildingsForViewController:self];
    }
    
    //Fetch locations statistic for mapView
    [dataController fetchLocationStatForViewController:self];
    
    [self centerToGT];
    
}

- (IBAction)searchLocation:(id)sender {
//    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(-5.0, 0.0, 320.0, 44.0)];
//    searchBar.autoresizingMask = UIViewAutoresizingFlexibleWidth;
//    UIView *searchBarView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, 310.0, 44.0)];
//    searchBarView.autoresizingMask = 0;
//    searchBar.delegate = self;
//    [searchBarView addSubview:searchBar];
//    self.navigationItem.titleView = searchBarView;
    
}

//Method to handle the UISearchBar "Search",

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [searchBar resignFirstResponder];
}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    //Hide the keyboard.
    [searchBar resignFirstResponder];
}

@end