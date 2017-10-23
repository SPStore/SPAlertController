![image]（https://github.com/SPStore/SPAlertController/blob/master/PreImages/1B7F5689700861D3D6E3A8511A02E443.jpg）
## 18种示例
```
// 示例1:actionSheet的默认样式
- (void)actionSheetTest1 {
    // actionSheet中，SPAlertAnimationTypeDefault 等价于 SPAlertAnimationTypeRaiseUp
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第取消");
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action4]; // 注意第4个按钮是第二次添加，但是最终会显示在最底部，因为第四个按钮是取消按钮，只要是取消按钮，一定会在最底端，其余按钮按照添加顺序依次排布
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例2:actionSheet从底部弹出，这也是默认样式
- (void)actionSheetTest2 {
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:nil preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeRaiseUp];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第取消");
    }];
    
    [alertController addAction:action1];
    [alertController addAction:action4]; // 注意第4个按钮是第二次添加，但是最终会显示在最底部，因为第四个按钮是取消按钮，只要是取消按钮，一定会在最底端，其余按钮按照添加顺序依次排布
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例3:actionSheet“从天而降”
- (void)actionSheetTest3 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:nil message:nil preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDropDown];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}


// 示例4:actionSheet设置字体和颜色
- (void)actionSheetTest4 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    // 设置大标题颜色
    alertController.titleColor = [UIColor redColor];
    // 设置大标题字体
    alertController.titleFont = [UIFont systemFontOfSize:50];
    // 设置小标题颜色
    alertController.messageColor = [UIColor blueColor];
    // 设置小标题字体
    alertController.messageFont = [UIFont systemFontOfSize:13];

    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    // 设置第2个action的字体
    action2.titleFont = [UIFont systemFontOfSize:11];
    // 设置第2个action的文字颜色
    action2.titleColor = [UIColor orangeColor];
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    // 设置第3个action的字体
    action3.titleFont = [UIFont systemFontOfSize:16];
    
    SPAlertAction *action4 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了取消");
    }];
    // 设置第4个action的字体
    action4.titleFont = [UIFont systemFontOfSize:40];
    // 设置第4个action的文字颜色
    action4.titleColor = [UIColor redColor];
    
    // 注:在addAction之后设置action的文字颜色和字体同样有效
    
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    
    action1.titleFont = [UIFont systemFontOfSize:11];

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例5:alert默认样式
- (void)alertTest5 {
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];

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

// 示例6:alert的alpha渐变动画，这也是默认样式
- (void)alertTest6 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
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

// 示例7:alert从小变大动画
- (void)alertTest7 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeExpand];
    
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

// 示例8:alert从小大变小动画
- (void)alertTest8 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
    action1.titleColor = [UIColor blueColor];
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例9:alert样式没有action
- (void)alertTest9 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例10:alert样式只有1个按钮
- (void)alertTest10 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"OK" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了OK");
    }];
    action1.titleColor = [UIColor blueColor];
    [alertController addAction:action1];
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例11:alert样式下按钮大于2个，垂直排布
- (void)alertTest11 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
    action1.titleColor = [UIColor blueColor];
    
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"第2个" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第2个");
    }];
    // SPAlertActionStyleDestructive默认文字为红色(可修改)
    SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"第3个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第3个");
    }];
    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例12:alert样式含有文本输入框
- (void)alertTest12 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeShrink];
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
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
        NSLog(@"第1个本本输入框回调");
        // 这个block只会回调一次，因此可以在这里自由定制textFiled，如设置textField的相关属性，设置代理，添加addTarget，监听通知等
        textField.placeholder = @"请输入手机号码";
    }];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSLog(@"第2个文本输入框回调");
        textField.placeholder = @"请输入密码";
        [textField addTarget:self action:@selector(textFieldDidChanged:) forControlEvents:UIControlEventEditingChanged];
    }];
    [self presentViewController:alertController animated:YES completion:nil];
}

- (void)textFieldDidChanged:(UITextField *)textField {

    if (textField.text.length) {
        self.sureAction.enabled = YES;
    } else {
        self.sureAction.enabled = NO;
    }
}

// 示例13:自定义视图
- (void)customTest13 {
    
    MyView *myView = [MyView shareMyView];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha customView:myView];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例14:自定义视图
- (void)customTest14 {
    
    ShoppingCartView *shoppingCartView = [[ShoppingCartView alloc] initWithFrame:CGRectMake(0, 0, 0, 300)];
    shoppingCartView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeRaiseUp customView:shoppingCartView];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例15:自定义视图
- (void)customTest15 {
    CommodityListView *commodityListView = [[CommodityListView alloc] initWithFrame:CGRectMake(0, 0, 0, 200)];
    commodityListView.backgroundColor = [UIColor whiteColor];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDropDown customView:commodityListView];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例16:当按钮过多时
- (void)test16 {
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
    SPAlertAction *action15 = [SPAlertAction actionWithTitle:@"取消" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {
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

    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例17:当文字和按钮同时过多时，文字占据更多位置
- (void)test17 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"请滑动查看更多内容" message:@"谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
    action1.titleColor = [UIColor blueColor];
    
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

    SPAlertAction *action6 = [SPAlertAction actionWithTitle:@"第6个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第6个");
    }];

    [alertController addAction:action1];
    [alertController addAction:action2];
    [alertController addAction:action3];
    [alertController addAction:action4];
    [alertController addAction:action5];
    [alertController addAction:action6];
    
    [self presentViewController:alertController animated:YES completion:nil];
}

// 示例18:含有文本输入框，且文字过多
- (void)test18 {
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"请滑动查看更多内容" message:@"谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢谢" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeDefault];
    
    SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"第1个" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        NSLog(@"点击了第1个");
    }];
    // 设置第1个action的字体
    action1.titleColor = [UIColor blueColor];
    
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
```
