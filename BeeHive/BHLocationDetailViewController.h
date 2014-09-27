//
//  BHLocationDetailViewController.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-11.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>
//#import "CorePlot-CocoaTouch.h"
@class BHLocation;
@class BHLocationStat;
@class BHDataController;

@interface BHLocationDetailViewController : UIViewController <CPTBarPlotDataSource, CPTBarPlotDelegate, CPTPlotDataSource>
@property (strong,nonatomic) BHLocation *location;
@property (strong,nonatomic) BHLocationStat *locationStat;
@property (strong,nonatomic) NSArray *weeklyStat;

@property (strong, nonatomic) IBOutlet UIImageView *locationImageView;
@property (strong, nonatomic) IBOutlet UILabel *occupancyLabel;
@property (strong, nonatomic) IBOutlet UILabel *btgLabel;
@property (strong, nonatomic) IBOutlet UILabel *queueLabel;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

-(int)currentWeeday;
-(void)initDailyPlot;
-(void)initHourlyStatPlotForDay:(int)dayIndex;

@end
