//
//  GBLittleNotificationManager.m
//  GBLittleNotification
//
//  Created by Luka Mirosevic on 13/12/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBLittleNotificationManager.h"

#import "GBLittleNotificationStencil.h"
#import "GBLittleNotification.h"

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
        return [GBLittleNotificationStencil _stencilWithIdentifier:nil];
    }
    //otherwise return the same one every time
    else {
        GBLittleNotificationStencil *stencil = self.stencils[notificationIdentifier];
        
        //if we don't have one yet, create a new one and remember it
        if (!stencil) {
            stencil = [GBLittleNotificationStencil _stencilWithIdentifier:notificationIdentifier];
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
    notification._backdrop = [[UIView alloc] initWithFrame:notification.targetViewForPresentation.bounds];
    notification._backdrop.backgroundColor = notification.backdropColor;
    notification._backdrop.userInteractionEnabled = notification.shouldBlockInteractionWhileDisplayed;
    
    //attach gesture recognizer
    [notification.notificationView addGestureRecognizer:notification._tapGestureRecognizer];
    
    //add the views to the targetview
    [notification.targetViewForPresentation addSubview:notification._backdrop];
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
    notification._restingFrame = restingFrame;
    
    //prep animations
    if (notification.willPresentBlock) notification.willPresentBlock(notification.notificationView, notification._restingFrame, notification.targetViewForPresentation, notification._backdrop);
    
    //do animation
    [UIView animateWithDuration:notification.animationDuration animations:^{
        if (notification.presentAnimation) notification.presentAnimation(notification.notificationView, notification._restingFrame, notification.targetViewForPresentation, notification._backdrop);
    } completion:^(BOOL finished) {
        if (notification.didPresentBlock) notification.didPresentBlock(notification.notificationView, notification._restingFrame, notification.targetViewForPresentation, notification._backdrop);
        
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
    notification._isPresented = YES;
    
    //delegate
    if ([notification.delegate respondsToSelector:@selector(littleNotificationDidPresent:)]) {
        [notification.delegate littleNotificationDidPresent:notification];
    }
    
    //global delegate
    if ([[GBLittleNotificationManager sharedManager].globalDelegate respondsToSelector:@selector(didPresentLittleNotification:withIdentifier:)]) {
        [[GBLittleNotificationManager sharedManager].globalDelegate didPresentLittleNotification:notification withIdentifier:notification.notificationIdentifier];
    }
}

-(void)_dismissNotification:(GBLittleNotification *)notification animated:(BOOL)animated {
    //will dismiss
    if ([notification.delegate respondsToSelector:@selector(littleNotificationWillDismiss:)]) {
        [notification.delegate littleNotificationWillDismiss:notification];
    }
    
    //prep animations
    if (notification.willDismissBlock) notification.willDismissBlock(notification.notificationView, notification._restingFrame, notification.targetViewForPresentation, notification._backdrop);
    
    //remove gesture recognizer
    [notification.notificationView removeGestureRecognizer:notification._tapGestureRecognizer];
    
    if (animated) {
        //do animation
        [UIView animateWithDuration:notification.animationDuration animations:^{
            if (notification.dismissAnimation) notification.dismissAnimation(notification.notificationView, notification._restingFrame, notification.targetViewForPresentation, notification._backdrop);
        } completion:^(BOOL finished) {
            if (notification.didDismissBlock) notification.didDismissBlock(notification.notificationView, notification._restingFrame, notification.targetViewForPresentation, notification._backdrop);
            
            //clean up view
            [notification._backdrop removeFromSuperview];
            [notification.notificationView removeFromSuperview];
            
            //remove from last if it's me
            if (self.lastNotification == notification) self.lastNotification = nil;
        }];
    }
    else {
        //animate
        if (notification.dismissAnimation) notification.dismissAnimation(notification.notificationView, notification._restingFrame, notification.targetViewForPresentation, notification._backdrop);
        
        //did
        if (notification.didDismissBlock) notification.didDismissBlock(notification.notificationView, notification._restingFrame, notification.targetViewForPresentation, notification._backdrop);
        
        //clean up view
        [notification._backdrop removeFromSuperview];
        [notification.notificationView removeFromSuperview];
        
        //remove from last if it's me
        if (self.lastNotification == notification) self.lastNotification = nil;
    }
    
    //set its state
    notification._isPresented = NO;
    
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
