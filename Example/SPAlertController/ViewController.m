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
#import "MyHeaderView.h"
#import "MyCenterView.h"
#import "MyFooterView.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

// RGB颜色
#define SPColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

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
@end

@implementation ViewController

#pragma mark ---------------------------- 示例方法 -------------------------------

// 示例1:actionSheet的默认动画样式(从底部弹出)
- (void)actionSheetTest1 {
    // actionSheet中，SPAlertAnimationTypeDefault 等价于 SPAlertAnimationTypeRaiseUp
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    //alertController.needDialogBlur = NO;
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

    [alertController addAction:action3]; // 注意第3个按钮是第2个添加，但是最终会显示在最底部，因为第四个按钮是取消按钮，只要是取消按钮，一定会在最底端，其余按钮按照添加顺序依次排布
    [alertController addAction:action2];

    [self presentViewController:alertController animated:YES completion:nil];
    
}

// 示例2:actionSheet从顶部弹出
- (void)actionSheetTest2 {
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

// 示例3:actionSheet没有取消按钮
- (void)actionSheetTest3 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    
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
    // 注:在addAction之后设置action的文字颜色和字体同样有效
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例4:actionSheet有多个取消按钮,取消样式的按钮显示全部在底部显示,最多只能显示5个取消样式的按钮,超过强制崩溃
- (void)actionSheetTest4 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"取消1" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消1");
    }];
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"取消2" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消2");
    }];
    SPAlertAction *action5 = [SPAlertAction actionWithTitle:@"取消3" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消3");
    }];
    // 注:在addAction之后设置action的文字颜色和字体同样有效
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例5:actionSheet无标题
- (void)actionSheetTest5 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:nil message:nil preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    
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
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"第4个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第4个");
    }];
    action4.titleColor = [UIColor magentaColor];
    SPAlertAction *action5 = [SPAlertAction actionWithTitle:@"第5个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第5个");
    }];
    action5.titleColor = [UIColor orangeColor];
    SPAlertAction *action6 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];

    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    [alertController addAction:action6];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例6:alert 默认样式(alpha渐变)
- (void)alertTest6 {
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // 设置第1个action的颜色
    action1.titleColor = [UIColor blueColor];
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];

    // 设置第2个action的颜色
    action2.titleColor = [UIColor redColor];
    [alertController addAction:action1];
    [alertController addAction:action2];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例7:alert 从小变大动画
- (void)alertTest7 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeExpand];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的颜色
    action1.titleColor = [UIColor blueColor];
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点点击了第2个");
    }];
    
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点点击了第3个");
    }];
    action3.titleColor = SPColorRGBA(30, 170, 40, 1);
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例8:alert从小大变小动画
- (void)alertTest8 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // 设置第1个action的字体
    action1.titleColor = [UIColor blueColor];
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    action2.titleColor = [UIColor redColor];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例9:alert 没有action
- (void)alertTest9 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha];
    [self presentViewController:alertController animated:YES completion:nil];
}


// 示例10:alert 只有一个按钮
- (void)alertTest10 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeExpand];
    
    alertController.titleFont = [UIFont systemFontOfSize:40];
    alertController.messageFont = [UIFont systemFontOfSize:12];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // 设置第1个action的颜色
    action1.titleColor = SPColorRGBA(30, 170, 40, 1);
    [alertController addAction:action1];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例11:alert 垂直排列2个按钮（2个按钮默认是水平排列）
- (void)alertTest11 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeExpand];
    
    // 2个按钮时默认是水平排列，想让2个按钮垂直排列，限制水平排列的最大个数
    alertController.maxNumberOfActionHorizontalArrangementForAlert = 1;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了确定");
    }];
    // 设置第1个action的颜色
    action1.titleColor = [UIColor redColor];
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    action2.titleColor = [UIColor blueColor];
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例12:alert 水平排列2个以上的按钮(默认超过2个按钮是垂直排列)
- (void)alertTest12 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];

    // 默认超过2个按钮就垂直排列，想要超过2个按钮依然水平排列，修改水平排列的最大个数，只要没超过这个最大数，一律水平排列
    alertController.maxNumberOfActionHorizontalArrangementForAlert = 3;
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
    action1.titleColor = [UIColor blueColor];
    
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

