//
//  BHLocation.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-03-06.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BHLocation : NSObject

@property (strong, nonatomic) NSString *locId;
@property (strong, nonatomic) NSString *name;
@property (strong, nonatomic) NSString *description;
@property (strong, nonatomic) NSString *photoUrl;
@property (strong, nonatomic) NSString *longitude;
@property (strong, nonatomic) NSString *latitude;

@end
