//
//  SPTextView.h
//  SPTextView
//
//  Created by 乐升平 on 2018/7/31.
//  Copyright © 2018 乐升平. All rights reserved.
//  github地址:https://github.com/SPStore/SPTextView

#import <UIKit/UIKit.h>

@interface SPTextView : UITextView

/** 占位文字 */
@property (nonatomic, copy) NSString *placeholder;
/** 占位文字的颜色 */
@property (nonatomic, strong) UIColor *placeholderColor;

// 占位文字的字体永远跟textView的字体保持一致，因此该自定义控件不提供单独设置占位文字字体的属性，因为textView的光标高度依赖于textview的字体，如果占位文字跟textView的字体不一致，会导致光标跟占位文字无法对齐
@end
