//
//  AVCallVideoBeautySetterView.h
//  OpenLive
//
//  Created by GongYuhua on 2019/3/26.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AVCallVideoBeautyOptions.h"

NS_ASSUME_NONNULL_BEGIN

@class AVCallVideoBeautySetterView;

@protocol AVCallVideoBeautySetterViewDelegate <NSObject>

- (void)videoChatBeauthSetterViewDidChange:(AVCallVideoBeautySetterView *)view;

@end


@interface AVCallVideoBeautySetterView : UIView

@property (nonatomic, strong) AVCallVideoBeautyOptions *beauthParams;

@property (weak, nonatomic) id<AVCallVideoBeautySetterViewDelegate> delegate;

- (void)reloadData;
- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
