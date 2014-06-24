//
//  BHBeeHiveViewController.m
//  BeeHive
//
//  Created by Louis CHEN on 6/19/14.
//  Copyright (c) 2014 Louis CHEN All rights reserved.
//

#import "BHBeeHiveViewController.h"
#import "BHListViewController.h"
#import "BHDataController.h"

#import "BHUtils.h"

//SDWebImage Library
#import <SDWebImage/UIImageView+WebCache.h>

#define IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)

@interface BHBeeHiveViewController ()

@end

@implementation BHBeeHiveViewController

- (IBAction)scanButtonClicked:(id)sender {
    [self performSegueWithIdentifier:@"scanSegue" sender:self
     ];
    

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
//    BHDataController *sharedDataController = [BHDataController sharedDataController];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    
    // if segue.identifier == truc 
    BHListViewController *destination = (BHListViewController*) segue.destinationViewController;
    
    destination.toto = 42; 
}

@end
