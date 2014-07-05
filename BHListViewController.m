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
#import "BHLocationTableViewCell.h"
#import "BHLocationDetailViewController.h"
#import "BHUtils.h"


//RefreshControl Library
#import "ODRefreshControl.h"

//SDWebImage Library
#import <SDWebImage/UIImageView+WebCache.h>

@implementation BHListViewController
@synthesize tableView = _tableView;
@synthesize refreshControl = _refreshControl;
@synthesize locationSearchBar = _locationSearchBar, filteredLocations = _filteredLocations, filteredBuildings = _filteredBuildings;
@synthesize toto; //incoming segue identifier

-(ODRefreshControl *)refreshControl
{
    if (!_refreshControl) {
        _refreshControl = [[ODRefreshControl alloc] initInScrollView:self.tableView];
    }
    return _refreshControl;
}

-(NSMutableArray *)filteredLocations
{
    if (!_filteredLocations) {
        _filteredLocations = [NSMutableArray arrayWithCapacity:0];
    }
    return _filteredLocations;
}

-(NSMutableArray *)filteredBuildings
{
    if (!_filteredBuildings) {
        _filteredBuildings = [NSMutableArray arrayWithCapacity:0];
    }
    return _filteredBuildings;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    toto = @"List";
    NSLog(@"*** %@ ***", toto);
    [self.locationSearchBar setShowsScopeBar:NO];
    [self.locationSearchBar sizeToFit];
    
    // Hide the search bar until user scrolls up
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.locationSearchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
    
    // IMPORTANT!
    // Added this line so that refresh control can properly be showed
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
//    self.edgesForExtendedLayout=UIRectEdgeNone;
//    self.extendedLayoutIncludesOpaqueBars=NO;
    self.automaticallyAdjustsScrollViewInsets=YES;
    
    // Add a footer so that the tabbar do not cover the tableView bottom if is not iphone5
    int footerHeight = 0;
    if (IS_IPHONE_5) {
//        footerHeight = 120;
        footerHeight = 0;
    } else if ( IS_IPHONE) {
//        footerHeight = 212;
        footerHeight = 0;
    } else if (IS_IPAD){
        footerHeight = 0;
    }
    
    UIView *footer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, footerHeight)];
    footer.backgroundColor = [UIColor clearColor];
    self.tableView.tableFooterView = footer;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    //Refresh Control
    [self.refreshControl addTarget:self action:@selector(dropViewDidBeginRefreshing:) forControlEvents:UIControlEventValueChanged];

}

- (void)viewWillAppear:(BOOL)animated
{
    BHDataController *dataController = [BHDataController sharedDataController];
    [dataController fetchLocationStatForViewController:self];
}

- (void)viewDidAppear
{
//    [self.tableView reloadData];
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

    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [self.filteredBuildings count];
    } else {
        BHDataController *sharedDataController = [BHDataController sharedDataController];
        return [sharedDataController.buildingList count];
    }
    
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        BHBuilding *bd = [self.filteredBuildings objectAtIndex:section];
        return bd.name;
    } else {
        BHDataController *dataController = [BHDataController sharedDataController];
        BHBuilding *bd = [dataController.buildingList objectAtIndex:section];
        return bd.name;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        BHBuilding *bd = [self.filteredBuildings objectAtIndex:section];
        return [bd.locations count];
    } else {
        BHDataController *dataController = [BHDataController sharedDataController];
        BHBuilding *bd = [dataController.buildingList objectAtIndex:section];
        return [bd.locations count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCell";
    BHLocationTableViewCell *cell;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    } else {
        cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    }
    
    // Configure the cell here
    BHDataController *dataController = [BHDataController sharedDataController];
    BHLocation *loc;
    
    // Check to see whether the normal table or search results table is being displayed and set the Candy object from the appropriate array
    BHBuilding *bd;
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        bd = [self.filteredBuildings objectAtIndex:indexPath.section];
    } else {
        bd = [dataController.buildingList objectAtIndex:indexPath.section];
    }
    
    loc = [bd.locations objectAtIndex:indexPath.row];
    
    BHLocationStat *locStat = [dataController.locationStats objectForKey:loc.locId];
    cell.textLabel.text = loc.name;
    
    // Determine label color
    cell.textLabel.textColor = [BHUtils titleColorForLocationStat:locStat];
    
    cell.detailTextLabel.text = [NSString stringWithFormat:@"Oc: %@%% of %@ Line: %@ Go: %@", locStat.occupancyPercent, locStat.maxCapacity, locStat.queue, locStat.bestTime];
    cell.detailTextLabel.font = [UIFont systemFontOfSize:11];
    
    // Using SDWebImage to load image
    [cell.imageView setImageWithURL:[NSURL URLWithString:loc.photoUrl]
                   placeholderImage:[UIImage imageNamed:@"Beehive.png"]];
    return cell;
}

//- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    return 45;
//}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Perform segue to candy detail
    [self performSegueWithIdentifier:@"showLocationDetailFromListView" sender:tableView]; 
    
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showLocationDetailFromListView"]) {

        BHLocationDetailViewController *detailViewController = [segue destinationViewController];
        BHDataController *dataController = [BHDataController sharedDataController];
        NSIndexPath *indexPath;
        BHBuilding *bd;
        
        if (sender == self.searchDisplayController.searchResultsTableView) {
            indexPath = [self.searchDisplayController.searchResultsTableView indexPathForSelectedRow];
            bd = [self.filteredBuildings objectAtIndex:indexPath.section];
            
        } else {
            indexPath = [self.tableView indexPathForSelectedRow];
            bd = [dataController.buildingList objectAtIndex:indexPath.section];
            
        }
        
        detailViewController.location = [bd.locations objectAtIndex:indexPath.row];
        
        NSArray *weeklyStat = [dataController.locationHourlyStats objectForKey:detailViewController.location.locId];
        detailViewController.weeklyStat = weeklyStat;
        
        if (!weeklyStat) {
            [dataController fetchStatForLocation:detailViewController];
        }
        
    }
}

// Refresh when dropping down
- (void)dropViewDidBeginRefreshing:(ODRefreshControl *)refreshControl
{
    BHDataController *dataController = [BHDataController sharedDataController];
    
    if (dataController.connectionLost) {
        //Fetch building List for mapView
        [dataController fetchBuildingsForViewController:self];
    }
    
    //Fetch locations statistic for mapView
    [dataController fetchLocationStatForViewController:self];
    
    // mimic the behavior of fectching
    //    double delayInSeconds = 1.5;
    //    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    //    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
    //        NSLog(@"Refreshed");
    //        [refreshControl endRefreshing];
    //    });
}

- (IBAction)refreshList:(id)sender {
    
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinner startAnimating];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:spinner];

    BHDataController *dataController = [BHDataController sharedDataController];
    
    if (dataController.connectionLost) {
        //Fetch building List
        [dataController fetchBuildingsForViewController:self];
    }
    
    //Fetch locations statistic 
    [dataController fetchLocationStatForViewController:self];
    
}


// search delegate method
#pragma mark Content Filtering
-(void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    
    // Update the filtered array based on the search text and scope.
    // Remove all objects from the filtered search array
    [self.filteredLocations removeAllObjects];
    [self.filteredBuildings removeAllObjects];
    

    BHDataController *dataController = [BHDataController sharedDataController];

    NSArray *buildingList = dataController.buildingList;
    
    for (BHBuilding *bud in buildingList) {
        BOOL addBuilding = NO;
        // copy the old building object
        BHBuilding *newBud = [[BHBuilding alloc] init];
        newBud.name = bud.name;
        newBud.description = bud.description;
        
        if ([bud.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
            newBud.locations = bud.locations;
            [self.filteredBuildings addObject:newBud];
        } else {
            NSMutableArray *newLocList = [[NSMutableArray alloc] init];
            for (BHLocation *loc in bud.locations) {
                if ([loc.name rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound ||
                    [loc.description rangeOfString:searchText options:NSCaseInsensitiveSearch].location != NSNotFound) {
                    [newLocList addObject:loc];
                    addBuilding = YES;
                    
                }
            }
            
            if (addBuilding) {
                newBud.locations = newLocList;
                [self.filteredBuildings addObject:newBud];
            }
        }
    }
    
}

#pragma mark - UISearchDisplayController Delegate Methods
-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    // Tells the table data source to reload when text changes
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    // Tells the table data source to reload when scope bar selection changes
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    // Return YES to cause the search result table view to be reloaded.
    return YES;
}

- (IBAction)searchLocation:(id)sender {
    [self.locationSearchBar becomeFirstResponder];
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



@end
