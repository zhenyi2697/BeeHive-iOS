//
//  BHProgressView.h
//  BeeHive
//
//  Created by Louis CHEN on 6/17/14.
//  Copyright (c) 2014 Louis CHEN. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LDProgressStripes,
    LDProgressGradient,
    LDProgressSolid
} LDProgressType;

@interface BHProgressView : UIView

@property (nonatomic) CGFloat progress;
@property (nonatomic) CGFloat labelProgress;

@property (nonatomic, strong) UIColor *color UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) UIColor *background UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSNumber *flat UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *animate UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *showStroke UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *showText UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *showBackground UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *showBackgroundInnerShadow UI_APPEARANCE_SELECTOR;

@property (nonatomic, strong) NSNumber *outerStrokeWidth UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *progressInset UI_APPEARANCE_SELECTOR;
@property (nonatomic, strong) NSNumber *borderRadius UI_APPEARANCE_SELECTOR;

@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) LDProgressType type;

- (void)overrideProgressText:(NSString *)progressText;
- (void)overrideProgressTextColor:(UIColor *)progressTextColor;

@end

