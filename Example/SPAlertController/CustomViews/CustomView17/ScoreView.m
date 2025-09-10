//
//  ScoreView.m
//  SPAlertController
//
//  Created by 乐升平 on 2018/12/24.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import "ScoreView.h"
#import "HCSStarRatingView.h"
#import "UIColor+DarkMode.h"

@interface ScoreView()

@property (nonatomic, weak) HCSStarRatingView *starRatingView;
//@property (nonatomic, weak) UIView *line;
//@property (nonatomic, weak) UIButton *finishButton;
@property (nonatomic, strong) NSMutableArray *subViewContraints;
@end

@implementation ScoreView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        
        self.backgroundColor = [UIColor alertBackgroundColor];
        
        HCSStarRatingView *starRatingView = [[HCSStarRatingView alloc] init];
        starRatingView.translatesAutoresizingMaskIntoConstraints = NO;
        starRatingView.maximumValue = 5;
        starRatingView.minimumValue = 0;
        starRatingView.value = 2;
        starRatingView.spacing = 20;
        starRatingView.tintColor = [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0];
        starRatingView.allowsHalfStars = YES;
        starRatingView.backgroundColor = [UIColor alertBackgroundColor];
        [starRatingView addTarget:self action:@selector(starRatingViewDidChangeValue:) forControlEvents:UIControlEventValueChanged];
        [self addSubview:starRatingView];
        _starRatingView = starRatingView;
    }
    return self;
}

- (void)starRatingViewDidChangeValue:(HCSStarRatingView *)starRatingView {
    
}

- (void)finishButtonAction {
    if (self.finishButtonBlock) {
        self.finishButtonBlock();
    }
}

- (void)updateConstraints {
    [super updateConstraints];
    CGFloat lineH = 1.0/[UIScreen mainScreen].scale;
    
    HCSStarRatingView *starRatingView = self.starRatingView;
//    UIView *line = self.line;
//    UIButton *finishButton = self.finishButton;
    
    NSMutableArray *subViewContraints = [NSMutableArray array];
    if (self.subViewContraints) {
        [NSLayoutConstraint deactivateConstraints:self.subViewContraints];
        subViewContraints = nil;
    }
    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:starRatingView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:40]];
    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:starRatingView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:-40]];
    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:starRatingView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:starRatingView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:starRatingView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:50]];

//    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0]];
//    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0]];
//    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:finishButton attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
//    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:lineH]];
//
//    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:finishButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0]];
//    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:finishButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.0f constant:0]];
//    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:finishButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
//    [subViewContraints addObject:[NSLayoutConstraint constraintWithItem:finishButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:50]];
    [NSLayoutConstraint activateConstraints:subViewContraints];
    self.subViewContraints = subViewContraints;
}

//- (void)layoutSubviews {
//    [super layoutSubviews];
//    CGFloat lineH = 1.0/[UIScreen mainScreen].scale;
//    self.starRatingView.frame = CGRectMake((self.bounds.size.width-200)/2.0, 0, 200, (self.bounds.size.height - lineH) / 2.0);
//    self.line.frame = CGRectMake(0, CGRectGetMaxY(self.starRatingView.frame), self.bounds.size.width, lineH);
//    self.finishButton.frame = CGRectMake(0, CGRectGetMaxY(self.line.frame), self.bounds.size.width, (self.bounds.size.height - lineH) / 2.0);
//}

@end
