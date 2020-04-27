//
//  SendAlertView.m
//  SPAlertController
//
//  Created by 乐升平 on 2018/12/24.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import "SendAlertView.h"
#import "SPTextView.h"
#import "UIColor+DarkMode.h"

@interface SendAlertView() <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userIconView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *contentImageView;
@property (weak, nonatomic) IBOutlet SPTextView *textView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewHeightConstraint;
@property (nonatomic, assign) CGFloat textH;

@end

@implementation SendAlertView

+ (instancetype)shareSendAlertView {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.backgroundColor = [UIColor colorPairsWithLightColor:[UIColor whiteColor] darkColor:[UIColor colorWithRed:44.0 / 255.0 green:44.0 / 255.0 blue:44.0 / 255.0 alpha:1.0]];
    self.userIconView.layer.cornerRadius = 4.0;
    self.userIconView.layer.masksToBounds = YES;
    self.textView.delegate = self;
    self.textView.layer.borderWidth = 0.5/[UIScreen mainScreen].scale;
    self.textView.layer.borderColor = [[UIColor grayColor] colorWithAlphaComponent:0.3].CGColor;
    self.textView.placeholder = @"给朋友留言";
    self.textView.placeholderColor = [UIColor lightGrayColor];
    
   _textH = ceil(self.textView.font.lineHeight) + self.textView.textContainerInset.top + self.textView.textContainerInset.bottom;

}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    }
    return self;
}

- (void)setContentImage:(UIImage *)contentImage {
    _contentImage = contentImage;
    self.contentImageView.image = contentImage;
    if (_contentImage) {
        CGFloat contentH;
        CGFloat imgRatio = _contentImage.size.height/_contentImage.size.width;
        CGFloat contentW = self.bounds.size.width-30; // 30是contentImageView的左右间距之和
        if (_contentImage.size.height < contentW) {
            contentH = _contentImage.size.height;
        } else {
            contentH = imgRatio * contentW;
        }
        if (contentH > [UIScreen mainScreen].bounds.size.height-300) { // 300是一个大概写的数字
            contentH = [UIScreen mainScreen].bounds.size.height-300;
        }
        // 更新图片的高度约束
        self.contentHeightConstraint.constant = contentH;
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView {

}

- (void)textViewDidChange:(UITextView *)textView {
    
    CGFloat maxHeight = textView.font.lineHeight * 3 + textView.textContainerInset.top + textView.textContainerInset.bottom;

    NSInteger height = ceilf([textView sizeThatFits:CGSizeMake(textView.bounds.size.width, MAXFLOAT)].height);
    
    if (_textH != height) { // 高度不一样，就改变了高度
        
        // 最大高度，可以滚动
        if (height > maxHeight && maxHeight > 0) {
            self.textView.scrollEnabled = YES;
            height = maxHeight;
        } else {
            self.textView.scrollEnabled = NO;
        }
        if (self.textViewHeightDidChange) {
            self.textViewHeightConstraint.constant = height;
            self.textViewHeightDidChange(height - _textH);
        }
        _textH = height;
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if (self.textViewDidEndEditting) {
        self.textViewDidEndEditting();
    }
}

- (void)keyboardWillShow:(NSNotification *)note {
    CGRect keyboardEndFrame = [note.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardEndY = keyboardEndFrame.origin.y; // 200
    CGFloat textViewMaxY = CGRectGetMaxY([self.textView.superview convertRect:self.textView.frame toView:nil]);
    CGFloat diff = textViewMaxY - keyboardEndY + 80;
    if (self.keyboardWillShow) {
        self.keyboardWillShow(diff);
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
