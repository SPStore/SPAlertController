//
//  WCLPassWordView.h
//  Youqun
//
//  Created by 乐升平 on 16/6/1.
//  Copyright © 2016年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>
@class PassWordView;

@protocol  PassWordViewDelegate<NSObject>

@optional
/**
 *  监听输入的改变
 */
- (void)passWordDidChange:(PassWordView *)passWord;

/**
 *  监听输入的完成时
 */
- (void)passWordCompleteInput:(PassWordView *)passWord;

/**
 *  监听开始输入
 */
- (void)passWordBeginInput:(PassWordView *)passWord;


@end

IB_DESIGNABLE

@interface PassWordView : UIView<UIKeyInput>

@property (assign, nonatomic) IBInspectable NSUInteger passWordNum;//密码的位数
@property (assign, nonatomic) IBInspectable CGFloat squareWidth;//正方形的大小
@property (assign, nonatomic) IBInspectable CGFloat pointRadius;//黑点的半径
@property (strong, nonatomic) IBInspectable UIColor *pointColor;//黑点的颜色
@property (strong, nonatomic) IBInspectable UIColor *rectColor;//边框的颜色
@property (weak, nonatomic) IBOutlet id<PassWordViewDelegate> delegate;
@property (strong, nonatomic, readonly) NSMutableString *textStore;//保存密码的字符串

@end

