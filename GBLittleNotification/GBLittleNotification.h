//
//  GBLittleNotification.h
//  Russia
//
//  Created by Luka Mirosevic on 14/07/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "GBLittleNotificationTypes.h"
#import "GBLittleNotificationStencil.h"
#import "GBLittleNotificationStencil+Presets.h"
#import "GBLittleNotificationManager.h"

#pragma mark - Public

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

#pragma mark - Private

@interface GBLittleNotification ()

@property (strong, nonatomic) UIView                                        *_backdrop;
@property (strong, nonatomic) UITapGestureRecognizer                        *_tapGestureRecognizer;
@property (assign, nonatomic) CGRect                                        _restingFrame;
@property (assign, nonatomic) BOOL                                          _isPresented;

@end
