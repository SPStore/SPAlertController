//
//  SPAlertController.m
//  SPAlertController
//
//  Created by 乐升平 on 18/10/12. https://github.com/SPStore/SPAlertController
//  Copyright © 2018-2019 leshengping (lesp163@163.com). All rights reserved.
//

#import "SPAlertController.h"

#define SP_SCREEN_WIDTH [UIScreen mainScreen].bounds.size.width
#define SP_SCREEN_HEIGHT [UIScreen mainScreen].bounds.size.height

#define SP_LINE_WIDTH 1.0 / [UIScreen mainScreen].scale

#define Is_iPhoneX MAX(SP_SCREEN_WIDTH, SP_SCREEN_HEIGHT) >= 812
#define SP_STATUS_BAR_HEIGHT (Is_iPhoneX ? 44 : 20)
#define SP_ACTION_TITLE_FONTSIZE 18
#define SP_ACTION_HEIGHT 55.0

@interface SPColorStyle : NSObject

+ (UIColor *)normalColor;
+ (UIColor *)selectedColor;
+ (UIColor *)lineColor;
+ (UIColor *)line2Color;
+ (UIColor *)lightLineColor;
+ (UIColor *)darkLineColor;
+ (UIColor *)lightWhite_DarkBlackColor;
+ (UIColor *)lightBlack_DarkWhiteColor;
+ (UIColor *)textViewBackgroundColor;
+ (UIColor *)alertRedColor;
+ (UIColor *)grayColor;

+ (UIColor *)colorPairsWithDynamicLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;
+ (UIColor *)colorPairsWithStaticLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor;
@end

@implementation SPColorStyle

+ (UIColor *)normalColor {
    return [self colorPairsWithDynamicLightColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]
                                       darkColor:[UIColor colorWithRed:44.0 / 255.0 green:44.0 / 255.0 blue:44.0 / 255.0 alpha:1.0]];
}

+ (UIColor *)selectedColor {
    return [self colorPairsWithDynamicLightColor:[[UIColor grayColor] colorWithAlphaComponent:0.1]
                                       darkColor:[UIColor colorWithRed:55.0 / 255.0 green:55.0 / 255.0 blue:55.0 / 255.0 alpha:1.0]];
}

+ (UIColor *)lineColor {
    return [self colorPairsWithDynamicLightColor:[self lightLineColor]
                                       darkColor:[self darkLineColor]];
}

+ (UIColor *)line2Color {
    return [self colorPairsWithDynamicLightColor:[[UIColor grayColor] colorWithAlphaComponent:0.15]
                                       darkColor:[UIColor colorWithRed:29.0 / 255.0 green:29.0 / 255.0 blue:29.0 / 255.0 alpha:1.0]];
}

+ (UIColor *)lightWhite_DarkBlackColor {
    return [self colorPairsWithDynamicLightColor:[UIColor whiteColor]
                                       darkColor:[UIColor blackColor]];
}

+ (UIColor *)lightBlack_DarkWhiteColor {
    return [self colorPairsWithDynamicLightColor:[UIColor blackColor]
                                       darkColor:[UIColor whiteColor]];
}

+ (UIColor *)lightLineColor {
    return [[UIColor grayColor] colorWithAlphaComponent:0.3];
}

+ (UIColor *)darkLineColor {
    return [UIColor colorWithRed:60.0 / 255.0 green:60.0 / 255.0 blue:60.0 / 255.0 alpha:1.0];
}

+ (UIColor *)textViewBackgroundColor {
    return [self colorPairsWithDynamicLightColor:[UIColor colorWithRed:247.0 / 255.0 green:247.0 / 255.0 blue:247.0 / 255.0 alpha:1.0]
                                       darkColor:[UIColor colorWithRed:54.0 / 255.0 green:54.0 / 255.0 blue:54.0 / 255.0 alpha:1.0]];
}

+ (UIColor *)alertRedColor {
    return [UIColor systemRedColor];
}

+ (UIColor *)grayColor {
    return [UIColor grayColor];
}

+ (UIColor *)colorPairsWithDynamicLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            } else {
                return lightColor;
            }
        }];
    } else {
        return lightColor;
    }
}

+ (UIColor *)colorPairsWithStaticLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        UIUserInterfaceStyle mode = UITraitCollection.currentTraitCollection.userInterfaceStyle;
        if (mode == UIUserInterfaceStyleDark) {
            return darkColor;
        } else if (mode == UIUserInterfaceStyleLight) {
            return lightColor;
        } else {
            return lightColor;
        }
    }
    return lightColor;
}

@end

#pragma mark ---------------------------- SPAlertAction begin --------------------------------

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"

@interface SPAlertAction()

@property (nonatomic, assign) SPAlertActionStyle style;
@property (nonatomic, copy) void (^handler)(SPAlertAction *action);
// 当在addAction之后设置action属性时,会回调这个block,设置相应控件的字体、颜色等
// 如果没有这个block，那使用时，只有在addAction之前设置action的属性才有效
@property (nonatomic, copy) void (^propertyChangedBlock)(SPAlertAction *action, BOOL needUpdateConstraints);
@end

@implementation SPAlertAction

// 由于要对装载action的数组进行拷贝，所以SPAlertAction也需要支持拷贝
- (id)copyWithZone:(NSZone *)zone {
    
    SPAlertAction *action = [[[self class] alloc] init];
    action.title = self.title;
    action.attributedTitle = self.attributedTitle;
    action.image = self.image;
    action.imageTitleSpacing = self.imageTitleSpacing;
    action.style = self.style;
    action.enabled = self.enabled;
    action.titleColor = self.titleColor;
    action.titleFont = self.titleFont;
    action.titleEdgeInsets = self.titleEdgeInsets;
    action.handler = self.handler;
    action.propertyChangedBlock = self.propertyChangedBlock;
    return action;
}

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(SPAlertActionStyle)style handler:(void (^ __nullable)(SPAlertAction *action))handler {
    SPAlertAction *action = [[self alloc] initWithTitle:title style:(SPAlertActionStyle)style handler:handler];
    return action;
}

- (instancetype)initWithTitle:(nullable NSString *)title style:(SPAlertActionStyle)style handler:(void (^ __nullable)(SPAlertAction *action))handler {
    self = [self init];
    self.title = title;
    self.style = style;
    self.handler = handler;
    if (style == SPAlertActionStyleDestructive) {
        self.titleColor = [SPColorStyle alertRedColor];
        self.titleFont = [UIFont systemFontOfSize:SP_ACTION_TITLE_FONTSIZE];
    } else if (style == SPAlertActionStyleCancel) {
        self.titleColor = [SPColorStyle lightBlack_DarkWhiteColor];
        self.titleFont = [UIFont boldSystemFontOfSize:SP_ACTION_TITLE_FONTSIZE];
    } else {
        self.titleColor = [SPColorStyle lightBlack_DarkWhiteColor];
        self.titleFont = [UIFont systemFontOfSize:SP_ACTION_TITLE_FONTSIZE];
    }
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    _enabled = YES; // 默认能点击
    _titleColor = [SPColorStyle lightBlack_DarkWhiteColor];
    _titleFont = [UIFont systemFontOfSize:SP_ACTION_TITLE_FONTSIZE];
    _titleEdgeInsets = UIEdgeInsetsMake(0, 15, 0, 15);
}

- (void)setTitle:(NSString *)title {
    _title = title;
    if (self.propertyChangedBlock) {
        self.propertyChangedBlock(self, YES);
    }
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    _attributedTitle = attributedTitle;
    if (self.propertyChangedBlock) {
        self.propertyChangedBlock(self, YES);
    }
}

- (void)setImage:(UIImage *)image {
    _image = image;
    if (self.propertyChangedBlock) {
        self.propertyChangedBlock(self, YES);
    }
}

- (void)setImageTitleSpacing:(CGFloat)imageTitleSpacing {
    _imageTitleSpacing = imageTitleSpacing;
    if (self.propertyChangedBlock) {
        self.propertyChangedBlock(self, YES);
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (self.propertyChangedBlock) {
        self.propertyChangedBlock(self,NO); // 颜色改变不需要更新布局
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    if (self.propertyChangedBlock) {
        self.propertyChangedBlock(self,YES); // 字体改变需要更新布局
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (self.propertyChangedBlock) {
        self.propertyChangedBlock(self,NO); // enabled改变不需要更新布局
    }
}

@end

#pragma mark ---------------------------- SPAlertAction end ----------------------------

#pragma mark ---------------------------- SPInterfaceActionItemSeparatorView begin --------------------------------

@interface SPInterfaceActionItemSeparatorView : UIView
@end
@implementation SPInterfaceActionItemSeparatorView
- (instancetype)init {
    if (self = [super init]) {
        self.backgroundColor = [SPColorStyle lineColor];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.backgroundColor = MIN(self.frame.size.width, self.frame.size.height) > SP_LINE_WIDTH ? [SPColorStyle line2Color] : [SPColorStyle lineColor];
}

@end
#pragma mark ---------------------------- SPAlertControllerActionView end --------------------------------

#pragma mark ---------------------------- SPInterfaceHeaderScrollView begin ----------------------------

@interface SPInterfaceHeaderScrollView : UIScrollView
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, weak) UILabel *messageLabel;
@property (nonatomic, weak) UIImageView *imageView;
@property (nonatomic, assign) CGSize imageLimitSize;
@property (nonatomic, weak) UIStackView *textFieldView;
@property (nonatomic, strong) NSMutableArray *textFields;
@property (nonatomic, assign) UIEdgeInsets contentEdgeInsets;
@property (nonatomic, copy) void(^headerViewSfeAreaDidChangBlock)(void);
@end

@implementation SPInterfaceHeaderScrollView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            self.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        self.contentEdgeInsets = UIEdgeInsetsMake(20, 15, 20, 15);
    }
    return self;
}

- (void)addTextField:(UITextField *)textField {
    [self.textFields addObject:textField];
    // 将textView添加到self.textFieldView中的布局队列中，UIStackView会根据设置的属性自动布局
    [self.textFieldView addArrangedSubview:textField];
    // 由于self.textFieldView是没有高度的，它的高度由子控件撑起，所以子控件必须要有高度
    [[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:30.0f] setActive:YES];
    [self setNeedsUpdateConstraints];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    if (@available(iOS 13.0, *)) {
        // 设置CGColor，不要传previousTraitCollection,previousTraitCollection指的是上一次的模式
        UIColor *resolvedColor = [[SPColorStyle lineColor] resolvedColorWithTraitCollection:self.traitCollection];
        for (UITextField *textField in self.textFields) {
            textField.layer.borderColor = resolvedColor.CGColor;
        }
    }
}

- (NSMutableArray *)textFields {
    if (!_textFields) {
        _textFields = [[NSMutableArray alloc] init];
    }
    return _textFields;
}

- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    CGFloat safeTop    = self.safeAreaInsets.top < 20 ? 20 : self.safeAreaInsets.top+10;
    CGFloat safeLeft   = self.safeAreaInsets.left < 15 ? 15 : self.safeAreaInsets.left;
    CGFloat safeBottom = self.safeAreaInsets.bottom < 20 ? 20 : self.safeAreaInsets.bottom+6;
    CGFloat safeRight  = self.safeAreaInsets.right < 15 ? 15 : self.safeAreaInsets.right;
    _contentEdgeInsets = UIEdgeInsetsMake(safeTop, safeLeft, safeBottom, safeRight);
    // 这个block，主要是更新Label的最大预估宽度
    if (self.headerViewSfeAreaDidChangBlock) {
        self.headerViewSfeAreaDidChangBlock();
    }
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];
    UIView *contentView = self.contentView;
    // 对contentView布局
    // 先移除旧约束，再添加新约束
    [NSLayoutConstraint deactivateConstraints:self.constraints];
    [NSLayoutConstraint deactivateConstraints:contentView.constraints];

    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentView)]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentView)]];
    [[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0] setActive:YES];
    NSLayoutConstraint *equalHeightConstraint = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
    equalHeightConstraint.priority = 998.0f; // 优先级不能最高， 最顶层的父view有高度限制，如果子控件撑起后的高度大于限制高度，则scrollView滑动查看全部内容
    equalHeightConstraint.active = YES;
    
    UIImageView *imageView = _imageView;
    UIStackView *textFieldView = _textFieldView;

    CGFloat leftMargin   = self.contentEdgeInsets.left;
    CGFloat rightMargin  = self.contentEdgeInsets.right;
    CGFloat topMargin    = self.contentEdgeInsets.top;
    CGFloat bottomMargin = self.contentEdgeInsets.bottom;
    
    // 对iconView布局
    if (imageView.image) {
        NSMutableArray *imageViewConstraints = [NSMutableArray array];
        [imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:MIN(imageView.image.size.width, _imageLimitSize.width)]];
        [imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:MIN(imageView.image.size.height, _imageLimitSize.height)]];
        [imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeCenterX multiplier:1.f constant:0]];
        [imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.f constant:topMargin]];
        if (_titleLabel.text.length || _titleLabel.attributedText.length) {
            [imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_titleLabel attribute:NSLayoutAttributeTop multiplier:1.f constant:-17]];
        } else if (_messageLabel.text.length || _messageLabel.attributedText.length) {
            [imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:_messageLabel attribute:NSLayoutAttributeTop multiplier:1.f constant:-17]];
        } else if (_textFields.count) {
            [imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textFieldView attribute:NSLayoutAttributeTop multiplier:1.f constant:-17]];
        } else {
            [imageViewConstraints addObject:[NSLayoutConstraint constraintWithItem:imageView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-bottomMargin]];
        }
        [NSLayoutConstraint activateConstraints:imageViewConstraints];
    }
    
    // 对titleLabel和messageLabel布局
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
    NSMutableArray *labels = [NSMutableArray array];
    if (_titleLabel.text.length || _titleLabel.attributedText.length) {
        [labels insertObject:_titleLabel atIndex:0];
    }
    if (_messageLabel.text.length || _messageLabel.attributedText.length) {
        [labels addObject:_messageLabel];
    }
    [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
        // 左右间距
        [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==leftMargin)-[label]-(==rightMargin)-|"] options:0 metrics:@{@"leftMargin":@(leftMargin),@"rightMargin":@(rightMargin)} views:NSDictionaryOfVariableBindings(label)]];
        // 第一个子控件顶部间距
        if (idx == 0) {
            if (!imageView.image) {
                [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.f constant:topMargin]];
            }
        }
        // 最后一个子控件底部间距
        if (idx == labels.count - 1) {
            if (self.textFields.count) {
                [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textFieldView attribute:NSLayoutAttributeTop multiplier:1.f constant:-bottomMargin]];
            } else {
                [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-bottomMargin]];
            }
        }
        // 子控件之间的垂直间距
        if (idx > 0) {
            [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:labels[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:7.5]];
        }
    }];
    [NSLayoutConstraint activateConstraints:titleLabelConstraints];
    
    if (self.textFields.count) {
        NSMutableArray *textFieldViewConstraints = [NSMutableArray array];
        if (!labels.count && !imageView.image) { // 没有titleLabel、messageLabel和iconView，textFieldView的顶部相对contentView,否则不用写,因为前面写好了
            [textFieldViewConstraints addObject:[NSLayoutConstraint constraintWithItem:textFieldView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeTop multiplier:1.f constant:topMargin]];
        }
        [textFieldViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==leftMargin)-[textFieldView]-(==rightMargin)-|"] options:0 metrics:@{@"leftMargin":@(leftMargin),@"rightMargin":@(rightMargin)} views:NSDictionaryOfVariableBindings(textFieldView)]];
        [textFieldViewConstraints addObject:[NSLayoutConstraint constraintWithItem:textFieldView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:contentView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-bottomMargin]];

        [NSLayoutConstraint activateConstraints:textFieldViewConstraints];
    }
    
    // systemLayoutSizeFittingSize:方法获取子控件撑起contentView后的高度，如果子控件是UILabel，那么子label必须设置preferredMaxLayoutWidth,否则当label多行文本时计算不准确
    NSLayoutConstraint *contentViewHeightConstraint = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:[contentView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height];
    contentViewHeightConstraint.active = YES;
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] init];
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.textColor = [SPColorStyle lightBlack_DarkWhiteColor];
        titleLabel.numberOfLines = 0;
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:titleLabel];
        _titleLabel = titleLabel;
    }
    return _titleLabel;
}

