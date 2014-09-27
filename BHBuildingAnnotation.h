//
//  BHBuildingAnnotation.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/25/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "BHBuilding.h"

@interface BHBuildingAnnotation : NSObject <MKAnnotation>
+(BHBuildingAnnotation *)annotationForBuilding:(BHBuilding *)building;
@property (nonatomic,strong) BHBuilding *building;
@end
