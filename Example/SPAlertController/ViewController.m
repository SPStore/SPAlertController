//
//  ViewController.m
//  SPAlertController
//
//  Created by 乐升平 on 17/10/12.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "ViewController.h"
#import "SPAlertController.h"
#import "SendAlertView.h"
#import "MyCenterView.h"
#import "ScoreView.h"
#import "UIColor+DarkMode.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define NaviHeight ([UIScreen mainScreen].bounds.size.height >= 812 ? 88 : 64)

// RGB颜色
#define SPColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define SYSTEM_BLUE_COLOR [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0]

// 随机色
#define SPRandomColor ZCColorRGBA(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256),1)

@interface ViewController () <UITableViewDelegate,UITableViewDataSource,SPAlertControllerDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) SPAlertAction *sureAction;
@property (nonatomic, strong) UITextField *phoneNumberTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (nonatomic, assign) BOOL haveBg;
@property (nonatomic, assign) BOOL lookBlur;
@property (nonatomic, weak) SPAlertController *alertController;
@end

@implementation ViewController {
    NSMutableDictionary *dic;
}

#pragma mark =============================== SPAlertControllerStyleActionSheet样式示例 ==============================================

// 示例1:actionSheet的默认动画样式(从底部弹出，有取消按钮)
- (void)actionSheetTest1 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:nil message:nil preferredStyle:SPAlertControllerStyleActionSheet];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"Default" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Default ");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"Destructive" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Destructive");
    }];

    action2.allowsAutoDismiss = NO;
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"Cancel" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Cancel");
    }];
    [alertController addAction:action1];
    [alertController addAction:action3]; // 取消按钮一定排在最底部
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:^{}];

}

// 示例2:actionSheet的默认动画(从底部弹出,无取消按钮)
- (void)actionSheetTest2 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"Default" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Default ");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"Destructive" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Destructive");
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 示例3:actionSheet从顶部弹出(无标题)
- (void)actionSheetTest3 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:nil message:nil preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromTop];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例4:actionSheet从顶部弹出(有标题)
- (void)actionSheetTest4 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:nil message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromTop];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    action3.titleColor = SPColorRGBA(30, 170, 40, 1);
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例5:actionSheet 水平排列（有取消按钮）
- (void)actionSheetTest5 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    alertController.needDialogBlur = _lookBlur;
    alertController.actionAxis = UILayoutConstraintAxisHorizontal;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"第4个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第4个");
    }];
    SPAlertAction *action5 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    // 注:在addAction之后设置action的文字颜色和字体同样有效
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例6:actionSheet 水平排列（无取消按钮）
- (void)actionSheetTest6 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    alertController.actionAxis = UILayoutConstraintAxisHorizontal;
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"第4个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第4个");
    }];
    // 注:在addAction之后设置action的文字颜色和字体同样有效
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例7:actionSheet action上有图标
- (void)actionSheetTest7 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:nil message:nil preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"视频通话" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了‘视频通话’");
    }];
    action1.image = [[UIImage imageNamed:@"video"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    action1.tintColor = [UIColor colorPairsWithLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]];
    action1.imageTitleSpacing = 5;
    
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"语音通话" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了‘语音通话’");
    }];
    action2.image = [[UIImage imageNamed:@"telephone"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    action2.tintColor = [UIColor colorPairsWithLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]];
    action2.imageTitleSpacing = 5;
    
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    // 注:在addAction之后设置action的文字颜色和字体同样有效
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例8:actionSheet 模拟多分区样式
- (void)actionSheetTest8 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    action1.titleColor = [UIColor orangeColor];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    action2.titleColor = [UIColor orangeColor];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"第4个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第4个");
    }];
    SPAlertAction *action5 = [SPAlertAction actionWithTitle:@"第5个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第5个");
    }];
    SPAlertAction *action6 = [SPAlertAction actionWithTitle:@"第6个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第6个");
    }];
    SPAlertAction *action7 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    action7.titleColor = SYSTEM_BLUE_COLOR;
    // 注:在addAction之后设置action的文字颜色和字体同样有效
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    [alertController addAction:action6];
    [alertController addAction:action7];
    
    if (@available(iOS 11.0, *)) {
        [alertController setCustomSpacing:6.0 afterAction:action2]; // 设置第2个action之后的间隙
    }
    if (@available(iOS 11.0, *)) {
        [alertController setCustomSpacing:6.0 afterAction:action4];  // 设置第4个action之后的间隙
    }
   
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例8:actionSheet 点击action不dismiss
- (void)actionSheetTest9 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromBottom];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    action1.allowsAutoDismiss = NO;
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    action2.allowsAutoDismiss = NO;

    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark =============================== SPAlertControllerStyleAlert样式示例 ==============================================