- (UILabel *)messageLabel {
    if (!_messageLabel) {
        UILabel *messageLabel = [[UILabel alloc] init];
        messageLabel.font = [UIFont systemFontOfSize:18];
        messageLabel.textAlignment = NSTextAlignmentCenter;
        messageLabel.textColor = [SPColorStyle grayColor];
        messageLabel.numberOfLines = 0;
        messageLabel.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView addSubview:messageLabel];
        _messageLabel = messageLabel;
    }
    return _messageLabel;
}

- (UIImageView *)imageView {
    if (!_imageView) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.contentView insertSubview:imageView atIndex:0];
        _imageView = imageView;
    }
    return _imageView;
}

- (UIStackView *)textFieldView {
    if (!_textFieldView) {
        UIStackView *textFieldView = [[UIStackView alloc] init];
        textFieldView.translatesAutoresizingMaskIntoConstraints = NO;
        textFieldView.distribution = UIStackViewDistributionFillEqually;
        textFieldView.axis = UILayoutConstraintAxisVertical;
        if (self.textFields.count) {
            [self.contentView addSubview:textFieldView];
        }
        _textFieldView = textFieldView;
    }
    return _textFieldView;
}

@end

#pragma mark ---------------------------- SPInterfaceHeaderScrollView end ----------------------------

#pragma mark ---------------------------- SPAlertControllerActionView begin --------------------------------

@interface SPAlertControllerActionView : UIView
@property (nonatomic, weak) id target;
@property (nonatomic, assign) SEL methodAction;
@property (nonatomic, strong) SPAlertAction *action;
@property (nonatomic, weak) UIButton *actionButton;
@property (nonatomic, strong) NSMutableArray *actionButtonConstraints;
@property (nonatomic, assign) CGFloat afterSpacing;
- (void)addTarget:(id)target action:(SEL)action;
@end

@implementation SPAlertControllerActionView

- (instancetype)init {
    if (self = [super init]) {
        _afterSpacing = SP_LINE_WIDTH;
    }
    return self;
}

- (void)setAction:(SPAlertAction *)action {
    _action = action;

    self.actionButton.titleLabel.font = action.titleFont;
    if (action.enabled) {
        [self.actionButton setTitleColor:action.titleColor forState:UIControlStateNormal];
    } else {
        [self.actionButton setTitleColor:[action.titleColor colorWithAlphaComponent:0.4] forState:UIControlStateNormal];
    }
    
    // 注意不能赋值给按钮的titleEdgeInsets，当只有文字时，按钮的titleEdgeInsets设置top和bottom值无效
    self.actionButton.contentEdgeInsets = action.titleEdgeInsets;
    self.actionButton.enabled = action.enabled;
    self.actionButton.tintColor = action.tintColor;
    if (action.attributedTitle) {
        // 这里之所以要设置按钮颜色为黑色，是因为如果外界在addAction:之后设置按钮的富文本，那么富文本的颜色在没有采用NSForegroundColorAttributeName的情况下会自动读取按钮上普通文本的颜色，在addAction:之前设置会保持默认色(黑色)，为了在addAction:前后设置富文本保持统一，这里先将按钮置为黑色，富文本就会是黑色
        [self.actionButton setTitleColor:[SPColorStyle lightBlack_DarkWhiteColor] forState:UIControlStateNormal];
        
        if ([action.attributedTitle.string containsString:@"\n"] || [action.attributedTitle.string containsString:@"\r"]) {
            self.actionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        [self.actionButton setAttributedTitle:action.attributedTitle forState:UIControlStateNormal];
        
        // 设置完富文本之后，还原按钮普通文本的颜色，其实这行代码加不加都不影响，只是为了让按钮普通文本的颜色保持跟action.titleColor一致
        [self.actionButton setTitleColor:action.titleColor forState:UIControlStateNormal];
    } else {
        if ([action.title containsString:@"\n"] || [action.title containsString:@"\r"]) {
            self.actionButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        }
        [self.actionButton setTitle:action.title forState:UIControlStateNormal];
    }
    [self.actionButton setImage:action.image forState:UIControlStateNormal];
    self.actionButton.titleEdgeInsets = UIEdgeInsetsMake(0, action.imageTitleSpacing, 0, -action.imageTitleSpacing);
    self.actionButton.imageEdgeInsets = UIEdgeInsetsMake(0, -action.imageTitleSpacing, 0, action.imageTitleSpacing);
}

- (void)addTarget:(id)target action:(SEL)methodAction {
    _target = target;
    _methodAction = methodAction;
}

- (void)touchUpInside:(UIButton *)sender {
    // 用函数指针实现_target调用_methodAction，相当于[_target performSelector:_methodAction withObject:self];但是后者会报警告
    SEL selector = _methodAction;
    IMP imp = [_target methodForSelector:selector];
    void (*func)(id, SEL,SPAlertControllerActionView *) = (void *)imp;
    func(_target, selector, self);
}

- (void)touchDown:(UIButton *)sender {
    sender.backgroundColor = [SPColorStyle selectedColor];
}

- (void)touchDragExit:(UIButton *)sender {
    sender.backgroundColor = [SPColorStyle normalColor];
}

- (SPAlertController *)findAlertController {
    UIResponder *next = [self nextResponder];
    do {
        if ([next isKindOfClass:[SPAlertController class]]) {
            return (SPAlertController *)next;
        } else {
            next = [next nextResponder];
        }
    } while (next != nil);
    return nil;
}

// 安全区域发生了改变,在这个方法里自动适配iPhoneX
- (void)safeAreaInsetsDidChange {
    [super safeAreaInsetsDidChange];
    // safeAreaInsets+titleEdgeInsets
    self.actionButton.contentEdgeInsets = UIEdgeInsetsAddEdgeInsets(self.safeAreaInsets, _action.titleEdgeInsets);
    [self setNeedsUpdateConstraints];
}

UIEdgeInsets UIEdgeInsetsAddEdgeInsets(UIEdgeInsets i1,UIEdgeInsets i2) {
    return UIEdgeInsetsMake(i1.top+i2.top, i1.left+i2.left, i1.bottom+i2.bottom, i1.right+i2.right);
}

- (void)updateConstraints {
    [super updateConstraints];

    UIButton *actionButton = self.actionButton;
    if (self.actionButtonConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.actionButtonConstraints];
        self.actionButtonConstraints = nil;
    }
    NSMutableArray *actionButtonConstraints = [NSMutableArray array];
    [actionButtonConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionButton]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionButton)]];
    [actionButtonConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[actionButton]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionButton)]];
    // 按钮必须确认高度，因为其父视图及父视图的父视图乃至根视图都没有设置高度，而且必须用NSLayoutRelationEqual，如果用NSLayoutRelationGreaterThanOrEqual,虽然也能撑起父视图，但是当某个按钮的高度有所变化以后，stackView会将其余按钮按的高度同比增减。
    // titleLabel的内容自适应的高度
    CGFloat labelH = actionButton.titleLabel.intrinsicContentSize.height;
    // 按钮的上下内边距之和
    CGFloat topBottom_insetsSum = actionButton.contentEdgeInsets.top+actionButton.contentEdgeInsets.bottom;
    // 文字的上下间距之和,等于SP_ACTION_HEIGHT-默认字体大小,这是为了保证文字上下有一个固定间距值，不至于使文字靠按钮太紧，,由于按钮内容默认垂直居中，所以最终的顶部或底部间距为topBottom_marginSum/2.0,这个间距，几乎等于18号字体时，最小高度为49时的上下间距
    CGFloat topBottom_marginSum = SP_ACTION_HEIGHT-[UIFont systemFontOfSize:SP_ACTION_TITLE_FONTSIZE].lineHeight;
    // 按钮高度
    CGFloat buttonH = labelH+topBottom_insetsSum+topBottom_marginSum;
    UIStackView *stackView = (UIStackView *)self.superview;
    NSLayoutRelation relation = NSLayoutRelationEqual;
    if ([stackView isKindOfClass:[UIStackView class]] && stackView.axis == UILayoutConstraintAxisHorizontal) {
        relation = NSLayoutRelationGreaterThanOrEqual;
    }
    // 如果字体保持默认18号，只有一行文字时最终结果约等于SP_ACTION_HEIGHT
    NSLayoutConstraint *buttonHonstraint = [NSLayoutConstraint constraintWithItem:actionButton attribute:NSLayoutAttributeHeight relatedBy:relation toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:buttonH];
    buttonHonstraint.priority = 999;
    [actionButtonConstraints addObject:buttonHonstraint];
    // 给一个最小高度，当按钮字体很小时，如果还按照上面的高度计算，高度会比较小
    NSLayoutConstraint *minHConstraint = [NSLayoutConstraint constraintWithItem:actionButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SP_ACTION_HEIGHT+topBottom_insetsSum];
    minHConstraint.priority = UILayoutPriorityRequired;
    [self addConstraints:actionButtonConstraints];
    self.actionButtonConstraints = actionButtonConstraints;
}

- (UIButton *)actionButton {
    if (!_actionButton) {
        UIButton *actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        actionButton.backgroundColor = [SPColorStyle normalColor];
        actionButton.translatesAutoresizingMaskIntoConstraints = NO;
        actionButton.titleLabel.textAlignment = NSTextAlignmentCenter;
        actionButton.titleLabel.adjustsFontSizeToFitWidth = YES;
        actionButton.titleLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        actionButton.titleLabel.minimumScaleFactor = 0.5;
        [actionButton addTarget:self action:@selector(touchUpInside:) forControlEvents:UIControlEventTouchUpInside]; // 手指按下然后在按钮有效事件范围内抬起
        [actionButton addTarget:self action:@selector(touchDown:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside]; // 手指按下或者手指按下后往外拽再往内拽
        [actionButton addTarget:self action:@selector(touchDragExit:) forControlEvents:UIControlEventTouchDragExit | UIControlEventTouchUpOutside | UIControlEventTouchCancel]; // 手指被迫停止、手指按下后往外拽或者取消，取消的可能性:比如点击的那一刻突然来电话
        [self addSubview:actionButton];
        _actionButton = actionButton;
    }
    return _actionButton;
}

@end
#pragma mark ---------------------------- SPAlertControllerActionView end --------------------------------

#pragma mark ---------------------------- SPInterfaceActionSequenceView begin --------------------------------

@interface SPInterfaceActionSequenceView : UIView
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, weak) UIView *contentView;
@property (nonatomic, weak) UIView *cancelView;
@property (nonatomic, weak) SPInterfaceActionItemSeparatorView *cancelActionLine;
@property (nonatomic, weak) UIStackView *stackView;
@property (nonatomic, strong) SPAlertAction *cancelAction;
@property (nonatomic, strong) NSMutableArray *actionLineConstraints;
@property (nonatomic, strong) NSMutableArray *actions;
@property (nonatomic, assign) UIStackViewDistribution stackViewDistribution;
@property (nonatomic, assign) UILayoutConstraintAxis axis;
@property (nonatomic, copy) void (^buttonClickedInActionViewBlock)(NSInteger index);
@end

@implementation SPInterfaceActionSequenceView

- (void)setAxis:(UILayoutConstraintAxis)axis {
    _axis = axis;
    self.stackView.axis = axis;
    [self setNeedsUpdateConstraints];
}

- (void)setStackViewDistribution:(UIStackViewDistribution)stackViewDistribution {
    _stackViewDistribution = stackViewDistribution;
    self.stackView.distribution = stackViewDistribution;
    [self setNeedsUpdateConstraints];
}

