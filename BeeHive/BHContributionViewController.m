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
@synthesize location = _location, locationStat = _locationStat;

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

-(CGFloat)tableView:(UITableView*)tableView heightForHeaderInSection:(NSInteger)section
{
    if(section == 0) {
        return 120;
    } else {
        return 1;
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(20,0,300,60)];
    
    // configure labels
    UILabel *occupacyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    occupacyLabel.backgroundColor = [UIColor clearColor];
    occupacyLabel.font = [UIFont systemFontOfSize:15];
    occupacyLabel.frame = CGRectMake(86,16,85,21);
    occupacyLabel.textColor = [UIColor blackColor];
    occupacyLabel.text = @"Occupancy: ";
    
    UILabel *occupacyValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    occupacyValueLabel.backgroundColor = [UIColor clearColor];
    occupacyValueLabel.font = [UIFont systemFontOfSize:14];
    occupacyValueLabel.frame = CGRectMake(174,17,85,21);
    occupacyValueLabel.textColor = [UIColor darkGrayColor];
    occupacyValueLabel.text = [NSString stringWithFormat:@"%@%%", self.locationStat.occupancyPercent];
    
    // Determine label color
    UIColor *titleColor;
    int percentage = (int)[self.locationStat.occupancyPercent integerValue];
    int lowThreshold = (int)[self.locationStat.thresholdMin integerValue];
    int highThreshold = (int)[self.locationStat.thresholdMax integerValue];
    if (percentage <= lowThreshold) {
        titleColor = [UIColor colorWithRed:0 green:150 blue:0 alpha:1]; //green
    } else if(percentage > lowThreshold && percentage < highThreshold) {
        titleColor =[UIColor orangeColor];
    } else {
        titleColor = [UIColor colorWithRed:180 green:0 blue:0 alpha:1]; //red
    }
    occupacyValueLabel.textColor = titleColor;
    
    
    UILabel *queueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    queueLabel.backgroundColor = [UIColor clearColor];
    queueLabel.font = [UIFont systemFontOfSize:15];
    queueLabel.frame = CGRectMake(86,36,56,21);
    queueLabel.textColor = [UIColor blackColor];
    queueLabel.text = @"Queue: ";
    
    UILabel *queueValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    queueValueLabel.backgroundColor = [UIColor clearColor];
    queueValueLabel.font = [UIFont systemFontOfSize:14];
    queueValueLabel.frame = CGRectMake(145,37,56,21);
    queueValueLabel.textColor = [UIColor darkGrayColor];
    queueValueLabel.text = self.locationStat.queue;
    
    UILabel *btgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    btgLabel.backgroundColor = [UIColor clearColor];
    btgLabel.font = [UIFont systemFontOfSize:15];
    btgLabel.frame = CGRectMake(86,56,80,21);
    btgLabel.textColor = [UIColor blackColor];
    btgLabel.text = @"Best to go: ";
    
    UILabel *btgValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    btgValueLabel.backgroundColor = [UIColor clearColor];
    btgValueLabel.font = [UIFont systemFontOfSize:14];
    btgValueLabel.frame = CGRectMake(169,57,80,21);
    btgValueLabel.textColor = [UIColor darkGrayColor];
    btgValueLabel.text = self.locationStat.bestTime;
        
    // create the imageView with the image in it
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 60, 60)];
    [imageView setImageWithURL:[NSURL URLWithString:self.location.photoUrl]
              placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
    
    
    UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    questionLabel.backgroundColor = [UIColor clearColor];
    questionLabel.font = [UIFont italicSystemFontOfSize:16];
    questionLabel.frame = CGRectMake(16,90,280,25);
    questionLabel.textColor = [UIColor blackColor];
    questionLabel.text = @"How is the place today?";
    
    [customView addSubview:imageView];
    [customView addSubview:occupacyLabel];
    [customView addSubview:queueLabel];
    [customView addSubview:btgLabel];
    [customView addSubview:occupacyValueLabel];
    [customView addSubview:queueValueLabel];
    [customView addSubview:btgValueLabel];
    [customView addSubview:questionLabel];
    
    return customView;
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
    [dataController postQueueLength:[NSString stringWithFormat:@"%ld", (long)self.checkmarkedIndexPath.row] forLocation:self.location.locId];
    
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)cancelContribution:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


@end
