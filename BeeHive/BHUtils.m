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
        titleColor = [UIColor colorWithRed:247.0f/255.0f green:148.0/255.0f blue:30.0f/255.0f alpha:1.0f]; //orange BeeHive -> UIColor
    } else {
        titleColor = [UIColor colorWithRed:255.0f/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:1.0f]; //red
    }
    return titleColor;
}

+(CPTColor *)titleColorForLocationStat2:(BHLocationStat *)locStat
{
    CPTColor *titleColor;
    int percentage = (int)[locStat.occupancyPercent integerValue];
    int lowThreshold = (int)[locStat.thresholdMin integerValue];
    int highThreshold = (int)[locStat.thresholdMax integerValue];
    
    if (percentage <= lowThreshold) {
        titleColor = [CPTColor colorWithComponentRed:0.0f/255.0f green:128.0f/255.0f blue:0.0f/255.0f alpha:1.0f]; //green
    } else if(percentage > lowThreshold && percentage < highThreshold) {
        titleColor = [CPTColor colorWithComponentRed:247.0f/255.0f green:148.0/255.0f blue:30.0f/255.0f alpha:1.0f]; //orange BeeHive for titleColorForLocationStat2 -> CPTColor
    } else {
        titleColor = [CPTColor colorWithComponentRed:255.0f/255.0f green:0.0/255.0f blue:0.0/255.0f alpha:1.0f]; //red
    }
    return titleColor;
}

+(NSString *)pinNameforLocationStat:(BHLocationStat *)locStat
{
    NSString *pinName = @"pin_orange";
    long percentage = (int)[locStat.occupancyPercent integerValue];
    int lowThreshold = (int)[locStat.thresholdMin integerValue];
    int highThreshold = (int)[locStat.thresholdMax integerValue];
    
    if (percentage <= lowThreshold) {
        pinName = @"pin_green";
    } else if(percentage > lowThreshold && percentage <= highThreshold) {
        pinName = @"pin_orange";
    } else {
        pinName = @"pin_red";
    }
//    NSLog(@"pin_custom");
    return pinName;
}

+(NSString *)pinNameForBuilding:(NSString *)bdId
{
    NSString *pinName = @"pin_orange";
    BHDataController *dataController = [BHDataController sharedDataController];
    NSString *occupancyString = [dataController.buildingStats objectForKey:bdId];
    long percentage = [occupancyString integerValue];
    int lowThreshold = 50;
    int highThreshold = 90;
    
    if (percentage <= lowThreshold) {
        pinName = @"pin_green";
    } else if(percentage > lowThreshold && percentage <= highThreshold) {
        pinName = @"pin_orange";
    } else {
        pinName = @"pin_red";
    }
    return pinName;
}


@end
