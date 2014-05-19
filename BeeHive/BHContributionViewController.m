//
//  BHContributionViewController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-11.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHContributionViewController.h"
#import "BHDataController.h"
#import "BHLocationDetailViewController.h"
#import "TWMessageBarManager.h"
#import "BHUtils.h"

@interface BHContributionViewController ()
@property (nonatomic, strong) NSIndexPath *checkmarkedIndexPath;
@property (nonatomic) int contributedNumber;
@property (nonatomic, strong) UILabel *contributionLabel;
- (IBAction)saveContribution:(id)sender;
@end

@implementation BHContributionViewController

@synthesize checkmarkedIndexPath = _checkmarkedIndexPath;
@synthesize location = _location, locationStat = _locationStat;
@synthesize contributionLabel = _contributionLabel;

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
    
    NSString *savedValue = [[NSUserDefaults standardUserDefaults] stringForKey:@"contributionCounter"];
    self.contributedNumber = [savedValue integerValue];
    
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
        if (IS_IPAD) {
            return 210;
        } else {
            return 120;
        }
    } else if(section ==1) {
        return 30;
    }
    return 1;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    // create the parent view that will hold header Label
    UIView* customView = [[UIView alloc] initWithFrame:CGRectMake(20,0,300,60)];
    
    if (section == 0) {
        // configure labels
        
        UILabel *occupacyLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        occupacyLabel.backgroundColor = [UIColor clearColor];
        occupacyLabel.textColor = [UIColor blackColor];
        occupacyLabel.text = @"Occupancy: ";
        
        UILabel *occupacyValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        occupacyValueLabel.backgroundColor = [UIColor clearColor];
        occupacyValueLabel.textColor = [UIColor darkGrayColor];
        occupacyValueLabel.text = [NSString stringWithFormat:@"%@%%", self.locationStat.occupancyPercent];
        
        // Determine label color
        occupacyValueLabel.textColor = [BHUtils titleColorForLocationStat:self.locationStat];
        
        UILabel *queueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        queueLabel.backgroundColor = [UIColor clearColor];
        queueLabel.textColor = [UIColor blackColor];
        queueLabel.text = @"Line: ";
        
        UILabel *queueValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        queueValueLabel.backgroundColor = [UIColor clearColor];
        queueValueLabel.textColor = [UIColor darkGrayColor];
        queueValueLabel.text = self.locationStat.queue;
        
        UILabel *btgLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        btgLabel.backgroundColor = [UIColor clearColor];
        btgLabel.textColor = [UIColor blackColor];
        btgLabel.text = @"Best to go: ";
        
        UILabel *btgValueLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        btgValueLabel.backgroundColor = [UIColor clearColor];
        btgValueLabel.textColor = [UIColor darkGrayColor];
        btgValueLabel.text = self.locationStat.bestTime;
        
        // create the imageView with the image in it
        UIImageView *imageView;
        if (IS_IPAD) {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(40, 40, 120, 120)];
        } else {
            imageView = [[UIImageView alloc] initWithFrame:CGRectMake(16, 16, 60, 60)];
        }
        [imageView setImageWithURL:[NSURL URLWithString:self.location.photoUrl]
                  placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
        
        
        UILabel *questionLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        questionLabel.backgroundColor = [UIColor clearColor];
        questionLabel.textColor = [UIColor blackColor];
        questionLabel.text = @"How is the place today?";
        
        
        if (IS_IPAD) {
            
            occupacyLabel.font = [UIFont systemFontOfSize:18];
            occupacyLabel.frame = CGRectMake(186,56,110,21);
            
            occupacyValueLabel.font = [UIFont systemFontOfSize:17];
            occupacyValueLabel.frame = CGRectMake(291,58,311,18);
            
            queueLabel.font = [UIFont systemFontOfSize:18];
            queueLabel.frame = CGRectMake(186,87,63,18);
            
            queueValueLabel.font = [UIFont systemFontOfSize:17];
            queueValueLabel.frame = CGRectMake(236,85,399,21);
            
            btgLabel.font = [UIFont systemFontOfSize:18];
            btgLabel.frame = CGRectMake(186,113,89,23);
            
            btgValueLabel.font = [UIFont systemFontOfSize:17];
            btgValueLabel.frame = CGRectMake(283,116,378,18);
            
            questionLabel.font = [UIFont italicSystemFontOfSize:19];
            questionLabel.frame = CGRectMake(16,175,280,25);
            
        } else {
            occupacyLabel.font = [UIFont systemFontOfSize:15];
            occupacyLabel.frame = CGRectMake(86,16,85,21);
            
            occupacyValueLabel.font = [UIFont systemFontOfSize:14];
            occupacyValueLabel.frame = CGRectMake(174,17,85,21);
            
            queueLabel.font = [UIFont systemFontOfSize:15];
            queueLabel.frame = CGRectMake(86,36,56,21);
            
            queueValueLabel.font = [UIFont systemFontOfSize:14];
            queueValueLabel.frame = CGRectMake(125,37,56,21);
            
            btgLabel.font = [UIFont systemFontOfSize:15];
            btgLabel.frame = CGRectMake(86,56,80,21);
            
            btgValueLabel.font = [UIFont systemFontOfSize:14];
            btgValueLabel.frame = CGRectMake(169,57,80,21);
            
            questionLabel.font = [UIFont italicSystemFontOfSize:16];
            questionLabel.frame = CGRectMake(16,90,280,25);
        }
        
        
        [customView addSubview:imageView];
        [customView addSubview:occupacyLabel];
        [customView addSubview:queueLabel];
        [customView addSubview:btgLabel];
        [customView addSubview:occupacyValueLabel];
        [customView addSubview:queueValueLabel];
        [customView addSubview:btgValueLabel];
        [customView addSubview:questionLabel];
        
    } else if (section == 1) {
        
        UILabel *contributionLabel;
        
        CGRect screenRect = [[UIScreen mainScreen] bounds];
        CGFloat screenWidth = screenRect.size.width;
        CGFloat screenHeight = screenRect.size.height;
        CGFloat labelWidth = screenWidth;
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight) {
            labelWidth = screenHeight;
        }
        
        if (IS_IPAD) {
            contributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,labelWidth,20)];
            contributionLabel.font = [UIFont systemFontOfSize:15];
        } else {
            contributionLabel = [[UILabel alloc] initWithFrame:CGRectMake(0,0,labelWidth,20)];
            contributionLabel.font = [UIFont systemFontOfSize:12];
        }
        
        contributionLabel.textColor = [UIColor blackColor];
        contributionLabel.textAlignment = NSTextAlignmentCenter;
        
        NSString *level;
        NSString *contributionText;
        
        if (self.contributedNumber > 0 && self.contributedNumber < 20 ) {
            level = @"Larva Yellow Jacket";
        } else if (self.contributedNumber >= 20 && self.contributedNumber < 100) {
            level = @"Baby Yellow Jacket";
        } else if (self.contributedNumber >= 100 && self.contributedNumber < 500) {
            level = @"Medium Yellow Jacket";
        } else if (self.contributedNumber >= 500 && self.contributedNumber < 1000) {
            level = @"King Yellow Jacket";
        } else {
            level = @"Helluvah Yellow Jacket";
        }
        
        if (self.contributedNumber == 0) {
            contributionText = @"You have not yet contributed.";
        } else {
            contributionText = [NSString stringWithFormat:@"%d Points", self.contributedNumber * 10];
        }
        
        contributionLabel.text = [NSString stringWithFormat:@"%@ - %@", level, contributionText];
        
        NSLayoutConstraint* con = [NSLayoutConstraint constraintWithItem:contributionLabel attribute:NSLayoutAttributeCenterX relatedBy:0 toItem:customView attribute: NSLayoutAttributeCenterX multiplier:1 constant:0];
        
        NSLayoutConstraint *con1 =[NSLayoutConstraint
                                           constraintWithItem:contributionLabel
                                           attribute:NSLayoutAttributeWidth
                                           relatedBy:NSLayoutRelationEqual
                                           toItem:customView
                                           attribute:NSLayoutAttributeWidth
                                           multiplier:1
                                           constant:0];
        
        [customView addSubview:contributionLabel];
        
        self.contributionLabel = contributionLabel;
        
        [customView addConstraint:con];
        [customView addConstraint:con1];

    }
    
    
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
    
