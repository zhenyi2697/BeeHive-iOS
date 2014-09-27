//
//  BHDataController.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-07.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>


@class BHLocationDetailViewController;

@interface BHDataController : NSObject

@property (nonatomic, strong) NSArray *buildingList;
@property (nonatomic, strong) NSArray *locationList;
@property (nonatomic, strong) NSDictionary *buildingStats;
@property (nonatomic, strong) NSDictionary *locationStats;
@property (nonatomic, strong) NSDictionary *locationHourlyStats;
@property (assign) BOOL connectionLost;
+(id)sharedDataController;
+ (NSArray*) computeLevelInfo: (NSInteger) contributedNumber;

-(void)fetchBuildingsForViewController:(UIViewController *)viewController;
-(void)fetchLocationStatForViewController:(UIViewController *)viewController;
-(void)fetchStatForLocation:(BHLocationDetailViewController *)locationDetailViewController;
-(void)fetchAllLocationHourlyStats;
-(void)postQueueLength:(NSString *)length forLocation:(NSString *)locationId;

@end
