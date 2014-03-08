//
//  BHBuilding.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-06.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHBuilding : NSObject
@property (strong, nonatomic) NSString *bdId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *latitude;
@property (nonatomic) NSArray *locations;
@end