// 示例9:alert 默认动画(收缩动画)
- (void)alertTest1 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    // 设置第2个action的颜色
    action2.titleColor = SYSTEM_BLUE_COLOR;
    [alertController addAction:action2];
    [alertController addAction:action1];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例10:alert 发散动画
- (void)alertTest2 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeExpand];
    alertController.needDialogBlur = _lookBlur;
    _alertController = alertController;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的颜色
    action1.titleColor = SYSTEM_BLUE_COLOR;
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点点击了第3个");
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [self presentViewController:alertController animated:YES completion:^{}];
}

// 示例11:alert渐变动画
- (void)alertTest3 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeFade];
    alertController.needDialogBlur = _lookBlur;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // 设置第1个action的字体
    action1.titleColor = SYSTEM_BLUE_COLOR;
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    action2.titleColor = [UIColor redColor];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例12:alert 垂直排列2个按钮（2个按钮默认是水平排列）
- (void)alertTest4 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeExpand];
    alertController.needDialogBlur = _lookBlur;
    // 2个按钮时默认是水平排列，这里强制垂直排列
    alertController.actionAxis = UILayoutConstraintAxisVertical;

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // 设置第1个action的颜色
    action1.titleColor = [UIColor redColor];
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    action2.titleColor = SYSTEM_BLUE_COLOR;
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例13:alert 水平排列2个以上的按钮(默认超过2个按钮是垂直排列)
- (void)alertTest5 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert];
    alertController.needDialogBlur = _lookBlur;
    // 2个按钮以上默认是垂直排列，这里强制设置水平排列
    alertController.actionAxis = UILayoutConstraintAxisHorizontal;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
    action1.titleColor = SYSTEM_BLUE_COLOR;
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    action2.titleColor = [UIColor magentaColor];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例14:alert 设置头部图标
- (void)alertTest6 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"“支付宝”的触控 ID" message:@"请验证已有指纹" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];

    // 设置图标
    alertController.image = [UIImage imageNamed:@"zhiwen"];
    
    SPAlertAction *action = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    action.titleColor = SYSTEM_BLUE_COLOR;
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例15:alert 含有文本输入框
- (void)alertTest7 {

    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeExpand];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    action1.titleColor = [UIColor redColor];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"确定");
    }];
    action2.titleColor = SYSTEM_BLUE_COLOR;
    action2.enabled = NO;
    self.sureAction = action2;
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSLog(@"第1个文本输入框回调");
        self.phoneNumberTextField = textField;
        // 这个block只会回调一次，因此可以在这里自由定制textFiled，如设置textField的相关属性，设置代理，添加addTarget，监听通知等
        textField.placeholder = @"请输入手机号码";
        textField.clearButtonMode = UITextFieldViewModeAlways;
        [textField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSLog(@"第2个文本输入框回调");
        self.passwordTextField = textField;
        textField.placeholder = @"请输入密码";
        textField.secureTextEntry = YES;
        textField.clearButtonMode = UITextFieldViewModeAlways;
        [textField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ========================================== 富文本样式示例 =======================================================

// 示例16:富文本(action设置富文本)
- (void)attributedStringTest1 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:nil message:nil preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    alertController.needDialogBlur = _lookBlur;

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:nil style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了拍摄");
    }];
    NSString *mainTitle1 = @"拍摄";
    NSString *subTitle1 = @"照片或视频";
    NSString *totalTitle1 = [NSString stringWithFormat:@"%@\n%@",mainTitle1,subTitle1];
    NSMutableAttributedString *attrTitle1 = [[NSMutableAttributedString alloc] initWithString:totalTitle1];
    
    NSMutableParagraphStyle *paragraphStyle1 = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle1.lineSpacing = 3;  // 设置行间距
    paragraphStyle1.lineBreakMode = 0;
    paragraphStyle1.alignment = NSTextAlignmentCenter;
    // 段落样式
    [attrTitle1 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle1 range:NSMakeRange(0, totalTitle1.length)];
    // 设置富文本子标题的字体
    [attrTitle1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[totalTitle1 rangeOfString:subTitle1]];
    [attrTitle1 addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:[totalTitle1 rangeOfString:subTitle1]];

    action1.attributedTitle = attrTitle1; // 设置富文本标题

    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"从手机相册选择" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了'从手机相册选择'");
    }];

    SPAlertAction *action3 = [SPAlertAction actionWithTitle:nil style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了'用微视拍摄'");
    }];
    NSString *mainTitle3 = @"用微视拍摄";
    NSString *subTitle3 = @"推广";
    NSString *totalTitle3 = [NSString stringWithFormat:@"%@\n%@",mainTitle3,subTitle3];
    NSMutableAttributedString *attrTitle3 = [[NSMutableAttributedString alloc] initWithString:totalTitle3];
    
    NSMutableParagraphStyle *paragraphStyle3 = [[NSMutableParagraphStyle alloc] init];
    paragraphStyle3.lineSpacing = 3;  // 设置行间距
    paragraphStyle3.lineBreakMode = 0;
    paragraphStyle3.alignment = NSTextAlignmentCenter;
    // 段落样式
    [attrTitle3 addAttribute:NSParagraphStyleAttributeName value:paragraphStyle3 range:NSMakeRange(0, totalTitle3.length)];
    // 设置富文本子标题的字体
    [attrTitle3 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:[totalTitle3 rangeOfString:subTitle3]];
    [attrTitle3 addAttribute:NSForegroundColorAttributeName value:[UIColor grayColor] range:[totalTitle3 rangeOfString:subTitle3]];
    
    action3.attributedTitle = attrTitle3; // 设置富文本标题
    
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];

    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例17:富文本(头部设置富文本)
