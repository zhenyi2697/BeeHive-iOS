//
//  BHUtils.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-05-19.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>
@class BHLocationStat;

@interface BHUtils : NSObject

+(UIColor *)titleColorForLocationStat:(BHLocationStat *)locStat;
+(CPTColor *)titleColorForLocationStat2:(BHLocationStat *)locStat;
+(NSString *)pinNameforLocationStat:(BHLocationStat *)locStat;
+(NSString *)pinNameForBuilding:(NSString *)bdId;

@end
