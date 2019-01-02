//
//  ViewController.m
//  SPAlertController
//
//  Created by 乐升平 on 17/10/12.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "ViewController.h"
#import "SPAlertController.h"
#import "MyView.h"
#import "ShoppingCartView.h"
#import "CommodityListView.h"
#import "SendAlertView.h"
#import "MyCenterView.h"
#import "PopView.h"
#import "ScoreView.h"
#import "PickerView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height
#define StatusHeight ([UIScreen mainScreen].bounds.size.height >= 812 ? 44 : 20)

// RGB颜色
#define SPColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]
#define SYSTEM_COLOR [UIColor colorWithRed:0.0 green:0.48 blue:1.0 alpha:1.0]

// 随机色
#define SPRandomColor ZCColorRGBA(arc4random_uniform(256), arc4random_uniform(256), arc4random_uniform(256),1)

@interface ViewController () <UITableViewDelegate,UITableViewDataSource, PassWordViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSArray *titles;
@property (nonatomic, strong) NSArray *dataSource;
@property (nonatomic, strong) SPAlertAction *sureAction;
@property (nonatomic, strong) UITextField *phoneNumberTextField;
@property (nonatomic, strong) UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UIButton *changeButton;
@property (nonatomic, assign) BOOL lookBlur;
@property (nonatomic, weak) SPAlertController *alertController;
@end

@implementation ViewController {
    NSMutableDictionary *dic;
}

#pragma mark =============================== SPAlertControllerStyleActionSheet样式示例 ==============================================

// 示例1:actionSheet的默认动画样式(从底部弹出，有取消按钮)
- (void)actionSheetTest1 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"Default" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Default ");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"Destructive" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了Destructive");
    }];

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
    alertController.actionAxis = UILayoutConstraintAxisHorizontal;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
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
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
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
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"视频通话" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了‘视频通话’");
    }];
    action1.image = [UIImage imageNamed:@"video"];
    action1.imageTitleSpacing = 5;
    
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"语音通话" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了‘语音通话’");
    }];
    action2.image = [UIImage imageNamed:@"telephone"];
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
    action7.titleColor = SYSTEM_COLOR;
    // 注:在addAction之后设置action的文字颜色和字体同样有效
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    [alertController addAction:action6];
    [alertController addAction:action7];
    
    alertController.needDialogBlur = NO;

    if (@available(iOS 11.0, *)) {
        [alertController setCustomSpacing:6.0 afterAction:action2]; // 设置第2个action之后的间隙
    }
    if (@available(iOS 11.0, *)) {
        [alertController setCustomSpacing:6.0 afterAction:action4];  // 设置第4个action之后的间隙
    }
   
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark =============================== SPAlertControllerStyleAlert样式示例 ==============================================

// 示例9:alert 默认动画(收缩动画)
- (void)alertTest1 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    // 设置第2个action的颜色
    action2.titleColor = SYSTEM_COLOR;
    [alertController addAction:action2];
    [alertController addAction:action1];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例10:alert 发散动画
- (void)alertTest2 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeExpand];
    _alertController = alertController;
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的颜色
    action1.titleColor = SYSTEM_COLOR;
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

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // 设置第1个action的字体
    action1.titleColor = SYSTEM_COLOR;
    
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
    action2.titleColor = SYSTEM_COLOR;
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例13:alert 水平排列2个以上的按钮(默认超过2个按钮是垂直排列)
- (void)alertTest5 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert];
    
    // 2个按钮以上默认是垂直排列，这里强制设置水平排列
    alertController.actionAxis = UILayoutConstraintAxisHorizontal;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
    action1.titleColor = SYSTEM_COLOR;
    
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
    action.titleColor = SYSTEM_COLOR;
    [alertController addAction:action];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例15:alert 含有文本输入框
- (void)alertTest7 {

    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    action1.titleColor = [UIColor redColor];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"确定");
    }];
    action2.titleColor = SYSTEM_COLOR;
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
    NSString *num = @"18077887788";
    NSString *desc = @"可能是一个电话号码";
    NSString *totalTitle = [NSString stringWithFormat:@"%@%@",num,desc];
    NSMutableAttributedString *attrTitle = [[NSMutableAttributedString alloc] initWithString:totalTitle];
    [attrTitle addAttribute:NSForegroundColorAttributeName value:SYSTEM_COLOR range:[totalTitle rangeOfString:num]];
    alertController.attributedTitle = attrTitle;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    action2.titleColor = SYSTEM_COLOR;

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