- (void)attributedStringTest2 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"" message:@"确定拨打吗？" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    alertController.needDialogBlur = _lookBlur;

    NSString *num = @"18077887788";
    NSString *desc = @"可能是一个电话号码";
    NSString *totalTitle = [NSString stringWithFormat:@"%@%@",num,desc];
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:totalTitle];
    [attrTitle addAttribute:NSForegroundColorAttributeName value:SYSTEM_BLUE_COLOR range:[totalTitle rangeOfString:num]];
    alertController.attributedTitle = attrTitle;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    action2.titleColor = SYSTEM_BLUE_COLOR;

    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ========================================== 自定义视图示例 =======================================================

// 示例18:自定义头部(xib)
- (void)customTest1 {
    
    SendAlertView *sendAlertView = [SendAlertView shareSendAlertView];
    static int k = 0;
    sendAlertView.contentImage = [UIImage imageNamed:[NSString stringWithFormat:@"send%d.jpeg",k]];
    k = !k; // 取反
    // 键盘将要弹出
    sendAlertView.keyboardWillShow = ^(CGFloat value){
        [self.alertController setOffsetForAlert:CGPointMake(0, -value) animated:YES];
    };
    // textView的高度发生了改变，value为改变量
    sendAlertView.textViewHeightDidChange = ^(CGFloat value) {
        // textView的高度改变后，对话框的高度也会跟着变，而且是以center为中心,高度向上下两边同时增大，为了保证对话框的底部固定，所以每次高度改变后要再向上偏移，偏移量就是value的一半
        CGPoint offset = self.alertController.offsetForAlert;
        offset.y = offset.y - value * 0.5;
        [self.alertController setOffsetForAlert:offset animated:YES];
    };
    // 结束编辑后恢复到中心位置
    sendAlertView.textViewDidEndEditting = ^{
        [self.alertController setOffsetForAlert:CGPointZero animated:YES];
    };
    
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomHeaderView:sendAlertView preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    _alertController = alertController;
    alertController.needDialogBlur = NO;
    // 一定要更新高度，因为对sendAlertView的contentImage赋值之后，高度改变了，自定义view的frame发生改变需要告诉SPAlertController
    [alertController updateCustomViewSize:[sendAlertView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize]];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"发送" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了发送");
    }];

    // 设置第2个action的颜色
    action2.titleColor = [UIColor colorWithRed:9.0/255.0 green:187.0/255.0 blue:7.0/255.0 alpha:1];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:^{}];
}

