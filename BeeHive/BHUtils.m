//
//  BHUtils.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-05-19.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHUtils.h"
#import "BHDataController.h"

@implementation BHUtils

+(UIColor *)titleColorForLocationStat:(BHLocationStat *)locStat
{
    UIColor *titleColor;
    int percentage = (int)[locStat.occupancyPercent integerValue];
    int lowThreshold = (int)[locStat.thresholdMin integerValue];
    int highThreshold = (int)[locStat.thresholdMax integerValue];
    
    if (percentage <= lowThreshold) {
        titleColor = [UIColor colorWithRed:0.0f/255.0f green:128.0f/255.0f blue:0.0f/255.0f alpha:1.0f]; //green
    } else if(percentage > lowThreshold && percentage < highThreshold) {
        titleColor = [UIColor colorWithRed:247.0f/255.0f green:148.0/255.0f blue:30.0f/255.0f alpha:1.0f]; //orange
    } else {
        titleColor = [UIColor colorWithRed:255.0f/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:1.0f]; //red
    }
    return titleColor;
}

+(NSString *)pinNameforLocationStat:(BHLocationStat *)locStat
{
    NSString *pinName = @"pin_orange";
    int percentage = (int)[locStat.occupancyPercent integerValue];
    int lowThreshold = (int)[locStat.thresholdMin integerValue];
    int highThreshold = (int)[locStat.thresholdMax integerValue];
    
    if (percentage <= lowThreshold) {
        pinName = @"pin_green";
    } else if(percentage > lowThreshold && percentage < highThreshold) {
        pinName = @"pin_orange";
    } else {
        pinName = @"pin_red";
    }
    return pinName;
}

+(NSString *)pinNameForBuilding:(NSString *)bdId
{
    NSString *pinName = @"pin_orange";
    BHDataController *dataController = [BHDataController sharedDataController];
    NSString *occupancyString = [dataController.buildingStats objectForKey:bdId];
    int percentage = [occupancyString integerValue];
    int lowThreshold = 50;
    int highThreshold = 80;
    
    if (percentage <= lowThreshold) {
        pinName = @"pin_green";
    } else if(percentage > lowThreshold && percentage < highThreshold) {
        pinName = @"pin_orange";
    } else {
        pinName = @"pin_red";
    }
    return pinName;
}

@end
