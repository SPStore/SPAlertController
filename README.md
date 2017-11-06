
# 目录
* [如何导入](#如何导入)
* [Gif演示图](#gif演示图)  
* [效果图](#效果图)
* [如何使用](#如何使用)

## 如何导入
##### 版本1.0.1
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 1.0.1'
end
```
##### 版本1.7.0
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 1.7.0'
end
```
然后在终端输入命令:pod install 

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
* 第一步：创建SPAlertController
```
SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleActionSheet animationType:SPAlertAnimationTypeDefault];

解释:
preferredStyle是提醒对话框的弹出样式，SPAlertControllerStyleActionSheet是从底部或者顶部弹出（顶部还是底部取决于animationType），SPAlertControllerStyleAlert从中间弹出，animationType是动画类型，有从底部往上弹出动画，从顶部往下弹出动画，从中间渐变弹出动画，缩放弹出动画等

```
* 第二步:创建action
```
SPAlertAction *actionOK = [SPAlertAction actionWithTitle:@"OK" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {
        
    }];
    
解释:
方法参数中的style是action的样式，这里跟系统的一致，共有SPAlertActionStyleDefault、SPAlertActionStyleCancel(取消)、SPAlertActionStyleDestructive(默认红色)这3种样式，跟系统不一样的是，SPAlertController可以自定义action的相关属性，如文本颜色、字体等;
block块:当点击action的时候回调
```
* 第三步:添加action
```
    [alertController addAction:actionOK];
```
* 第四步:modal出alertController
```
    [self presentViewController:alertController animated:YES completion:nil];
```
#### 以上这就是最基本的四步操作，当然你可以中间再设置alertController的属性或者action的属性，至于具体哪些属性干什么,示例程序中有非常详细的注释.

### 还可以做什么?
* 添加文本输入框
```
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        // 这个block只会回调一次，因此可以在这里自由定制textFiled，如设置textField的相关属性，设置代理，添加addTarget，监听通知等
    }];
```
* 自定义整个弹出视图
```
 MyView *myView = [MyView shareMyView];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha customView:myView];
    [self presentViewController:alertController animated:YES completion:nil];
    
    解释:
自定义整个弹出视图时,添加action或textField没有任何作用，因为已经自定义了整个视图，自带的内部布局将不起作用

```
如:
```
    MyView *myView = [MyView shareMyView];
    
    SPAlertController *alertController = [SPAlertController alertControllerWithTitle:@"这是大标题" message:@"这是小标题" preferredStyle:SPAlertControllerStyleAlert animationType:SPAlertAnimationTypeAlpha customView:myView];
    
    [self presentViewController:alertController animated:YES completion:nil];
```
        
[回到顶部](#目录) 
