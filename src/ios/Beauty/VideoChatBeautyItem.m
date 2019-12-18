//
//  VideoChatBeautyItem.m
//  QingShu
//
//  Created by vitas on 2019/5/25.
//  Copyright © 2019 Vitas. All rights reserved.
//

#import "VideoChatBeautyItem.h"

#define kNSUserDefaultKey_isBeautyOn @"kNSUserDefaultKey_isBeautyOn"
#define kNSUserDefaultKey_contrastLevel @"kNSUserDefaultKey_contrastLevel"
#define kNSUserDefaultKey_lighteningLevel @"kNSUserDefaultKey_lighteningLevel"
#define kNSUserDefaultKey_smoothnessLevel @"kNSUserDefaultKey_smoothnessLevel"
#define kNSUserDefaultKey_rednessLevel @"kNSUserDefaultKey_rednessLevel"

@interface VideoChatBeautyItem ()

@property (nonatomic, strong) NSUserDefaults *userDefaults;

@end

@implementation VideoChatBeautyItem

+ (instancetype)defaultOptions
{
    return [[VideoChatBeautyItem alloc] init];
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.userDefaults = [NSUserDefaults standardUserDefaults];
        
        if ([self containKey:kNSUserDefaultKey_isBeautyOn]) {
            self.isBeautyOn = [self.userDefaults boolForKey:kNSUserDefaultKey_isBeautyOn];
        } else {
            self.isBeautyOn = YES;
        }
        
        if ([self containKey:kNSUserDefaultKey_contrastLevel]) {
            self.contrastLevel = [self.userDefaults integerForKey:kNSUserDefaultKey_contrastLevel];
        } else {
            self.contrastLevel = 1;
        }
        
        if ([self containKey:kNSUserDefaultKey_lighteningLevel]) {
            self.lighteningLevel = [self.userDefaults floatForKey:kNSUserDefaultKey_lighteningLevel];
        } else {
            self.lighteningLevel = 0.7;
        }
        
        if ([self containKey:kNSUserDefaultKey_smoothnessLevel]) {
            self.smoothnessLevel = [self.userDefaults floatForKey:kNSUserDefaultKey_smoothnessLevel];
        } else {
            self.smoothnessLevel = 0.5;
        }
        
        if ([self containKey:kNSUserDefaultKey_rednessLevel]) {
            self.rednessLevel = [self.userDefaults floatForKey:kNSUserDefaultKey_rednessLevel];
        } else {
            self.rednessLevel = 0.1;
        }
        
        self.beautyOptions = [[AgoraBeautyOptions alloc] init];
        self.beautyOptions.lighteningContrastLevel = self.contrastLevel;
        self.beautyOptions.lighteningLevel = self.lighteningLevel;
        self.beautyOptions.smoothnessLevel = self.smoothnessLevel;
        self.beautyOptions.rednessLevel = self.rednessLevel;
    }
    return self;
}

- (void)setIsBeautyOn:(BOOL)isBeautyOn
{
    _isBeautyOn = isBeautyOn;
    
    [self.userDefaults setBool:isBeautyOn forKey:kNSUserDefaultKey_isBeautyOn];
    [self.userDefaults synchronize];
}

- (void)setContrastLevel:(AgoraLighteningContrastLevel)contrastLevel
{
    _contrastLevel = contrastLevel;
    
    self.beautyOptions.lighteningContrastLevel = contrastLevel;
    
    [self.userDefaults setInteger:contrastLevel forKey:kNSUserDefaultKey_contrastLevel];
    [self.userDefaults synchronize];
}

- (void)setLighteningLevel:(float)lighteningLevel
{
    _lighteningLevel = lighteningLevel;
    
    self.beautyOptions.lighteningLevel = lighteningLevel;
    
    [self.userDefaults setFloat:lighteningLevel forKey:kNSUserDefaultKey_lighteningLevel];
    [self.userDefaults synchronize];
}

- (void)setSmoothnessLevel:(float)smoothnessLevel
{
    _smoothnessLevel = smoothnessLevel;
    
    self.beautyOptions.smoothnessLevel = smoothnessLevel;
    
    [self.userDefaults setFloat:smoothnessLevel forKey:kNSUserDefaultKey_smoothnessLevel];
    [self.userDefaults synchronize];
}

- (void)setRednessLevel:(float)rednessLevel
{
    _rednessLevel = rednessLevel;
    
    self.beautyOptions.rednessLevel = rednessLevel;
    
    [self.userDefaults setFloat:rednessLevel forKey:kNSUserDefaultKey_rednessLevel];
    [self.userDefaults synchronize];
}

- (BOOL)containKey:(NSString *)keyName
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:keyName] != NULL;
}

@end
