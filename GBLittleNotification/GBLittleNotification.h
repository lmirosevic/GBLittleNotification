//
//  GBLittleNotification.h
//  Russia
//
//  Created by Luka Mirosevic on 14/07/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

typedef enum {
    GBLittleNotificationDisplayEdgeTop,
    GBLittleNotificationDisplayEdgeBottom,
} GBLittleNotificationDisplayEdge;

typedef void(^GBLittleNotificationAnimationBlock)(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop);
typedef void(^GBLittleNotificationSimpleBlock)(void);

@interface GBLittleNotificationStencil : NSObject

@property (copy, nonatomic, readonly) NSString                              *notificationIdentifier;                    //so you don't have to recreate them all the time

@property (strong, nonatomic) UIView                                        *notificationView;                          //no default, you must supply this

@property (copy, nonatomic) GBLittleNotificationAnimationBlock              willPresentBlock;
@property (copy, nonatomic) GBLittleNotificationAnimationBlock              presentAnimation;
@property (copy, nonatomic) GBLittleNotificationAnimationBlock              didPresentBlock;

@property (copy, nonatomic) GBLittleNotificationAnimationBlock              willDismissBlock;
@property (copy, nonatomic) GBLittleNotificationAnimationBlock              dismissAnimation;
@property (copy, nonatomic) GBLittleNotificationAnimationBlock              didDismissBlock;

@property (copy, nonatomic) GBLittleNotificationSimpleBlock                 didTapBlock;

@property (assign, nonatomic) BOOL                                          shouldDismissWhenTapped;                    //defaults to YES
@property (assign, nonatomic) BOOL                                          shouldBlockInteractionWhileDisplayed;       //defaults to NO
@property (strong, nonatomic) UIColor                                       *backdropColor;                             //defaults to [UIColor clearColor]
@property (assign, nonatomic) NSTimeInterval                                restDuration;                               //defaults to 2 seconds
@property (assign, nonatomic) NSTimeInterval                                animationDuration;                          //defaults to 0.3 seconds
@property (assign, nonatomic) CGFloat                                       verticalOffset;                             //defaults to 20 points from the bottom
@property (assign, nonatomic) GBLittleNotificationDisplayEdge               displayEdge;                                //defaults to bottom
@property (assign, nonatomic) BOOL                                          isSticky;                                   //defaults to NO
@property (weak, nonatomic) UIView                                          *targetViewForPresentation;                 //defaults to [[UIApplication sharedApplication] keyWindow]

-(void)setPresentAnimationWillAnimate:(GBLittleNotificationAnimationBlock)willPresentBlock animation:(GBLittleNotificationAnimationBlock)animationBlock didAnimate:(GBLittleNotificationAnimationBlock)didPresentBlock;
-(void)setDismissAnimationWillAnimate:(GBLittleNotificationAnimationBlock)willDismissBlock animation:(GBLittleNotificationAnimationBlock)animationBlock didAnimate:(GBLittleNotificationAnimationBlock)didDismissBlock;

GBLittleNotificationStencil * GBLittleNotificationStencilFactory(NSString *identifier);//returns a stencil object, which is a GBLittleNotification object, except stripped of the action methods and delegate. You use it to configure a notification type once so that it can be reuse. The convenience initializer `-[GBLittleNotification littleNotificationWithIdentifier]` then returns a new notification object which is already preconfigured with the properties you previously set on the stencil.

@end

@protocol GBLittleNotificationDelegate;

@interface GBLittleNotification : GBLittleNotificationStencil

@property (weak, nonatomic) id<GBLittleNotificationDelegate>                delegate;
@property (assign, nonatomic, readonly) BOOL                                isPresented;

-(void)present;
-(void)dismiss;

-(void)presentWithTapHandler:(GBLittleNotificationSimpleBlock)tapHandler;

+(GBLittleNotification *)littleNotificationWithIdentifier:(NSString *)notificationIdentifier;//if you configured this type of notification before, you will get one of those objects from here

@end


@protocol GBLittleNotificationDelegate <NSObject>
@optional

-(void)littleNotificationWillPresent:(GBLittleNotification *)littleNotification;
-(void)littleNotificationDidPresent:(GBLittleNotification *)littleNotification;
-(void)littleNotificationWillDismiss:(GBLittleNotification *)littleNotification;
-(void)littleNotificationDidDismiss:(GBLittleNotification *)littleNotification;

@end

#import "GBLittleNotificationStencil+Presets.h"

