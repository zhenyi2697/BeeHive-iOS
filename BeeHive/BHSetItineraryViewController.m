//
//  BHSetItineraryViewController.m
//  BeeHive
//
//  Created by Louis CHEN on 7/20/14.
//  Copyright (c) 2014 Louis CHEN. All rights reserved.
//

#import "BHSetItineraryViewController.h"
#import "BHBuildingAnnotation.h"
#import "BHLocationAnnotation.h"
#import "BHDataController.h"
#import "BHLocationAnnotationView.h"
#import "BHUtils.h"
#import "BHListViewController.h"

#import "BHLocation.h"

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface BHSetItineraryViewController () 
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL isInSearchMode;
@property (nonatomic) BOOL isSearchBarHidden;
@property (nonatomic) BOOL isInLocationMode;
@property (strong, nonatomic) BHBuildingAnnotation *selectedAnnotation;
@property (strong, nonatomic) BHLocationAnnotation *selectedLocationAnnotation;
@property (nonatomic, strong) NSArray *arrRoutePoints;
@property (nonatomic, strong) MKPolyline *objPolyline;
@end

@implementation BHSetItineraryViewController
@synthesize mapView = _mapView, annotations = _annotations, locationAnnotations = _locationAnnotations, buildingAnnotations = _buildingAnnotations, filteredAnnotations = _filteredAnnotations;
@synthesize isInLocationMode =_isInLocationMode;
//@synthesize refreshButton = _refreshButton;
@synthesize selectedAnnotation = _selectedAnnotation, selectedLocationAnnotation = _selectedLocationAnnotation;
@synthesize toLocation = _toLocation;
@synthesize locationManager = _locationManager;
@synthesize currentLocation = _currentLocation;

#pragma mark - Updates

- (void)updateMapView
{
    if (self.mapView.annotations) [self.mapView removeAnnotations:self.mapView.annotations];
    if (self.annotations) [self.mapView addAnnotations:self.annotations];
}

// delegate method
- (void)setMapView:(MKMapView *)mapView
{
    _mapView = mapView;
    _mapView.delegate = self;
    //    [_mapView setMapType: MKMapTypeHybrid];
//    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
//    [self updateMapView];
}

