//
//  WCLPassWordView.m
//  Youqun
//
//  Created by 乐升平 on 16/6/1.
//  Copyright © 2016年 iDress. All rights reserved.
//

#import "PassWordView.h"

@interface PassWordView ()

@property (strong, nonatomic) NSMutableString *textStore;// 保存密码的字符串

@end

@implementation PassWordView

static NSString  * const MONEYNUMBERS = @"0123456789";

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.textStore = [NSMutableString string];
        self.squareWidth = 45;
        self.passWordNum = 6;
        self.pointRadius = 6;
        self.rectColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        self.pointColor = [UIColor colorWithRed:223.0/255.0 green:223.0/255.0 blue:223.0/255.0 alpha:1.0];
        [self becomeFirstResponder];
    }
    return self;
}

/**
 *  设置正方形的边长
 */
- (void)setSquareWidth:(CGFloat)squareWidth {
    _squareWidth = squareWidth;
    [self setNeedsDisplay];
}

/**
 *  设置键盘的类型
 */
- (UIKeyboardType)keyboardType {
    return UIKeyboardTypeNumberPad;
}

/**
 *  设置密码的位数
 */
- (void)setPassWordNum:(NSUInteger)passWordNum {
    _passWordNum = passWordNum;
    [self setNeedsDisplay];
}

- (BOOL)becomeFirstResponder {
    if ([self.delegate respondsToSelector:@selector(passWordBeginInput:)]) {
        [self.delegate passWordBeginInput:self];
    }
    return [super becomeFirstResponder];
}

/**
 *  是否能成为第一响应者
 */
- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (![self isFirstResponder]) {
        [self becomeFirstResponder];
    }
}

#pragma mark - UIKeyInput
/**
 *  用于显示的文本对象是否有任何文本
 */
- (BOOL)hasText {
    return self.textStore.length > 0;
}

/**
 *  插入文本
 */
- (void)insertText:(NSString *)text {
    if (self.textStore.length < self.passWordNum) {
        //判断是否是数字
        NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:MONEYNUMBERS] invertedSet];
        NSString*filtered = [[text componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
        BOOL basicTest = [text isEqualToString:filtered];
        if(basicTest) {
            [self.textStore appendString:text];
            if ([self.delegate respondsToSelector:@selector(passWordDidChange:)]) {
                [self.delegate passWordDidChange:self];
            }
            if (self.textStore.length == self.passWordNum) {
                if ([self.delegate respondsToSelector:@selector(passWordCompleteInput:)]) {
                    [self.delegate passWordCompleteInput:self];
                }
            }
            [self setNeedsDisplay];
        }
    }
}

/**
 *  删除文本
 */
- (void)deleteBackward {
    if (self.textStore.length > 0) {
        [self.textStore deleteCharactersInRange:NSMakeRange(self.textStore.length - 1, 1)];
        if ([self.delegate respondsToSelector:@selector(passWordDidChange:)]) {
            [self.delegate passWordDidChange:self];
        }
    }
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
- (void)drawRect:(CGRect)rect {
    CGFloat height = rect.size.height;
    CGFloat width = rect.size.width;
    CGFloat x = (width - self.squareWidth*self.passWordNum)/2.0;
    CGFloat y = (height - self.squareWidth)/2.0;
    CGContextRef context = UIGraphicsGetCurrentContext();
    //画外框
    CGContextAddRect(context, CGRectMake( x, y, self.squareWidth*self.passWordNum, self.squareWidth));
    CGContextSetLineWidth(context, 1);
    CGContextSetStrokeColorWithColor(context, self.rectColor.CGColor);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    //画竖条
    for (int i = 1; i <= self.passWordNum; i++) {
        CGContextMoveToPoint(context, x+i*self.squareWidth, y);
        CGContextAddLineToPoint(context, x+i*self.squareWidth, y+self.squareWidth);
        CGContextClosePath(context);
    }
    CGContextDrawPath(context, kCGPathFillStroke);
    CGContextSetFillColorWithColor(context, self.pointColor.CGColor);
    //画黑点
    for (int i = 1; i <= self.textStore.length; i++) {
        CGContextAddArc(context,  x+i*self.squareWidth - self.squareWidth/2.0, y+self.squareWidth/2, self.pointRadius, 0, M_PI*2, YES);
        CGContextDrawPath(context, kCGPathFill);
    }
}


@end