// 示例13:alert 无标题
- (void)alertTest13 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:nil message:nil preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"点一下" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点一下");
    }];
    action1.titleColor = [UIColor blueColor];
    [alertController addAction:action1];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例14:alert 含有文本输入框
- (void)alertTest14 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"取消");
    }];
    action1.titleColor = [UIColor redColor];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"确定" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"确定");
    }];
    action2.titleColor = [UIColor blueColor];
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

// 示例15:自定义整个对话框(alert样式)
- (void)customTest15 {
    
    MyView *myView = [MyView shareMyView];
    myView.passwordView.delegate = self;
    [myView.cancelButton addTarget:self action:@selector(cancelButtonInCustomHeaderViewClicked) forControlEvents:UIControlEventTouchUpInside];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha customView:myView];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例16:自定义整个对话框(actionSheet样式从底部弹出)
- (void)customTest16 {
    
    ShoppingCartView *shoppingCartView = [[ShoppingCartView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, ScreenHeight*2/3)];
    [shoppingCartView hideTopView];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromBottom customView:shoppingCartView];
    alertController.needDialogBlur = NO;
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例17:自定义整个对话框(actionSheet样式从右边弹出)
- (void)customTest17 {
    
    ShoppingCartView *shoppingCartView = [[ShoppingCartView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-70, ScreenHeight)];
    shoppingCartView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromRight customView:shoppingCartView];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例18:自定义整个对话框(actionSheet样式从左边弹出)
- (void)customTest18 {
    
    ShoppingCartView *shoppingCartView = [[ShoppingCartView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-70, ScreenHeight)];
    shoppingCartView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromLeft customView:shoppingCartView];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例19:自定义整个对话框(actionSheet样式从顶部弹出)
- (void)customTest19 {
    CommodityListView *commodityListView = [[CommodityListView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth, 200)];
    commodityListView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeFromTop customView:commodityListView];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例20:自定义headerView
- (void)customTest20 {
    MyHeaderView *myHeaderView = [[MyHeaderView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    SPAlertController *alertController = [SPAlertController alertControllerWithPreferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault customHeaderView:myHeaderView];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的颜色
    action1.titleColor = [UIColor blueColor];
    
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

// 示例21:自定义中间的view，这种自定义下:如果是SPAlertControllerStyleAlert样式，action个数不能大于maxNumberOfActionHorizontalArrangementForAlert,超过maxNumberOfActionHorizontalArrangementForAlert的action将不显示,如果是SPAlertControllerStyleActionSheet样式,action必须为取消样式才会显示
- (void)customTest21 {
    MyCenterView *centerView = [[MyCenterView alloc] initWithFrame:CGRectMake(0, 0, ScreenWidth-40, 200)];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault customCenterView:centerView];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的颜色
    action1.titleColor = [UIColor blueColor];
    
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

// 示例22:自定义footerView
// 宽度如果设置为0，内部自动会把宽度等宽于对话框
- (void)customTest22 {
    MyFooterView *footerView = [MyFooterView shareMyFooterView];
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"苹果logo" message:nil preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault customFooterView:footerView];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"我是一个按钮" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了 我是一个按钮");
    }];
    [alertController addAction:action2];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例23:当按钮过多时
- (void)specialtest23 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"请滑动查看更多内容" message:@"谢谢" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    alertController.maxTopMarginForActionSheet = 100;
    
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
        NSLog(@"点击了第8个");
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

// 示例24:当文字和按钮同时过多时，文字占据更多位置
- (void)specialtest24 {
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

// 示例25:含有文本输入框，且文字过多,默认会滑动到第一个文本输入框的位置
- (void)specialtest25 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"请滑动查看更多内容" message:@"谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    
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

// 示例26:去除对话框的毛玻璃(默认0.5透明)
- (void)dialogRemoveBlurTest26 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    
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

// 示例27:背景外观样式
- (void)backgroundAppearanceStyleTest27:(SPBackgroundViewAppearanceStyle)appearanceStyle {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    
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
    [self dismissViewControllerAnimated:YES completion:nil];
    
    MyHeaderView *headerView = [[MyHeaderView alloc] initWithFrame:CGRectMake(0, 0, 0, ScreenWidth-150)];
    headerView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertVc = [SPAlertController alertControllerWithPreferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha customHeaderView:headerView];
    alertVc.maxMarginForAlert = 75;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self presentViewController:alertVc animated:YES completion:nil];
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:nil];
    });
}

