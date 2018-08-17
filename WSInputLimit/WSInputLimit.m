//
//  WSInputLimit.m
//  UITextView+LimitInput
//
//  Created by 余汪送 on 2018/8/16.
//  Copyright © 2018年 capsule. All rights reserved.
//

#import "WSInputLimit.h"
#import <objc/runtime.h>

typedef void(^_EnumerateCompletion)(NSInteger count, NSInteger length, NSString *filterText);

@interface WSInputLimit ()
@property (nonatomic, weak) UITextField *textField;
@property(nonatomic, weak) UITextView *textView;
@property(nonatomic, assign) NSInteger currentCharacterCount;
@end

@implementation WSInputLimit

@synthesize currentCharacterNum = _currentCharacterNum;

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark setter
- (void)setTextField:(UITextField *)textField {
    _textField = textField;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)setTextView:(UITextView *)textView {
    _textView = textView;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:nil];
}

#pragma mark getter
- (NSInteger)currentCharacterNum {
    return _currentCharacterCount;
}

- (NSInteger)canEnterCharacter {
    return MAX(0, _maxCharacter - _currentCharacterCount);
}

- (NSInteger)decimalPlace {
    if (_decimalPlace < 1) {
        _decimalPlace = 2;
    }
    return _decimalPlace;
}

- (NSCharacterSet *)emojiSet {
    static NSMutableCharacterSet *emojiSet;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        emojiSet = [[NSMutableCharacterSet alloc] init];
        // U+FE00-FE0F (Variation Selectors)
        [emojiSet addCharactersInRange:NSMakeRange(0xFE00, 0xFE0F - 0xFE00 + 1)];
        // U+2100-27BF
        [emojiSet addCharactersInRange:NSMakeRange(0x2100, 0x27BF - 0x2100 + 1)];
        // U+1D000-1F9FF
        [emojiSet addCharactersInRange:NSMakeRange(0x1D000, 0x1F9FF - 0x1D000 + 1)];
    });
    
    return emojiSet;
}

#pragma mark textFieldTextDidChange
- (void)textFieldTextDidChange:(NSNotification *)notifi {
    if (_disable) return;
    if (!_textField) return;
    UITextField *currentTF = notifi.object;
    if (_textField != currentTF) return;
    
    UITextRange *markedTextRange = [_textField markedTextRange];
    UITextPosition *position = [_textField positionFromPosition:markedTextRange.start offset:0];
    if (markedTextRange && position) return;
    
    __weak typeof(self) weakSelf = self;
    [self filterInputText:_textField.text completion:^(NSString *resultText) {
        UITextRange* selectedRange = weakSelf.textField.selectedTextRange;
        weakSelf.textField.text = resultText;
        weakSelf.textField.selectedTextRange = selectedRange;
    }];
}

#pragma mark textViewTextDidChange
- (void)textViewTextDidChange:(NSNotification *)notifi {
    if (_disable) return;
    if (!_textView) return;
    UITextView *currentTextView = notifi.object;
    if (_textView != currentTextView) return;
    
    UITextRange *markedTextRange = [_textView markedTextRange];
    UITextPosition *position = [_textView positionFromPosition:markedTextRange.start offset:0];
    if (markedTextRange && position) return;
    
    __weak typeof(self) weakSelf = self;
    [self filterInputText:_textView.text completion:^(NSString *resultText) {
        NSRange selectedRange = weakSelf.textView.selectedRange;
        weakSelf.textView.text = resultText;
        weakSelf.textView.selectedRange = NSMakeRange(selectedRange.location, 0);
    }];
}

#pragma mark helper
- (void)filterInputText:(NSString *)text completion:(void(^)(NSString *resultText))completion {
    __weak typeof(self) weakSelf = self;
    [self enumerateSubstringsFromString:text ompletion:^(NSInteger count, NSInteger length, NSString *filterText) {
        NSString *resultText = filterText;
        NSInteger maxNum = MAX(0, weakSelf.maxCharacter);
        weakSelf.currentCharacterCount = count;
        if (maxNum > 0 && weakSelf.currentCharacterCount > maxNum) {
            resultText = [filterText substringToIndex:length];
        }
        if (completion) {
            completion(resultText);
        }
    }];
}

- (void)enumerateSubstringsFromString:(NSString *)text ompletion:(_EnumerateCompletion)completion
{
    __block NSInteger count = 0;
    __block NSInteger length = 0;
    __block NSString *filterText = @"";
    NSInteger maxNum = MAX(0, _maxCharacter);
    
    [text enumerateSubstringsInRange:NSMakeRange(0, text.length)
                             options:NSStringEnumerationByComposedCharacterSequences
                          usingBlock:^(NSString * _Nullable substring, NSRange substringRange, NSRange enclosingRange, BOOL * _Nonnull stop) {
                              count ++;
                              if (maxNum > 0 && count > maxNum) {
                                  *stop = YES;
                              } else {
                                  length += substringRange.length;
                              }
                              if ([self enumerateString:filterText inRange:substringRange replacementText:substring]) {
                                  filterText = [filterText stringByAppendingString:substring];
                              }
                          }];
    
    if (completion) {
        completion(count, length, filterText);
    }
}

- (BOOL)enumerateString:(NSString *)string inRange:(NSRange)range replacementText:(NSString *)text {
    if (_decimaStyle) {
        if (![self validateRegex:@"^[0-9]*$" toString:text] && ![text isEqualToString:@"."]) {
            return NO;
        }
        if ([string isEqualToString:@"0"] && ![text isEqualToString:@"."]) {
            return NO;
        }
        if (([string isEqualToString:@""] || [string containsString:@"."]) &&
            [text isEqualToString:@"."]) {
            return NO;
        }
        NSString *str = [string stringByAppendingString:text];
        NSRange _range = [str rangeOfString:@"."];
        if (_range.location != NSNotFound) {
            NSInteger l = str.length - _range.location - 1;
            if (l > self.decimalPlace) {
                return NO;
            }
        }
    } else if (_onlyNumbers) {
        return [self validateRegex:@"^[0-9]*$" toString:text];
    } else if (_disableEmoji) {
        return [text rangeOfCharacterFromSet:[self emojiSet]].location == NSNotFound;
    }
    
    return YES;
}

- (BOOL)validateRegex:(NSString *)regex toString:(NSString *)string {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",regex];
    return [predicate evaluateWithObject:string];
}

@end


@implementation UITextView (WSInputLimit)

- (WSInputLimit *)limit {
    WSInputLimit *limit = objc_getAssociatedObject(self, _cmd);
    if (!limit) {
        limit = [[WSInputLimit alloc]init];
        limit.textView = self;
        objc_setAssociatedObject(self, _cmd, limit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return limit;
}

@end

@implementation UITextField (WSInputLimit)

- (WSInputLimit *)limit {
    WSInputLimit *limit = objc_getAssociatedObject(self, _cmd);
    if (!limit) {
        limit = [[WSInputLimit alloc]init];
        limit.textField = self;
        objc_setAssociatedObject(self, _cmd, limit, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return limit;
}

@end
