//
//  UIColor+DarkMode.m
//  SPAlertController
//
//  Created by 乐升平 on 2020/4/26.
//  Copyright © 2020 乐升平. All rights reserved.
//

#import "UIColor+DarkMode.h"

@implementation UIColor (DarkMode)

+ (UIColor *)alertBackgroundColor {
    return [self colorPairsWithLightColor:[[UIColor whiteColor] colorWithAlphaComponent:0.7]
                                     darkColor:[UIColor colorWithRed:44.0 / 255.0 green:44.0 / 255.0 blue:44.0 / 255.0 alpha:1.0]];
}

+ (UIColor *)colorPairsWithLightColor:(UIColor *)lightColor darkColor:(UIColor *)darkColor {
    if (@available(iOS 13.0, *)) {
        return [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if(traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                return darkColor;
            } else {
                return lightColor;
            }
        }];
    } else {
        return lightColor;
    }
}

@end
