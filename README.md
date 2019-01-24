 ```objective-c  
    UITextView *textView = nil;
    /// 是否禁用限制
    textView.limit.disable = YES;
    /// 禁用emoji输入
    textView.limit.disableEmoji = YES;
    
    /// 允许最大输入100个字符(length长度大于1的,按照1个字符计算)
    textView.limit.maxCharacterNumber = 100;
    
    /// 仅输入数字
    textView.limit.onlyNumbers = YES;
    /// 仅输入中文
    textView.limit.onlyChinese = YES;
    /// 仅输入英文字母
    textView.limit.onlyLetter = YES;
    
    /// 控制输入小数样式
    textView.limit.decimaStyle = YES;
    /// 控制小数位数
    textView.limit.decimalPlace = 2;
    
    /// 过滤输入中的数字(即数字不能输入)
    textView.limit.filterPattern = @"[0-9]+";
    /// 只允许输入数字
    textView.limit.allowPattern = @"[0-9]+";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChange:) name:UITextViewTextDidChangeNotification object:textView];
    

- (void)textViewTextDidChange:(NSNotification *)notifi {
    NSLog(@"当前输入: %d, 还可以输入: %d", textView.limit.currentCharNumber, textView.limit.canEnterCharNumber);
}
    
```