// 示例19:自定义整个对话框(alert样式)
- (void)customTest2 {
    
    MyView *myView = [MyView shareMyView];
    myView.passwordView.delegate = self;
    [myView.cancelButton addTarget:self action:@selector(cancelButtonInCustomHeaderViewClicked) forControlEvents:UIControlEventTouchUpInside];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomAlertView:myView preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    alertController.offsetForAlert = CGPointMake(0, -100);
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例20:自定义整个对话框(actionSheet样式从底部弹出)
- (void)customTest3 {
    
    ShoppingCartView *shoppingCartView = [[ShoppingCartView alloc] init];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomAlertView:shoppingCartView preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromBottom];
    [alertController updateCustomViewSize:CGSizeMake(ScreenWidth, ScreenHeight*2/3)];
    alertController.needDialogBlur = NO;
    _alertController = alertController;
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例21:自定义整个对话框(actionSheet样式从右边弹出)
- (void)customTest4 {
    
    ShoppingCartView *shoppingCartView = [[ShoppingCartView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-70, ScreenHeight)];
    shoppingCartView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomAlertView:shoppingCartView preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromRight];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例22:自定义整个对话框(actionSheet样式从左边弹出)
- (void)customTest5 {
    
    ShoppingCartView *shoppingCartView = [[ShoppingCartView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-70, ScreenHeight)];
    shoppingCartView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomAlertView:shoppingCartView preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromLeft];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例23:自定义整个对话框(actionSheet样式从顶部弹出)
- (void)customTest6 {
    CommodityListView *commodityListView = [[CommodityListView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    commodityListView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomAlertView:commodityListView preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromTop];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例24:自定义整个对话框(pickerView)
- (void)customTest7 {
    PickerView *pickerView = [[PickerView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 240)];
    pickerView.backgroundColor = [UIColor whiteColor];
    pickerView.cancelClickedBlock = ^{
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    };
    pickerView.doneClickedBlock = ^{
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    };
    
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomAlertView:pickerView preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromBottom];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例25:自定义action部分
- (void)customTest8 {
    // scoreview的子控件采用的是自动布局，由于高度上能够由子控件撑起来，所以高度可以给0，如果宽度也能撑起，宽度也可以给0
    ScoreView *scoreView = [[ScoreView alloc] initWithFrame:CGRectMake(0, 0, 275, 0)];
    scoreView.finishButtonBlock = ^{
        [self.presentedViewController dismissViewControllerAnimated:YES completion:nil];
    };
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomActionSequenceView:scoreView title:@"提示" message:@"请给我们的app打分" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    alertController.needDialogBlur = NO;
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例26:插入一个组件
- (void)customTest9 {
    MyCenterView *centerView = [[MyCenterView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-40, 200)];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    
    // 插入一个view
    [alertController insertComponentView:centerView];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的颜色
    action1.titleColor = SYSTEM_COLOR;
    
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

// 示例27:自定义整个对话框(全屏)
- (void)customTest10 {
    NSArray *titles = @[@"文字", @"图片", @"视频", @"语音", @"投票", @"签到", @"点赞",@"笔记",@"导航",@"收藏",@"下载",@"更多"];
    NSMutableArray *imgs = [NSMutableArray arrayWithCapacity:titles.count];
    for (NSInteger i = 0; i < titles.count; i ++) {
        [imgs addObject:[NSString stringWithFormat:@"publish_%zi", i]];
    }
    PopView *popView = [[PopView alloc] initWithImages:imgs titles:titles clickedButtonBlock:^(NSInteger index) {
        NSLog(@"点击了----%zi",index);
    } cancelBlock:^(PopView *popView) {
        [popView close];
        // 不要等到所有动画结束之后再dismiss，那样感觉太生硬
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        });
    }];
    popView.tapBackgroundBlock = ^(PopView *popView) {
        [popView close];
        // 不要等到所有动画结束之后再dismiss，那样感觉太生硬
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.presentedViewController dismissViewControllerAnimated:NO completion:nil];
        });
    };
    
    // 这里也可以用actionSheet样式
    SPAlertController *alertController = [SPAlertController alertControllerWithCustomAlertView:popView preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeNone];
    alertController.minDistanceToEdges = 0; // 要想自定义view全屏，该属性必须为0，否则四周会有间距
    alertController.needDialogBlur = NO; // 去除对话框的毛玻璃
    alertController.cornerRadiusForAlert = 0; // 去除圆角半径
    // 设置背景遮罩为毛玻璃样式
    [alertController setBackgroundViewAppearanceStyle:SPBackgroundViewAppearanceStyleBlurExtraLight alpha:1.0];
    [self presentViewController:alertController animated:NO completion:^{
        // 执行popView的弹出动画
        [popView open];
    }];
}

