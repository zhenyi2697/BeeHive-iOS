//
//  BHAppDelegate.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2/17/2014.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHAppDelegate.h"
#import "BHDataController.h"
#import <RestKit/RestKit.h>
#import "BHBuilding.h"
#import "BHLocation.h"
#import "BHMapViewController.h"
#import "BHBuildingAnnotation.h"
#import <GoogleMaps/GoogleMaps.h>

@implementation BHAppDelegate

- (void)loadDataFromRemoteServer
{
    BHDataController *dataController = [BHDataController sharedDataController];
    UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
    UINavigationController *navigationController = [[tabBarController viewControllers] objectAtIndex:0];
    BHMapViewController *mapViewController = [[navigationController viewControllers] objectAtIndex:0];
    
    // Set up logging level for RestKit
    RKLogConfigureByName("RestKit", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelWarning);
    RKLogConfigureByName("RestKit/Network", RKLogLevelWarning);
    
    //Fetch building List for mapView
    [dataController fetchBuildingsForViewController:mapViewController];
    
    // deprecated: now fetchStatistics is called inside the callback of fetchBuildings
    //Fetch locations statistic for mapView
//    [dataController fetchLocationStatForViewController:mapViewController];
    
    //Fetch all location hourly statictic for location detail view
    [dataController fetchAllLocationHourlyStats];
    
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    
    self.window.frame = CGRectMake(0, 0, [[UIScreen mainScreen]bounds].size.width, [[UIScreen mainScreen]bounds].size.height);
    
    [self loadDataFromRemoteServer];
    
    [GMSServices provideAPIKey:@"AIzaSyBCe9eLi04OPVY4hSrjw6p80dM9iKTM2WM"];
    
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
