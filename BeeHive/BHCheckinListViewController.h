//
//  BHCheckinListViewController.h
//  BeeHive
//
//  Created by Louis CHEN on 6/30/14.
//  Copyright (c) 2014 Louis CHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BHLocation.h"
#import "BHLocationStat.h"

//RefreshControl Library
#import "ODRefreshControl.h"


@interface BHCheckinListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) ODRefreshControl *refreshControl;
@property (strong,nonatomic) NSMutableArray *filteredLocations;
@property (strong,nonatomic) NSMutableArray *filteredBuildings;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *refreshButton;


@property NSString *toto;
//@property IBOutlet UISearchBar *locationSearchBar;
//- (IBAction)searchLocation:(id)sender;
@end

