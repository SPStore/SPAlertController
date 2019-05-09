//
//  PopView.m
//  SPAlertController
//
//  Created by Libo on 2018/12/23.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import "PopView.h"
#import "SPButton.h" // SPButton的github地址:https://github.com/SPStore/SPButton

static NSInteger const kColumnCount = 4; // 每一页的列数
static NSInteger const kRowCount = 2; // 每一页的行数
static CGFloat const kColSpacing = 15; // 列间距
static CGFloat const kRowSpacing = 20; // 行间距
static NSTimeInterval kAnimationDuration = 0.7; // 动画总时长
static NSTimeInterval kDelay = 0.0618; // 按钮接着上一个按钮的延时时间

@interface PopView() <UIScrollViewDelegate>
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIPageControl *pageControl;
@property (nonatomic, strong) UIButton *cancelButton;
@property (nonatomic, strong) UIView *line;
@property (nonatomic, copy) void (^clickedButtonBlock)(NSInteger);
@property (nonatomic, copy) void (^cancelBlock)(PopView *popView);
@end

@implementation PopView
{
    NSInteger buttonCount;
}

- (instancetype)initWithImages:(NSArray<NSString *> *)images
                        titles:(NSArray<NSString *> *)titles
                  clickedButtonBlock:(void (^)(NSInteger))clickedButtonBlock
                   cancelBlock:(void (^)(PopView *popView))cancelBlock {
    
    _clickedButtonBlock = clickedButtonBlock;
    _cancelBlock = cancelBlock;
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction)];
    [self addGestureRecognizer:tap];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    if (self = [self initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight)]) {
        buttonCount = MIN(images.count, titles.count);
        for (int i = 0; i < buttonCount; i++) {
            SPButton *button = [[SPButton alloc] initWithImagePosition:SPButtonImagePositionTop];
            [button setImage:[UIImage imageNamed:images[i]] forState:UIControlStateNormal];
            [button setTitle:titles[i] forState:UIControlStateNormal];
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            [button setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
            button.imageView.contentMode = UIViewContentModeScaleAspectFit;
            button.imageTitleSpace = 5;
            [button addTarget:self action:@selector(buttonAction:) forControlEvents:UIControlEventTouchUpInside];
            button.tag = i+100;
            [self.scrollView addSubview:button];
        }
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
    }
    return self;
}

- (void)open {

    for (int i = 0; i < buttonCount; i++) {
        SPButton *button = [self.scrollView viewWithTag:i+100];
        CGFloat buttonH = button.bounds.size.height;
        CGFloat totalH = (buttonH * kRowCount + kRowSpacing * (kRowCount - 1));
        CGFloat buttonEndY = button.frame.origin.y - totalH - buttonH;
        // delay参数计算出来的意思是：每一列比它的上一列延时kDelay秒
        [UIView animateWithDuration:kAnimationDuration
                              delay:i % kColumnCount * kDelay
             usingSpringWithDamping:0.6
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseIn animations:^{
                                CGRect buttonFrame = button.frame;
                                buttonFrame.origin.y = buttonEndY;
                                button.frame = buttonFrame;
                            } completion:^(BOOL finished) {
                            }];
    }
}

- (void)close {
    for (int i = 0; i < buttonCount; i++) {
        SPButton *button = [self.scrollView viewWithTag:i+100];
        CGFloat buttonH = button.bounds.size.height;
        CGFloat totalH = (buttonH * kRowCount + kRowSpacing * (kRowCount - 1));
        CGFloat buttonBeginY = button.frame.origin.y + buttonH + totalH;
        
        // delay参数计算出来的意思是：第一行每个按钮都比第二行的每个按钮延时0.1秒,同时每列比它的下一列延时kDelay秒
        [UIView animateWithDuration:kAnimationDuration
                              delay:(1-i/kColumnCount)/10.0 + (kDelay * kColumnCount - i % kColumnCount * kDelay - kDelay)
             usingSpringWithDamping:0.6
              initialSpringVelocity:0
                            options:UIViewAnimationOptionCurveEaseOut animations:^{
                                CGRect buttonFrame = button.frame;
                                buttonFrame.origin.y = buttonBeginY;
                                button.frame = buttonFrame;
                            } completion:^(BOOL finished) {
                                [self removeFromSuperview];
                            }];
    }
}

