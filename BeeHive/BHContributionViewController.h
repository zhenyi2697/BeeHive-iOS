//
//  BHContributionViewController.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-11.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
@class BHLocation;
@class BHLocationStat;

@interface BHContributionViewController : UITableViewController

@property (nonatomic, strong) BHLocation *location;
@property (strong, nonatomic) BHLocationStat *locationStat;

@end
