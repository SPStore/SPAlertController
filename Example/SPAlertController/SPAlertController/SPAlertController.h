//
//  SPAlertController.h
//  SPAlertController
//
//  Created by 乐升平 on 17/10/12. https://github.com/SPStore/SPAlertController
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, SPAlertActionStyle) {
    SPAlertActionStyleDefault = 0,  // 默认样式
    SPAlertActionStyleCancel,       // 取消样式,只有在SPAlertControllerStyleActionSheet下才有效果
    SPAlertActionStyleDestructive   // 红色字体样式，SPAlertControllerStyleActionSheet和SPAlertControllerStyleAlert均有效
};

typedef NS_ENUM(NSInteger, SPAlertControllerStyle) {
    SPAlertControllerStyleActionSheet = 0, // 从底部或顶部弹出
    SPAlertControllerStyleAlert,           // 从中间弹出
};

typedef NS_ENUM(NSInteger, SPAlertAnimationType) {
    SPAlertAnimationTypeDefault = 0, // 默认动画，如果是actionSheet,默认为SPAlertAnimationTypeRaiseUp，如果是alert,默认为SPAlertAnimationTypeAlpha
    SPAlertAnimationTypeRaiseUp,     // 从下往上弹，一般用于actionSheet
    SPAlertAnimationTypeDropDown,    // 从上往下弹，一般用于actionSheet
    SPAlertAnimationTypeAlpha,       // 透明度从0到1，一般用于alert
    SPAlertAnimationTypeExpand,      // 发散动画，一般用于alert
    SPAlertAnimationTypeShrink       // 收缩动画，一般用于alert
};

// ================================ action类 ================================

@interface SPAlertAction : NSObject <NSCopying>
/**
 *  创建一个action
 *
 *  @param title    标题
 *  @param style    action样式
 *  @param handler  点中后的bolok回调
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

/**
 *  创建控制器
 *
 *  @param title    大标题
 *  @param message  副标题
 *  @param preferredStyle  样式
 *  @param animationType   动画类型
 *  @param customView      自定义的view，如果customView传nil，就跟第一个方法等效
 */
// 对话框的大小取决于customView的大小
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(nullable UIView *)customView;

/**
 *  创建控制器
 *
 *  @param preferredStyle  样式
 *  @param animationType   动画类型
 *  @param customTitleView 自定义的titleView，如果customTitleView传nil，就跟第一个方法等效
 */
// 如果customTitleView宽度小于等于0，或者大于等于了对话框的宽度，会自动等宽于对话框，除此之外，宽度会按照customTitleView的宽度居中布局
+ (instancetype)alertControllerWithPreferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customTitleView:(nullable UIView *)customTitleView;

/**
 *  创建控制器
 *
 *  @param title    大标题
 *  @param message  副标题
 *  @param preferredStyle  样式
 *  @param animationType   动画类型
 *  @param customCenterView 自定义的centerView，如果customCenterView传nil，就跟第一个方法等效
 */
// 如果customCenterView宽度小于等于0，或者大于等于了对话框的宽度，会自动等宽于对话框，除此之外，宽度会按照customCenterView的宽度居中布局
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customCenterView:(nullable UIView *)customCenterView;

/**
 *  创建控制器
 *
 *  @param title    大标题
 *  @param message  副标题
 *  @param preferredStyle  样式
 *  @param animationType   动画类型
 *  @param customFooterView 自定义的customFooterView，如果customFooterView传nil，就跟第一个方法等效
 */
// 如果customFooterView宽度小于等于0，或者大于等于了对话框的宽度，会自动等宽于对话框，除此之外，宽度会按照customCenterView的宽度居中布局
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
 *  @param configurationHandler  一旦添加后就会回调一次(仅回调一次,因此可以在这个block块里面自由定制textFiled，如设置textField的属性，设置代理，添加addTarget，监听通知等),只有present后，textField才有superView
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

/** actionSheet样式下,最大的顶部间距,默认为0,iPhoneX下默认44 */
// 如果是从顶部弹出来，该属性则充当底部间距
@property (nonatomic, assign) CGFloat maxTopMarginForActionSheet;

/** alert样式下,四周的最大间距,默认为20 */
@property (nonatomic, assign) CGFloat maxMarginForAlert;

/** alert样式下，圆角半径 */
@property (nonatomic, assign) CGFloat cornerRadiusForAlert;

/** alert样式下，弹窗的中心y值，为正向下偏移，为负向上偏移 */
@property (nonatomic, assign) CGFloat offsetYForAlert;

/** alert样式下，水平排列的最大个数，如果大于了这个数，则所有action将垂直排列；默认是2 */
// 当自定义了footerView时，该属性不起作用
@property (nonatomic, assign) NSInteger maxNumberOfActionHorizontalArrangementForAlert;

/** 是否需要毛玻璃效果,默认为YES */
@property (nonatomic, assign) BOOL needBlur;

@end


@interface SPAlertPresentationController : UIPresentationController
@end

// ================================ 动画类 ================================

@interface SPAlertAnimation : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)animationIsPresenting:(BOOL)presenting;

@end

NS_ASSUME_NONNULL_END
