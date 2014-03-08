//
//  BHDataController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-07.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHDataController.h"

@implementation BHDataController

@synthesize buildingList = _buildingList, locationList = _locationList;

+ (id)sharedDataController {
    static BHDataController *sharedDataController = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedDataController = [[self alloc] init];
    });
    return sharedDataController;
}

@end
