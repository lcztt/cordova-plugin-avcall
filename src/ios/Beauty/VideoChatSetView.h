//
//  VideoChatSetView.h
//  OpenLive
//
//  Created by GongYuhua on 2019/3/26.
//  Copyright © 2019 Agora. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoChatBeautyItem.h"

NS_ASSUME_NONNULL_BEGIN

@class VideoChatSetView;

@protocol VideoChatSetViewDelegate <NSObject>

- (void)videoChatBeauthSetterViewDidChange:(VideoChatSetView *)view;

@end


@interface VideoChatSetView : UIView

@property (nonatomic, strong) VideoChatBeautyItem *beauthParams;

@property (weak, nonatomic) id<VideoChatSetViewDelegate> delegate;

- (void)reloadData;
- (void)show;
- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