- (void)buttonClickedInActionView:(SPAlertControllerActionView *)actionView {
    NSInteger index = [self.actions indexOfObject:actionView.action];
    if (self.buttonClickedInActionViewBlock) {
        self.buttonClickedInActionViewBlock(index);
    }
}

- (void)setCustomSpacing:(CGFloat)spacing afterActionIndex:(NSInteger)index {
    UIStackView *stackView = self.stackView;
    SPAlertControllerActionView *actionView = stackView.arrangedSubviews[index];
    actionView.afterSpacing = spacing;
    if (@available(iOS 11.0, *)) {
        [self.stackView setCustomSpacing:spacing afterView:actionView];
    }
    [self updateLineConstraints];
}

- (CGFloat)customSpacingAfterActionIndex:(NSInteger)index {
    UIStackView *stackView = self.stackView;
    SPAlertControllerActionView *actionView = stackView.arrangedSubviews[index];
    if (@available(iOS 11.0, *)) {
       return [self.stackView customSpacingAfterView:actionView];
    } else {
        return 0.0;
    }
}

- (void)addAction:(SPAlertAction *)action {
    [self.actions addObject:action];
    UIStackView *stackView = self.stackView;

    SPAlertControllerActionView *currentActionView = [[SPAlertControllerActionView alloc] init];
    currentActionView.action = action;
    [currentActionView addTarget:self action:@selector(buttonClickedInActionView:)];
    [stackView addArrangedSubview:currentActionView];

    if (stackView.arrangedSubviews.count > 1) { // arrangedSubviews个数大于1，说明本次添加至少是第2次添加，此时要加一条分割线
        [self addLineForStackView:stackView];
    }
    [self setNeedsUpdateConstraints];
}

- (void)addCancelAction:(SPAlertAction *)action {
    // 如果已经存在取消样式的按钮，则直接崩溃
    NSAssert(!_cancelAction, @"SPAlertController can only have one action with a style of SPAlertActionStyleCancel");
    _cancelAction = action;
    [self.actions addObject:action];
    SPAlertControllerActionView *cancelActionView = [[SPAlertControllerActionView alloc] init];
    cancelActionView.translatesAutoresizingMaskIntoConstraints = NO;
    cancelActionView.action = action;
    [cancelActionView addTarget:self action:@selector(buttonClickedInActionView:)];
    [self.cancelView addSubview:cancelActionView];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cancelActionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancelActionView)]];
    [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[cancelActionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancelActionView)]];
    
    [self setNeedsUpdateConstraints];
}

// 为stackView添加分割线(细节)
- (void)addLineForStackView:(UIStackView *)stackView {
    SPInterfaceActionItemSeparatorView *actionLine = [[SPInterfaceActionItemSeparatorView alloc] init];
    actionLine.translatesAutoresizingMaskIntoConstraints = NO;
    // 这里必须用addSubview:，不能用addArrangedSubview:,因为分割线不参与排列布局
    [stackView addSubview:actionLine];
}

// 从一个数组筛选出不在另一个数组中的数组
- (NSArray *)filteredArrayFromArray:(NSArray *)array notInArray:(NSArray *)otherArray {
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"NOT (SELF in %@)", otherArray];
    // 用谓词语句筛选出所有的分割线
    NSArray *subArray = [array filteredArrayUsingPredicate:predicate];
    return subArray;
}

// 更新分割线约束(细节)
- (void)updateLineConstraints {

    UIStackView *stackView = self.stackView;
    NSArray *arrangedSubviews = stackView.arrangedSubviews;
    if (arrangedSubviews.count <= 1) return;
    // 用谓词语句筛选出所有的分割线
    NSArray *lines = [self filteredArrayFromArray:stackView.subviews notInArray:stackView.arrangedSubviews];
    if (arrangedSubviews.count < lines.count) return;
    NSMutableArray *actionLineConstraints = [NSMutableArray array];
    if (self.actionLineConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.actionLineConstraints];
        self.actionLineConstraints = nil;
    }
    for (int i = 0; i < lines.count; i++) {
        SPInterfaceActionItemSeparatorView *actionLine = lines[i];
        SPAlertControllerActionView *actionView1 = arrangedSubviews[i];
        SPAlertControllerActionView *actionView2 = arrangedSubviews[i+1];
        if (self.axis == UILayoutConstraintAxisHorizontal) {
            [actionLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[actionLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionLine)]];
            [actionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:actionLine attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:actionView1 attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
            [actionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:actionLine attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:actionView2 attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
            [actionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:actionLine attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:actionView1.afterSpacing]];
        } else {
            [actionLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionLine)]];
            [actionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:actionLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:actionView1 attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
            [actionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:actionLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:actionView2 attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
            [actionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:actionLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:actionView1.afterSpacing]];
        }
    }
    [NSLayoutConstraint activateConstraints:actionLineConstraints];
    self.actionLineConstraints = actionLineConstraints;
}

- (void)updateConstraints {
    [super updateConstraints];
    UIView *scrollView = self.scrollView;
    UIView *contentView = self.contentView;
    UIView *cancelView = self.cancelView;
    SPInterfaceActionItemSeparatorView *cancelActionLine = self.cancelActionLine;

    [NSLayoutConstraint deactivateConstraints:self.constraints];
    if (scrollView && scrollView.superview) {
        // 对scrollView布局
        NSMutableArray *scrollViewConstraints = [NSMutableArray array];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[scrollView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(scrollView)]];
        [scrollViewConstraints addObject:[NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        if (cancelActionLine.superview) {
            [scrollViewConstraints addObject:[NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cancelActionLine attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        } else {
            [scrollViewConstraints addObject:[NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        }
        [NSLayoutConstraint activateConstraints:scrollViewConstraints];
        
        [NSLayoutConstraint deactivateConstraints:scrollView.constraints];
        // 对contentView布局
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentView)]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentView)]];
        [[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeWidth multiplier:1.0 constant:0] setActive:YES];
        NSLayoutConstraint *equalHeightConstraint = [NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:scrollView attribute:NSLayoutAttributeHeight multiplier:1.0 constant:0];
        // 计算scrolView的最小和最大高度，下面这个if语句是保证当actions的g总个数大于4时，scrollView的高度至少为4个半SP_ACTION_HEIGHT的高度，否则自适应内容
        CGFloat minHeight = 0.0;
        if (_axis == UILayoutConstraintAxisVertical) {
            if (self.cancelAction) {
                if (self.actions.count > 4) { // 如果有取消按钮且action总个数大于4，则除去取消按钮之外的其余部分的高度至少为3个半SP_ACTION_HEIGHT的高度,即加上取消按钮就是总高度至少为4个半SP_ACTION_HEIGHT的高度
                    minHeight = SP_ACTION_HEIGHT * 3.5;
                    equalHeightConstraint.priority = 997.0f; // 优先级为997，必须小于998.0，因为头部如果内容过多时高度也会有限制，头部的优先级为998.0.这里定的规则是，当头部和action部分同时过多时，头部的优先级更高，但是它不能高到以至于action部分小于最小高度
                } else { // 如果有取消按钮但action的个数大不于4，则该多高就显示多高
                    equalHeightConstraint.priority = 1000.0f; // 由子控件撑起
                }
            } else {
                if (self.actions.count > 4) {
                    minHeight = SP_ACTION_HEIGHT * 4.5;
                    equalHeightConstraint.priority = 997.0f;
                } else {
                    equalHeightConstraint.priority = 1000.0f;
                }
            }
        } else {
            minHeight = SP_ACTION_HEIGHT;
        }
        NSLayoutConstraint *minHeightConstraint = [NSLayoutConstraint constraintWithItem:scrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:minHeight];
        minHeightConstraint.priority = 999.0;// 优先级不能大于对话框的最小顶部间距的优先级(999.0)
        minHeightConstraint.active = YES;
        equalHeightConstraint.active = YES;
        
        UIStackView *stackView = self.stackView;
        [NSLayoutConstraint deactivateConstraints:contentView.constraints];
        // 对stackView布局
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[stackView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(stackView)]];
        [NSLayoutConstraint activateConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[stackView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(stackView)]];
        
        // 对stackView里面的分割线布局
        [self updateLineConstraints];
    }
  
    if (self.cancelActionLine.superview) { // cancelActionLine有superView则必有scrollView和cancelView
        NSMutableArray *cancelActionLineConstraints = [NSMutableArray array];
        [cancelActionLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cancelActionLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancelActionLine)]];
        [cancelActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:cancelActionLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:cancelView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
        [cancelActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:cancelActionLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:8.0]];
        [NSLayoutConstraint activateConstraints:cancelActionLineConstraints];
    }
    
    // 对cancelView布局
    if (self.cancelAction) { // 有取消样式的按钮才对cancelView布局
        NSMutableArray *cancelViewConstraints = [NSMutableArray array];
        [cancelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[cancelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(cancelView)]];
        [cancelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:cancelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        if (!self.cancelActionLine.superview) {
            [cancelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:cancelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        }
        [NSLayoutConstraint activateConstraints:cancelViewConstraints];
    }
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        UIScrollView *scrollView = [[UIScrollView alloc] init];
        scrollView.showsHorizontalScrollIndicator = NO;
        scrollView.translatesAutoresizingMaskIntoConstraints = NO;
        if (@available(iOS 11.0, *)) {
            scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        if ((self.cancelAction && self.actions.count > 1) || (!self.cancelAction && self.actions.count > 0)) {
            [self addSubview:scrollView];
        }
        _scrollView = scrollView;
    }
    return _scrollView;
}

- (UIView *)contentView {
    if (!_contentView) {
        UIView *contentView = [[UIView alloc] init];
        contentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.scrollView addSubview:contentView];
        _contentView = contentView;
    }
    return _contentView;
}

- (UIStackView *)stackView {
    if (!_stackView) {
        UIStackView *stackView = [[UIStackView alloc] init];
        stackView.translatesAutoresizingMaskIntoConstraints = NO;
        stackView.distribution = UIStackViewDistributionFillProportionally;
        stackView.spacing = SP_LINE_WIDTH; // 该间距腾出来的空间显示分割线
        stackView.axis = UILayoutConstraintAxisVertical;
        [self.contentView addSubview:stackView];
        _stackView = stackView;
    }
    return _stackView;
}

- (UIView *)cancelView {
    if (!_cancelView) {
        UIView *cancelView = [[UIView alloc] init];
        cancelView.translatesAutoresizingMaskIntoConstraints = NO;
        if (self.cancelAction) {
            [self addSubview:cancelView];
        }
        _cancelView = cancelView;
    }
    return _cancelView;
}

- (SPInterfaceActionItemSeparatorView *)cancelActionLine {
    if (!_cancelActionLine) {
        SPInterfaceActionItemSeparatorView *cancelActionLine = [[SPInterfaceActionItemSeparatorView alloc] init];
        cancelActionLine.translatesAutoresizingMaskIntoConstraints = NO;
        if (self.cancelView.superview && self.scrollView.superview) {
            [self addSubview:cancelActionLine];
        }
        _cancelActionLine = cancelActionLine;
    }
    return _cancelActionLine;
}

- (NSMutableArray *)actions {
    if (!_actions) {
        _actions = [[NSMutableArray alloc] init];
    }
    return _actions;
}

@end
#pragma mark ---------------------------- SPInterfaceActionSequenceView end --------------------------------


#pragma mark ---------------------------- SPAlertController begin --------------------------------

@interface SPAlertController () <UIViewControllerTransitioningDelegate>
@property (nonatomic, strong) UIView *alertControllerView;
@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, weak) UIView *alertView;
@property (nonatomic, strong) UIView *customAlertView;
@property (nonatomic, weak) SPInterfaceHeaderScrollView *headerView;
@property (nonatomic, strong) UIView *customHeaderView;
@property (nonatomic, weak) SPInterfaceActionSequenceView *actionSequenceView;
@property (nonatomic, strong) UIView *customActionSequenceView;
@property (nonatomic, strong) UIView *componentView;
@property (nonatomic, assign) CGSize customViewSize;
@property (nonatomic, weak) SPInterfaceActionItemSeparatorView *headerActionLine;
@property (nonatomic, strong) NSMutableArray *headerActionLineConstraints;
@property (nonatomic, weak) SPInterfaceActionItemSeparatorView *componentActionLine;
@property (nonatomic, strong) NSMutableArray *componentViewConstraints;
@property (nonatomic, strong) NSMutableArray *componentActionLineConstraints;
@property (nonatomic, strong) UIView *dimmingKnockoutBackdropView;
@property (nonatomic, strong) NSMutableArray *alertControllerViewConstraints;
@property (nonatomic, strong) NSMutableArray *headerViewConstraints;
@property (nonatomic, strong) NSMutableArray *actionSequenceViewConstraints;
@property (nonatomic, assign) SPAlertControllerStyle preferredStyle;
@property (nonatomic, assign) SPAlertAnimationType animationType;
@property (nonatomic, assign) UIBlurEffectStyle backgroundViewAppearanceStyle;
@property (nonatomic, assign) CGFloat backgroundViewAlpha;

// action数组
@property (nonatomic) NSArray<SPAlertAction *> *actions;
// textFiled数组
@property (nonatomic) NSArray<UITextField *> *textFields;
// 除去取消样式action的其余action数组
@property (nonatomic) NSMutableArray<SPAlertAction *> *otherActions;
@property (nonatomic, assign) BOOL isForceLayout; // 是否强制排列，外界设置了actionAxis属性认为是强制
@property (nonatomic, assign) BOOL isForceOffset; // 是否强制偏移，外界设置了offsetForAlert属性认为是强制
@end

@implementation SPAlertController
@synthesize title = _title;

#pragma mark - public
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:title message:message customAlertView:nil customHeaderView:nil customActionSequenceView:nil componentView:nil preferredStyle:preferredStyle animationType:SPAlertAnimationTypeDefault];
    return alertVc;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:title message:message customAlertView:nil customHeaderView:nil customActionSequenceView:nil componentView:nil preferredStyle:preferredStyle animationType:animationType];
    return alertVc;
}

