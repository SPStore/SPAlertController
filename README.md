
# 3.0版本有极大的优化，由于采用了iOS9之后推出的UIStackView，因此3.0版本只支持iOS9及iOS9以上的系统
# SPAlertController
[![Build Status](http://img.shields.io/travis/SPStore/SPAlertController.svg?style=flat)](https://travis-ci.org/SPStore/SPAlertController)
[![Pod Version](http://img.shields.io/cocoapods/v/SPAlertController.svg?style=flat)](http://cocoadocs.org/docsets/SPAlertController/)
[![Pod Platform](http://img.shields.io/cocoapods/p/SPAlertController.svg?style=flat)](http://cocoadocs.org/docsets/SPAlertController/)
![Language](https://img.shields.io/badge/language-Object--C-ff69b4.svg)
[![Pod License](http://img.shields.io/cocoapods/l/SPAlertController.svg?style=flat)](https://www.apache.org/licenses/LICENSE-2.0.html)
[![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/SPStore/SPAlertController)
# 目录
* [CocoaPods](#CocoaPods) 
* [使用示例](#使用示例)
* [效果图](#效果图) 
* [历史版本](#历史版本)

## 功能特点
- [x] 采用VFL布局，3.0版本开始核心控件为UIStackView，不依赖任何其余框架，风格与微信几乎零误差
- [x] 3.0版本开始对话框头部新增图片设置
- [x] 3.0版本开始action支持图片设置
- [x] 3.0版本开始，iOS11及其以上系统可单独设置指定action后的间距
- [x] 3.0版本开始支持富文本
- [x] action的排列可灵活设置垂直排列和水平排列
- [x] 每个action的高度自适应
- [x] 支持旋转(横竖屏)
- [x] 可以自定义各种UIView
- [x] 支持对话框毛玻璃和背景蒙层毛玻璃
- [x] 全面适配iPhoneX，iPhoneXR，iPhoneXS，iPhoneXS MAX

## CocoaPods
##### 版本3.0.1
```
platform:ios,'9.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 3.0.1'
end

3.0.1版本使背景蒙层动画更加的柔和
```

## 使用示例
```
SPAlertController *alert = [SPAlertController alertControllerWithTitle:@"我是主标题" message:@"我是副标题" preferredStyle:SPAlertControllerStyleActionSheet];

SPAlertAction *action1 = [SPAlertAction actionWithTitle:@"Default" style:SPAlertActionStyleDefault handler:^(SPAlertAction * _Nonnull action) {}];
SPAlertAction *action2 = [SPAlertAction actionWithTitle:@"Destructive" style:SPAlertActionStyleDestructive handler:^(SPAlertAction * _Nonnull action) {}];
SPAlertAction *action3 = [SPAlertAction actionWithTitle:@"Cancel" style:SPAlertActionStyleCancel handler:^(SPAlertAction * _Nonnull action) {}];

[alert addAction:action1];
[alert addAction:action2];
[alert addAction:action3]; 
[self presentViewController: alert animated:YES completion:^{}];
```

## Topics
### 创建SPAlertController
```
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle;
```
```
+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType;
```
上面2种创建方式唯一的区别就是：第2种方式多了一个animationType参数，该参数可以设置弹出动画。如果以第一种方式创建，会采用默认动画，默认动画跟preferredStyle 有关，如果是SPAlertControllerStyleActionSheet样式，默认动画为从底部弹出，如果是SPAlertControllerStyleAlert样式，默认动画为从中间弹出

## 效果图
![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/F6C0259AFBAD7E5F651CB1FD41796DEF.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/06A97B9DBDE3F07D2207BAA2085D25C6.jpg)  

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/A76E51AC536052790CD80C184E803432.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/9C6F94D5ECF90CE6A94D90D507DB18EC.jpg)  

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/4DB2CAFA218FEE08E36578C94F2A5B71.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/03A721F9F6A4F39346134F7EEE49FA2E.jpg)

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3DB1CF20C14DFE9103B827F06BE5ACE5.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/1A20B204D250B3DBFE973A4EC0C5209F.jpg)  

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/57DDD7273486D292452471FAFDDC9F18.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/CDD1F2ADE694932980AB1509921FB628.jpg) 

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/EAEFB2EAA7932E456E7D85238E2C73C7.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/2DB32E8A0446B214C5EDC97998B127BA.jpg) 

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/19E17ECCD0C1A8CE7D0499CD8AF06A2F.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/30D02B422FC9CA27F5CBA37FF85BADE6.jpg)  

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/36186FEFDD89D2356EFEF140093A28A7.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/3E8019BA57F447785BD2561ECF95D234.jpg)

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/91B2F76B900C0EA9B5E34B8AE64CAB36.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/1776B8F36B3C3051C2C2FE3AE12D843F.jpg)

![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/1FE9B512B50D7E139B30E0BDB5B3FF6E.jpg)....................![image](https://github.com/SPStore/SPAlertController/blob/master/PreImages/86C4035CB7097B99FA89706E3668055E.jpg)


## 历史版本
##### 版本3.0 
```
platform:ios,'9.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 3.0'
end

3.0版本进行了全方位的大重构
```
##### 版本2.5.2（老版本的终结版）
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 2.5.2'
end

按钮处于最底部时长按touchDown事件的延时现象采用新方式解决，另外修复了内存泄露问题
```
##### 版本2.5.1
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 2.5.1'
end

此版本修改了action的选中效果，以及解决iOS11之后，按钮处于最底部时长按touchDown事件的延时现象
```
##### 版本2.5.0
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 2.5.0'
end

此版本在2.2.1版本的基础上主要改动有：
1、毛玻璃思路另辟蹊径，毛玻璃效果不会受到背景遮罩的影响，同时背景遮罩不再被镂空
2、增加动画枚举，可以从左右弹出
3、自定义view时的背景色改为透明色
4、增加actionHeight属性，修复maxNumberOfActionHorizontalArrangementForAlert属性
5、去除了中间tableView的最后一条分割线
6、修改了分割线的颜色，更加接近微信原生
7、修复centerView上有textView/textField，旋转屏幕后不可见问题
8、优化代码

```
##### 版本2.1.1
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 2.1.1'
end
```
##### 版本2.1.0
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 2.1.0'
end
```
##### 版本2.0
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 2.0'
end
```
##### 版本1.7.0
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 1.7.0'
end
```
##### 版本1.0.1
```
platform:ios,'8.0'
target 'MyApp' do
  pod 'SPAlertController', '~> 1.0.1'
end
```
[回到顶部](#目录) 
