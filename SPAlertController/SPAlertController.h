//
//  SPAlertController.h
//  SPAlertController
//
//  Created by 乐升平 on 17/10/12. https://github.com/SPStore/SPAlertController
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SPAlertControllerStyle) {
    SPAlertControllerStyleActionSheet = 0, // 弹出后处于屏幕四周的某一侧(顶/左/底/右),具体在哪一侧取决于动画类型
    SPAlertControllerStyleAlert,           // 弹出后处于屏幕中心位置
};

typedef NS_ENUM(NSInteger, SPAlertAnimationType) {
    SPAlertAnimationTypeDefault = 0, // 默认动画，如果是SPAlertControllerStyleActionSheet样式,默认动画等效于SPAlertAnimationTypeFromBottom，如果是SPAlertControllerStyleAlert样式,默认动画等效于SPAlertAnimationTypeAlpha
    SPAlertAnimationTypeFromBottom,  // 从底部弹出，常用于SPAlertControllerStyleActionSheet样式
    SPAlertAnimationTypeFromTop,     // 从顶部弹出，常用于SPAlertControllerStyleActionSheet样式且自定义对话框
    SPAlertAnimationTypeFromRight,   // 从右边弹出，常用于SPAlertControllerStyleActionSheet样式且自定义对话框
    SPAlertAnimationTypeFromLeft,    // 从左边弹出，常用于SPAlertControllerStyleActionSheet样式且自定义对话框
    SPAlertAnimationTypeAlpha,       // 透明度从0到1，常用于SPAlertControllerStyleAlert样式
    SPAlertAnimationTypeExpand,      // 发散动画，常用于SPAlertControllerStyleAlert样式
    SPAlertAnimationTypeShrink,      // 收缩动画，常用于SPAlertControllerStyleAlert样式
    
    SPAlertAnimationTypeRaiseUp NS_ENUM_DEPRECATED_IOS(8_0, 8_0, "该枚举值相当于SPAlertAnimationTypeFromBottom"),     // 从底部弹出，一般用于SPAlertControllerStyleActionSheet样式
    SPAlertAnimationTypeDropDown NS_ENUM_DEPRECATED_IOS(8_0, 8_0, "该枚举值相当于SPAlertAnimationTypeFromTop"),    // 从顶部弹出，一般用于SPAlertControllerStyleActionSheet样式且自定义对话框
};

typedef NS_ENUM(NSInteger, SPAlertActionStyle) {
    SPAlertActionStyleDefault = 0,  // 默认样式
    SPAlertActionStyleCancel,       // 取消样式
    SPAlertActionStyleDestructive   // 红色字体样式
};

typedef NS_ENUM(NSInteger, SPBackgroundViewAppearanceStyle) {
    SPBackgroundViewAppearanceStyleTranslucent = 0,  // 无毛玻璃效果,黑色透明(默认是0.5透明)
    SPBackgroundViewAppearanceStyleBlurDark,
    SPBackgroundViewAppearanceStyleBlurExtraLight,
    SPBackgroundViewAppearanceStyleBlurLight,
};


// ================================ action类 ================================

@interface SPAlertAction : NSObject <NSCopying>
/**
 *  创建一个action
 *
 *  @param title    标题
 *  @param style    action样式
 *  @param handler  点击后的bolok回调
 */
+ (instancetype)actionWithTitle:(nullable NSString *)title style:(SPAlertActionStyle)style handler:(void (^ __nullable)(SPAlertAction *action))handler;

/* action的标题 */
@property (nullable, nonatomic, readonly) NSString *title;
/* 样式 */
@property (nonatomic, readonly) SPAlertActionStyle style;
/* 是否能点击,默认为YES,当为NO时，action的文字颜色为浅灰色，字体17号，且无法修改 */
@property (nonatomic, getter=isEnabled) BOOL enabled;
/* action的标题颜色 */
@property (nonatomic, strong) UIColor *titleColor;
/* action的标题字体 */
@property (nonatomic, strong) UIFont *titleFont;

@end



@class SPAlertController;
@protocol SPAlertControllerDelegate <NSObject>
@optional;
// 将要出现
- (void)sp_alertControllerWillShow:(SPAlertController *)alertController;
// 已经出现
- (void)sp_alertControllerDidShow:(SPAlertController *)alertController;
// 将要隐藏
- (void)sp_alertControllerWillHide:(SPAlertController *)alertController;
// 已经隐藏
- (void)sp_alertControllerDidHide:(SPAlertController *)alertController;

@end

// ================================ 控制器类 ================================

@interface SPAlertController : UIViewController

/**
 *  创建控制器
 *
 *  @param title    大标题
 *  @param message  副标题
 *  @param preferredStyle  样式
 *  @param animationType   动画类型
 */
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType;

