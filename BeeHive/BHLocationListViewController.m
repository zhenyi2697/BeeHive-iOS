//
//  BHLocationListViewController.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/25/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHLocationListViewController.h"

@interface BHLocationListViewController ()
@property (strong,nonatomic) NSArray *locationList;
@end

@implementation BHLocationListViewController

@synthesize locationList = _locationList;

- (NSArray *)locationList
{
    if (!_locationList) {
        _locationList = [[NSArray alloc] initWithObjects:@"Starbucks", @"Chick-fil-a", @"Post Office", @"Pizza hut", @"Food court", @"Box Office", nil];
    }
    return _locationList;
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
	// Do any additional setup after loading the view.
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 6;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"LocationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell here
    cell.textLabel.text = [self.locationList objectAtIndex:indexPath.row];
    return cell;
}

@end
