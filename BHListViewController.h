//
//  BHListViewController.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/18/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

//RefreshControl Library
#import "ODRefreshControl.h"

@interface BHListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate, UISearchDisplayDelegate>
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@property(nonatomic, strong) ODRefreshControl *refreshControl;
@property (strong,nonatomic) NSMutableArray *filteredLocations;
@property (strong,nonatomic) NSMutableArray *filteredBuildings;
@property IBOutlet UISearchBar *locationSearchBar;
- (IBAction)searchLocation:(id)sender;
@end