+ (instancetype)alertControllerWithCustomAlertView:(UIView *)customAlertView preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:nil message:nil customAlertView:customAlertView customHeaderView:nil customActionSequenceView:nil componentView:nil preferredStyle:preferredStyle animationType:animationType];
    return alertVc;
}

+ (instancetype)alertControllerWithCustomHeaderView:(UIView *)customHeaderView preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:nil message:nil customAlertView:nil customHeaderView:customHeaderView customActionSequenceView:nil componentView:nil preferredStyle:preferredStyle animationType:animationType];
    return alertVc;
}

+ (instancetype)alertControllerWithCustomActionSequenceView:(UIView *)customActionSequenceView title:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:title message:message customAlertView:nil customHeaderView:nil customActionSequenceView:customActionSequenceView componentView:nil preferredStyle:preferredStyle animationType:animationType];
    return alertVc;
}

- (void)setOffsetForAlert:(CGPoint)offsetForAlert animated:(BOOL)animated {
    _offsetForAlert = offsetForAlert;
    _isForceOffset = YES;
    [self makeViewOffsetWithAnimated:animated];
}

- (void)insertComponentView:(UIView *)componentView {
    _componentView = componentView;
}

// 添加action
- (void)addAction:(SPAlertAction *)action {
    NSMutableArray *actions = self.actions.mutableCopy;
    [actions addObject:action];
    self.actions = actions;
    if (self.preferredStyle == SPAlertControllerStyleAlert) { // alert样式不论是否为取消样式的按钮，都直接按顺序添加
        if (action.style != SPAlertActionStyleCancel) {
            [self.otherActions addObject:action];
        }
        [self.actionSequenceView addAction:action];
    } else { // actionSheet样式
        if (action.style == SPAlertActionStyleCancel) { // 如果是取消样式的按钮
            [self.actionSequenceView addCancelAction:action];
        } else {
            [self.otherActions addObject:action];
            [self.actionSequenceView addAction:action];
        }
    }
    
    if (!self.isForceLayout) { // 如果为NO,说明外界没有设置actionAxis，此时按照默认方式排列
        if (self.preferredStyle == SPAlertControllerStyleAlert) {
            if (self.actions.count > _maxNumberOfActionHorizontalArrangementForAlert) { // alert样式下，action的个数大于2时垂直排列,这里不等式右边写_maxNumberOfActionHorizontalArrangementForAlert是为了让被废弃的_maxNumberOfActionHorizontalArrangementForAlert依然生效
                _actionAxis = UILayoutConstraintAxisVertical; // 本框架任何一处都不允许调用actionAxis的setter方法，如果调用了则无法判断是外界调用还是内部调用
                [self updateActionAxis];
            } else { // action的个数小于等于2，action水平排列
                _actionAxis = UILayoutConstraintAxisHorizontal;
                [self updateActionAxis];
            }
        } else { // actionSheet样式下默认垂直排列
            _actionAxis = UILayoutConstraintAxisVertical;
            [self updateActionAxis];
            
        }
    } else {
        [self updateActionAxis];
    }
    
    // 这个block是保证外界在添加action之后再设置action属性时依然生效；当使用时在addAction之后再设置action的属性时，会回调这个block
    __weak typeof(self) weakSelf = self;
    action.propertyChangedBlock = ^(SPAlertAction *action, BOOL needUpdateConstraints) {
        __strong typeof(self) strongSelf = weakSelf;
        if (strongSelf.preferredStyle == SPAlertControllerStyleAlert) {
            // alert样式下：arrangedSubviews数组和actions是对应的
            NSInteger index = [strongSelf.actions indexOfObject:action];
            SPAlertControllerActionView *actionView = [strongSelf.actionSequenceView.stackView.arrangedSubviews objectAtIndex:index];
            if ([actionView isKindOfClass:[SPAlertControllerActionView class]]) {
                actionView.action = action;
            }
            if (strongSelf.presentationController.presentingViewController) {
                // 文字显示不全处理
                [strongSelf handleIncompleteTextDisplay];
            }
        } else {
            if (action.style == SPAlertActionStyleCancel) {
                // cancelView中只有唯一的一个actionView
                SPAlertControllerActionView *actionView = [strongSelf.actionSequenceView.cancelView.subviews lastObject];
                if ([actionView isKindOfClass:[SPAlertControllerActionView class]]) { // 这个判断可以不加，加判断是防止有一天改动框架不小心在cancelView中加了新的view产生安全隐患
                    actionView.action = action;
                }
            } else {
                // actionSheet样式下：arrangedSubviews数组和otherActions是对应的
                NSInteger index = [strongSelf.otherActions indexOfObject:action];
                SPAlertControllerActionView *actionView = [strongSelf.actionSequenceView.stackView.arrangedSubviews objectAtIndex:index];
                if ([actionView isKindOfClass:[SPAlertControllerActionView class]]) {
                    actionView.action = action;
                }
            }
        }
        if (strongSelf.presentationController.presentingViewController && needUpdateConstraints) { // 如果在present完成后的某个时刻再去设置action的属性，字体等改变需要更新布局
            [strongSelf.actionSequenceView setNeedsUpdateConstraints];
        }
    };
}

// 添加文本输入框
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField * _Nonnull))configurationHandler {
    NSAssert(self.preferredStyle == SPAlertControllerStyleAlert,@"SPAlertController does not allow 'addTextFieldWithConfigurationHandler:' to be called in the style of SPAlertControllerStyleActionSheet");
    UITextField *textField = [[UITextField alloc] init];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.backgroundColor = [SPColorStyle textViewBackgroundColor];
    // 系统的UITextBorderStyleLine样式线条过于黑，所以自己设置
    textField.layer.borderWidth = SP_LINE_WIDTH;
    // 这里设置的颜色是静态的，动态设置CGColor,还需要监听深浅模式的切换
    textField.layer.borderColor = [SPColorStyle colorPairsWithStaticLightColor:[SPColorStyle lineColor] darkColor:[SPColorStyle darkLineColor]].CGColor;
    // 在左边设置一张view，充当光标左边的间距，否则光标紧贴textField不美观
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    textField.leftView.userInteractionEnabled = NO;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.font = [UIFont systemFontOfSize:14];
    // 去掉textField键盘上部的联想条
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [textField addTarget:self action:@selector(textFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    NSMutableArray *array = self.textFields.mutableCopy;
    [array addObject:textField];
    self.textFields = array;
    [self.headerView addTextField:textField];
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (void)setCustomSpacing:(CGFloat)spacing afterAction:(SPAlertAction *)action {
    if (@available(iOS 11.0, *)) {
        if (action == nil) return;
        if (action.style == SPAlertActionStyleCancel) {
            NSLog(@"*** warning in -[SPAlertController setCustomSpacing:afterAction:]: 'the -action must not be a action with SPAlertActionStyleCancel style'");
        } else if (![self.otherActions containsObject:action]) {
            NSLog(@"*** warning in -[SPAlertController setCustomSpacing:afterAction:]: 'the -action must be contained in the -actions array, not a action with SPAlertActionStyleCancel style'");
        } else {
            NSInteger index = [self.otherActions indexOfObject:action];
            [self.actionSequenceView setCustomSpacing:spacing afterActionIndex:index];
        }
    } else {
        // 报异常
        [self doesNotRecognizeSelector:@selector(setCustomSpacing:afterAction:)];
    }
}

- (CGFloat)customSpacingAfterAction:(SPAlertAction *)action {
    if (@available(iOS 11.0, *)) {
        if ([self.otherActions containsObject:action]) {
            NSInteger index = [self.otherActions indexOfObject:action];
            return [self.actionSequenceView customSpacingAfterActionIndex:index];
        }
    } else {
        // 报异常
        [self doesNotRecognizeSelector:@selector(setCustomSpacing:afterAction:)];
    }
    return 0.0;
}

- (void)setBackgroundViewAppearanceStyle:(UIBlurEffectStyle)style alpha:(CGFloat)alpha {
    _backgroundViewAppearanceStyle = style;
    _backgroundViewAlpha = alpha;
}

- (void)updateCustomViewSize:(CGSize)size {
    _customViewSize = size;
    [self layoutAlertControllerView];
    [self layoutChildViews];
}

#pragma mark - Private
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message customAlertView:(UIView *)customAlertView customHeaderView:(UIView *)customHeaderView customActionSequenceView:(UIView *)customActionSequenceView componentView:(UIView *)componentView preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType {
    self = [self init];
    _title = title;
    _message = message;
    _preferredStyle = preferredStyle;
    // 如果是默认动画，preferredStyle为alert时动画默认为alpha，preferredStyle为actionShee时动画默认为fromBottom
    if (animationType == SPAlertAnimationTypeDefault) {
        if (preferredStyle == SPAlertControllerStyleAlert) {
            animationType = SPAlertAnimationTypeShrink;
        } else {
            animationType = SPAlertAnimationTypeFromBottom;
        }
    }
    _animationType = animationType;
    if (preferredStyle == SPAlertControllerStyleAlert) {
        _maxMarginForAlert = (MIN(SP_SCREEN_WIDTH, SP_SCREEN_HEIGHT) - 275) / 2.0;
        _minDistanceToEdges = (MIN(SP_SCREEN_WIDTH, SP_SCREEN_HEIGHT) - 275) / 2.0;
        _cornerRadius = 6.0;
    } else {
        _minDistanceToEdges = 70;
        _maxTopMarginForActionSheet = 70;
        _cornerRadius = 13.0;
    }
    if (preferredStyle == SPAlertControllerStyleAlert) {
        _actionAxis = UILayoutConstraintAxisHorizontal;
    } else {
        _actionAxis = UILayoutConstraintAxisVertical;
    }
    _customAlertView = customAlertView;
    _customHeaderView = customHeaderView;
    _customActionSequenceView = customActionSequenceView;
    _componentView = componentView; // componentView参数是为了支持老版本的自定义footerView
    return self;
}

- (instancetype)init {
    if (self = [super init]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    // 视图控制器定义它呈现视图控制器的过渡风格（默认为NO）
    self.providesPresentationContextTransitionStyle = YES;
    self.definesPresentationContext = YES;
    self.modalPresentationStyle = UIModalPresentationCustom;
    self.transitioningDelegate = self;
    
    _titleFont = [UIFont boldSystemFontOfSize:18];
    _titleColor = [SPColorStyle lightBlack_DarkWhiteColor];
    _messageFont = [UIFont systemFontOfSize:16];
    _messageColor = [SPColorStyle grayColor];
    _textAlignment = NSTextAlignmentCenter;
    _imageLimitSize = CGSizeMake(CGFLOAT_MAX, CGFLOAT_MAX);
    _cornerRadiusForAlert = 6.0;
    _backgroundViewAppearanceStyle = -1;
    _backgroundViewAlpha = 0.5;
    _tapBackgroundViewDismiss = YES;
    _needDialogBlur = NO;
    _maxNumberOfActionHorizontalArrangementForAlert = 2;
}

- (void)layoutAlertControllerView {
    if (!self.alertControllerView.superview) return;
    if (self.alertControllerViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.alertControllerViewConstraints];
        self.alertControllerViewConstraints = nil;
    }
    if (self.preferredStyle == SPAlertControllerStyleAlert) { // alert样式
        [self layoutAlertControllerViewForAlertStyle];
    } else { // actionSheet样式
        [self layoutAlertControllerViewForActionSheetStyle];
    }
}

- (void)layoutAlertControllerViewForAlertStyle {
    UIView *alertControllerView = self.alertControllerView;
    NSMutableArray *alertControllerViewConstraints = [NSMutableArray array];
    CGFloat topValue = _minDistanceToEdges;
    CGFloat bottomValue = _minDistanceToEdges;
    CGFloat maxWidth = MIN(SP_SCREEN_WIDTH, SP_SCREEN_HEIGHT)-_minDistanceToEdges * 2;
    CGFloat maxHeight = SP_SCREEN_HEIGHT-topValue-bottomValue;
    if (!self.customAlertView) {
        // 当屏幕旋转的时候，为了保持alert样式下的宽高不变，因此取MIN(SP_SCREEN_WIDTH, SP_SCREEN_HEIGHT)
        [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:maxWidth]];
    } else {
        [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:maxWidth]];
        if (_customViewSize.width) { // 如果宽度没有值，则会假定customAlertView水平方向能由子控件撑起
            // 限制最大宽度，且能保证内部约束不报警告
            CGFloat customWidth = MIN(_customViewSize.width, maxWidth);
            [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:customWidth]];
        }
        if (_customViewSize.height) { // 如果高度没有值，则会假定customAlertView垂直方向能由子控件撑起
            CGFloat customHeight = MIN(_customViewSize.height, maxHeight);
            [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:customHeight]];
        }
    }
    NSLayoutConstraint *topConstraint = [NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:alertControllerView.superview attribute:NSLayoutAttributeTop multiplier:1.0f constant:topValue];
    topConstraint.priority = 999.0;// 这里优先级为999.0是为了小于垂直中心的优先级，如果含有文本输入框，键盘弹出后，特别是旋转到横屏后，对话框的空间比较小，这个时候优先偏移垂直中心，顶部优先级按理说应该会被忽略，但是由于子控件含有scrollView，所以该优先级仍然会被激活，子控件显示不全scrollView可以滑动。如果外界自定义了整个对话框，且自定义的view上含有文本输入框，子控件不含有scrollView，顶部间距会被忽略
    [alertControllerViewConstraints addObject:topConstraint];
    NSLayoutConstraint *bottomConstraint = [NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:alertControllerView.superview attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-bottomValue];
    bottomConstraint.priority = 999.0; // 优先级跟顶部同理
    [alertControllerViewConstraints addObject:bottomConstraint];
    [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertControllerView.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant: _offsetForAlert.x]];
    NSLayoutConstraint *alertControllerViewConstraintCenterY = [NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:alertControllerView.superview attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:(self.isBeingPresented && !self.isBeingDismissed) ? 0 : _offsetForAlert.y];
    [alertControllerViewConstraints addObject:alertControllerViewConstraintCenterY];
    [NSLayoutConstraint activateConstraints:alertControllerViewConstraints];
    self.alertControllerViewConstraints = alertControllerViewConstraints;
}