// Selector functions - to be updated to "setAsDeparture"
-(void)setAsDeparture
{
    //[self performSegueWithIdentifier: @"setAsDeparture" sender:self];
//    self.currentLocation.coordinate.latitude = self.selectedLocationAnnotation.location.latitude;
//    self.currentLocation.coordinate.longitude = 1.0f;
    
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
                        options: UIViewAnimationOptionCurveEaseInOut
                     animations:^{
                         MKCoordinateRegion region;
                         MKCoordinateSpan span;
                         span.latitudeDelta = 0.021;
                         span.longitudeDelta = 0.021; //0.021;
                         region.span=span;
                         CLLocationCoordinate2D centerLocation;
                         centerLocation.latitude = 33.774179;
                         centerLocation.longitude = -84.397580; //-84.398027;
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


//MKMapViewDelegate method
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    
    // Don't overwrite current location annotation
    if([annotation isKindOfClass: [MKUserLocation class]]) {
        return nil; //default bleu point
        //        // custom user location annotation
        //        static NSString* AnnotationIdentifier = @"Annotation";
        //        MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationIdentifier];
        //
        //        if (!pinView) {
        //            MKPinAnnotationView *customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationIdentifier];
        //            if (annotation == mapView.userLocation) customPinView.image = [UIImage imageNamed:@"Buzz.png"];
        ////            else customPinView.image = [UIImage imageNamed:@"mySomeOtherImage.png"];
        //            customPinView.animatesDrop = NO;
        //            customPinView.canShowCallout = YES;
        //            return customPinView;
        //
        //        } else {
        //
        //            pinView.annotation = annotation;
        //        }
        //        return pinView;
        
    } else if ([annotation isKindOfClass:[BHBuildingAnnotation class]]) {
        //        MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BdAnno2"];
        
        MKAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BdAnno2"];
        aView.canShowCallout = YES;// DON'T FORGET THIS LINE OF CODE !!
        
        // Using SDWebImage to load image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [imageView setImageWithURL:[NSURL URLWithString:((BHBuildingAnnotation *)annotation).building.photoUrl] placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
        aView.leftCalloutAccessoryView = imageView;
        
        aView.rightCalloutAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIButton *showDetailButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
        [aView.rightCalloutAccessoryView addSubview:showDetailButton];
        
        [showDetailButton addTarget:self action:@selector(showLocationsForBuilding) forControlEvents:UIControlEventTouchUpInside];
        
        NSString *bdId = ((BHBuildingAnnotation *)annotation).building.bdId;
        BHDataController *dataController = [BHDataController sharedDataController];
        NSString *pinName = @"pin_orange";
        if (dataController.locationStats) {
            pinName = [BHUtils pinNameForBuilding:bdId];
        } else {
            NSLog(@"Not loaded");
        }
        
        if (IS_IPAD) {
            pinName = [pinName stringByAppendingString:@".png"];
        } else {
            pinName = [pinName stringByAppendingString:@"_small.png"];
        }
        aView.image = [UIImage imageNamed:pinName];
        
        aView.calloutOffset = CGPointMake(0, 0);
        
        return aView;
        
    } else if ([annotation isKindOfClass:[BHLocationAnnotation class]]) {
        
        MKAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"LocAnno2"];
        aView.canShowCallout = YES;// DON'T FORGET THIS LINE OF CODE !!
        
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [imageView setImageWithURL:[NSURL URLWithString:((BHLocationAnnotation *)annotation).location.photoUrl] placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
        aView.leftCalloutAccessoryView = imageView;
        
        // change pin color based on real time occupancy value
        BHDataController *dataController = [BHDataController sharedDataController];
        NSString *locId = ((BHLocationAnnotation *)annotation).location.locId;
        NSString *pinName = @"pin_orange";
        
        //        NSLog(@"pin_orange");
        
        if (dataController.locationStats) {
            BHLocationStat *locStat = [dataController.locationStats objectForKey:locId];
            pinName = [BHUtils pinNameforLocationStat:locStat];
        } else {
            NSLog(@"Not loaded");
        }
        
        // create right view
        aView.rightCalloutAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        UIButton *showDetailButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [aView.rightCalloutAccessoryView addSubview:showDetailButton];
        [showDetailButton addTarget:self action:@selector(setAsDeparture) forControlEvents:UIControlEventTouchUpInside];
        
        aView.annotation = annotation;
        
        // append pin image
        if (IS_IPAD) {
            pinName = [pinName stringByAppendingString:@".png"];
        } else {
            pinName = [pinName stringByAppendingString:@"_small.png"];
        }
        aView.image = [UIImage imageNamed:pinName];
        
        //        aView.centerOffset = CGPointMake(0, 15);
        aView.calloutOffset = CGPointMake(0,0);
        
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
        self.selectedLocationAnnotation = view.annotation;
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
    [self updateMapView];
//    NSLog(@"%@", self.annotations);
}

-(void)showLocationAnnotations
{
    self.annotations = self.locationAnnotations;
    [self updateMapView];
//    NSLog(@"%@", self.annotations);
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    double spanDelta = mapView.region.span.latitudeDelta;
    
    // not in search mode
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

#pragma mark - Begin

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated{
    [self startLocationServices];
    self.tabBarController.tabBar.hidden = YES;
}

- (void)viewWillDisappear:(BOOL)animated {
    [self stopLocationServices];
    self.tabBarController.tabBar.hidden = NO;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // bar and button color
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    
    // Load anotation data
    if (!self.annotations) {
        BHDataController *sharedDataController = [BHDataController sharedDataController];
        NSArray *bdList = sharedDataController.buildingList;
        NSMutableArray *annotations = [NSMutableArray arrayWithCapacity:[bdList count]];
        for (BHBuilding *bd in bdList) {
            [annotations addObject:[BHBuildingAnnotation annotationForBuilding:bd]];
        }
        self.annotations = annotations;
        self.buildingAnnotations = annotations;
        NSArray *locList = sharedDataController.locationList;
        NSMutableArray *annotations2 = [NSMutableArray arrayWithCapacity:[locList count]];
        for (BHLocation* loc in locList) {
            [annotations2 addObject:[BHLocationAnnotation annotationForLocation:loc]];
        }
        self.locationAnnotations = annotations2;
    }
//    NSLog(@"load: %@", self.annotations);
    
    [self updateMapView];
    [self centerToGT];
    
    CLLocationCoordinate2D coord;
    coord.longitude = (CLLocationDegrees)[self.toLocation.longitude doubleValue];
    coord.latitude = (CLLocationDegrees)[self.toLocation.latitude doubleValue];
    MKPlacemark* place = [[MKPlacemark alloc] initWithCoordinate: coord addressDictionary: nil];
    MKMapItem* destination = [[MKMapItem alloc] initWithPlacemark: place];
    destination.name = self.toLocation.name;
    
//    if(arrRoutePoints) // Remove all annotations
//        [objMapView removeAnnotations:[objMapView annotations]];
//
    _arrRoutePoints = [self getRoutePointFrom:_currentLocation to:self.toLocation];
    [self drawRoute];
    
}

#pragma mark - Overlay

/* MKMapViewDelegate Meth0d -- for viewForOverlay*/
- (MKOverlayView*)mapView:(MKMapView*)theMapView viewForOverlay:(id <MKOverlay>)overlay
{
    MKPolylineView *view = [[MKPolylineView alloc] initWithPolyline:_objPolyline];
    view.fillColor = [UIColor orangeColor];
    view.strokeColor = [UIColor orangeColor];
    view.lineWidth = 5;
    return view;
}

/* This will get the route coordinates from the google api. */
- (NSArray*)getRoutePointFrom:(CLLocation *)origin to:(BHLocation *)destination
{
    NSString* saddr = [NSString stringWithFormat:@"%f,%f", origin.coordinate.latitude, origin.coordinate.longitude];
    NSString* daddr = [NSString stringWithFormat:@"%f,%f", [destination.latitude floatValue], [destination.longitude floatValue]];
    //dirflg=h Switches on "Avoid Highways" route finding mode.
    //dirflg=t Switches on "Avoid Tolls" route finding mode.
    //dirflg=r Switches on "Public Transit" - only works in some areas. Can also set date and time info described below.
    //dirflg=w Switches to walking directions - still in beta.
    //dirflg=b Switches to biking directions - only works in some areas and still in beta.
    NSString* mode = @"b";
    
    NSString* apiUrlStr = [NSString stringWithFormat:@"http://maps.google.com/maps?output=dragdir&saddr=%@&daddr=%@&dirflg=%@", saddr, daddr, mode];
    NSURL* apiUrl = [NSURL URLWithString:apiUrlStr];
    
    NSError *error;
    NSString *apiResponse = [NSString stringWithContentsOfURL:apiUrl encoding:NSUTF8StringEncoding error:&error];
    
    NSDate * duration = [NSDate new];
    duration = [self getDuration: apiResponse];
    
//    NSString* encodedPoints = [apiResponse stringByMatching:@"points:\\\"([^\\\"]*)\\\"" capture:1L];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"points:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
    NSLog(@"%@", match);
    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    
    return [self decodePolyLine:[encodedPoints mutableCopy]];
}


- (NSDate*) getDuration: (NSString *)apiResponse {
    NSDate * date = [NSDate new];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"tooltipHtml:\\\"([^\\\"]*)\\\"" options:0 error:NULL];
    NSTextCheckingResult *match = [regex firstMatchInString:apiResponse options:0 range:NSMakeRange(0, [apiResponse length])];
    NSLog(@"%@", match);
    NSString *encodedPoints = [apiResponse substringWithRange:[match rangeAtIndex:1]];
    NSLog(@"%@", encodedPoints);
    
    return date;
}


- (NSMutableArray *)decodePolyLine:(NSMutableString *)encodedString
{
    [encodedString replaceOccurrencesOfString:@"\\\\" withString:@"\\"
                                      options:NSLiteralSearch
                                        range:NSMakeRange(0, [encodedString length])];
    NSInteger len = [encodedString length];
    NSInteger index = 0;
    NSMutableArray *array = [[NSMutableArray alloc] init];
    NSInteger lat=0;
    NSInteger lng=0;
    while (index < len) {
        NSInteger b;
        NSInteger shift = 0;
        NSInteger result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlat = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lat += dlat;
        shift = 0;
        result = 0;
        do {
            b = [encodedString characterAtIndex:index++] - 63;
            result |= (b & 0x1f) << shift;
            shift += 5;
        } while (b >= 0x20);
        NSInteger dlng = ((result & 1) ? ~(result >> 1) : (result >> 1));
        lng += dlng;
        NSNumber *latitude = [[NSNumber alloc] initWithFloat:lat * 1e-5];
        NSNumber *longitude = [[NSNumber alloc] initWithFloat:lng * 1e-5];
        printf("\n[%f,", [latitude doubleValue]);
        printf("%f]", [longitude doubleValue]);
        CLLocation *loc = [[CLLocation alloc] initWithLatitude:[latitude floatValue] longitude:[longitude floatValue]];
        [array addObject:loc];
    }
    return array;
}

- (void)drawRoute
{
    NSUInteger numPoints = [_arrRoutePoints count];
//    NSLog(@"points: %@", _arrRoutePoints );
    if (numPoints > 1)
    {
        CLLocationCoordinate2D* coords = malloc(numPoints * sizeof(CLLocationCoordinate2D));
        for (int i = 0; i < numPoints; i++)
        {
            CLLocation* current = [_arrRoutePoints objectAtIndex:i];
            coords[i] = current.coordinate;
        }
        
        self.objPolyline = [MKPolyline polylineWithCoordinates:coords count:numPoints];
        free(coords);
        
        [self.mapView addOverlay:_objPolyline];
        [self.mapView setNeedsDisplay];
    }
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
//    if([[segue identifier] isEqualToString:@"setAsDeparture"]) {
//        
//        BHLocationDetailViewController *detailViewController = [segue destinationViewController];
//        BHDataController *dataController = [BHDataController sharedDataController];
//        detailViewController.location = self.selectedLocationAnnotation.location;
//        
//        NSArray *weeklyStat = [dataController.locationHourlyStats objectForKey:detailViewController.location.locId];
//        detailViewController.weeklyStat = weeklyStat;
//        
//        if (!weeklyStat) {
//            [dataController fetchStatForLocation:detailViewController];
//        }
//    }
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
    NSLog(@"Location services started");
}

- (void) stopLocationServices {
    [self.locationManager stopUpdatingLocation];
    self.locationManager.delegate = nil;
    NSLog(@"Location services stopped");
}

//locationManager didUpdateLocations *********************************************************
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    self.currentLocation = [locations lastObject];
    NSLog(@"lat%f - lon%f", self.currentLocation.coordinate.latitude, self.currentLocation.coordinate.longitude);
    _arrRoutePoints = [self getRoutePointFrom:_currentLocation to:self.toLocation];
    [self drawRoute];
    [self stopLocationServices];
}

#pragma mark - Save

- (IBAction)saveItinerary:(UIBarButtonItem *)sender {

    [self.navigationController popToRootViewControllerAnimated:YES];
    [[[self.navigationController viewControllers] objectAtIndex:0] setToto:@"ItinerarySet"];
    

}

@end
