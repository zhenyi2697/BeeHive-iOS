//
//  BHLocationAnnotationView.m
//  BeeHive
//
//  Created by Zhenyi ZHANG on 2014-04-08.
//  Copyright (c) 2014 Zhenyi Zhang. All rights reserved.
//

#import "BHLocationAnnotationView.h"

#define kHeight 36
#define kWidth 36
#define kBorder 0

@implementation BHLocationAnnotationView

@synthesize annotationImage = _annotationImage, annotationLabel = _annotationLabel;
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

// determine the MKAnnotationView based on the annotation info and reuseIdentifier
- (id)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    if(self)
    {
        self.frame = CGRectMake(0, 0, kWidth, kHeight);
        self.backgroundColor = [UIColor clearColor];
        
        // Add the annotation'image
        self.annotationImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, kWidth, kHeight)];
        self.annotationImage.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.annotationImage];
        
        //Creating label for display number on bubble
        self.annotationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, 36, 18)];
        self.annotationLabel.font = [UIFont systemFontOfSize:17.0];
        self.annotationLabel.textColor = [UIColor whiteColor];
        self.annotationLabel.textAlignment=NSTextAlignmentCenter;
        self.annotationLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.annotationLabel.backgroundColor = [UIColor clearColor];
        [self.annotationImage addSubview:self.annotationLabel]; }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
