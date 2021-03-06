//
//  UIView+AVCall.h
//  avcall
//
//  Created by vitas on 2019/7/29.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIView (AVCall)

- (void)bringToFront;

/// frame.origin
@property (nonatomic) CGPoint origin;
/// frame.size
@property (nonatomic) CGSize size;
/// Shortcut for frame.origin.x
@property (nonatomic) CGFloat left;
/// Shortcut for frame.origin.y
@property (nonatomic) CGFloat top;
/// Shortcut for frame.origin.x + frame.size.width
@property (nonatomic) CGFloat right;
/// Shortcut for frame.origin.y + frame.size.height
@property (nonatomic) CGFloat bottom;
/// Shortcut for frame.size.width
@property (nonatomic) CGFloat width;
/// Shortcut for frame.size.height
@property (nonatomic) CGFloat height;
/// Shortcut for center.x
@property (nonatomic) CGFloat centerX;
/// Shortcut for center.y
@property (nonatomic) CGFloat centerY;

@end

NS_ASSUME_NONNULL_END