- (void)layoutAlertControllerViewForActionSheetStyle {
    switch (self.animationType) {
        case SPAlertAnimationTypeFromBottom:
        case SPAlertAnimationTypeRaiseUp:
        default:
            [self layoutAlertControllerViewForAnimationTypeWithHV:@"H"
                                                   equalAttribute:NSLayoutAttributeBottom
                                                notEqualAttribute:NSLayoutAttributeTop
                                            lessOrGreaterRelation:NSLayoutRelationGreaterThanOrEqual];
            break;
        case SPAlertAnimationTypeFromTop:
        case SPAlertAnimationTypeDropDown:
            [self layoutAlertControllerViewForAnimationTypeWithHV:@"H"
                                                   equalAttribute:NSLayoutAttributeTop
                                                notEqualAttribute:NSLayoutAttributeBottom
                                            lessOrGreaterRelation:NSLayoutRelationLessThanOrEqual];
            break;
        case SPAlertAnimationTypeFromLeft:
            [self layoutAlertControllerViewForAnimationTypeWithHV:@"V"
                                                   equalAttribute:NSLayoutAttributeLeft
                                                notEqualAttribute:NSLayoutAttributeRight
                                            lessOrGreaterRelation:NSLayoutRelationLessThanOrEqual];
            break;
        case SPAlertAnimationTypeFromRight:
            [self layoutAlertControllerViewForAnimationTypeWithHV:@"V"
                                                   equalAttribute:NSLayoutAttributeRight
                                                notEqualAttribute:NSLayoutAttributeLeft
                                            lessOrGreaterRelation:NSLayoutRelationLessThanOrEqual];
            break;
    }
}

- (void)layoutAlertControllerViewForAnimationTypeWithHV:(NSString *)hv
                                             equalAttribute:(NSLayoutAttribute)equalAttribute
                                      notEqualAttribute:(NSLayoutAttribute)notEqualAttribute
                                               lessOrGreaterRelation:(NSLayoutRelation)relation {
    UIView *alertControllerView = self.alertControllerView;
    NSMutableArray *alertControllerViewConstraints = [NSMutableArray array];
    if (!self.customAlertView) {
        [alertControllerViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"%@:|-0-[alertControllerView]-0-|",hv] options:0 metrics:nil views:NSDictionaryOfVariableBindings(alertControllerView)]];
    } else {
        NSLayoutAttribute centerXorY = [hv isEqualToString:@"H"] ? NSLayoutAttributeCenterX : NSLayoutAttributeCenterY;
        [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:centerXorY relatedBy:NSLayoutRelationEqual toItem:alertControllerView.superview attribute:centerXorY multiplier:1.0 constant:0]];
        if (_customViewSize.width) { // 如果宽度没有值，则会假定customAlertViewh水平方向能由子控件撑起
            CGFloat alertControllerViewWidth = 0.0;
            if ([hv isEqualToString:@"H"]) {
                alertControllerViewWidth = MIN(_customViewSize.width, SP_SCREEN_WIDTH);
            } else {
                alertControllerViewWidth = MIN(_customViewSize.width, SP_SCREEN_WIDTH-_minDistanceToEdges);
            }
            [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:alertControllerViewWidth]];
        }
        if (_customViewSize.height) { // 如果高度没有值，则会假定customAlertViewh垂直方向能由子控件撑起
            CGFloat alertControllerViewHeight = 0.0;
            if ([hv isEqualToString:@"H"]) {
                alertControllerViewHeight = MIN(_customViewSize.height, SP_SCREEN_HEIGHT-_minDistanceToEdges);
            } else {
                alertControllerViewHeight = MIN(_customViewSize.height, SP_SCREEN_HEIGHT);
            }
            [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:alertControllerViewHeight]];
        }
    }
    [alertControllerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertControllerView attribute:equalAttribute relatedBy:NSLayoutRelationEqual toItem:alertControllerView.superview attribute:equalAttribute multiplier:1.0 constant:0]];
    NSLayoutConstraint *someSideConstraint = [NSLayoutConstraint constraintWithItem:alertControllerView attribute:notEqualAttribute relatedBy:relation toItem:alertControllerView.superview attribute:notEqualAttribute multiplier:1.0 constant:_minDistanceToEdges];
    someSideConstraint.priority = 999.0;
    [alertControllerViewConstraints addObject:someSideConstraint];
    [NSLayoutConstraint activateConstraints:alertControllerViewConstraints];
    self.alertControllerViewConstraints = alertControllerViewConstraints;
}

- (void)layoutChildViews {
    // 对头部布局
    [self layoutHeaderView];
    
    // 对头部和action部分之间的分割线布局
    [self layoutHeaderActionLine];
    
    // 对组件view布局
    [self layoutComponentView];

    // 对组件view与action部分之间的分割线布局
    [self layoutComponentActionLine];
    
    // 对action部分布局
    [self layoutActionSequenceView];
}

// 对头部布局，高度由子控件撑起
- (void)layoutHeaderView {
    UIView *headerView = self.customHeaderView ? self.customHeaderView : self.headerView;
    if (!headerView.superview) return;
    UIView *alertView = self.alertView;
    NSMutableArray *headerViewConstraints = [NSMutableArray array];
    if (self.headerViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.headerViewConstraints];
        self.headerViewConstraints = nil;
    }
    if (!self.customHeaderView) {
        [headerViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerView)]];
    } else {
        if (_customViewSize.width) {
            CGFloat maxWidth = [self maxWidth];
            CGFloat headerViewWidth = MIN(maxWidth, _customViewSize.width);
            [headerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:headerViewWidth]];
        }
        if (_customViewSize.height) {
            NSLayoutConstraint *customHeightConstraint = [NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customViewSize.height];
            customHeightConstraint.priority = UILayoutPriorityDefaultHigh;
            [headerViewConstraints addObject:customHeightConstraint];
        }
        [headerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    }
    [headerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    if (!self.headerActionLine.superview) {
        [headerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    }
    [NSLayoutConstraint activateConstraints:headerViewConstraints];
    self.headerViewConstraints = headerViewConstraints;
}

// 对头部和action部分之间的分割线布局
- (void)layoutHeaderActionLine {
    if (!self.headerActionLine.superview) return;
    UIView *headerActionLine = self.headerActionLine;
    UIView *headerView = self.customHeaderView ? self.customHeaderView : self.headerView;
    UIView *actionSequenceView = self.customActionSequenceView ? self.customActionSequenceView : self.actionSequenceView;
    NSMutableArray *headerActionLineConstraints = [NSMutableArray array];
    if (self.headerActionLineConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.headerActionLineConstraints];
        self.headerActionLineConstraints = nil;
    }
    [headerActionLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerActionLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerActionLine)]];
    [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    if (!self.componentView.superview) {
        [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:actionSequenceView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    }
    [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SP_LINE_WIDTH]];

    [NSLayoutConstraint activateConstraints:headerActionLineConstraints];
    self.headerActionLineConstraints = headerActionLineConstraints;
}

// 对组件view布局
- (void)layoutComponentView {
    if (!self.componentView.superview) return;
    UIView *componentView = self.componentView;
    UIView *headerActionLine = self.headerActionLine;
    UIView *componentActionLine = self.componentActionLine;
    NSMutableArray *componentViewConstraints = [NSMutableArray array];
    if (self.componentViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.componentViewConstraints];
        self.componentViewConstraints = nil;
    }
    [componentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:componentView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerActionLine attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [componentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:componentView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:componentActionLine attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [componentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:componentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.alertView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    if (_customViewSize.height) {
        NSLayoutConstraint *heightConstraint = [NSLayoutConstraint constraintWithItem:componentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customViewSize.height];
        heightConstraint.priority = UILayoutPriorityDefaultHigh; // 750
        [componentViewConstraints addObject:heightConstraint];
    }
    if (_customViewSize.width) {
        CGFloat maxWidth = [self maxWidth];
        CGFloat componentViewWidth = MIN(maxWidth, _customViewSize.width);
        [componentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:componentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:componentViewWidth]];
    }
    [NSLayoutConstraint activateConstraints:componentViewConstraints];
    self.componentViewConstraints = componentViewConstraints;
}

// 对组件view和action部分之间的分割线布局
- (void)layoutComponentActionLine {
    if (!self.componentActionLine.superview) return;
    UIView *componentActionLine = self.componentActionLine;
    NSMutableArray *componentActionLineConstraints = [NSMutableArray array];
    if (self.componentActionLineConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.componentActionLineConstraints];
        self.componentActionLineConstraints = nil;
    }
    [componentActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:componentActionLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.actionSequenceView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [componentActionLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[componentActionLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(componentActionLine)]];
    [componentActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:componentActionLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:SP_LINE_WIDTH]];
    [NSLayoutConstraint activateConstraints:componentActionLineConstraints];
    self.componentActionLineConstraints = componentActionLineConstraints;
}

// 对action部分布局，高度由子控件撑起
- (void)layoutActionSequenceView {
    UIView *actionSequenceView = self.customActionSequenceView ? self.customActionSequenceView : self.actionSequenceView;
    if (!actionSequenceView.superview) return;
    UIView *alertView = self.alertView;
    UIView *headerActionLine = self.headerActionLine;

    NSMutableArray *actionSequenceViewConstraints = [NSMutableArray array];
    if (self.actionSequenceViewConstraints) {
        [NSLayoutConstraint deactivateConstraints:self.actionSequenceViewConstraints];
        self.actionSequenceViewConstraints = nil;
    }
    if (!self.customActionSequenceView) {
        [actionSequenceViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionSequenceView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionSequenceView)]];
    } else {

        if (_customViewSize.width) {
            CGFloat maxWidth = [self maxWidth];
            if (_customViewSize.width > maxWidth) _customViewSize.width = maxWidth;
            [actionSequenceViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionSequenceView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customViewSize.width]];
        }
        if (_customViewSize.height) {
            NSLayoutConstraint *customHeightConstraint = [NSLayoutConstraint constraintWithItem:actionSequenceView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customViewSize.height];
            customHeightConstraint.priority = UILayoutPriorityDefaultHigh;
            [actionSequenceViewConstraints addObject:customHeightConstraint];
        }
        [actionSequenceViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionSequenceView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    }
    if (!headerActionLine) {
        [actionSequenceViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionSequenceView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    }
    [actionSequenceViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionSequenceView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];

    [NSLayoutConstraint activateConstraints:actionSequenceViewConstraints];
    self.actionSequenceViewConstraints = actionSequenceViewConstraints;
}

- (CGFloat)maxWidth {
    if (self.preferredStyle == SPAlertControllerStyleAlert) {
        return MIN(SP_SCREEN_WIDTH, SP_SCREEN_HEIGHT)-_minDistanceToEdges * 2;
    } else {
        return SP_SCREEN_WIDTH;
    }
}

// 文字显示不全处理
- (void)handleIncompleteTextDisplay {
    // alert样式下水平排列时如果文字显示不全则垂直排列
    if (!self.isForceLayout) { // 外界没有设置排列方式
        if (self.preferredStyle == SPAlertControllerStyleAlert) {
            for (SPAlertAction *action in self.actions) {
                // 预估按钮宽度
                CGFloat preButtonWidth = (MIN(SP_SCREEN_WIDTH, SP_SCREEN_HEIGHT) - _minDistanceToEdges * 2 - SP_LINE_WIDTH * (self.actions.count - 1)) / self.actions.count - action.titleEdgeInsets.left - action.titleEdgeInsets.right;
                // 如果action的标题文字总宽度，大于按钮的contentRect的宽度，则说明水平排列会导致文字显示不全，此时垂直排列
                if (action.attributedTitle) {
                    if (ceil([action.attributedTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, SP_ACTION_HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size.width) > preButtonWidth) {
                        _actionAxis = UILayoutConstraintAxisVertical;
                        [self updateActionAxis];
                        [self.actionSequenceView setNeedsUpdateConstraints];
                        break; // 一定要break，只要有一个按钮文字过长就垂直排列
                    }
                } else {
                    if (ceil([action.title boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, SP_ACTION_HEIGHT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:action.titleFont} context:nil].size.width) > preButtonWidth) {
                        _actionAxis = UILayoutConstraintAxisVertical;
                        [self updateActionAxis];
                        [self.actionSequenceView setNeedsUpdateConstraints];
                        break;
                    }
                }
            }
        }
    }
}

// 专门处理第三方IQKeyboardManager,非自定义view时禁用IQKeyboardManager移动textView/textField效果，自定义view时取消禁用
- (void)handleIQKeyboardManager {
    SEL selector = NSSelectorFromString(@"sharedManager");
    IMP imp = [NSClassFromString(@"IQKeyboardManager") methodForSelector:selector];
    if (imp != NULL) {
        NSObject *(*func)(id, SEL) = (void *)imp;
        NSObject *mgr = func(NSClassFromString(@"IQKeyboardManager"), selector);
        if ([mgr isKindOfClass:NSClassFromString(@"IQKeyboardManager")]) {
            @try {
                NSMutableSet *disabledDistanceHandlingClasses = [mgr valueForKey:@"_disabledDistanceHandlingClasses"];
                NSMutableSet *disabledToolbarClasses = [mgr valueForKey:@"_disabledToolbarClasses"];
                if (![disabledDistanceHandlingClasses containsObject:NSClassFromString(@"SPAlertController")]) {
                    [disabledDistanceHandlingClasses addObject:NSClassFromString(@"SPAlertController")];
                    [disabledToolbarClasses addObject:NSClassFromString(@"SPAlertController")];
                }
            } @catch (NSException *exception) {
                NSLog(@"exception = %@",exception);
            } @finally {
                
            }
        }
    }
}

