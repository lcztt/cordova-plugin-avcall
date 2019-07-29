//
//  AVCallVideoBeautySetterView.m
//  OpenLive
//
//  Created by GongYuhua on 2019/3/26.
//  Copyright © 2019 Agora. All rights reserved.
//

#import "AVCallVideoBeautySetterView.h"
#import "UIView+AVCall.h"

@interface AVCallVideoBeautySetterView ()

@property (nonatomic, strong) UIView *contentView;

@property (strong, nonatomic) UISegmentedControl *switcher;

@property (strong, nonatomic) UILabel *contrastTitleLabel;
@property (strong, nonatomic) UISegmentedControl *contrastSwitcher;

@property (strong, nonatomic) UILabel *lighteningTitleLabel;
@property (strong, nonatomic) UILabel *lighteningValueLabel;
@property (strong, nonatomic) UISlider *lighteningSlider;

@property (strong, nonatomic) UILabel *smoothnessTitleLabel;
@property (strong, nonatomic) UILabel *smoothnessValueLabel;
@property (strong, nonatomic) UISlider *smoothnessSlider;

@property (strong, nonatomic) UILabel *rednessTitleLabel;
@property (strong, nonatomic) UILabel *rednessValueLabel;
@property (strong, nonatomic) UISlider *rednessSlider;

@end

@implementation AVCallVideoBeautySetterView

- (instancetype)initWithFrame:(CGRect)frame
{
    frame = [UIScreen mainScreen].bounds;
    self = [super initWithFrame:frame];
    if (self) {
        
        self.contentView = [[UIView alloc] init];
        self.contentView.backgroundColor = [UIColor whiteColor];
        self.contentView.layer.masksToBounds = YES;
        self.contentView.layer.cornerRadius = 4;
        self.contentView.layer.borderWidth = 0;
        [self addSubview:self.contentView];
        
        self.switcher = [[UISegmentedControl alloc] initWithItems:@[@"ON", @"OFF"]];
        [self.switcher addTarget:self action:@selector(doSwitched:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.switcher];
        
        self.contrastTitleLabel = [[UILabel alloc] init];
        self.contrastTitleLabel.font = [UIFont systemFontOfSize:16];
        self.contrastTitleLabel.textColor = [UIColor blackColor];
        self.contrastTitleLabel.text = @"亮度";
        [self.contentView addSubview:self.contrastTitleLabel];
        
        self.contrastSwitcher = [[UISegmentedControl alloc] initWithItems:@[@"Low", @"Normal", @"High"]];
        [self.contrastSwitcher addTarget:self action:@selector(doConstrastChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.contrastSwitcher];

        self.lighteningTitleLabel = [[UILabel alloc] init];
        self.lighteningTitleLabel.font = [UIFont systemFontOfSize:16];
        self.lighteningTitleLabel.textColor = [UIColor blackColor];
        self.lighteningTitleLabel.text = @"光线";
        [self.contentView addSubview:self.lighteningTitleLabel];
        
        self.lighteningValueLabel = [[UILabel alloc] init];
        self.lighteningValueLabel.font = [UIFont systemFontOfSize:16];
        self.lighteningValueLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.lighteningValueLabel];
        
        self.lighteningSlider = [[UISlider alloc] init];
        [self.lighteningSlider addTarget:self action:@selector(doLighteningSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.lighteningSlider];
        
        self.smoothnessTitleLabel = [[UILabel alloc] init];
        self.smoothnessTitleLabel.font = [UIFont systemFontOfSize:16];
        self.smoothnessTitleLabel.textColor = [UIColor blackColor];
        self.smoothnessTitleLabel.text = @"平滑";
        [self.contentView addSubview:self.smoothnessTitleLabel];
        
        self.smoothnessValueLabel = [[UILabel alloc] init];
        self.smoothnessValueLabel.font = [UIFont systemFontOfSize:16];
        self.smoothnessValueLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.smoothnessValueLabel];
        
        self.smoothnessSlider = [[UISlider alloc] init];
        [self.smoothnessSlider addTarget:self action:@selector(doSmoothnessSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.smoothnessSlider];
        
        self.rednessTitleLabel = [[UILabel alloc] init];
        self.rednessTitleLabel.font = [UIFont systemFontOfSize:16];
        self.rednessTitleLabel.textColor = [UIColor blackColor];
        self.rednessTitleLabel.text = @"红润";
        [self.contentView addSubview:self.rednessTitleLabel];
        
        self.rednessValueLabel = [[UILabel alloc] init];
        self.rednessValueLabel.font = [UIFont systemFontOfSize:16];
        self.rednessValueLabel.textColor = [UIColor blackColor];
        [self.contentView addSubview:self.rednessValueLabel];
        
        self.rednessSlider = [[UISlider alloc] init];
        [self.rednessSlider addTarget:self action:@selector(doRednessSliderChanged:) forControlEvents:UIControlEventValueChanged];
        [self.contentView addSubview:self.rednessSlider];
        
        [self _layoutSubviews];
    }
    return self;
}

- (void)_layoutSubviews
{
    self.contentView.width = 300;
    
    self.switcher.size = CGSizeMake(270, 30);
    self.switcher.origin = CGPointMake(15, 10);
    
    self.contrastSwitcher.size = CGSizeMake(160, 30);
    self.contrastSwitcher.right = self.contentView.width - (15);
    self.contrastSwitcher.top = self.switcher.bottom + (20);
    
    [self.contrastTitleLabel sizeToFit];
    self.contrastTitleLabel.left = (15);
    self.contrastTitleLabel.centerY = self.contrastSwitcher.centerY;
    
    self.lighteningSlider.frame = self.contrastSwitcher.frame;
    self.lighteningSlider.top = self.contrastSwitcher.bottom + (20);
    
    [self.lighteningTitleLabel sizeToFit];
    self.lighteningTitleLabel.left = (15);
    self.lighteningTitleLabel.centerY = self.lighteningSlider.centerY;
    
    self.lighteningValueLabel.frame = self.lighteningTitleLabel.frame;
    self.lighteningValueLabel.left = self.lighteningTitleLabel.right + (5);
    
    self.smoothnessSlider.frame = self.lighteningSlider.frame;
    self.smoothnessSlider.top = self.lighteningSlider.bottom + (20);
    
    [self.smoothnessTitleLabel sizeToFit];
    self.smoothnessTitleLabel.left = (15);
    self.smoothnessTitleLabel.centerY = self.smoothnessSlider.centerY;
    
    self.smoothnessValueLabel.frame = self.smoothnessTitleLabel.frame;
    self.smoothnessValueLabel.left = self.smoothnessTitleLabel.right + (5);
    
    self.rednessSlider.frame = self.smoothnessSlider.frame;
    self.rednessSlider.top = self.smoothnessSlider.bottom + (20);
    
    [self.rednessTitleLabel sizeToFit];
    self.rednessTitleLabel.left = (15);
    self.rednessTitleLabel.centerY = self.rednessSlider.centerY;
    
    self.rednessValueLabel.frame = self.rednessTitleLabel.frame;
    self.rednessValueLabel.left = self.rednessTitleLabel.right + (5);
    
    self.contentView.height = self.rednessSlider.bottom + (10);
    self.contentView.center = self.center;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismiss)];
    [self addGestureRecognizer:tap];
}

