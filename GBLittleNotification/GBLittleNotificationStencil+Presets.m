//
//  GBLittleNotificationStencil+Presets.m
//  Russia
//
//  Created by Luka Mirosevic on 15/07/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBLittleNotificationStencil+Presets.h"

@implementation GBLittleNotificationStencil (Presets)

-(void)setPresentAnimationFromPreset:(GBLittleNotificationPresentAnimationPreset)presentPreset {
    switch (presentPreset) {
        case GBLittleNotificationPresentAnimationPresetSlideLeft: {
            [self setPresentAnimationWillAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 0;
                notificationView.frame = CGRectMake(targetViewForPresentation.frame.origin.x + targetViewForPresentation.frame.size.width,
                                                    restingFrame.origin.y,
                                                    restingFrame.size.width,
                                                    restingFrame.size.height);
            } animation:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 1;
                notificationView.frame = restingFrame;
            } didAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                
            }];
        } break;
            
        case GBLittleNotificationPresentAnimationPresetSlideUp: {
            [self setPresentAnimationWillAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 0;
                notificationView.frame = CGRectMake(restingFrame.origin.x,
                                                    targetViewForPresentation.frame.origin.y + targetViewForPresentation.frame.size.height,
                                                    restingFrame.size.width,
                                                    restingFrame.size.height);
            } animation:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 1;
                notificationView.frame = restingFrame;
            } didAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                
            }];
        } break;
            
        case GBLittleNotificationPresentAnimationPresetSlideDown: {
            [self setPresentAnimationWillAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 0;
                notificationView.frame = CGRectMake(restingFrame.origin.x,
                                                    targetViewForPresentation.frame.origin.y - targetViewForPresentation.frame.size.height,
                                                    restingFrame.size.width,
                                                    restingFrame.size.height);
            } animation:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 1;
                notificationView.frame = restingFrame;
            } didAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                
            }];
        } break;
    }

}

-(void)setDismissAnimationFromPreset:(GBLittleNotificationDismissAnimationPreset)dismissPreset {
    switch (dismissPreset) {
        case GBLittleNotificationDismissAnimationPresetSlideLeft: {
            [self setDismissAnimationWillAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 1;
            } animation:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                notificationView.frame = CGRectMake(targetViewForPresentation.frame.origin.x - restingFrame.size.width,
                                                    restingFrame.origin.y,
                                                    restingFrame.size.width,
                                                    restingFrame.size.height);
                backdrop.alpha = 0;
            } didAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                
            }];
        } break;
            
        case GBLittleNotificationDismissAnimationPresetSlideDown: {
            [self setDismissAnimationWillAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 1;
            } animation:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                notificationView.frame = CGRectMake(restingFrame.origin.x,
                                                    targetViewForPresentation.frame.origin.y + targetViewForPresentation.frame.size.height,
                                                    restingFrame.size.width,
                                                    restingFrame.size.height);
                backdrop.alpha = 0;
            } didAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                
            }];
        } break;
            
        case GBLittleNotificationDismissAnimationPresetSlideUp: {
            [self setDismissAnimationWillAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 1;
            } animation:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                backdrop.alpha = 0;
                notificationView.frame = CGRectMake(restingFrame.origin.x,
                                                    targetViewForPresentation.frame.origin.y - targetViewForPresentation.frame.size.height,
                                                    restingFrame.size.width,
                                                    restingFrame.size.height);
            } didAnimate:^(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop) {
                
            }];
        } break;
    }
}

-(void)setAnimatioWithPresentPreset:(GBLittleNotificationPresentAnimationPreset)presentPreset andDismissPreset:(GBLittleNotificationDismissAnimationPreset)dismissPreset {
    [self setPresentAnimationFromPreset:presentPreset];
    [self setDismissAnimationFromPreset:dismissPreset];
}

@end