- (void)configureHeaderView {
    if (self.image) {
        self.headerView.imageLimitSize = _imageLimitSize;
        self.headerView.imageView.image = _image;
        self.headerView.imageView.tintColor = _imageTintColor;
        [self.headerView setNeedsUpdateConstraints];
    }
    if(self.attributedTitle.length) {
        self.headerView.titleLabel.attributedText = self.attributedTitle;
        [self setupPreferredMaxLayoutWidthForLabel:self.headerView.titleLabel];
    } else if(self.title.length) {
        self.headerView.titleLabel.text = _title;
        self.headerView.titleLabel.font = _titleFont;
        self.headerView.titleLabel.textColor = _titleColor;
        self.headerView.titleLabel.textAlignment = _textAlignment;
        [self setupPreferredMaxLayoutWidthForLabel:self.headerView.titleLabel];
    }
    if (self.attributedMessage.length) {
        self.headerView.messageLabel.attributedText = self.attributedMessage;
        [self setupPreferredMaxLayoutWidthForLabel:self.headerView.messageLabel];
    } else if (self.message.length) {
        self.headerView.messageLabel.text = _message;
        self.headerView.messageLabel.font = _messageFont;
        self.headerView.messageLabel.textColor = _messageColor;
        self.headerView.messageLabel.textAlignment = _textAlignment;
        [self setupPreferredMaxLayoutWidthForLabel:self.headerView.messageLabel];
    }
}

- (void)setupPreferredMaxLayoutWidthForLabel:(UILabel *)textLabel {
    if (self.preferredStyle == SPAlertControllerStyleAlert) {
        textLabel.preferredMaxLayoutWidth = MIN(SP_SCREEN_WIDTH, SP_SCREEN_HEIGHT) - self.minDistanceToEdges * 2 - self.headerView.contentEdgeInsets.left - self.headerView.contentEdgeInsets.right;
    } else {
        textLabel.preferredMaxLayoutWidth  = SP_SCREEN_WIDTH - self.headerView.contentEdgeInsets.left - self.headerView.contentEdgeInsets.right;
    }
}

// 这个方法是实现点击回车切换到下一个textField，如果没有下一个，会自动退出键盘. 不能在代理方法里实现，因为如果设置了代理，外界就不能成为textFiled的代理了，通知也监听不到回车
- (void)textFieldDidEndOnExit:(UITextField *)textField {
    NSInteger index = [self.textFields indexOfObject:textField];
    if (self.textFields.count > index + 1) {
        UITextField *nextTextField = [self.textFields objectAtIndex:index + 1];
        [textField resignFirstResponder];
        [nextTextField becomeFirstResponder];
    }
}

// 更新action的排列方式
- (void)updateActionAxis {
    self.actionSequenceView.axis = _actionAxis;
    if (_actionAxis == UILayoutConstraintAxisVertical) {
        self.actionSequenceView.stackViewDistribution = UIStackViewDistributionFillProportionally;// 布局方式为子控件自适应内容高度
    } else {
        self.actionSequenceView.stackViewDistribution = UIStackViewDistributionFillEqually; // 布局方式为子控件等宽
    }
}

// 该方法是保证被废弃的maxNumberOfActionHorizontalArrangementForAlert属性的有效性
- (void)setupActionAxis {
    if (self.preferredStyle == SPAlertControllerStyleAlert) {
        if (self.actions.count > self.maxNumberOfActionHorizontalArrangementForAlert) {
            _actionAxis = UILayoutConstraintAxisVertical;
            [self updateActionAxis];
        } else {
            _actionAxis = UILayoutConstraintAxisHorizontal;
            [self updateActionAxis];
        }
    }
}

- (void)makeViewOffsetWithAnimated:(BOOL)animated {
    if (!self.beingPresented && !self.beingDismissed) {
        [self layoutAlertControllerView];
        if (animated) {
            [UIView animateWithDuration:0.25 animations:^{
                [self.view.superview layoutIfNeeded];
            }];
        }
    }
}

// 获取自定义view的大小
- (CGSize)sizeForCustomView:(UIView *)customView {
    [customView layoutIfNeeded];
    CGSize settingSize = customView.frame.size;
    CGSize fittingSize = [customView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    return CGSizeMake(MAX(settingSize.width, fittingSize.width), MAX(settingSize.height, fittingSize.height));
}

#pragma mark - system methods

- (void)loadView {
    // 重新创建self.view，这样可以采用自己的一套布局，轻松改变控制器view的大小
    self.view = self.alertControllerView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self configureHeaderView];
    
    self.needDialogBlur = _needDialogBlur;
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self handleIQKeyboardManager];
    
    if (!_isForceOffset && !_customAlertView && !_customHeaderView && !_customActionSequenceView && !_componentView) {
        // 监听键盘改变frame，键盘frame改变需要移动对话框
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardFrameWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    }
    if (self.textFields.count) {
        UITextField *firstTextfield = [self.textFields firstObject];
        if (!firstTextfield.isFirstResponder) {
            [firstTextfield becomeFirstResponder];
        }
    }
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // 屏幕旋转后宽高发生了交换，头部的label最大宽度需要重新计算
    [self setupPreferredMaxLayoutWidthForLabel:self.headerView.titleLabel];
    [self setupPreferredMaxLayoutWidthForLabel:self.headerView.messageLabel];
    // 对自己创建的alertControllerView布局，在这个方法里，self.view才有父视图，有父视图才能改变其约束
    [self layoutAlertControllerView];
    [self layoutChildViews];
    
    if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
        [self setCornerRadius:_cornerRadius];
    }
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    [self handleIncompleteTextDisplay];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - 键盘通知

- (void)keyboardFrameWillChange:(NSNotification *)notification {
    if (!_isForceOffset && (_offsetForAlert.y == 0.0 || _textFields.lastObject.isFirstResponder)) {
        CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardEndY = keyboardEndFrame.origin.y;
        CGFloat diff = fabs((SP_SCREEN_HEIGHT - keyboardEndY) * 0.5);
        _offsetForAlert.y = -diff;
        [self makeViewOffsetWithAnimated:YES];
    }
}

#pragma mark - setterx

- (void)setTitle:(NSString *)title {
    _title = title;
    if (self.isViewLoaded) { // 如果条件为真，说明外界在对title赋值之前就已经使用了self.view，先走了viewDidLoad方法，如果先走的viewDidLoad，需要在title的setter方法中重新设置数据,以下setter方法中的条件同理
        self.headerView.titleLabel.text = title;
        // 文字发生变化后再更新布局，这里更新布局也不是那么重要，因为headerView中的布局方法只有当SPAlertController被present后才会走一次，而那时候，一般title,titleFont、message、messageFont等都是最新值，这里防止的是：在SPAlertController被present后的某个时刻再去设置title,titleFont等，我们要更新布局
        if (self.presentationController.presentingViewController) { // 这个if条件的意思是当SPAlertController被present后的某个时刻设置了title，如果在present之前设置的就不用更新，系统会主动更新
            [self.headerView setNeedsUpdateConstraints];
        }
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    if (self.isViewLoaded) {
        self.headerView.titleLabel.font = titleFont;
        if (self.presentationController.presentingViewController) {
            [self.headerView setNeedsUpdateConstraints];
        }
    }
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (self.isViewLoaded) {
        self.headerView.titleLabel.textColor = titleColor;
    }
}

- (void)setMessage:(NSString *)message {
    _message = message;
    if (self.isViewLoaded) {
        self.headerView.messageLabel.text = message;
        if (self.presentationController.presentingViewController) {
            [self.headerView setNeedsUpdateConstraints];
        }
    }
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    if (self.isViewLoaded) {
        self.headerView.messageLabel.font = messageFont;
        if (self.presentationController.presentingViewController) {
            [self.headerView setNeedsUpdateConstraints];
        }
    }
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    if (self.isViewLoaded) {
        self.headerView.messageLabel.textColor = messageColor;
    }
}

- (void)setTextAlignment:(NSTextAlignment)textAlignment {
    _textAlignment = textAlignment;
    self.headerView.titleLabel.textAlignment = _textAlignment;
    self.headerView.messageLabel.textAlignment = _textAlignment;
}

- (void)setIcon:(UIImage *)image {
    _image = image;
    if (self.isViewLoaded) {
        self.headerView.imageView.image = _image;
        if (self.presentationController.presentingViewController) {
            [self.headerView setNeedsUpdateConstraints];
        }
    }
}

- (void)setIconLimitSize:(CGSize)imageLimitSize {
    _imageLimitSize = imageLimitSize;
    if (self.isViewLoaded) {
        self.headerView.imageLimitSize = _imageLimitSize;
        if (self.presentationController.presentingViewController) {
            [self.headerView setNeedsUpdateConstraints];
        }
    }
}

- (void)setImageTintColor:(UIColor *)imageTintColor {
    _imageTintColor = imageTintColor;
    if (self.isViewLoaded) {
        self.headerView.imageView.tintColor = imageTintColor;
    }
}

- (void)setAttributedTitle:(NSAttributedString *)attributedTitle {
    _attributedTitle = attributedTitle;
    if (self.isViewLoaded) {
        self.headerView.titleLabel.attributedText = _attributedTitle;
        if (self.presentationController.presentingViewController) {
            [self.headerView setNeedsUpdateConstraints];
        }
    }
}

- (void)setAttributedMessage:(NSAttributedString *)attributedMessage {
    _attributedMessage = attributedMessage;
    if (self.isViewLoaded) {
        self.headerView.messageLabel.attributedText = _attributedMessage;
        if (self.presentationController.presentingViewController) {
            [self.headerView setNeedsUpdateConstraints];
        }
    }
}

// 该属性3.0版本开始被废弃
- (void)setMaxMarginForAlert:(CGFloat)maxMarginForAlert {
    _maxMarginForAlert = maxMarginForAlert;
    self.minDistanceToEdges = _maxMarginForAlert;
}

// 该属性3.0版本开始被废弃
- (void)setMaxTopMarginForActionSheet:(CGFloat)maxTopMarginForActionSheet {
    _maxTopMarginForActionSheet = maxTopMarginForActionSheet;
    self.minDistanceToEdges = _maxTopMarginForActionSheet;
}

- (void)setMinDistanceToEdges:(CGFloat)minDistanceToEdges {
    _minDistanceToEdges = minDistanceToEdges;
    if (self.isViewLoaded) {
        [self setupPreferredMaxLayoutWidthForLabel:self.headerView.titleLabel];
        [self setupPreferredMaxLayoutWidthForLabel:self.headerView.messageLabel];
        if (self.presentationController.presentingViewController) {
            [self layoutAlertControllerView];
            [self.headerView setNeedsUpdateConstraints];
            [self.actionSequenceView setNeedsUpdateConstraints];
        }
    }
}

- (void)setCornerRadius:(CGFloat)cornerRadius {
    _cornerRadius = cornerRadius;
    if (self.preferredStyle == SPAlertControllerStyleAlert) {
        self.containerView.layer.cornerRadius = _cornerRadius;
        self.containerView.layer.masksToBounds = YES;
    } else {
        if (_cornerRadius > 0.0) {
            UIRectCorner corner = UIRectCornerTopLeft | UIRectCornerTopRight;
            switch (_animationType) {
                case SPAlertAnimationTypeFromBottom:
                    corner = UIRectCornerTopLeft | UIRectCornerTopRight;
                    break;
                case SPAlertAnimationTypeFromTop:
                    corner = UIRectCornerBottomLeft | UIRectCornerBottomRight;
                    break;
                case SPAlertAnimationTypeFromLeft:
                    corner = UIRectCornerTopRight | UIRectCornerBottomRight;
                    break;
                case SPAlertAnimationTypeFromRight:
                    corner = UIRectCornerTopLeft | UIRectCornerBottomLeft;
                    break;
                default:
                    break;
            }
            CAShapeLayer *maskLayer = (CAShapeLayer *)_containerView.layer.mask;
            maskLayer.path = [UIBezierPath bezierPathWithRoundedRect:_containerView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(_cornerRadius, _cornerRadius)].CGPath;
            maskLayer.frame = _containerView.bounds;
        } else {
            _containerView.layer.mask = nil;
        }
    }
}

- (void)setCornerRadiusForAlert:(CGFloat)cornerRadiusForAlert {
    _cornerRadiusForAlert = cornerRadiusForAlert;
    _cornerRadius = cornerRadiusForAlert;
    if (self.preferredStyle == SPAlertControllerStyleAlert) {
        self.containerView.layer.cornerRadius = _cornerRadiusForAlert;
        self.containerView.layer.masksToBounds = YES;
    }
}

// 此属性3.0版本开始被废弃
- (void)setMaxNumberOfActionHorizontalArrangementForAlert:(NSInteger)maxNumberOfActionHorizontalArrangementForAlert {
    _maxNumberOfActionHorizontalArrangementForAlert = maxNumberOfActionHorizontalArrangementForAlert;
    // 被废弃的maxNumberOfActionHorizontalArrangementForAlert属性需要的方法
    [self setupActionAxis];
}

- (void)setActionAxis:(UILayoutConstraintAxis)actionAxis {
    _actionAxis = actionAxis;
    // 调用该setter方法则认为是强制布局，该setter方法只有外界能调，这样才能判断外界有没有调用actionAxis的setter方法，从而是否按照外界的指定布局方式进行布局
    _isForceLayout = YES;

    [self updateActionAxis];
}

- (void)setOffsetForAlert:(CGPoint)offsetForAlert {
    _offsetForAlert = offsetForAlert;
    _isForceOffset = YES;
    [self makeViewOffsetWithAnimated:NO];
}

// 被废弃
- (void)setOffsetYForAlert:(CGFloat)offsetYForAlert {
    _offsetYForAlert = offsetYForAlert;
    _offsetForAlert.y = _offsetYForAlert;
    _isForceOffset = YES;
}

- (void)setNeedDialogBlur:(BOOL)needDialogBlur {
    _needDialogBlur = needDialogBlur;
    if (_needDialogBlur) {
        self.containerView.backgroundColor = [UIColor clearColor];
        if (!self.dimmingKnockoutBackdropView) {
            self.dimmingKnockoutBackdropView = [NSClassFromString(@"_UIDimmingKnockoutBackdropView") alloc];
            if (self.dimmingKnockoutBackdropView) {
                // 下面4行相当于self.dimmingKnockoutBackdropView = [self.dimmingKnockoutBackdropView performSelector:NSSelectorFromString(@"initWithStyle:") withObject:@(UIBlurEffectStyleLight)];
                SEL selector = NSSelectorFromString(@"initWithStyle:");
                IMP imp = [self.dimmingKnockoutBackdropView methodForSelector:selector];
                if (imp != NULL) {
                    UIView *(*func)(id, SEL,UIBlurEffectStyle) = (void *)imp;
                    self.dimmingKnockoutBackdropView = func(self.dimmingKnockoutBackdropView, selector, UIBlurEffectStyleLight);
                    self.dimmingKnockoutBackdropView.frame = self.containerView.bounds;
                    self.dimmingKnockoutBackdropView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [self.containerView insertSubview:self.dimmingKnockoutBackdropView atIndex:0];
                }
            } else { // 这个else是防止假如_UIDimmingKnockoutBackdropView这个类不存在了的时候，做一个备案
                UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
                self.dimmingKnockoutBackdropView = [[UIVisualEffectView alloc] initWithEffect:blur];
                self.dimmingKnockoutBackdropView.frame = self.containerView.bounds;
                self.dimmingKnockoutBackdropView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
                [self.containerView insertSubview:self.dimmingKnockoutBackdropView atIndex:0];
            }
        }
    } else {
        [self.dimmingKnockoutBackdropView removeFromSuperview];
        self.dimmingKnockoutBackdropView = nil;
        if (_customAlertView) {
            self.containerView.backgroundColor = [UIColor clearColor];
        } else {
            self.containerView.backgroundColor = [SPColorStyle lightWhite_DarkBlackColor];
        }
    }
}

#pragma mark - lazy load

- (UIView *)alertControllerView {
    if (!_alertControllerView) {
        UIView *alertControllerView = [[UIView alloc] init];
        alertControllerView.translatesAutoresizingMaskIntoConstraints = NO;
        _alertControllerView = alertControllerView;
    }
    return _alertControllerView;
}

- (UIView *)containerView {
    if (!_containerView) {
        UIView *containerView = [[UIView alloc] init];
        containerView.frame = self.alertControllerView.bounds;
        containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (_preferredStyle == SPAlertControllerStyleAlert) {
            containerView.layer.cornerRadius = _cornerRadius;
            containerView.layer.masksToBounds = YES;
        } else {
            if (_cornerRadius > 0.0) {
                CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
                containerView.layer.mask = maskLayer;
            }
        }
        [self.alertControllerView addSubview:containerView];
        
        _containerView = containerView;
    }
    return _containerView;
}

- (UIView *)alertView {
    if (!_alertView) {
        UIView *alertView = [[UIView alloc] init];
        alertView.frame = self.alertControllerView.bounds;
        alertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (!self.customAlertView) {
            [self.containerView addSubview:alertView];
        }
        _alertView = alertView;
    }
    return _alertView;
}

- (UIView *)customAlertView {
    // customAlertView有值但是没有父view
    if (_customAlertView && !_customAlertView.superview) {
        if (CGSizeEqualToSize(_customViewSize, CGSizeZero)) {
            // 获取_customAlertView的大小
            _customViewSize = [self sizeForCustomView:_customAlertView];
        }
        // 必须在在下面2行代码之前获取_customViewSize
        _customAlertView.frame = self.alertControllerView.bounds;
        _customAlertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.containerView addSubview:_customAlertView];
    }
    return _customAlertView;
}

