//
//  GBLittleNotificationStencil+Presets.h
//  Russia
//
//  Created by Luka Mirosevic on 15/07/2013.
//  Copyright (c) 2013 Goonbee. All rights reserved.
//

#import "GBLittleNotification.h"

typedef enum {
    GBLittleNotificationPresentAnimationPresetSlideLeft, 
    GBLittleNotificationPresentAnimationPresetSlideDown,
    GBLittleNotificationPresentAnimationPresetSlideUp,
} GBLittleNotificationPresentAnimationPreset;

typedef enum {
    GBLittleNotificationDismissAnimationPresetSlideLeft,
    GBLittleNotificationDismissAnimationPresetSlideUp,
    GBLittleNotificationDismissAnimationPresetSlideDown,
} GBLittleNotificationDismissAnimationPreset;

@interface GBLittleNotificationStencil (Presets)

-(void)setPresentAnimationFromPreset:(GBLittleNotificationPresentAnimationPreset)presentPreset;
-(void)setDismissAnimationFromPreset:(GBLittleNotificationDismissAnimationPreset)dismissPreset;

-(void)setAnimatioWithPresentPreset:(GBLittleNotificationPresentAnimationPreset)presentPreset andDismissPreset:(GBLittleNotificationDismissAnimationPreset)dismissPreset;

@end