- (void)buttonAction:(UIButton *)sender {
    if (self.clickedButtonBlock) {
        self.clickedButtonBlock(sender.tag-100);
    }
}

- (void)tapAction {
    if (self.tapBackgroundBlock) {
        self.tapBackgroundBlock(self);
    }
}

- (void)cancelButtonAction {
    if (self.cancelBlock) {
        self.cancelBlock(self);
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGFloat offsetX = scrollView.contentOffset.x;
    self.pageControl.currentPage = (NSInteger)(offsetX / self.bounds.size.width + 0.5);
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat bottom = 0;
    if (@available(iOS 11.0, *)) {
        bottom = self.safeAreaInsets.bottom;
    }
    
    CGFloat superWidth = self.frame.size.width;
    CGFloat superHeight = self.frame.size.height;
    
    CGFloat cancelButtonW = superWidth;
    CGFloat cancelButtonH = 40;
    CGFloat cancelButtonX = 0;
    CGFloat cancelButtonY = superHeight-cancelButtonH-bottom;
    self.cancelButton.frame = CGRectMake(cancelButtonX, cancelButtonY, cancelButtonW, cancelButtonH);
    
    CGFloat lineW = superWidth;
    CGFloat lineH = 1.0/[UIScreen mainScreen].scale;
    CGFloat lineX = 0;
    CGFloat lineY = superHeight-cancelButtonH-lineH-bottom;
    self.line.frame = CGRectMake(lineX, lineY, lineW, lineH);
    
    CGFloat scrollViewH = superHeight-cancelButtonH-lineH-bottom;
    self.scrollView.frame = CGRectMake(0, 0, superWidth, scrollViewH);
    self.pageControl.frame = CGRectMake(0, superHeight-cancelButtonH-lineH-bottom-30, superWidth, 30);
    
    // 先计算好每个按钮的动画前的frame，等执行动画的时候只要改变y值即可
    NSInteger buttonCountEveryPage = kColumnCount * kRowCount; // 每一页的按钮个数
    NSInteger pageCount = (buttonCount-1) / buttonCountEveryPage + 1; // 总页数
    self.pageControl.numberOfPages = pageCount;

    for (int i = 0; i < buttonCount; i++) {
        SPButton *button = [self.scrollView viewWithTag:i+100];
        NSInteger page = i / buttonCountEveryPage; // 第几页
        NSInteger row = (i - buttonCountEveryPage * page) / kColumnCount; // 第几页的第几行
        NSInteger col = i % kColumnCount; // 第几列
        CGFloat buttonW = (superWidth - kColSpacing * (kColumnCount + 1)) / kColumnCount;
        CGFloat buttonH = MIN(buttonW, button.currentImage.size.width)+30;
        CGFloat buttonX = kColSpacing + (buttonW + kColSpacing) * col + page * superWidth;
        CGFloat buttonBeginY = scrollViewH + (buttonH + kRowSpacing) * row;
        button.frame = CGRectMake(buttonX, buttonBeginY, buttonW, buttonH);
    }
    self.scrollView.contentSize = CGSizeMake(superWidth * pageCount, 0);
}

- (UIScrollView *)scrollView {
    
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.scrollsToTop = NO;
        _scrollView.bounces = NO;
        _scrollView.pagingEnabled = YES;
        _scrollView.delegate = self;
        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.currentPageIndicatorTintColor = [UIColor orangeColor];
        _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
        [self addSubview:_pageControl];
    }
    return _pageControl;
}

- (UIButton *)cancelButton {
    
    if (!_cancelButton) {
        _cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _cancelButton.backgroundColor = [UIColor clearColor];
        [_cancelButton setImage:[UIImage imageNamed:@"取消"] forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(cancelButtonAction) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_cancelButton];
    }
    return _cancelButton;
}

- (UIView *)line {
    
    if (!_line) {
        _line = [[UIView alloc] init];
        _line.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.3];
        [self addSubview:_line];
    }
    return _line;
}

@end
