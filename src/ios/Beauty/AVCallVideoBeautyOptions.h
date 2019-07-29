//
//  AVCallVideoBeautyOptions.h
//  QingShu
//
//  Created by vitas on 2019/5/25.
//  Copyright © 2019 Vitas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AgoraRtcEngineKit/AgoraRtcEngineKit.h>


NS_ASSUME_NONNULL_BEGIN

@interface AVCallVideoBeautyOptions : NSObject

+ (instancetype)defaultOptions;

@property (strong, nonatomic) AgoraBeautyOptions *beautyOptions;

@property (assign, nonatomic) BOOL isBeautyOn;

@property (nonatomic, assign) AgoraLighteningContrastLevel contrastLevel;

/** The brightness level.
 
 The value ranges from 0.0 (original) to 1.0.
 */
@property (nonatomic, assign) float lighteningLevel;

/** The sharpness level.
 
 The value ranges from 0.0 (original) to 1.0. This parameter is usually used to remove blemishes.
 */
@property (nonatomic, assign) float smoothnessLevel;

/** The redness level.
 
 The value ranges from 0.0 (original) to 1.0. This parameter adjusts the red saturation level.
 */
@property (nonatomic, assign) float rednessLevel;

@end

NS_ASSUME_NONNULL_END
