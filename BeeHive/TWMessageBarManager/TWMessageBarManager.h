//
//  TWMessageBarManager.h
//
//  Created by Terry Worona on 5/13/13.
//  Copyright (c) 2013 Terry Worona. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  Three base message bar types. Their look & feel is defined within the MessageBarStyleSheet.
 */
typedef enum {
    TWMessageBarMessageTypeError,
    TWMessageBarMessageTypeSuccess,
    TWMessageBarMessageTypeInfo
} TWMessageBarMessageType;

@protocol TWMessageBarStyleSheet <NSObject>

/**
 *  Background color of message view.
 *
 *  @param type A MessageBarMessageType (error, information, success, etc).
 *
 *  @return UIColor istance representing the message view's background color.
 */
- (UIColor *)backgroundColorForMessageType:(TWMessageBarMessageType)type;

/**
 *  Bottom stroke color of message view.
 *
 *  @param type A MessageBarMessageType (error, information, success, etc).
 *
 *  @return UIColor istance representing the message view's bottom stroke color.
 */
- (UIColor *)strokeColorForMessageType:(TWMessageBarMessageType)type;

/**
 *  Icon image of the message view.
 *
 *  @param type A MessageBarMessageType (error, information, success, etc)
 *
 *  @return UIImage istance representing the message view's icon.
 */
- (UIImage *)iconImageForMessageType:(TWMessageBarMessageType)type;

@end

@interface TWMessageBarManager : NSObject

/**
 *  Singleton instance through which all presentation is managed.
 *
 *  @return MessageBarManager instance (singleton).
 */
+ (TWMessageBarManager *)sharedInstance;

/**
 *  Default display duration for each message.
 *  This can be customized on a per-message basis (see presentation functions below).
 *
 *  @return Default display duration (3 seconds).
 */
+ (CGFloat)defaultDuration;

/**
 *  An object conforming to the TWMessageBarStyleSheet protocol defines the message bar's look and feel.
 *  If no style sheet is supplied, a default class is provided on initialization (see implementation for details).
 */
@property (nonatomic, strong) NSObject<TWMessageBarStyleSheet> *styleSheet;

/**
 *  Shows a message with the supplied title, description and type (dictates color, stroke and icon).
 *
 *  @param title        Header text in the message view.
 *  @param description  Description text in the message view.
 *  @param type         Type dictates color, stroke and icon shown in the message view.
 */
- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type;

/**
 *  Shows a message with the supplied title, description, type (dictates color, stroke and icon) & callback block.
 *
 *  @param title        Header text in the message view.
 *  @param description  Description text in the message view.
 *  @param type         Type dictates color, stroke and icon shown in the message view.
 *  @param callback     Callback block to be executed if a message is tapped.
 */
- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type callback:(void (^)())callback;

/**
 *  Shows a message with the supplied title, description, type (dictates color, stroke and icon) & duration.
 *
 *  @param title        Header text in the message view.
 *  @param description  Description text in the message view.
 *  @param type         Type dictates color, stroke and icon shown in the message view.
 *  @param duration     Default duration is 3 seconds, this can be overridden by supplying an optional duration parameter.
 */
- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type duration:(CGFloat)duration;

/**
 *  Shows a message with the supplied title, description, type (dictates color, stroke and icon), callback block & duration.
 *
 *  @param title        Header text in the message view.
 *  @param description  Description text in the message view.
 *  @param type         Type dictates color, stroke and icon shown in the message view.
 *  @param duration     Default duration is 3 seconds, this can be overridden by supplying an optional duration parameter.
 *  @param callback     Callback block to be executed if a message is tapped.
 */
- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type duration:(CGFloat)duration callback:(void (^)())callback;

/**
 *  Shows a message with the supplied title, description, type (dictates color, stroke and icon), callback block & duration.
 *
 *  @param title            Header text in the message view.
 *  @param description      Description text in the message view.
 *  @param type             Type dictates color, stroke and icon shown in the message view.
 *  @param statusBarStyle   Applied during the presentation of the message. If not supplied, style will default to UIStatusBarStyleDefault.
 *  @param callback         Callback block to be executed if a message is tapped.
 */
- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)())callback;

/**
 *  Shows a message with the supplied title, description, type (dictates color, stroke and icon), callback block & duration.
 *
 *  @param title            Header text in the message view.
 *  @param description      Description text in the message view.
 *  @param type             Type dictates color, stroke and icon shown in the message view.
 *  @param duration         Default duration is 3 seconds, this can be overridden by supplying an optional duration parameter.
 *  @param statusBarStyle   Applied during the presentation of the message. If not supplied, style will default to UIStatusBarStyleDefault.
 *  @param callback         Callback block to be executed if a message is tapped.
 */
- (void)showMessageWithTitle:(NSString *)title description:(NSString *)description type:(TWMessageBarMessageType)type duration:(CGFloat)duration statusBarStyle:(UIStatusBarStyle)statusBarStyle callback:(void (^)())callback;

/**
 *  Hides the topmost message and removes all remaining messages in the queue.
 *
 *  @param animated     Animates the current message view off the screen.
 */
- (void)hideAllAnimated:(BOOL)animated;
- (void)hideAll; // non-animated

@end

@interface UIDevice (Additions)

/**
 *  Determines if the device instance is running iOS 7 or later.
 *
 *  @return YES if the device instance is running an OS >= 7, otherwise NO.
 */
- (BOOL)isRunningiOS7OrLater;

@end
