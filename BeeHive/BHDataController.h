//
//  BHDataController.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-07.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHDataController : NSObject

@property (nonatomic, strong) NSArray *buildingList;
@property (nonatomic, strong) NSArray *locationList;
@property (nonatomic, strong) NSDictionary *locationStats;
+(id)sharedDataController;

-(void)fetchBuildingsForViewController:(UIViewController *)viewController;
-(void)fetchLocationStatForViewController:(UIViewController *)viewController;

@end