- (SPInterfaceHeaderScrollView *)headerView {
    if (!_headerView) {
        SPInterfaceHeaderScrollView *headerView = [[SPInterfaceHeaderScrollView alloc] init];
        headerView.backgroundColor = [SPColorStyle normalColor];
        headerView.translatesAutoresizingMaskIntoConstraints = NO;
        __weak typeof(self) weakSelf = self;
        headerView.headerViewSfeAreaDidChangBlock = ^{
            [weakSelf setupPreferredMaxLayoutWidthForLabel:weakSelf.headerView.titleLabel];
            [weakSelf setupPreferredMaxLayoutWidthForLabel:weakSelf.headerView.messageLabel];
        };
        if (!self.customHeaderView) {
            if ((self.title.length || self.attributedTitle.length || self.message.length || self.attributedMessage.length || self.textFields.count || self.image)) {
                [self.alertView addSubview:headerView];
            }
        }
        _headerView = headerView;
    }
    return _headerView;
}

- (UIView *)customHeaderView {
    // _customHeaderView有值但是没有父view
    if (_customHeaderView && !_customHeaderView.superview) {
        // 获取_customHeaderView的大小
        if (CGSizeEqualToSize(_customViewSize, CGSizeZero)) {
            // 获取_customHeaderView的大小
            _customViewSize = [self sizeForCustomView:_customHeaderView];
        }
        _customHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.alertView addSubview:_customHeaderView];
    }
    return _customHeaderView;
}

- (SPInterfaceActionSequenceView *)actionSequenceView {
    if (!_actionSequenceView) {
        SPInterfaceActionSequenceView *actionSequenceView = [[SPInterfaceActionSequenceView alloc] init];
        actionSequenceView.translatesAutoresizingMaskIntoConstraints = NO;
        __weak typeof(self) weakSelf = self;
        actionSequenceView.buttonClickedInActionViewBlock = ^(NSInteger index) {
            [weakSelf dismissViewControllerAnimated:YES completion:nil];
            SPAlertAction *action = weakSelf.actions[index];
            if (action.handler) {
                action.handler(action);
            }
        };
        if (self.actions.count && !self.customActionSequenceView) {
            [self.alertView addSubview:actionSequenceView];
        }
        _actionSequenceView = actionSequenceView;
    }
    return _actionSequenceView;
}

- (UIView *)customActionSequenceView {
    // _customActionSequenceView有值但是没有父view
    if (_customActionSequenceView && !_customActionSequenceView.superview) {
        // 获取_customHeaderView的大小
        if (CGSizeEqualToSize(_customViewSize, CGSizeZero)) {
            // 获取_customActionSequenceView的大小
            _customViewSize = [self sizeForCustomView:_customActionSequenceView];
        }
        _customActionSequenceView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.alertView addSubview:_customActionSequenceView];
    }
    return _customActionSequenceView;
}

- (SPInterfaceActionItemSeparatorView *)headerActionLine {
    if (!_headerActionLine) {
        SPInterfaceActionItemSeparatorView *headerActionLine = [[SPInterfaceActionItemSeparatorView alloc] init];
        headerActionLine.translatesAutoresizingMaskIntoConstraints = NO;
        if ((self.headerView.superview || self.customHeaderView.superview) && (self.actionSequenceView.superview || self.customActionSequenceView.superview)) {
            [self.alertView addSubview:headerActionLine];
        }
        _headerActionLine = headerActionLine;
    }
    return _headerActionLine;
}

- (UIView *)componentView {
    if (_componentView && !_componentView.superview) {
        NSAssert(self.headerActionLine.superview, @"Due to the -componentView is added between the -head and the -action section, the -head and -action must exist together");
        // 获取_componentView的大小
        if (CGSizeEqualToSize(_customViewSize, CGSizeZero)) {
            // 获取_componentView的大小
            _customViewSize = [self sizeForCustomView:_componentView];
        }
        _componentView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.alertView addSubview:_componentView];
    }
    return _componentView;
}

- (SPInterfaceActionItemSeparatorView *)componentActionLine {
    if (!_componentActionLine) {
        SPInterfaceActionItemSeparatorView *componentActionLine = [[SPInterfaceActionItemSeparatorView alloc] init];
        componentActionLine.translatesAutoresizingMaskIntoConstraints = NO;
        // 必须组件view和action部分同时存在
        if (self.componentView.superview && (self.actionSequenceView.superview || self.customActionSequenceView.superview)) {
            [self.alertView addSubview:componentActionLine];
        }
        _componentActionLine = componentActionLine;
    }
    return _componentActionLine;
}

- (NSArray<SPAlertAction *> *)actions {
    if (!_actions) {
        _actions = [NSArray array];
    }
    return _actions;
}

- (NSArray<UITextField *> *)textFields {
    if (!_textFields) {
        _textFields = [NSArray array];
    }
    return _textFields;
}

- (NSMutableArray *)otherActions {
    if (!_otherActions) {
        _otherActions = [[NSMutableArray alloc] init];
    }
    return _otherActions;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [SPAlertAnimation animationIsPresenting:YES];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    [self.view endEditing:YES];
    return [SPAlertAnimation animationIsPresenting:NO];
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0) {
    return [[SPAlertPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

#pragma mark - 被废弃的方法

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(UIView *)customView {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:nil message:nil customAlertView:customView customHeaderView:nil customActionSequenceView:nil componentView:nil preferredStyle:preferredStyle animationType:animationType];
    return alertVc;
}
+ (instancetype)alertControllerWithPreferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customHeaderView:(nullable UIView *)customHeaderView {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:nil message:nil customAlertView:nil customHeaderView:customHeaderView customActionSequenceView:nil componentView:nil preferredStyle:preferredStyle animationType:animationType];
    return alertVc;
}
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customCenterView:(UIView *)customCenterView {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:title message:message customAlertView:nil customHeaderView:nil customActionSequenceView:nil componentView:customCenterView preferredStyle:preferredStyle animationType:animationType];
    return alertVc;
}
+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customFooterView:(UIView *)customFooterView {
    SPAlertController *alertVc = [[SPAlertController alloc] initWithTitle:title message:message customAlertView:nil customHeaderView:nil customActionSequenceView:customFooterView componentView:nil preferredStyle:preferredStyle animationType:animationType];
    return alertVc;
}

@end

#pragma mark ---------------------------- SPAlertController end --------------------------------

@interface SPOverlayView: UIView
@property (nonatomic, strong) UIView *presentedView;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@end

@implementation SPOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}
- (void)setAppearanceStyle:(UIBlurEffectStyle)appearanceStyle alpha:(CGFloat)alpha {
    switch (appearanceStyle) {
        case -1: {
            [self.effectView removeFromSuperview];
            self.effectView = nil;
            if (alpha < 0) {
                alpha = 0.5;
            }
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
            self.alpha = 0;
        }
            break;
        default:{
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:appearanceStyle];
            [self createVisualEffectViewWithBlur:blur alpha:alpha];
        }
    }
}

- (void)createVisualEffectViewWithBlur:(UIBlurEffect *)blur alpha:(CGFloat)alpha {
    self.backgroundColor = [UIColor clearColor];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = self.bounds;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    effectView.userInteractionEnabled = NO;
    effectView.alpha = alpha;
    [self addSubview:effectView];
    _effectView = effectView;
}

@end

#pragma mark ---------------------------- SPAlertPresentationController begin --------------------------------

@interface SPAlertPresentationController()
@property (nonatomic, strong) SPOverlayView *overlayView;
@end

@implementation SPAlertPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
    }
    return self;
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    self.overlayView.frame = self.containerView.bounds;
}

- (void)containerViewDidLayoutSubviews {
    [super containerViewDidLayoutSubviews];

}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];

    SPAlertController *alertController = (SPAlertController *)self.presentedViewController;

    [self.overlayView setAppearanceStyle:alertController.backgroundViewAppearanceStyle alpha:alertController.backgroundViewAlpha];
    
    // 遮罩的alpha值从0～1变化，UIViewControllerTransitionCoordinator协是一个过渡协调器，当执行模态过渡或push过渡时，可以对视图中的其他部分做动画
    id <UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.overlayView.alpha = 1.0;
        } completion:nil];
    } else {
        self.overlayView.alpha = 1.0;
    }
    if ([alertController.delegate respondsToSelector:@selector(willPresentAlertController:)]) {
        [alertController.delegate willPresentAlertController:alertController];
    }  else if ([alertController.delegate respondsToSelector:@selector(sp_alertControllerWillShow:)]) { // 支持老版本
        [alertController.delegate sp_alertControllerWillShow:alertController];
    }
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    [super presentationTransitionDidEnd:completed];
    
    SPAlertController *alertController = (SPAlertController *)self.presentedViewController;
    if ([alertController.delegate respondsToSelector:@selector(didPresentAlertController:)]) {
        [alertController.delegate didPresentAlertController:alertController];
    } else if ([alertController.delegate respondsToSelector:@selector(sp_alertControllerDidShow:)]) { // 支持老版本
        [alertController.delegate sp_alertControllerDidShow:alertController];
    }
}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
    // 遮罩的alpha值从1～0变化，UIViewControllerTransitionCoordinator协议执行动画可以保证和转场动画同步
    id <UIViewControllerTransitionCoordinator> coordinator = [self.presentedViewController transitionCoordinator];
    if (coordinator) {
        [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext> context) {
            self.overlayView.alpha = 0.0;
        } completion:nil];
    } else {
        self.overlayView.alpha = 0.0;
    }
    SPAlertController *alertController = (SPAlertController *)self.presentedViewController;
    if ([alertController.delegate respondsToSelector:@selector(willDismissAlertController:)]) {
        [alertController.delegate willDismissAlertController:alertController];
    } else if ([alertController.delegate respondsToSelector:@selector(sp_alertControllerWillHide:)]) { // 支持老版本
        [alertController.delegate sp_alertControllerWillHide:alertController];
    }
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [super dismissalTransitionDidEnd:completed];
    if (completed) {
        [_overlayView removeFromSuperview];
        _overlayView = nil;
    }
    SPAlertController *alertController = (SPAlertController *)self.presentedViewController;
    if ([alertController.delegate respondsToSelector:@selector(didDismissAlertController:)]) {
        [alertController.delegate didDismissAlertController:alertController];
    } else if ([alertController.delegate respondsToSelector:@selector(sp_alertControllerDidHide:)]) { // 支持老版本
        [alertController.delegate sp_alertControllerDidHide:alertController];
    }
}

