//
//  BHMapViewController.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/17/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface BHMapViewController : UIViewController
@property (nonatomic,strong) NSArray *annotations;  // of id <MKAnnotation>
@property (nonatomic,strong) NSArray *locationAnnotations;  // of BHLocationAnnotation
@property (nonatomic,strong) NSArray *buildingAnnotations;  // of BHBuildingAnnotation
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;

@end
