//
//  BHLocationAnnotationView.h
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-04-08.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface BHLocationAnnotationView : MKAnnotationView
@property (nonatomic, strong) UILabel *annotationLabel;
@property (nonatomic, strong) UIImageView *annotationImage;
@end