- (CGRect)frameOfPresentedViewInContainerView{
    return self.presentedView.frame;
}

- (void)tapOverlayView {
    SPAlertController *alertController = (SPAlertController *)self.presentedViewController;
    if (alertController.tapBackgroundViewDismiss) {
        [alertController dismissViewControllerAnimated:YES completion:^{}];
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (SPOverlayView *)overlayView {
    if (!_overlayView) {
        _overlayView = [[SPOverlayView alloc] init];
        _overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOverlayView)];
        [_overlayView addGestureRecognizer:tap];
        [self.containerView addSubview:_overlayView];
    }
    return _overlayView;
}

@end

#pragma mark ---------------------------- SPAlertPresentationController end --------------------------------


#pragma mark ---------------------------- SPAlertAnimation begin --------------------------------

@interface SPAlertAnimation()
@property (nonatomic, assign) BOOL presenting;
@end

@implementation SPAlertAnimation

+ (instancetype)animationIsPresenting:(BOOL)isPresenting {
    return [[self alloc] initWithPresenting:isPresenting];
}

- (instancetype)initWithPresenting:(BOOL)isPresenting {
    if (self = [super init]) {
        self.presenting = isPresenting;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        [self presentAnimationTransition:transitionContext];
    } else {
        [self dismissAnimationTransition:transitionContext];
    }
}

- (void)presentAnimationTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    SPAlertController *alertController = (SPAlertController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];

    switch (alertController.animationType) {
        case SPAlertAnimationTypeRaiseUp:
        case SPAlertAnimationTypeFromBottom:
            [self raiseUpWhenPresentForController:alertController transition:transitionContext];
            break;
        case SPAlertAnimationTypeFromRight:
            [self fromRightWhenPresentForController:alertController transition:transitionContext];
            break;
        case SPAlertAnimationTypeDropDown:
        case SPAlertAnimationTypeFromTop:
            [self dropDownWhenPresentForController:alertController transition:transitionContext];
            break;
        case SPAlertAnimationTypeFromLeft:
            [self fromLeftWhenPresentForController:alertController transition:transitionContext];
            break;
        case SPAlertAnimationTypeAlpha:
        case SPAlertAnimationTypeFade:
            [self alphaWhenPresentForController:alertController transition:transitionContext];
            break;
        case SPAlertAnimationTypeExpand:
            [self expandWhenPresentForController:alertController transition:transitionContext];
            break;
        case SPAlertAnimationTypeShrink:
            [self shrinkWhenPresentForController:alertController transition:transitionContext];
            break;
        case SPAlertAnimationTypeNone:
            [self noneWhenPresentForController:alertController transition:transitionContext];
            break;
        default:
            break;
    }
}

- (void)dismissAnimationTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    SPAlertController *alertController = (SPAlertController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    if ([alertController isKindOfClass:[SPAlertController class]]) {
        switch (alertController.animationType) {
            case SPAlertAnimationTypeRaiseUp:
            case SPAlertAnimationTypeFromBottom:
                [self dismissCorrespondingRaiseUpForController:alertController transition:transitionContext];
                break;
            case SPAlertAnimationTypeFromRight:
                [self dismissCorrespondingFromRightForController:alertController transition:transitionContext];
                break;
            case SPAlertAnimationTypeFromLeft:
                [self dismissCorrespondingFromLeftForController:alertController transition:transitionContext];
                break;
            case SPAlertAnimationTypeDropDown:
            case SPAlertAnimationTypeFromTop:
                [self dismissCorrespondingDropDownForController:alertController transition:transitionContext];
                break;
            case SPAlertAnimationTypeAlpha:
            case SPAlertAnimationTypeFade:
                [self dismissCorrespondingAlphaForController:alertController transition:transitionContext];
                break;
            case SPAlertAnimationTypeExpand:
                [self dismissCorrespondingExpandForController:alertController transition:transitionContext];
                break;
            case SPAlertAnimationTypeShrink:
                [self dismissCorrespondingShrinkForController:alertController transition:transitionContext];
                break;
            case SPAlertAnimationTypeNone:
                [self dismissCorrespondingNoneForController:alertController transition:transitionContext];
                break;
            default:
                break;
        }
    }
}

// 从底部弹出的present动画
- (void)raiseUpWhenPresentForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = [transitionContext containerView];
    // 将alertController的view添加到containerView上
    [containerView addSubview:alertController.view];
    // 标记需要刷新布局
    [containerView setNeedsLayout];
    // 在有标记刷新布局的情况下立即布局，这行代码很重要，第一：立即布局会立即调用SPAlertController的viewWillLayoutSubviews的方法，第二：立即布局后可以获取到alertController.view的frame
    [containerView layoutIfNeeded];
    
    // 这3行代码不能放在[containerView layoutIfNeeded]之前，如果放在之前，[containerView layoutIfNeeded]强制布局后会将以下设置的frame覆盖
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.y = SP_SCREEN_HEIGHT;
    alertController.view.frame = controlViewFrame;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        if (alertController.preferredStyle == SPAlertControllerStyleActionSheet) {
            controlViewFrame.origin.y = SP_SCREEN_HEIGHT-controlViewFrame.size.height;
        } else {
            controlViewFrame.origin.y = (SP_SCREEN_HEIGHT-controlViewFrame.size.height) / 2.0;
            [self offSetCenter:alertController];
        }
        alertController.view.frame = controlViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [alertController layoutAlertControllerView];
    }];
}

// 从底部弹出对应的dismiss动画
- (void)dismissCorrespondingRaiseUpForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = SP_SCREEN_HEIGHT;
        alertController.view.frame = controlViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

// 从右边弹出的present动画
- (void)fromRightWhenPresentForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    // 将alertController的view添加到containerView上
    [containerView addSubview:alertController.view];
    // 标记需要刷新布局
    [containerView setNeedsLayout];
    // 在有标记刷新布局的情况下立即布局，这行代码很重要，第一：立即布局会立即调用SPAlertController的viewWillLayoutSubviews的方法，第二：立即布局后可以获取到alertController.view的frame
    [containerView layoutIfNeeded];
    
    // 这3行代码不能放在[containerView layoutIfNeeded]之前，如果放在之前，[containerView layoutIfNeeded]强制布局后会将以下设置的frame覆盖
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.x = SP_SCREEN_WIDTH;
    alertController.view.frame = controlViewFrame;
    
    if (alertController.preferredStyle == SPAlertControllerStyleAlert) {
        [self offSetCenter:alertController];
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        if (alertController.preferredStyle == SPAlertControllerStyleActionSheet) {
            controlViewFrame.origin.x = SP_SCREEN_WIDTH-controlViewFrame.size.width;
        } else {
            controlViewFrame.origin.x = (SP_SCREEN_WIDTH-controlViewFrame.size.width) / 2.0;
        }
        alertController.view.frame = controlViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [alertController layoutAlertControllerView];
    }];
}

// 从右边弹出对应的dismiss动画
- (void)dismissCorrespondingFromRightForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.x = SP_SCREEN_WIDTH;
        alertController.view.frame = controlViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

// 从左边弹出的present动画
- (void)fromLeftWhenPresentForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    // 将alertController的view添加到containerView上
    [containerView addSubview:alertController.view];
    // 标记需要刷新布局
    [containerView setNeedsLayout];
    // 在有标记刷新布局的情况下立即布局，这行代码很重要，第一：立即布局会立即调用SPAlertController的viewWillLayoutSubviews的方法，第二：立即布局后可以获取到alertController.view的frame
    [containerView layoutIfNeeded];
    
    // 这3行代码不能放在[containerView layoutIfNeeded]之前，如果放在之前，[containerView layoutIfNeeded]强制布局后会将以下设置的frame覆盖
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.x = -controlViewFrame.size.width;
    alertController.view.frame = controlViewFrame;
    
    if (alertController.preferredStyle == SPAlertControllerStyleAlert) {
        [self offSetCenter:alertController];
    }
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        if (alertController.preferredStyle == SPAlertControllerStyleActionSheet) {
            controlViewFrame.origin.x = 0;
        } else {
            controlViewFrame.origin.x = (SP_SCREEN_WIDTH-controlViewFrame.size.width) / 2.0;
        }
        alertController.view.frame = controlViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [alertController layoutAlertControllerView];
    }];
}

// 从左边弹出对应的dismiss动画
- (void)dismissCorrespondingFromLeftForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.x = -controlViewFrame.size.width;
        alertController.view.frame = controlViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

// 从顶部弹出的present动画
- (void)dropDownWhenPresentForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    // 将alertController的view添加到containerView上
    [containerView addSubview:alertController.view];
    // 标记需要刷新布局
    [containerView setNeedsLayout];
    // 在有标记刷新布局的情况下立即布局，这行代码很重要，第一：立即布局会立即调用SPAlertController的viewWillLayoutSubviews的方法，第二：立即布局后可以获取到alertController.view的frame
    [containerView layoutIfNeeded];
    
    // 这3行代码不能放在[containerView layoutIfNeeded]之前，如果放在之前，[containerView layoutIfNeeded]强制布局后会将以下设置的frame覆盖
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.y = -controlViewFrame.size.height;
    alertController.view.frame = controlViewFrame;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        if (alertController.preferredStyle == SPAlertControllerStyleActionSheet) {
            controlViewFrame.origin.y = 0;
        } else {
            controlViewFrame.origin.y = (SP_SCREEN_HEIGHT-controlViewFrame.size.height) / 2.0;
            [self offSetCenter:alertController];
        }
        alertController.view.frame = controlViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [alertController layoutAlertControllerView];
    }];
}

// 从顶部弹出对应的dismiss动画
- (void)dismissCorrespondingDropDownForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {

    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = -controlViewFrame.size.height;
        alertController.view.frame = controlViewFrame;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

// alpha值从0到1变化的present动画
- (void)alphaWhenPresentForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    // 标记需要刷新布局
    [containerView setNeedsLayout];
    // 在有标记刷新布局的情况下立即布局，这行代码很重要，第一：立即布局会立即调用SPAlertController的viewWillLayoutSubviews的方法，第二：立即布局后可以获取到alertController.view的frame,不仅如此，走了viewWillLayoutSubviews键盘就会弹出，此后可以获取到alertController.offset
    [containerView layoutIfNeeded];
    
    alertController.view.alpha = 0;
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self offSetCenter:alertController];
        alertController.view.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [alertController layoutAlertControllerView];
    }];
}

// alpha值从0到1变化对应的的dismiss动画
- (void)dismissCorrespondingAlphaForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

// 发散的prensent动画
- (void)expandWhenPresentForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    // 标记需要刷新布局
    [containerView setNeedsLayout];
    // 在有标记刷新布局的情况下立即布局，这行代码很重要，第一：立即布局会立即调用SPAlertController的viewWillLayoutSubviews的方法，第二：立即布局后可以获取到alertController.view的frame,不仅如此，走了viewWillLayoutSubviews键盘就会弹出，此后可以获取到alertController.offset
    [containerView layoutIfNeeded];
    
    alertController.view.transform = CGAffineTransformMakeScale(0.9, 0.9);
    alertController.view.alpha = 0.0;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self offSetCenter:alertController];
        alertController.view.transform = CGAffineTransformIdentity;
        alertController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [alertController layoutAlertControllerView];
    }];
}

// 发散对应的dismiss动画
- (void)dismissCorrespondingExpandForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformIdentity;
        alertController.view.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
    }];
}

// 收缩的present动画
- (void)shrinkWhenPresentForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    // 标记需要刷新布局
    [containerView setNeedsLayout];
    // 在有标记刷新布局的情况下立即布局，这行代码很重要，第一：立即布局会立即调用SPAlertController的viewWillLayoutSubviews的方法，第二：立即布局后可以获取到alertController.view的frame,不仅如此，走了viewWillLayoutSubviews键盘就会弹出，此后可以获取到alertController.offset
    [containerView layoutIfNeeded];
    
    alertController.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    alertController.view.alpha = 0;

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        [self offSetCenter:alertController];
        alertController.view.transform = CGAffineTransformIdentity;
        alertController.view.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:finished];
        [alertController layoutAlertControllerView];
    }];
}

// 收缩对应的的dismiss动画
- (void)dismissCorrespondingShrinkForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    // 与发散对应的dismiss动画相同
    [self dismissCorrespondingExpandForController:alertController transition:transitionContext];
}

// 无动画
- (void)noneWhenPresentForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    [transitionContext completeTransition:transitionContext.animated];
}

- (void)dismissCorrespondingNoneForController:(SPAlertController *)alertController transition:(id<UIViewControllerContextTransitioning>)transitionContext {
    [transitionContext completeTransition:transitionContext.animated];
}

- (void)offSetCenter:(SPAlertController *)alertController {
    if (!CGPointEqualToPoint(alertController.offsetForAlert, CGPointZero)) {
        CGPoint controlViewCenter = alertController.view.center;
        controlViewCenter.x = SP_SCREEN_WIDTH / 2.0 + alertController.offsetForAlert.x;
        controlViewCenter.y = SP_SCREEN_HEIGHT / 2.0 + alertController.offsetForAlert.y;
        alertController.view.center = controlViewCenter;
    }
}

@end
#pragma clang diagnostic pop

#pragma mark ---------------------------- SPAlertAnimation end --------------------------------