- (void)cancelButtonInCustomHeaderViewClicked {
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 切换背景
- (IBAction)changeBackgroundImage:(UIButton *)sender {
    if (!sender.selected) {
        
        NSInteger c = 1+(arc4random() % 4);
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
    
    self.tableView.tableHeaderView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, CGFLOAT_MIN)];
    self.tableView.sectionFooterHeight = CGFLOAT_MIN;
    
    self.titles = @[@"ActionSheet样式",@"Alert样式",@"自定义视图",@"特殊情况",@"毛玻璃"];
    self.dataSource = @[@[@"actionSheet样式 默认动画(从底部弹出)",@"actionSheet样式从顶部弹出",@"actionSheet样式 没有取消样式按钮",@"actionSheet样式 有多个取消样式按钮",@"actionSheet样式 无标题"],@[@"alert样式 默认动画(alpha渐变)",@"alert样式 从小变大动画",@"alert样式 从大变小动画",@"alert样式 没有按钮",@"alert样式 有一个按钮",@"alert样式 垂直排列2个按钮",@"alert样式 水平排列2个以上的按钮",@"alert样式 无标题",@"alert样式 含有文本输入框"],@[@"自定义整个对话框(alert样式)",@"自定义整个对话框(actionSheet样式(底)）",@"自定义整个对话框(actionSheet样式(右)）",@"自定义整个对话框(actionSheet样式(左)）",@"自定义整个对话框(actionSheet样式(顶))",@"自定义headerView",@"自定义centerView",@"自定义footerView"],@[@"当按钮过多时，以scrollView滑动",@"当文字和按钮同时过多时,二者都可滑动",@"含有文本输入框，且文字过多"],@[@"去除对话框的毛玻璃",@"透明黑色背景样式(背景无毛玻璃,默认)",@"背景毛玻璃Dark样式",@"背景毛玻璃ExtraLight样式",@"背景毛玻璃Light样式"]];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.dataSource.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.dataSource[section] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    if (_lookBlur) {
        cell.backgroundColor = [UIColor clearColor];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }
    cell.textLabel.text = self.dataSource[indexPath.section][indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont boldSystemFontOfSize:18];
    label.text = self.titles[section];
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.section == 0) {
        switch (indexPath.row) {
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
            default:
                break;
        }
    } else if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:
                [self alertTest6];
                break;
            case 1:
                [self alertTest7];
                break;
            case 2:
                [self alertTest8];
                break;
            case 3:
                [self alertTest9];
                break;
            case 4:
                [self alertTest10];
                break;
            case 5:
                [self alertTest11];
                break;
            case 6:
                [self alertTest12];
                break;
            case 7:
                [self alertTest13];
                break;
            case 8:
                [self alertTest14];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 2) {
        switch (indexPath.row) {
            case 0:
                [self customTest15];
                break;
            case 1:
                [self customTest16];
                break;
            case 2:
                [self customTest17];
                break;
            case 3:
                [self customTest18];
                break;
            case 4:
                [self customTest19];
                break;
            case 5:
                [self customTest20];
                break;
            case 6:
                [self customTest21];
                break;
            case 7:
                [self customTest22];
                break;
            default:
                break;
        }
    } else if (indexPath.section == 3) {
        switch (indexPath.row) {
            case 0:
                [self specialtest23];
                break;
            case 1:
                [self specialtest24];
                break;
            case 2:
                [self specialtest25];
                break;
            default:
                break;
        }
    } else {
        switch (indexPath.row) {
            case 0:
                [self dialogRemoveBlurTest26];
                break;
            case 1:
                [self backgroundAppearanceStyleTest27:SPBackgroundViewAppearanceStyleTranslucent];
                break;
            case 2:
                [self backgroundAppearanceStyleTest27:SPBackgroundViewAppearanceStyleBlurDark];
                break;
            case 3:
                [self backgroundAppearanceStyleTest27:SPBackgroundViewAppearanceStyleBlurExtraLight];
                break;
            case 4:
                [self backgroundAppearanceStyleTest27:SPBackgroundViewAppearanceStyleBlurLight];
                break;
        }
    }
    
}

@end
