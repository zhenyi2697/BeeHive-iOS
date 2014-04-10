//
//  BHMapViewController.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/17/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BHMapViewController : UIViewController <UISearchBarDelegate>
@property (nonatomic,strong) NSArray *annotations;  // of id <MKAnnotation>
@property (nonatomic,strong) NSArray *locationAnnotations;  // of BHLocationAnnotation
@property (nonatomic,strong) NSArray *buildingAnnotations;  // of BHBuildingAnnotation
@property (nonatomic,strong) NSMutableArray *filteredAnnotations;  //filtered location annotations
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;
- (IBAction)refreshMap:(UIBarButtonItem *)sender;
@property (strong, nonatomic) IBOutlet UISearchBar *searchBar;

@end
