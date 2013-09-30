//
//  GBLittleNotification.m
//  Russia
//
//  Created by Luka Mirosevic on 14/07/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBLittleNotification.h"

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

+(GBLittleNotificationStencil *)stencilWithIdentifier:(NSString *)notificationIdentifier {
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





@interface GBLittleNotification () <UIGestureRecognizerDelegate>

@property (assign, nonatomic, readwrite) BOOL                               isPresented;

@property (strong, nonatomic) UIView                                        *backdrop;
@property (assign, nonatomic) CGRect                                        restingFrame;

@property (strong, nonatomic) UITapGestureRecognizer                        *tapGestureRecognizer;

@end




@interface GBLittleNotificationManager ()

@property (strong, nonatomic) NSMutableDictionary                           *stencils;
@property (strong, nonatomic) GBLittleNotification                          *lastNotification;

@end

@implementation GBLittleNotificationManager

#pragma mark - CA

-(NSMutableDictionary *)stencils {
    if (!_stencils) {
        _stencils = [NSMutableDictionary new];
    }
    
    return _stencils;
}

#pragma mark - Life

+(GBLittleNotificationManager *)sharedManager {
    static GBLittleNotificationManager *_sharedManager;
    @synchronized(self) {
        if (!_sharedManager) {
            _sharedManager = [GBLittleNotificationManager new];
        }
    }
    
    return _sharedManager;
}

#pragma mark - API

-(GBLittleNotificationStencil *)stencilForIdentifier:(NSString *)notificationIdentifier {
    //if there's no identifier then just create a default stencil
    if (!notificationIdentifier) {
        return [GBLittleNotificationStencil stencilWithIdentifier:nil];
    }
    //otherwise return the same one every time
    else {
        GBLittleNotificationStencil *stencil = self.stencils[notificationIdentifier];
        
        //if we don't have one yet, create a new one and remember it
        if (!stencil) {
            stencil = [GBLittleNotificationStencil stencilWithIdentifier:notificationIdentifier];
            self.stencils[notificationIdentifier] = stencil;
        }
        
        return stencil;
    }
}

#pragma mark - private API

-(void)_presentNotification:(GBLittleNotification *)notification {
    [self _dismissLastNotification];
    
    self.lastNotification = notification;

    if (!notification.presentAnimation) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"GBLittleNotification did not have a present animation block" userInfo:nil];
    if (!notification.dismissAnimation) @throw [NSException exceptionWithName:NSInternalInconsistencyException reason:@"GBLittleNotification did not have a dismiss animation block" userInfo:nil];
    
    //will present
    if ([notification.delegate respondsToSelector:@selector(littleNotificationWillPresent:)]) {
        [notification.delegate littleNotificationWillPresent:notification];
    }
    
    //show backdrop
    notification.backdrop = [[UIView alloc] initWithFrame:notification.targetViewForPresentation.bounds];
    notification.backdrop.backgroundColor = notification.backdropColor;
    notification.backdrop.userInteractionEnabled = notification.shouldBlockInteractionWhileDisplayed;
    
    //attach gesture recognizer
    [notification.notificationView addGestureRecognizer:notification.tapGestureRecognizer];

    [notification.targetViewForPresentation addSubview:notification.backdrop];
    [notification.targetViewForPresentation addSubview:notification.notificationView];
    
    //in case of bottom
    CGRect restingFrame;
    switch (notification.displayEdge) {
        case GBLittleNotificationDisplayEdgeBottom: {
            restingFrame = CGRectMake((notification.targetViewForPresentation.bounds.size.width - notification.notificationView.frame.size.width) * 0.5,
                                      notification.targetViewForPresentation.bounds.size.height - notification.notificationView.frame.size.height - notification.verticalOffset,
                                      notification.notificationView.frame.size.width,
                                      notification.notificationView.frame.size.height);
        } break;
            
        case GBLittleNotificationDisplayEdgeTop: {
            restingFrame = CGRectMake((notification.targetViewForPresentation.bounds.size.width - notification.notificationView.frame.size.width) * 0.5,
                                      notification.targetViewForPresentation.bounds.origin.y + notification.verticalOffset,
                                      notification.notificationView.frame.size.width,
                                      notification.notificationView.frame.size.height);
        } break;
    }
    
    //remember the frame
    notification.restingFrame = restingFrame;
    
    //prep animations
    if (notification.willPresentBlock) notification.willPresentBlock(notification.notificationView, notification.restingFrame, notification.targetViewForPresentation, notification.backdrop);
    
    //do animation
    [UIView animateWithDuration:notification.animationDuration animations:^{
        if (notification.presentAnimation) notification.presentAnimation(notification.notificationView, notification.restingFrame, notification.targetViewForPresentation, notification.backdrop);
    } completion:^(BOOL finished) {
        if (notification.didPresentBlock) notification.didPresentBlock(notification.notificationView, notification.restingFrame, notification.targetViewForPresentation, notification.backdrop);
       
        //auto dismiss
        if (!notification.isSticky) {
            __weak GBLittleNotification *weakNotification = notification;
            double delayInSeconds = notification.restDuration;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                if (weakNotification) {
                    [self _dismissNotification:weakNotification animated:YES];
                }
            });
        }
    }];
    
    //set its state
    notification.isPresented = YES;
    
    //did present
    if ([notification.delegate respondsToSelector:@selector(littleNotificationDidPresent:)]) {
        [notification.delegate littleNotificationDidPresent:notification];
    }
}

