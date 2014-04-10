//
//  BHContributionViewController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-11.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHContributionViewController.h"
#import "BHDataController.h"
#include "JDStatusBarNotification.h"

@interface BHContributionViewController ()
@property (nonatomic, strong) NSIndexPath *checkmarkedIndexPath;
- (IBAction)saveContribution:(id)sender;

@end

@implementation BHContributionViewController

@synthesize checkmarkedIndexPath = _checkmarkedIndexPath;
@synthesize location = _location;

-(NSIndexPath *)checkmarkedIndexPath
{
    if (! _checkmarkedIndexPath) {
        _checkmarkedIndexPath = [NSIndexPath indexPathForRow:2 inSection:0];
    }
    
    return _checkmarkedIndexPath;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.title = self.location.name;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    static NSString *CellIdentifier = @"ContributionCell";
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
//    if (indexPath.row == self.checkmarkedRow) {
//        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//    } else {
//        cell.accessoryType = UITableViewCellAccessoryNone;
//    }
//    return cell;
//}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *oldCell = [tableView cellForRowAtIndexPath:self.checkmarkedIndexPath];
    oldCell.accessoryType = UITableViewCellAccessoryNone;

    // In cellForRow... we check this variable to decide where we put the checkmark
    self.checkmarkedIndexPath = indexPath;
    
    // We reload the table view and the selected row will be checkmarked
    [tableView reloadData];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryCheckmark;
    
    // We select the row without animation to simulate that nothing happened here :)
    [tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
    
    // We deselect the row with animation
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (IBAction)saveContribution:(id)sender {
    
    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
    [JDStatusBarNotification showWithStatus:@"Sending queue information ..." styleName:JDStatusBarStyleDefault];
    
    BHDataController *dataController = [BHDataController sharedDataController];
    [dataController postQueueLength:[NSString stringWithFormat:@"%d", self.checkmarkedIndexPath.row] forLocation:self.location.locId];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelContribution:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


@end
