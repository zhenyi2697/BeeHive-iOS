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
#import "BHLocationDetailViewController.h"
#import "BHLocationAnnotationView.h"
#import "BHUtils.h"

//SDWebImage Library
#import <SDWebImage/UIImageView+WebCache.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface BHMapViewController () <MKMapViewDelegate, UISearchBarDelegate>
@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (nonatomic) BOOL isInLocationMode;
@property (nonatomic) BOOL isInSearchMode;
@property (nonatomic) BOOL isSearchBarHidden;
@property (strong, nonatomic) BHBuildingAnnotation *selectedAnnotation;
@property (strong, nonatomic) BHLocationAnnotation *selectedLocationAnnotation;
//- (IBAction)searchLocation:(id)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *locationSearchBar;
@end

@implementation BHMapViewController
@synthesize mapView = _mapView, annotations = _annotations, locationAnnotations = _locationAnnotations, buildingAnnotations = _buildingAnnotations, filteredAnnotations = _filteredAnnotations;
@synthesize isInLocationMode =_isInLocationMode;
@synthesize refreshButton = _refreshButton;
@synthesize selectedAnnotation = _selectedAnnotation, selectedLocationAnnotation = _selectedLocationAnnotation;
@synthesize searchBar = _searchBar, isSearchBarHidden = _isSearchBarHidden;

#pragma mark - Updates

-(NSMutableArray *)filteredAnnotations
{
    if (!_filteredAnnotations) {
        _filteredAnnotations = [NSMutableArray arrayWithCapacity:0];
    }
    return _filteredAnnotations;
}

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
//    [_mapView setMapType: MKMapTypeHybrid];
    [self updateMapView];
}

- (void)setAnnotations:(NSArray *)annotations
{
    _annotations = annotations;
//    [self updateMapView];
}

// Selector functions
-(void)showLocationDetailFromMapView
{
    [self performSegueWithIdentifier: @"showLocationDetailFromMapView" sender:self];
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


//MKMapViewDelegate 方法
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
//        MKAnnotationView *aView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"BdAnno"];
        
        MKAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"BdAnno"];
        aView.canShowCallout = YES;// DON'T FORGET THIS LINE OF CODE !!
        
        // Using SDWebImage to load image
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
        [imageView setImageWithURL:[NSURL URLWithString:((BHBuildingAnnotation *)annotation).building.photoUrl] placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
        aView.leftCalloutAccessoryView = imageView;
            
        // create right view
//        aView.rightCalloutAccessoryView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30,30)];
//        UIButton *showDetailButton = [UIButton buttonWithType:UIButtonTypeCustom];
////        [showDetailButton setBackgroundImage:[UIImage imageNamed:@"disclosure.png"] forState:UIControlStateNormal];
//        [showDetailButton setTitle:@">" forState:UIControlStateNormal];
//        [aView.rightCalloutAccessoryView addSubview:showDetailButton];
        
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

        MKAnnotationView *aView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"LocAnno"];
        aView.canShowCallout = YES;// DON'T FORGET THIS LINE OF CODE !!
        
//        // custom annotation view (unuseful...)
//        BHLocationAnnotationView *locView =[[BHLocationAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"LocAnno"];
//        [locView.annotationImage setImageWithURL:[NSURL URLWithString:((BHLocationAnnotation *)annotation).location.photoUrl] placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
//        locView.annotationLabel.text = @"Test";
//        locView.canShowCallout = YES;
        
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
        [showDetailButton addTarget:self action:@selector(showLocationDetailFromMapView) forControlEvents:UIControlEventTouchUpInside];
        
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

// useful to pop pins with spinTech selector
//- (void)mapViewDidFinishRenderingMap:(MKMapView *)mapView fullyRendered:(BOOL)fullyRendered {
//    for (id<MKAnnotation> currentAnnotation in mapView.annotations) {
//        if ([currentAnnotation isEqual:[[mapView annotations] lastObject]]) {
//            [mapView selectAnnotation:currentAnnotation animated:FALSE];
//        }
//    }
//    
//}


