//
//  BHListViewController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/18/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHListViewController.h"
#import "BHBuilding.h"
#import "BHLocation.h"
#import "BHLocationStat.h"
#import "BHDataController.h"

//RefreshControl Library
#import "ODRefreshControl.h"

@interface BHListViewController ()
@property (strong,nonatomic) NSArray *buildingArray;
@end


@implementation BHListViewController

@synthesize buildingArray = _buildingArray;

- (NSArray *)buildingArray
{
    if (!_buildingArray) {
        _buildingArray = [[NSArray alloc] initWithObjects:@"Academy of Medicine", @"College of Compting", @"Van Leer", @"Klaus", @"Lyman Hall", @"Student Center", @"Clough", @"CRC", @"Tech Tower", @"Tutoring", @"Housing Office",nil];
    }
    return _buildingArray;
}

//- (id)initWithStyle:(UITableViewStyle)style
//{
//    self = [super initWithStyle:style];
//    if (self) {
//        // Custom initialization
//    }
//    return self;
//}

- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    double delayInSeconds = 3.0;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSLog(@"Refreshed");
        [refreshControl endRefreshing];
    });
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // IMPORTANT!
    // Added this line so that refresh control can properly be showed
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
//    self.edgesForExtendedLayout=UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=YES;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Refresh Control
    ODRefreshControl *refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    [refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];
}

- (void)viewDidAppear
{
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    BHDataController *sharedDataController = [BHDataController sharedDataController];
    return [sharedDataController.buildingList count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    BHDataController *dataController = [BHDataController sharedDataController];
    BHBuilding *bd = [dataController.buildingList objectAtIndex:section];
    return bd.name;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    BHDataController *dataController = [BHDataController sharedDataController];
    BHBuilding *bd = [dataController.buildingList objectAtIndex:section];
    return [bd.locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell here
//    cell.textLabel.text = [self.buildingArray objectAtIndex:indexPath.row];
    BHDataController *dataController = [BHDataController sharedDataController];
    BHBuilding *bd = [dataController.buildingList objectAtIndex:indexPath.section];
    BHLocation *loc = [bd.locations objectAtIndex:indexPath.row];
    BHLocationStat *locStat = [dataController.locationStats objectForKey:loc.locId];
    cell.textLabel.text = loc.name;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Occupancy: %@. Best to go after %@", locStat.occupancy, locStat.bestTime];
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}

 */

@end
