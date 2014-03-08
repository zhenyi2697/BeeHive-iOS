//
//  BHLocationAnnotation.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-08.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHLocationAnnotation.h"

@implementation BHLocationAnnotation

@synthesize location = _location;

+(BHLocationAnnotation *)annotationForLocation:(BHLocation *)location
{
    BHLocationAnnotation *annotation = [[BHLocationAnnotation alloc] init];
    annotation.location = location;
    return annotation;
}

//MKAnnotation protocol 的方法， title的setter
-(NSString *)title
{
    return self.location.name;
}

//MKAnnotation protocol 的方法， subtitle的setter
- (NSString *)subtitle
{
    
    return self.location.description;
}

//MKAnnotation protocol 的方法， coordinate的setter
- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = [self.location.latitude doubleValue];
    coordinate.longitude = [self.location.longitude doubleValue];
    
    return coordinate;
}

@end