// 示例19:插入一个组件1
- (void)customTest2 {
    MyCenterView *centerView = [[MyCenterView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-40, 200)];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    
    // 插入一个view
    [alertController insertComponentView:centerView];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的颜色
    action1.titleColor = SYSTEM_BLUE_COLOR;
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    
    // 设置第2个action的颜色
    action2.titleColor = [UIColor redColor];
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例20:插入一个组件2
- (void)customTest3 {
    ScoreView *scoreView = [[ScoreView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-40, 200)];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    
    // 插入一个view
    [alertController insertComponentView:scoreView];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"完成" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的颜色
    action1.titleColor = SYSTEM_BLUE_COLOR;

    [alertController addAction:action1];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ========================================== 特殊情况示例 =======================================================

// 示例21:当按钮过多时
- (void)specialtest1 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"请滑动查看更多内容" message:@"谢谢" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    alertController.minDistanceToEdges = 100;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"第4个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第4个");
    }];
    SPAlertAction *action5 = [SPAlertAction actionWithTitle:@"第5个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第5个");
    }];
    SPAlertAction *action6 = [SPAlertAction actionWithTitle:@"第6个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第6个");
    }];
    SPAlertAction *action7 = [SPAlertAction actionWithTitle:@"第7个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第7个");
    }];
    SPAlertAction *action8 = [SPAlertAction actionWithTitle:@"第8个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第8个");
    }];
    SPAlertAction *action9 = [SPAlertAction actionWithTitle:@"第9个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第9个");
    }];
    SPAlertAction *action10 = [SPAlertAction actionWithTitle:@"第10个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第10个");
    }];
    SPAlertAction *action11 = [SPAlertAction actionWithTitle:@"第11个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第11个");
    }];
    SPAlertAction *action12 = [SPAlertAction actionWithTitle:@"第12个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第12个");
    }];
    SPAlertAction *action13 = [SPAlertAction actionWithTitle:@"第13个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第13个");
    }];
    SPAlertAction *action14 = [SPAlertAction actionWithTitle:@"第14个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第14个");
    }];
    SPAlertAction *action15 = [SPAlertAction actionWithTitle:@"第15个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第15个");
    }];
    SPAlertAction *action16 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    [alertController addAction:action6];
    [alertController addAction:action7];
    [alertController addAction:action8];
    [alertController addAction:action9];
    [alertController addAction:action10];
    [alertController addAction:action11];
    [alertController addAction:action12];
    [alertController addAction:action13];
    [alertController addAction:action14];
    [alertController addAction:action15];
    [alertController addAction:action16];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例22:当文字和按钮同时过多时，文字占据更多位置
- (void)specialtest2 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"请滑动查看更多内容" message:@"谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"第4个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第4个");
    }];
    SPAlertAction *action5 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    
    SPAlertAction *action6 = [SPAlertAction actionWithTitle:@"第5个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第5个");
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    [alertController addAction:action6];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例23:含有文本输入框，且文字过多,默认会滑动到第一个文本输入框的位置
- (void)specialtest3 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"请滑动查看更多内容" message:@"谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeNone];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例24:action上的文字过长（垂直）
- (void)specialtest4 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"提示" message:@"SPAlertControllerStyleAlert样式下2个按钮默认是水平排列，如果存在按钮文字过长，则自动会切换为垂直排列，除非外界设置了'actionAxis'。如果垂直排列后文字依然过长，则会压缩字体适应宽度，压缩到0.5倍封顶" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    alertController.messageColor = [UIColor redColor];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"明白" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了明白");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"我的文字太长了，所以垂直排列显示更多文字，垂直后依然显示不全则压缩字体，压缩到0.5倍封顶" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了'上九天揽月，下五洋捉鳖'");
    }];
    action2.titleColor = SYSTEM_BLUE_COLOR;

    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例25:action上的文字过长（水平）
- (void)specialtest5 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"提示" message:@"SPAlertControllerStyleAlert样式下2个按钮默认是水平排列，如果存在按钮文字过长，则自动会切换为垂直排列，本例之所以为水平排列，是因为外界设置了'actionAxis'为UILayoutConstraintAxisHorizontal。" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    alertController.messageColor = [UIColor redColor];
    
    // 强制水平排列
    alertController.actionAxis = UILayoutConstraintAxisHorizontal;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"明白" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了明白");
    }];
    
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"我的文字太长了，会压缩字体" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了'我的文字太长了，会压缩字体'");
    }];
    action2.titleColor = SYSTEM_BLUE_COLOR;
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ========================================== 背景毛玻璃示例 =======================================================

// 示例26:背景外观样式
- (void)backgroundAppearanceStyleTest:(UIBlurEffectStyle)appearanceStyle {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromBottom];
    
    alertController.needDialogBlur = _lookBlur;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"Default" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Default");
    }];
    
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"Destructive" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Destructive");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"Cancel" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Cancel");
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [alertController setBackgroundViewAppearanceStyle:appearanceStyle alpha:1];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark - 文本输入框的代理方法

