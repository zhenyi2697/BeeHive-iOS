//
//  BHDailyStat.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-29.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHDailyStat : NSObject
@property (strong, nonatomic) NSString *day;
@property (strong, nonatomic) NSString *clients;
@property (strong, nonatomic) NSArray *hours;
@end
