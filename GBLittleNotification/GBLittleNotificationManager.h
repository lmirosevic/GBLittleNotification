//
//  GBLittleNotificationManager.h
//  GBLittleNotification
//
//  Created by Luka Mirosevic on 13/12/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - Public

@protocol GBLittleNotificationManagerDelegate;

@class GBLittleNotification;
@class GBLittleNotificationStencil;

@interface GBLittleNotificationManager : NSObject

@property (weak, nonatomic) id<GBLittleNotificationManagerDelegate>         globalDelegate;

+(GBLittleNotificationManager *)sharedManager;

-(GBLittleNotificationStencil *)stencilForIdentifier:(NSString *)notificationIdentifier;

@end

@protocol GBLittleNotificationManagerDelegate <NSObject>
@optional

-(void)didPresentLittleNotification:(GBLittleNotification *)notification withIdentifier:(NSString *)notificationIdentifier;
-(void)didTapOnLittleNotification:(GBLittleNotification *)notification withIdentifier:(NSString *)notificationIdentifier;

@end

#pragma mark - Private

@interface GBLittleNotificationManager ()

-(void)_presentNotification:(GBLittleNotification *)notification;
-(void)_dismissNotification:(GBLittleNotification *)notification animated:(BOOL)animated;

@end
