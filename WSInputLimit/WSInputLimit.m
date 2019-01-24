//
//  WSInputLimit.m
//  LimitInput
//
//  Created by 余汪送 on 2019/1/24.
//  Copyright © 2019 capsule. All rights reserved.
//

#import "WSInputLimit.h"
#import <objc/runtime.h>

NSString *const WSInputLimitOnlyNumbersPattern = @"[0-9]+";
NSString *const WSInputLimitOnlyChinesePattern = @"[\u4e00-\u9fa5]+";
NSString *const WSInputLimitOnlyLetterPattern = @"[A-Za-z]+";
NSString *const WSInputLimitFilterEmojiPattern = @"[^\\u0020-\\u007E\\u00A0-\\u00BE\\u2E80-\\uA4CF\\uF900-\\uFAFF\\uFE30-\\uFE4F\\uFF00-\\uFFEF\\u0080-\\u009F\\u2000-\\u201f\r\n]";

static inline NSString *WSInputLimitDecimaStylePattern(NSInteger decimalPlace) {
    return [NSString stringWithFormat:@"([1-9][0-9]*|0)(\\.)?([0-9]{1,%ld})?", MAX(1, decimalPlace)];
}

@interface WSInputLimit ()

@property (nonatomic, weak, readonly) UITextField *textField;
@property (nonatomic, weak, readonly) UITextView *textView;

@end

@implementation WSInputLimit

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)initWithTextField:(UITextField *)textField {
    if (self = [super init]) {
        _textField = textField;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:_textField];
    }
    return self;
}

- (instancetype)initWithTextView:(UITextView *)textView {
    if (self = [super init]) {
        _textView = textView;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:_textView];
    }
    return self;
}

#pragma mark textFieldTextDidChange
- (void)textFieldTextDidChange:(NSNotification *)notifi {
    if (_disable) {
        return;
    }
    UITextField *textField = notifi.object;
    if (textField == _textField) {
        UITextRange *markedTextRange = [_textField markedTextRange];
        UITextPosition *position = [_textField positionFromPosition:markedTextRange.start offset:0];
        if (markedTextRange && position) {
            return;
        }
        
        NSString *result = [self handleText:_textField.text];
        UITextRange* selectedRange = _textField.selectedTextRange;
        _textField.text = result;
        _textField.selectedTextRange = selectedRange;
    }
}

#pragma mark textViewTextDidChange
- (void)textViewTextDidChange:(NSNotification *)notifi {
    if (_disable) {
        return;
    }
    UITextView *textView = notifi.object;
    if (textView == _textView) {
        UITextRange *markedTextRange = [_textView markedTextRange];
        UITextPosition *position = [_textView positionFromPosition:markedTextRange.start offset:0];
        if (markedTextRange && position) {
            return;
        }
        
        NSString *result = [self handleText:_textView.text];
        NSRange selectedRange = _textView.selectedRange;
        _textView.text = result;
        _textView.selectedRange = NSMakeRange(selectedRange.location, 0);
    }
}

- (NSString *)handleText:(NSString *)text {
    if (_onlyNumbers) {
        NSString *result = [self subStringFromText:text withPattern:WSInputLimitOnlyNumbersPattern];
        return result;
    }
    
    if (_onlyChinese) {
        NSString *result = [self subStringFromText:text withPattern:WSInputLimitOnlyChinesePattern];
        return result;
    }
    
    if (_onlyLetter) {
        NSString *result = [self subStringFromText:text withPattern:WSInputLimitOnlyLetterPattern];
        return result;
    }
    
    if (_decimaStyle) {
        NSString *pattern = WSInputLimitDecimaStylePattern(_decimalPlace);
        NSString *result = [self subStringFromText:text withPattern:pattern];
        return result;
    }
    
    if (_allowPattern) {
        NSString *result = [self subStringFromText:text withPattern:_allowPattern];
        return result;
    }
    
    NSString *filterPattern = _filterPattern;
    if (_disableEmoji) {
        filterPattern = WSInputLimitFilterEmojiPattern;
    }
    if (filterPattern) {
        NSRegularExpression *regex = [[NSRegularExpression alloc]initWithPattern:filterPattern options:0 error:NULL];
        NSString *result = [regex stringByReplacingMatchesInString:text
                                                           options:0
                                                             range:NSMakeRange(0, text.length)
                                                      withTemplate:@""];
        result = [self lengthHandle:result];
        return result;
    }
    
    NSString *result = [self lengthHandle:text];
    return result;
}

- (NSString *)subStringFromText:(NSString *)string withPattern:(NSString *)pattern {
    NSRange range = [string rangeOfString:pattern
                                  options:NSRegularExpressionSearch
                                    range:NSMakeRange(0, string.length)];
    NSString *result = @"";
    if (range.location != NSNotFound) {
        result = [string substringWithRange:range];
    }
    result = [self lengthHandle:result];
    return result;
}

- (NSString *)lengthHandle:(NSString *)text {
    __block NSString *filterText = @"";
    __block NSInteger currentChatNum = 0;
    NSInteger maxCharacterNumber = _maxCharacterNumber;
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              if (maxCharacterNumber > 0 && currentChatNum >= maxCharacterNumber) {
                                  *stop = YES;
                              } else {
                                  filterText = [filterText stringByAppendingString:substring];
                                  currentChatNum ++;
                              }
                          }];
    _currentCharNumber = currentChatNum;
    _canEnterCharNumber = MAX(0, _maxCharacterNumber - _currentCharNumber);
    return filterText;
}

@end



@implementation UITextView (WSInputLimit)

- (WSInputLimit *)limit {
    WSInputLimit *limit = objc_getAssociatedObject(self, _cmd);
    if (!limit) {
        limit = [[WSInputLimit alloc]initWithTextView:self];
        objc_setAssociatedObject(self, _cmd, limit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return limit;
}

@end

@implementation UITextField (WSInputLimit)

- (WSInputLimit *)limit {
    WSInputLimit *limit = objc_getAssociatedObject(self, _cmd);
    if (!limit) {
        limit = [[WSInputLimit alloc]initWithTextField:self];
        objc_setAssociatedObject(self, _cmd, limit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return limit;
}

@end
