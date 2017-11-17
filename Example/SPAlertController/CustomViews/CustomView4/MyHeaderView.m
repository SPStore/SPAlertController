//
//  MyTitleView.m
//  SPAlertController
//
//  Created by Libo on 2017/11/5.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "MyHeaderView.h"

@interface MyHeaderView()

@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, weak) UILabel *label;
@property (nonatomic, strong) NSMutableArray *imageViewConstraints;
@property (nonatomic, strong) NSMutableArray *labelConstraints;

@end

@implementation MyHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.translatesAutoresizingMaskIntoConstraints = NO;
    imageView.image = [UIImage imageNamed:@"勾"];
    [self addSubview:imageView];
    _imageView = imageView;
    
    UILabel *label = [[UILabel alloc] init];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    label.text = @"完成";
    label.font = [UIFont boldSystemFontOfSize:20];
    label.textAlignment = NSTextAlignmentCenter;
    [self addSubview:label];
    _label = label;
}

- (void)updateConstraints {
    [super updateConstraints];
    UIImageView *imageView = self.imageView;
    UILabel *label = self.label;
    
    NSMutableArray *imageViewConstraints = [NSMutableArray array];
    NSMutableArray *labelConstraints = [NSMutableArray array];
    
    if (self.imageViewConstraints) {
        [self removeConstraints:self.imageViewConstraints];
        self.imageViewConstraints = nil;
    }
    if (self.labelConstraints) {
        [self removeConstraints:self.labelConstraints];
        self.labelConstraints = nil;
    }
    
    [imageViewConstraints addObject: [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
    [imageViewConstraints addObject: [NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:imageView attribute:NSLayoutAttributeHeight multiplier:1.0f constant:0]];
    [imageViewConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(imageView,label)]];
    [self addConstraints:imageViewConstraints];
    
    [labelConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label)]];
    [labelConstraints addObjectsFromArray: [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[imageView]-0-[label]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(label,imageView)]];
    [labelConstraints addObject: [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:50]];
    [self addConstraints:labelConstraints];
    
    self.imageViewConstraints = imageViewConstraints;
    self.labelConstraints = labelConstraints;
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}

@end




