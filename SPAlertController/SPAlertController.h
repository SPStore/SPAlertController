//
//  SPAlertController.h
//  SPAlertController
//
//  Created by 乐升平 on 17/10/12.
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

// ---------------------------- action类 ------------------------------

@interface SPAlertAction : NSObject <NSCopying>

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(SPAlertActionStyle)style handler:(void (^ __nullable)(SPAlertAction *action))handler;

// action的标题
@property (nullable, nonatomic, readonly) NSString *title;
// 样式
@property (nonatomic, readonly) SPAlertActionStyle style;
// 是否能点击,默认为YES,当为NO时，action的文字颜色为浅灰色，字体17号，且无法修改
@property (nonatomic, getter=isEnabled) BOOL enabled;
// action的标题颜色
@property (nonatomic, strong) UIColor *titleColor;
// action的标题字体
@property (nonatomic, strong) UIFont *titleFont;

@end

// ---------------------------- 控制器类 ------------------------------

@interface SPAlertController : UIViewController

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType;

// 如果customView传nil，就跟上面的方法等价,customView只有高度有效
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(nullable UIView *)customView;

- (void)addAction:(SPAlertAction *)action;
@property (nonatomic, readonly) NSArray<SPAlertAction *> *actions;

// configurationHandler只会回调一次，可以在block块里面自由定制textFiled，如设置textField的属性，设置代理，添加addTarget，监听通知等
- (void)addTextFieldWithConfigurationHandler:(void (^ __nullable)(UITextField *textField))configurationHandler;
@property (nullable, nonatomic, readonly) NSArray<UITextField *> *textFields;

@property (nonatomic, readonly) SPAlertControllerStyle preferredStyle;
@property (nonatomic, readonly) SPAlertAnimationType animationType;

@property (nonatomic, strong, readonly) UIView *alertView;

// 大标题
@property (nullable, nonatomic, copy) NSString *title;
// 副标题
@property (nullable, nonatomic, copy) NSString *message;
// 大标题颜色
@property (nonatomic, strong) UIColor *titleColor;
// 副标题颜色
@property (nonatomic, strong) UIColor *messageColor;
// 大标题字体
@property (nonatomic, strong) UIFont *titleFont;
// 副标题字体
@property (nonatomic, strong) UIFont *messageFont;

// 是否需要毛玻璃效果,默认为YES
@property (nonatomic, assign) BOOL needBlur;

// actionSheet样式下,最大的顶部间距,默认为0
@property (nonatomic, assign) CGFloat maxTopMarginForActionSheet;

// alert样式下,四周的最大间距,默认为20
@property (nonatomic, assign) CGFloat maxMarginForAlert;

// alert样式下，弹窗的中心y值，为正向上偏移，为负向下偏移
@property (nonatomic, assign) CGFloat offsetY;

@end

// ---------------------------- 动画类 ------------------------------

@interface SPAlertAnimation : NSObject <UIViewControllerAnimatedTransitioning>

+ (instancetype)animationIsPresenting:(BOOL)presenting;

@end

NS_ASSUME_NONNULL_END