-(void)_dismissNotification:(GBLittleNotification *)notification animated:(BOOL)animated {
    //will dismiss
    if ([notification.delegate respondsToSelector:@selector(littleNotificationWillDismiss:)]) {
        [notification.delegate littleNotificationWillDismiss:notification];
    }
    
    //prep animations
    if (notification.willDismissBlock) notification.willDismissBlock(notification.notificationView, notification.restingFrame, notification.targetViewForPresentation, notification.backdrop);
    
    //remove gesture recognizer
    [notification.notificationView removeGestureRecognizer:notification.tapGestureRecognizer];
    
    if (animated) {
        //do animation
        [UIView animateWithDuration:notification.animationDuration animations:^{
            if (notification.dismissAnimation) notification.dismissAnimation(notification.notificationView, notification.restingFrame, notification.targetViewForPresentation, notification.backdrop);
        } completion:^(BOOL finished) {
            if (notification.didDismissBlock) notification.didDismissBlock(notification.notificationView, notification.restingFrame, notification.targetViewForPresentation, notification.backdrop);
            
            //clean up view
            [notification.backdrop removeFromSuperview];
            [notification.notificationView removeFromSuperview];
            
            //remove from last if it's me
            if (self.lastNotification == notification) self.lastNotification = nil;
        }];
    }
    else {
        //animate
        if (notification.dismissAnimation) notification.dismissAnimation(notification.notificationView, notification.restingFrame, notification.targetViewForPresentation, notification.backdrop);
        
        //did
        if (notification.didDismissBlock) notification.didDismissBlock(notification.notificationView, notification.restingFrame, notification.targetViewForPresentation, notification.backdrop);
        
        //clean up view
        [notification.backdrop removeFromSuperview];
        [notification.notificationView removeFromSuperview];
        
        //remove from last if it's me
        if (self.lastNotification == notification) self.lastNotification = nil;
    }
    
    //set its state
    notification.isPresented = NO;
    
    //did dismiss
    if ([notification.delegate respondsToSelector:@selector(littleNotificationDidDismiss:)]) {
        [notification.delegate littleNotificationDidDismiss:notification];
    }
}

-(void)_dismissLastNotification {
    if (self.lastNotification) {
        [self _dismissNotification:self.lastNotification animated:NO];
        self.lastNotification = nil;
    }
}

@end





@implementation GBLittleNotification

#pragma mark - Life

+(GBLittleNotification *)littleNotificationWithIdentifier:(NSString *)notificationIdentifier {
    return [[self alloc] initWithStencil:[[GBLittleNotificationManager sharedManager] stencilForIdentifier:notificationIdentifier]];
}

-(id)initWithStencil:(GBLittleNotificationStencil *)stencil {
    if (self = [super init]) {
        //set all the properties from the stencil
        self.notificationIdentifier = stencil.notificationIdentifier;
        self.shouldDismissWhenTapped = stencil.shouldDismissWhenTapped;
        self.shouldBlockInteractionWhileDisplayed = stencil.shouldBlockInteractionWhileDisplayed;
        self.backdropColor = stencil.backdropColor;
        self.restDuration = stencil.restDuration;
        self.animationDuration = stencil.animationDuration;
        self.verticalOffset = stencil.verticalOffset;
        self.displayEdge = stencil.displayEdge;
        self.isSticky = stencil.isSticky;
        self.targetViewForPresentation = stencil.targetViewForPresentation;

        self.notificationView = stencil.notificationView;
        
        self.willPresentBlock = stencil.willPresentBlock;
        self.presentAnimation = stencil.presentAnimation;
        self.didPresentBlock = stencil.didPresentBlock;
        
        self.willDismissBlock = stencil.willDismissBlock;
        self.dismissAnimation = stencil.dismissAnimation;
        self.didDismissBlock = stencil.didDismissBlock;
        
        self.didTapBlock = stencil.didTapBlock;
        
        //create the tap gesture recognizer
        self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didTap:)];
        self.tapGestureRecognizer.delegate = self;
    }
    
    return self;
}

#pragma mark - API

-(void)present {
    [[GBLittleNotificationManager sharedManager] _presentNotification:self];
}

-(void)dismiss {
    [[GBLittleNotificationManager sharedManager] _dismissNotification:self animated:YES];
}

-(void)presentWithTapHandler:(GBLittleNotificationSimpleBlock)tapHandler {
    self.didTapBlock = tapHandler;
    
    [[GBLittleNotificationManager sharedManager] _presentNotification:self];
}

#pragma mark - Gesture

//we don't want our touch to get registered in case the user tapped on a control
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if ([touch.view isKindOfClass:UIControl.class]) {
        return NO;
    }
    else {
        return YES;
    }
}

-(void)_didTap:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.state == UIGestureRecognizerStateEnded) {
        //if the tap is on the notification view
        CGPoint tapLocation = [tapGestureRecognizer locationInView:self.notificationView];
        
        if (CGRectContainsPoint(self.notificationView.bounds, tapLocation)) {
            //call on tap code
            if (self.didTapBlock) self.didTapBlock();
            
            //notify delegate
            if ([[GBLittleNotificationManager sharedManager].globalDelegate respondsToSelector:@selector(didTapOnLittleNotification:withIdentifier:)]) {
                [[GBLittleNotificationManager sharedManager].globalDelegate didTapOnLittleNotification:self withIdentifier:self.notificationIdentifier];
            }
            
            if (self.shouldDismissWhenTapped) {
                //dismiss
                [self dismiss];
            }
        }
    }
}

@end


GBLittleNotificationStencil * GBLittleNotificationStencilFactory(NSString *identifier) {
    return [[GBLittleNotificationManager sharedManager] stencilForIdentifier:identifier];
}



