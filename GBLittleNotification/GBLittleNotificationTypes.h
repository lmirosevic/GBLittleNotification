//
//  GBLittleNotificationTypes.h
//  GBLittleNotification
//
//  Created by Luka Mirosevic on 13/12/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

typedef enum {
    GBLittleNotificationDisplayEdgeTop,
    GBLittleNotificationDisplayEdgeBottom,
} GBLittleNotificationDisplayEdge;

typedef void(^GBLittleNotificationAnimationBlock)(UIView *notificationView, CGRect restingFrame, UIView *targetViewForPresentation, UIView *backdrop);
typedef void(^GBLittleNotificationSimpleBlock)(void);

