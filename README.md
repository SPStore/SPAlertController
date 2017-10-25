
# 目录
* [如何导入](#如何导入)
* [Gif演示图](#gif演示图)  
* [效果图](#效果图)
* [如何使用](#如何使用)

## 如何导入
##### 版本1.0
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 1.0'
end
然后在终端输入命令:pod install 
```
## Gif演示图
（友情提示：如果您的网络较慢，gif图可能会延迟加载，您可以先把宝贵的时间浏览其它信息）

<br>![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/SPAlertController.gif)
## 效果图
###### 1.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3006981-565e263954a40e50.jpg)
###### 2.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3006981-6986ab0f6619715d.jpg)
###### 3.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3006981-9f2f51972e69c502.jpg)
###### 4.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3006981-67e8ea700d3711ad.jpg)
###### 5.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3006981-dc96f2f9e50f6ba8.jpg)
###### 6.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3006981-58b49fe452c435c8.jpg)
###### 7.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/6D8ADCBCD9BA9CD455B48711CCBB88E6.jpg)
###### 8.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3006981-3974cfeac8a9016b.jpg)
###### 9.
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3006981-d77afa589120fca6.jpg)

## 如何使用
* 如果你想提醒对话框从底部或顶部弹出，请选用SPAlertControllerStyleActionSheet样式，如:
```
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
```
* 如果你想提醒对话框从屏幕中间弹出，请选用SPAlertControllerStyleAlert样式，如:
```
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
```
* 添加文本输入框
```
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        // 这个block只会回调一次，因此可以在这里自由定制textFiled，如设置textField的相关属性，设置代理，添加addTarget，监听通知等
    }];
```
* 如果你想自定义，在提醒对话框中有不一样的布局，那么你可以使用下面这个方法
```
// customView就是你的自定义view
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(nullable UIView *)customView;

```
如:
```
    MyView *myView = [MyView shareMyView];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha customView:myView];
    
    [self presentViewController:alertController animated:YES completion:nil];
```
        
［回到顶部］(#目录)
