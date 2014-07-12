//
//  BHBeeHiveViewController.h
//  BeeHive
//
//  Created by Louis CHEN on 6/19/14.
//  Copyright (c) 2014 Louis CHEN. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>


@interface BHBeeHiveViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
}

- (void) prepareProgressionView;

@end
