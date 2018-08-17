//
//  WSInputLimit.h
//  UITextView+LimitInput
//
//  Created by 余汪送 on 2018/8/16.
//  Copyright © 2018年 capsule. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface WSInputLimit : NSObject

///是否禁用限制
@property (nonatomic, assign) BOOL disable;

///是否禁用emoji输入
@property (nonatomic, assign) BOOL disableEmoji;

///限制最大字符
@property (nonatomic, assign) NSInteger maxCharacter;
///获取当前字符的个数(emoji按照一个字符计算)
@property (nonatomic, assign, readonly) NSInteger currentCharacterNum;
///还能输入字符的个数
@property (nonatomic, assign) NSInteger canEnterCharacter;

///限制仅数字
@property (nonatomic, assign) BOOL onlyNumbers;

///小数样式
@property (nonatomic, assign) BOOL decimaStyle;
///小数位数,默认2位(0.00)
@property (nonatomic, assign) NSInteger decimalPlace;

@end


@interface UITextView (WSInputLimit)
@property (nonatomic, strong, readonly) WSInputLimit *limit;
@end

@interface UITextField (WSInputLimit)
@property (nonatomic, strong, readonly) WSInputLimit *limit;
@end