/*
 以下4个类方法均用于自定义,除了最后一个参数不一致之外,其余参数均一致;如果最后一个参数传nil,就跟上面那个类方法等效.
 1.SPAlertControllerStyleAlert样式下非自定义时对话框的默认宽度恒为屏幕宽-40,高度最大为屏幕高-40,如果想设置对话框的宽度以及修改最大高度,可以通过调整maxMarginForAlert属性来设置,高度上只要没有超出最大高度，会自适应内容.自定义时大小取决于自定义view的大小
 2.SPAlertControllerStyleActionSheet样式下非自定义时对话框的默认宽度为屏幕宽,高度最大为屏幕高,最大高度可通过maxTopMarginForActionSheet属性来修改,高度上只要没超出最大高度,会自适应内容.自定义时大小取决于自定义view的大小
 
 关于自定义的view的宽高如何让给定？
 1、如果自定义的view本身采用的是自动布局，如果自定义的view的大小是由内部子控件自动撑起，那么SPAlertController内部会获取到这个撑起后的大小去设置，此时自定义的view如果另行设置frame是无效也是无意义的；如果自定义的view的大小不是由子控件撑起，内部会调用layoutIfNeed计算自动布局后的frame, 如果是xib布的局不手动设置frame的话，那么SPAlertController会获取xib中默认的frame
 2、如果采用的是非自动布局,那么外界应该对自定义的view手动设置frame
 3、如果自定义的view重写了intrinsicContentSize，那么SPAlertController将会用intrinsicContentSize去设置自定义view的大小，也就是intrinsicContentSize优先级最高，无论哪种布局，都会以它为先
 */

// 自定义整个对话框
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(nullable UIView *)customView;

// 自定义headerView
+ (instancetype)alertControllerWithPreferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customHeaderView:(nullable UIView *)customHeaderView;

// 自定义centerView
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customCenterView:(nullable UIView *)customCenterView;

// 自定义footerView
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customFooterView:(nullable UIView *)customFooterView;

/**
 *  添加action
 */
- (void)addAction:(SPAlertAction *)action;

/** action数组 */
@property (nonatomic, readonly) NSArray<SPAlertAction *> *actions;

/**
 *  添加文本输入框
 *
 * 一旦添加后就会回调一次(仅回调一次,因此可以在这个block块里面自由定制textFiled,如设置textField的属性,设置代理,添加addTarget,监听通知等); 只有present后,textField才有superView
 */
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;

/** textField的数组 */
@property (nullable, nonatomic, readonly) NSArray<UITextField *> *textFields;

/** 样式 */
@property (nonatomic, readonly) SPAlertControllerStyle preferredStyle;
/** 动画类型 */
@property (nonatomic, readonly) SPAlertAnimationType animationType;

/** 大标题 */
@property (nullable, nonatomic, copy) NSString *title;
/** 副标题 */
@property (nullable, nonatomic, copy) NSString *message;
/** 大标题颜色 */
@property (nonatomic, strong) UIColor *titleColor;
/** 副标题颜色 */
@property (nonatomic, strong) UIColor *messageColor;
/** 大标题字体 */
@property (nonatomic, strong) UIFont *titleFont;
/** 副标题字体 */
@property (nonatomic, strong) UIFont *messageFont;

/** action的高度，在添加action之前设置性能会更佳 */
@property (nonatomic, assign) CGFloat actionHeight;

/** actionSheet样式下,最大的顶部间距,从底部、右边、左边弹出时默认为0,iPhoneX及以上机型默认44,从顶部弹出时无论哪种机型都默认为0;
    注意该属性中的top单词不是精确的指顶部，当从右边弹出时，top指的就是左，从左边弹出时，top指的就是右，从顶部弹出时，top指的就是底
 */
@property (nonatomic, assign) CGFloat maxTopMarginForActionSheet;

/** alert样式下,四周的最大间距,默认为20 */
@property (nonatomic, assign) CGFloat maxMarginForAlert;

/** alert样式下，圆角半径 */
@property (nonatomic, assign) CGFloat cornerRadiusForAlert;

/** alert样式下，弹窗的中心y值，为正向下偏移，为负向上偏移 */
@property (nonatomic, assign) CGFloat offsetYForAlert;


/** alert样式下,水平排列的最大个数,如果大于了这个数,则所有action将垂直排列,默认是2；在添加action之前设置性能会更佳
    由于水平排列的action都是排布在footerView上,所以如果自定义了footerView，该属性将失去效用
 */
@property (nonatomic, assign) NSInteger maxNumberOfActionHorizontalArrangementForAlert;

/** 是否需要对话框拥有毛玻璃,默认为YES----Dialog单词是对话框的意思 */
@property (nonatomic, assign) BOOL needDialogBlur;

/** 是否单击背景退出对话框,默认为YES */
@property (nonatomic, assign) BOOL tapBackgroundViewDismiss;

@property (nonatomic, weak) id<SPAlertControllerDelegate> delegate;


/** 设置蒙层的外观样式,可通过alpha调整透明度,如果设置了毛玻璃样式,设置alpha<1可能会有警告,警告是正常的 */
- (void)setBackgroundViewAppearanceStyle:(SPBackgroundViewAppearanceStyle)style alpha:(CGFloat)alpha;

@end


@interface SPAlertPresentationController : UIPresentationController
@end

// ================================ 动画类 ================================

@interface SPAlertAnimation : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)animationIsPresenting:(BOOL)presenting;

@end

NS_ASSUME_NONNULL_END