//    [JDStatusBarNotification showActivityIndicator:YES indicatorStyle:UIActivityIndicatorViewStyleGray];
//    [JDStatusBarNotification showWithStatus:@"Sending queue information ..." styleName:JDStatusBarStyleDefault];
    [[TWMessageBarManager sharedInstance] showMessageWithTitle:@"Thank you for your contribution !" description:@"Points + 10 !" type:TWMessageBarMessageTypeSuccess duration:3.0];

    
    BHDataController *dataController = [BHDataController sharedDataController];
    [dataController postQueueLength:[NSString stringWithFormat:@"%ld", (long)self.checkmarkedIndexPath.row] forLocation:self.location.locId];
    
    NSString *valueToSave = [NSString stringWithFormat:@"%d", self.contributedNumber + 1 ];
    [[NSUserDefaults standardUserDefaults]
     setObject:valueToSave forKey:@"contributionCounter"];
    
    // modify data source to take account the newest changes
    BHLocationStat *locationStat = [dataController.locationStats objectForKey:self.location.locId];
    NSString *queueText = nil;
    switch (self.checkmarkedIndexPath.row) {
        case 0:
            queueText = @"closed";
            break;
        case 1:
            queueText = @"short";
            break;
        case 2:
            queueText = @"medium";
            break;
        case 3:
            queueText = @"long";
            break;
        default:
            break;
    }
    locationStat.queue = queueText;
    

    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)viewWillAppear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter] addObserver:self  selector:@selector(orientationChanged:)  name:UIDeviceOrientationDidChangeNotification  object:nil];
}


// detect orientation change and act accordingly
- (void)orientationChanged:(NSNotification *)notification{
    [self adjustViewsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)adjustViewsForOrientation:(UIInterfaceOrientation) orientation {
    
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    CGFloat screenHeight = screenRect.size.height;
    
    if (orientation == UIInterfaceOrientationPortrait || orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        //load the portrait view
        self.contributionLabel.frame = CGRectMake(0,0,screenWidth,20);
        
    } else if (orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
    {
        //load the landscape view
        self.contributionLabel.frame = CGRectMake(0,0,screenHeight,20);
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [[NSNotificationCenter defaultCenter]removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}


- (IBAction)cancelContribution:(id)sender {
    [[self presentingViewController] dismissViewControllerAnimated:YES completion:nil];
}


@end
