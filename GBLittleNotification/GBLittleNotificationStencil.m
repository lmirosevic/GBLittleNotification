//
//  GBLittleNotificationStencil.m
//  GBLittleNotification
//
//  Created by Luka Mirosevic on 13/12/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBLittleNotificationStencil.h"

static BOOL const kDefaultShouldDismissWhenTapped =                         YES;
static BOOL const kDefaultShouldBlockInteractionWhenDisplayed =             NO;
#define kDefaultBackdropColor                                               [UIColor clearColor]
static NSTimeInterval const kDefaultRestDuration =                          2;
static NSTimeInterval const kDefaultAnimationDuration =                     0.3;
static CGFloat const kDefaultVerticalOffset =                               20;
static GBLittleNotificationDisplayEdge const kDefaultDisplayEdge =          GBLittleNotificationDisplayEdgeBottom;
static BOOL const kDefaultIsSticky =                                        NO;
#define kDefaultTargetViewForPresentation                                   [[UIApplication sharedApplication] keyWindow]

@interface GBLittleNotificationStencil ()

@property (copy, nonatomic, readwrite) NSString                             *notificationIdentifier;

@end

@implementation GBLittleNotificationStencil

#pragma mark - Life

+(GBLittleNotificationStencil *)_stencilWithIdentifier:(NSString *)notificationIdentifier {
    return [[self alloc] initWithIdentifier:notificationIdentifier];
}

-(id)initWithIdentifier:(NSString *)notificationIdentifier {
    if (self = [super init]) {
        self.notificationIdentifier = notificationIdentifier;
        
        self.shouldDismissWhenTapped = kDefaultShouldDismissWhenTapped;
        self.shouldBlockInteractionWhileDisplayed = kDefaultShouldBlockInteractionWhenDisplayed;
        self.backdropColor = kDefaultBackdropColor;
        self.restDuration = kDefaultRestDuration;
        self.animationDuration = kDefaultAnimationDuration;
        self.verticalOffset = kDefaultVerticalOffset;
        self.displayEdge = kDefaultDisplayEdge;
        self.isSticky = kDefaultIsSticky;
        self.targetViewForPresentation = kDefaultTargetViewForPresentation;
    }
    
    return self;
}

#pragma mark - API

-(void)setPresentAnimationWillAnimate:(GBLittleNotificationAnimationBlock)willPresentBlock animation:(GBLittleNotificationAnimationBlock)animationBlock didAnimate:(GBLittleNotificationAnimationBlock)didPresentBlock {
    self.willPresentBlock = willPresentBlock;
    self.presentAnimation = animationBlock;
    self.didPresentBlock = didPresentBlock;
}


-(void)setDismissAnimationWillAnimate:(GBLittleNotificationAnimationBlock)willDismissBlock animation:(GBLittleNotificationAnimationBlock)animationBlock didAnimate:(GBLittleNotificationAnimationBlock)didDismissBlock {
    self.willDismissBlock = willDismissBlock;
    self.dismissAnimation = animationBlock;
    self.didDismissBlock = didDismissBlock;
}

@end
