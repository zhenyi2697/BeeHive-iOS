//
//  BHBuildingAnnotation.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/25/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHBuildingAnnotation.h"

@implementation BHBuildingAnnotation

@synthesize building;

+(BHBuildingAnnotation *)annotationForBuilding:(BHBuilding *)building
{
    BHBuildingAnnotation *annotation = [[BHBuildingAnnotation alloc] init];
    annotation.building = building;
    return annotation;
}

//MKAnnotation protocol 的方法， title的setter
-(NSString *)title
{
    return self.building.name;
}

//MKAnnotation protocol 的方法， subtitle的setter
- (NSString *)subtitle
{
    
    return self.building.description;
}

//MKAnnotation protocol 的方法， coordinate的setter
- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.building.latitude doubleValue];
    coordinate.longitude = [self.building.longitude doubleValue];
    
    return coordinate;
}

@end
