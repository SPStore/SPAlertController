//
//  UIColor+DarkMode.h
//  SPAlertController
//
//  Created by 乐升平 on 2020/4/26.
//  Copyright © 2020 乐升平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (DarkMode)

+ (UIColor *)alertBackgroundColor;

/// 创建颜色对
/// @param lightColor iOS13以下的系统显示的颜色或未开启深色模式下显示的颜色
/// @param darkColor 深色模式下显示的颜色
+ (UIColor *) colorPairsWithLightColor:(UIColor *) lightColor darkColor:(UIColor *) darkColor;

@end

NS_ASSUME_NONNULL_END
