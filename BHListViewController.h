//
//  BHListViewController.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/18/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BHListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property(nonatomic, strong) IBOutlet UITableView *tableView;
@end
