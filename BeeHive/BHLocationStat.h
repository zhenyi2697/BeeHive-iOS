//
//  BHLocationStat.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-08.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHLocationStat : NSObject
@property (strong, nonatomic) NSString *locId;
@property (strong, nonatomic) NSString *occupancy;
@property (strong, nonatomic) NSString *occupancyRaw;
@property (strong, nonatomic) NSString *occupancyPercent;
@property (strong, nonatomic) NSString *bestTime;
@property (strong, nonatomic) NSString *maxCapacity;
@property (strong, nonatomic) NSString *queue;
@property (strong, nonatomic) NSString *thresholdMin;
@property (strong, nonatomic) NSString *thresholdMax;
@end
