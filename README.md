* 支持禁止emoji输入   
* 支持输入字符长度限制（emoji当成一个字符）  
* 支持小数样式输入限制，并支持小数位数限制    
```objective-c  
    UITextView *textView = [[UITextView alloc]init];
    //禁止emoji输入
    textView.limit.disableEmoji = YES;
    
    //小数格式
    textView.limit.decimaStyle = YES;
    //小数位数限制(即: 0.00000)
    textView.limit.decimalPlace = 5;
    
    //限制输入字符个数
    textView.limit.maxCharacter = 20;
    //获取还可以输入的字符个数
    NSInteger canEnterCharNum = textView.limit.canEnterCharacter;
    //获取当前输入的字符个数
    NSInteger currentCharNum = textView.limit.currentCharacterNum;
    
    //是否禁用限制
    textView.limit.disable = YES;   
    
```