#pragma mark ========================================== 特殊情况示例 =======================================================

// 示例28:当按钮过多时
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

// 示例29:当文字和按钮同时过多时，文字占据更多位置
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

// 示例30:含有文本输入框，且文字过多,默认会滑动到第一个文本输入框的位置
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

// 示例31:action上的文字过长（垂直）
- (void)specialtest4 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"提示" message:@"SPAlertControllerStyleAlert样式下2个按钮默认是水平排列，如果存在按钮文字过长，则自动会切换为垂直排列，除非外界设置了'actionAxis'。如果垂直排列后文字依然过长，则会压缩字体适应宽度，压缩到0.5倍封顶" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    alertController.messageColor = [UIColor redColor];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"明白" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了明白");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"我的文字太长了，所以垂直排列显示更多文字，垂直后依然显示不全则压缩字体，压缩到0.5倍封顶" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了'上九天揽月，下五洋捉鳖'");
    }];
    action2.titleColor = SYSTEM_COLOR;

    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例32:action上的文字过长（水平）
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
    action2.titleColor = SYSTEM_COLOR;
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

#pragma mark ========================================== 毛玻璃示例 =======================================================

// 示例33:去除对话框的毛玻璃(默认0.5透明)
- (void)dialogRemoveBlurTest1 {
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet];
    
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
    
    // 设置对话框不需要毛玻璃
    alertController.needDialogBlur = NO;
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例34:背景外观样式
- (void)backgroundAppearanceStyleTest2:(SPBackgroundViewAppearanceStyle)appearanceStyle {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromBottom];
    
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
    
    if (appearanceStyle == SPBackgroundViewAppearanceStyleTranslucent) {
        // 0.5是半透明(默认),设置1为不透明,0为全透明
        [alertController setBackgroundViewAppearanceStyle:appearanceStyle alpha:0.5];
    } else {
        [alertController setBackgroundViewAppearanceStyle:appearanceStyle alpha:1];
    }
    
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

#pragma mark - PassWordViewDelegate(密码输入框的代理方法)

// 监听开始输入
- (void)passWordBeginInput:(PassWordView *)passWord {
    NSLog(@"密码开始输入");
}

// 监听输入的改变
- (void)passWordDidChange:(PassWordView *)passWord {
    NSLog(@"当前已输入：%@",passWord.textStore);
}

// 监听输入的完成时
- (void)passWordCompleteInput:(PassWordView *)passWord {
    NSLog(@"密码输入完成");
    [self dismissViewControllerAnimated:YES completion:^{
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            SPAlertController *alertVc = [SPAlertController alertControllerWithTitle:@"支付成功" message:nil preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeFade];
            // 头部图标
            alertVc.image = [UIImage imageNamed:@"success"];
            [self presentViewController:alertVc animated:YES completion:^{
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.7 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [self dismissViewControllerAnimated:YES completion:nil];
                });
            }];
        });

    }];
}

- (void)cancelButtonInCustomHeaderViewClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 切换背景
- (IBAction)changeBackgroundImage:(UIButton *)sender {
    if (!sender.selected) {
        NSInteger c = 1+(arc4random() % 2);
        self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"背景%li.jpg",c]]];
    } else {
        self.tableView.backgroundView = nil;
    }
    _lookBlur = !sender.selected;
    sender.selected = !sender.selected;
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dic = [NSMutableDictionary dictionaryWithCapacity:2];
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
    
    self.titles = @[@"ActionSheet样式",@"Alert样式",@"富文本",@"自定义视图",@"特殊情况",@"毛玻璃"];
    self.dataSource = @[
                        @[@"actionSheet样式 默认动画(从底部弹出,有取消按钮)",@"actionSheet样式 默认动画(从底部弹出,无取消按钮)",@"actionSheet样式 从顶部弹出(无标题)",@"actionSheet样式 从顶部弹出(有标题)",@"actionSheet样式 水平排列（有取消样式按钮）",@"actionSheet样式 水平排列（无取消样式按钮)",@"actionSheet样式 action含图标",@"actionSheet样式 模拟多分区样式(>=iOS11才支持)"
                          ],
                        @[@"alert样式 默认动画(收缩动画)",@"alert样式 发散动画",@"alert样式 渐变动画",@"alert样式 垂直排列2个按钮",@"alert样式 水平排列2个以上的按钮",@"alert样式 设置头部图标",@"alert样式 含有文本输入框"
                          ],
                        @[@"富文本(action设置富文本)",@"富文本(头部设置富文本)"
                          ],
                        @[@"自定义头部(xib)",@"自定义整个对话框(alert样式)",@"自定义整个对话框(actionSheet样式(底))",@"自定义整个对话框(actionSheet样式(右)）",@"自定义整个对话框(actionSheet样式(左)）",@"自定义整个对话框(actionSheet样式(顶))",@"自定义整个对话框(pickerView)",@"自定义action部分",@"插入一个组件",@"自定义整个对话框(全屏)"
                          ],
                        @[@"当按钮过多时，以scrollView滑动",@"当文字和按钮同时过多时,二者都可滑动",@"含有文本输入框，且文字过多",@"action上的文字过长（垂直）",@"action上的文字过长（水平）"
                          ],
                        @[@"去除对话框的毛玻璃",@"透明黑色背景样式(背景无毛玻璃,默认)",@"背景毛玻璃Dark样式",@"背景毛玻璃ExtraLight样式",@"背景毛玻璃Light样式"
                          ]
                        ];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger index = [[dic valueForKey:[NSString stringWithFormat:@"%ld",section]] integerValue];
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
    if (_lookBlur) {
        cell.backgroundColor = [UIColor clearColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
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
        titleLabel.font = [UIFont boldSystemFontOfSize:18];
        titleLabel.userInteractionEnabled = YES;
        titleLabel.tag = 200;
        [header.contentView addSubview:titleLabel];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [header addGestureRecognizer:tap];
    }
    UILabel *titleLabel = [header viewWithTag:200];
    titleLabel.text = self.titles[section];
    header.tag = 100 + section;
    return header;
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    
    UITableViewHeaderFooterView *header = (UITableViewHeaderFooterView *)tap.view;
    NSInteger section = header.tag - 100;
    NSString *key = [NSString stringWithFormat:@"%ld",section];
    if ([dic[key] integerValue] == 0) {
        [dic setValue:@(1) forKey:key];
    } else {
        [dic setValue:@(0) forKey:key];
    }
    [self.tableView reloadSections:[NSIndexSet indexSetWithIndex:section] withRowAnimation:UITableViewRowAnimationFade];
    if (self.tableView.contentOffset.y < -StatusHeight) {
        [self.tableView setContentOffset:CGPointMake(0, -StatusHeight) animated:YES];
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
            case 3:
                [self customTest4];
                break;
            case 4:
                [self customTest5];
                break;
            case 5:
                [self customTest6];
                break;
            case 6:
                [self customTest7];
                break;
            case 7:
                [self customTest8];
                break;
            case 8:
                [self customTest9];
                break;
            case 9:
                [self customTest10];
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
                [self dialogRemoveBlurTest1];
                break;
            case 1:
                [self backgroundAppearanceStyleTest2:SPBackgroundViewAppearanceStyleTranslucent];
                break;
            case 2:
                [self backgroundAppearanceStyleTest2:SPBackgroundViewAppearanceStyleBlurDark];
                break;
            case 3:
                [self backgroundAppearanceStyleTest2:SPBackgroundViewAppearanceStyleBlurExtraLight];
                break;
            case 4:
                [self backgroundAppearanceStyleTest2:SPBackgroundViewAppearanceStyleBlurLight];
                break;
        }
    }
    
}

@end