- (void)textFieldDidChanged:(UITextField *)textField {
    
    if (_phoneNumberTextField.text.length && _passwordTextField.text.length) {
        self.sureAction.enabled = YES;
    } else {
        self.sureAction.enabled = NO;
    }
}

- (void)cancelButtonInCustomHeaderViewClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - SPAlertControllerDelegate

- (void)willPresentAlertController:(SPAlertController *)alertController {
    
}

- (void)didPresentAlertController:(SPAlertController *)alertController {
    
}

- (void)willDismissAlertController:(SPAlertController *)alertController {
    
}

- (void)didDismissAlertController:(SPAlertController *)alertController {
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupNavi];
    dic = [NSMutableDictionary dictionaryWithCapacity:2];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
    
    self.titles = @[@"actionSheet样式",@"alert样式",@"富文本",@"自定义视图",@"特殊情况",@"背景毛玻璃"];
    self.dataSource = @[
                        @[@"actionSheet样式 默认动画(从底部弹出,有取消按钮)",@"actionSheet样式 默认动画(从底部弹出,无取消按钮)",@"actionSheet样式 从顶部弹出(无标题)",@"actionSheet样式 从顶部弹出(有标题)",@"actionSheet样式 水平排列（有取消样式按钮）",@"actionSheet样式 水平排列（无取消样式按钮)",@"actionSheet样式 action含图标",@"actionSheet样式 模拟多分区样式(>=iOS11才支持)", @"点击action不dismiss"],
                        @[@"alert样式 默认动画(收缩动画)",@"alert样式 发散动画",@"alert样式 渐变动画",@"alert样式 垂直排列2个按钮",@"alert样式 水平排列2个以上的按钮",@"alert样式 设置头部图标",@"alert样式 含有文本输入框"],
                        @[@"富文本(action设置富文本)",@"富文本(头部设置富文本)"],
                        @[@"自定义头部(xib)",@"插入一个组件1",@"插入一个组件2"],
                        @[@"当按钮过多时，以scrollView滑动",@"当文字和按钮同时过多时,二者都可滑动",@"含有文本输入框，且文字过多",@"action上的文字过长（垂直）",@"action上的文字过长（水平）"],
                        @[@"背景毛玻璃Dark样式",@"背景毛玻璃ExtraLight样式",@"背景毛玻璃Light样式"]
                        ];
}

- (void)setupNavi {
    self.navigationItem.title = @"演示Demo";
    UIButton *changeBgButton = [UIButton buttonWithType:UIButtonTypeCustom];
    changeBgButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    [changeBgButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [changeBgButton setTitle:@"切换背景" forState:UIControlStateNormal];
    changeBgButton.titleLabel.font = [UIFont systemFontOfSize:12];
    changeBgButton.frame = CGRectMake(0, 0, 70, 25);
    changeBgButton.layer.cornerRadius = 5;
    changeBgButton.layer.masksToBounds = YES;
    [changeBgButton addTarget:self action:@selector(changeBackgroundImage:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:changeBgButton];
    
    UIButton *blurButton = [UIButton buttonWithType:UIButtonTypeCustom];
    blurButton.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    [blurButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [blurButton setTitle:@"打开毛玻璃" forState:UIControlStateNormal];
    [blurButton setTitle:@"关闭毛玻璃" forState:UIControlStateSelected];
    blurButton.titleLabel.font = [UIFont systemFontOfSize:12];
    blurButton.frame = CGRectMake(0, 0, 70, 25);
    blurButton.layer.cornerRadius = 5;
    blurButton.layer.masksToBounds = YES;
    [blurButton addTarget:self action:@selector(lookBlurAction:) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:blurButton];

}

- (void)changeBackgroundImage:(UIButton *)sender {
    if (!sender.selected) {
        NSInteger c = 1+(arc4random() % 2);
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"背景%li.jpg",(long)c]]];
        sender.backgroundColor = [UIColor orangeColor];
    } else {
        self.tableView.backgroundView = nil;
        sender.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    }
    _haveBg = !sender.selected;
    sender.selected = !sender.selected;
    [self.tableView reloadData];
}

