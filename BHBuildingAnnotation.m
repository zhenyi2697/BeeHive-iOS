//
//  BHBuildingAnnotation.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/25/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHBuildingAnnotation.h"

@implementation BHBuildingAnnotation

//MKAnnotation protocol 的方法， title的setter
-(NSString *)title
{
    return @"Clough (288)";
}

//MKAnnotation protocol 的方法， subtitle的setter
- (NSString *)subtitle
{
    
    return @"Best time to go: 5 min later";
}

//MKAnnotation protocol 的方法， coordinate的setter
- (CLLocationCoordinate2D)coordinate
{
    CLLocationCoordinate2D coordinate;
    coordinate.latitude = 33.777179;
    coordinate.longitude = -84.399627;
    
    return coordinate;
}

@end
