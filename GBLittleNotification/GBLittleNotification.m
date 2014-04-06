//
//  GBLittleNotification.m
//  Russia
//
//  Created by Luka Mirosevic on 14/07/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBLittleNotification.h"

#import "GBLittleNotificationManager.h"

GBLittleNotificationStencil * GBLittleNotificationStencilFactory(NSString *identifier) {
    return [[GBLittleNotificationManager sharedManager] stencilForIdentifier:identifier];
}

@interface GBLittleNotification () <UIGestureRecognizerDelegate>

@property (copy, nonatomic, readwrite) NSString                             *notificationIdentifier;
@property (assign, nonatomic, readwrite) BOOL                               isPresented;

@end

@implementation GBLittleNotification

@synthesize notificationIdentifier;

#pragma mark - CA

-(BOOL)_isPresented {
    return self.isPresented;
}

-(void)set_isPresented:(BOOL)isPresented {
    self.isPresented = isPresented;
}

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
        self._tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_didTap:)];
        self._tapGestureRecognizer.delegate = self;
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