- (void)reloadData
{
    self.switcher.selectedSegmentIndex = self.beauthParams.isBeautyOn ? 0 : 1;
    
    self.lighteningSlider.value = self.beauthParams.lighteningLevel;
    self.lighteningValueLabel.text = [self displayStringOfValue:self.beauthParams.lighteningLevel];
    
    NSInteger index = [self indexOfLevel:self.beauthParams.contrastLevel];
    self.contrastSwitcher.selectedSegmentIndex = index;
    
    self.smoothnessSlider.value = self.beauthParams.smoothnessLevel;
    self.smoothnessValueLabel.text = [self displayStringOfValue:self.beauthParams.smoothnessLevel];
    
    self.rednessSlider.value = self.beauthParams.rednessLevel;
    self.rednessValueLabel.text = [self displayStringOfValue:self.beauthParams.rednessLevel];
}

#pragma mark -

- (void)doSwitched:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    self.beauthParams.isBeautyOn = (index == 0);
    
    if ([self.delegate respondsToSelector:@selector(videoChatBeauthSetterViewDidChange:)]) {
        [self.delegate videoChatBeauthSetterViewDidChange:self];
    }
}

- (void)doLighteningSliderChanged:(UISlider *)sender
{
    self.beauthParams.lighteningLevel = sender.value;
    self.lighteningValueLabel.text = [self displayStringOfValue:self.beauthParams.lighteningLevel];
    
//    if ([self.delegate respondsToSelector:@selector(videoChatBeauthSetterViewDidChange:)]) {
//        [self.delegate videoChatBeauthSetterViewDidChange:self];
//    }
}

- (void)doConstrastChanged:(UISegmentedControl *)sender
{
    NSInteger index = sender.selectedSegmentIndex;
    self.beauthParams.contrastLevel = [self levelAtIndex:index];
    
//    if ([self.delegate respondsToSelector:@selector(videoChatBeauthSetterViewDidChange:)]) {
//        [self.delegate videoChatBeauthSetterViewDidChange:self];
//    }
}

- (void)doSmoothnessSliderChanged:(UISlider *)sender
{
    self.beauthParams.smoothnessLevel = sender.value;
    self.smoothnessValueLabel.text = [self displayStringOfValue:self.beauthParams.smoothnessLevel];
    
//    if ([self.delegate respondsToSelector:@selector(videoChatBeauthSetterViewDidChange:)]) {
//        [self.delegate videoChatBeauthSetterViewDidChange:self];
//    }
}

- (void)doRednessSliderChanged:(UISlider *)sender
{
    self.beauthParams.rednessLevel = sender.value;
    self.rednessValueLabel.text = [self displayStringOfValue:self.beauthParams.rednessLevel];
    
//    if ([self.delegate respondsToSelector:@selector(videoChatBeauthSetterViewDidChange:)]) {
//        [self.delegate videoChatBeauthSetterViewDidChange:self];
//    }
}

- (NSString *)displayStringOfValue:(CGFloat)value
{
    return [NSString stringWithFormat:@"%.1f", value];
}

- (NSInteger)indexOfLevel:(AgoraLighteningContrastLevel)level
{
    switch (level) {
        case AgoraLighteningContrastLow:    return 0;
        case AgoraLighteningContrastNormal: return 1;
        case AgoraLighteningContrastHigh:   return 2;
    }
}

- (AgoraLighteningContrastLevel)levelAtIndex:(NSInteger)index
{
    switch (index) {
        case 0: return AgoraLighteningContrastLow;
        case 1: return AgoraLighteningContrastNormal;
        case 2: return AgoraLighteningContrastHigh;
        default: return AgoraLighteningContrastNormal;
    }
}

- (void)show
{
    self.contentView.alpha = 0;
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        self.contentView.alpha = 1;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
        self.contentView.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