- (void)lookBlurAction:(UIButton *)sender {
    _lookBlur = !sender.selected;
    if (!sender.selected) {
        sender.backgroundColor = [UIColor orangeColor];
        if (!_haveBg) {
            SPAlertController *alertVc = [SPAlertController alertControllerWithTitle:@"提示" message:@"切换背景看毛玻璃效果更明显哦！" preferredStyle:SPAlertControllerStyleAlert];
            SPAlertAction *action = [SPAlertAction actionWithTitle:@"知道了" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
                
            }];
            [alertVc addAction:action];
            [self presentViewController:alertVc animated:YES completion:nil];
        }
    } else {
        sender.backgroundColor = [UIColor colorWithRed:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1.0];
    }
    sender.selected = !sender.selected;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger index = [[dic valueForKey:[NSString stringWithFormat:@"%ld",(long)section]] integerValue];
    if (index == 1) {
        return 0;
    } else {
        return [self.dataSource[section] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"alertControllerTestCell" forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.adjustsFontSizeToFitWidth = YES;
    cell.textLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
    if (_haveBg) {
        cell.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor blackColor];
    } else {
        cell.textLabel.textColor = [UIColor colorPairsWithLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]];
    }
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {

    static NSString *headerID = @"header";
    UITableViewHeaderFooterView *header = [tableView dequeueReusableHeaderFooterViewWithIdentifier:headerID];
    if (header == nil) {
        header = [[UITableViewHeaderFooterView alloc] initWithReuseIdentifier:headerID];
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.font = [UIFont boldSystemFontOfSize:16];
        titleLabel.userInteractionEnabled = YES;
        titleLabel.tag = 200;
        [header.contentView addSubview:titleLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [header addGestureRecognizer:tap];
    }
    UILabel *titleLabel = [header viewWithTag:200];
    titleLabel.text = self.titles[section];
    header.tag = 100 + section;
    if (_haveBg)
    {
        titleLabel.textColor = [UIColor blackColor];
    }
    else
    {
        titleLabel.textColor = [UIColor colorPairsWithLightColor:[UIColor blackColor] darkColor:[UIColor whiteColor]];
    }
    return header;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)tap.view;
    NSInteger section = header.tag - 100;
    NSString *key = [NSString stringWithFormat:@"%ld",(long)section];
    if ([dic[key] integerValue] == 0) {
        [dic setValue:@(1) forKey:key];
    } else {
        [dic setValue:@(0) forKey:key];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    if (self.tableView.contentOffset.y < -NaviHeight) {
        [self.tableView setContentOffset:CGPointMake(0, -NaviHeight) animated:YES];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) { //  actionSheet样式区
            case 0:
                [self actionSheetTest1];
                break;
            case 1:
                [self actionSheetTest2];
                break;
            case 2:
                [self actionSheetTest3];
                break;
            case 3:
                [self actionSheetTest4];
                break;
            case 4:
                [self actionSheetTest5];
                break;
            case 5:
                [self actionSheetTest6];
                break;
            case 6:
                [self actionSheetTest7];
                break;
            case 7:
                [self actionSheetTest8];
                break;
            case 8:
                [self actionSheetTest9];
                break;
        }
    } else if (indexPath.section == 1) { //  alert样式区
        switch (indexPath.row) {
            case 0:
                [self alertTest1];
                break;
            case 1:
                [self alertTest2];
                break;
            case 2:
                [self alertTest3];
                break;
            case 3:
                [self alertTest4];
                break;
            case 4:
                [self alertTest5];
                break;
            case 5:
                [self alertTest6];
                break;
            case 6:
                [self alertTest7];
                break;
        }
    } else if (indexPath.section == 2) { // 富文本区
        switch (indexPath.row) {
            case 0:
                [self attributedStringTest1];
                break;
            case 1:
                [self attributedStringTest2];
                break;
        }
    } else if (indexPath.section == 3) { // 自定义区
        switch (indexPath.row) {
            case 0:
                [self customTest1];
                break;
            case 1:
                [self customTest2];
                break;
            case 2:
                [self customTest3];
                break;
        }
    } else if (indexPath.section == 4) { // 特殊情况区
        switch (indexPath.row) {
            case 0:
                [self specialtest1];
                break;
            case 1:
                [self specialtest2];
                break;
            case 2:
                [self specialtest3];
                break;
            case 3:
                [self specialtest4];
                break;
            case 4:
                [self specialtest5];
                break;
        }
    } else {
        switch (indexPath.row) { // 毛玻璃区
            case 0:
                [self backgroundAppearanceStyleTest:UIBlurEffectStyleDark];
                break;
            case 1:
                [self backgroundAppearanceStyleTest:UIBlurEffectStyleExtraLight];
                break;
            case 2:
                [self backgroundAppearanceStyleTest:UIBlurEffectStyleLight];
                break;
        }
    }
    
}

@end