// pin drop annimation delegate methode 
//- (void)mapView:(MKMapView *)mapView
//didAddAnnotationViews:(NSArray *)annotationViews
//{
//    for (MKAnnotationView *annView in annotationViews)
//    {
//        CGRect endFrame = annView.frame;
//        annView.frame = CGRectOffset(endFrame, 0, -500);
//        [UIView animateWithDuration:0.5
//                         animations:^{ annView.frame = endFrame; }];
//    }
//}


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
//    NSLog(@"> %@", self.annotations);

}

-(void)showLocationAnnotations
{
    self.annotations = self.locationAnnotations;
    [self updateMapView];
//    NSLog(@"> %@", self.annotations);

}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{

    double spanDelta = mapView.region.span.latitudeDelta;
    
    // not in search mode
    if (spanDelta < 0.01) {
        if (!self.isInLocationMode) {
            if (!self.isInSearchMode) {
                [self showLocationAnnotations];
            }
        }
        self.isInLocationMode = YES;
    } else {
        if (self.isInLocationMode) {
            if (!self.isInSearchMode) {
                [self showBuildingAnnotations];
            }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // bar and button color
    self.navigationController.navigationBar.tintColor = [UIColor orangeColor];
    self.locationSearchBar.tintColor = [UIColor orangeColor];
//    self.locationSearchBar.barTintColor = [UIColor colorWithWhite: 0.95 alpha:1];
    
    self.locationSearchBar.hidden = YES;
    self.isSearchBarHidden = YES;
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
//    NSLog(@">load: %@", self.annotations);
//    [self updateMapView];
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

# pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"showLocationDetailFromMapView"]) {
        
        BHLocationDetailViewController *detailViewController = [segue destinationViewController];
        BHDataController *dataController = [BHDataController sharedDataController];
        detailViewController.location = self.selectedLocationAnnotation.location;
        
        NSArray *weeklyStat = [dataController.locationHourlyStats objectForKey:detailViewController.location.locId];
        detailViewController.weeklyStat = weeklyStat;
        
        if (!weeklyStat) {
            [dataController fetchStatForLocation:detailViewController];
        }
    }
}

# pragma mark - Research

- (IBAction)searchLocation:(id)sender {
    if (self.isSearchBarHidden) { // if hidden then reveal
        self.locationSearchBar.hidden = NO;
        self.isSearchBarHidden = NO;
        [self.locationSearchBar becomeFirstResponder];
    } else { // if not hidden then cancel
//        self.locationSearchBar.hidden = YES;
//        self.isSearchBarHidden = YES;
        [self exitedSearchMode];
        self.searchBar.text = @"";
        [self.locationSearchBar resignFirstResponder];
    }
}

//Method to handle the UISearchBar "Search"
-(void)exitedSearchMode
{
    self.isInSearchMode = NO;
    if (self.isInLocationMode) {
        [self showLocationAnnotations];
    } else {
        [self showBuildingAnnotations];
    }
    self.locationSearchBar.hidden = YES;
    self.isSearchBarHidden = YES;
}

-(void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self exitedSearchMode];
    self.searchBar.text = @"";
    [searchBar resignFirstResponder];

}

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:YES animated:YES];
    self.isInSearchMode = YES;
}

-(void)searchBarTextDidEndEditing:(UISearchBar *)searchBar
{
    [searchBar setShowsCancelButton:NO animated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    
    [self.filteredAnnotations removeAllObjects];

    for (BHLocationAnnotation *anno in self.locationAnnotations) {
        if ([anno.location.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
            [anno.location.description rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound)
        {
            [self.filteredAnnotations addObject:anno];
        }
    }
    self.annotations = self.filteredAnnotations;
    [self updateMapView];
}


// When not click on the keyboard area, hide the keyboard
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
//    NSLog(@"%hhd", self.isInSearchMode);
    
    [self.view endEditing:YES];
    if ([self.searchBar.text isEqual:@""] && self.isInSearchMode) {
        [self exitedSearchMode];
    } else {
        // still in search mode
    }
    
//    UITouch *touch = [[event allTouches] anyObject];
//    if (![[touch view] isKindOfClass:[UITextField class]]){
//        
//    }
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    // click on key board search button
    [searchBar resignFirstResponder];
}

@end