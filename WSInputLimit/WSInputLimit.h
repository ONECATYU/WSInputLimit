//
//  WSInputLimit.h
//  LimitInput
//
//  Created by 余汪送 on 2019/1/24.
//  Copyright © 2019 capsule. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface WSInputLimit : NSObject

/// 是否禁用
@property (nonatomic, assign) BOOL disable;
/// 是否禁止输入emoji
@property (nonatomic, assign) BOOL disableEmoji;

/// 限制最大可输入字符个数(length长度大于1的,按照1个字符计算)
@property (nonatomic, assign) NSInteger maxCharacterNumber;
/// 获取当前已经输入字符的个数
@property (nonatomic, assign, readonly) NSInteger currentCharNumber;
/// 获取当前还可以输入字符的个数
@property (nonatomic, assign, readonly) NSInteger canEnterCharNumber;

/// 仅数字
@property (nonatomic, assign) BOOL onlyNumbers;
/// 仅中文
@property (nonatomic, assign) BOOL onlyChinese;
/// 仅英文字母
@property (nonatomic, assign) BOOL onlyLetter;

/// 限制小数输入
@property (nonatomic, assign) BOOL decimaStyle;
/// 控制小数输入位数(当小于1时,保留1位)
@property (nonatomic, assign) NSInteger decimalPlace;

/// 按照给定的正则式过滤
@property (nonatomic, copy) NSString *filterPattern;
/// 按照给定的正则式输入
@property (nonatomic, copy) NSString *allowPattern;


- (instancetype)initWithTextField:(UITextField *)textField;
- (instancetype)initWithTextView:(UITextView *)textView;

+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)init NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END



NS_ASSUME_NONNULL_BEGIN

@interface UITextView (WSInputLimit)
@property (nonatomic, strong, readonly) WSInputLimit *limit;
@end

@interface UITextField (WSInputLimit)
@property (nonatomic, strong, readonly) WSInputLimit *limit;
@end

NS_ASSUME_NONNULL_END
