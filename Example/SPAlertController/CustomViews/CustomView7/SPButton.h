//
//  SPButton.h
//  SPButton
//
//  Created by 乐升平 on 2018/11/20.
//  Copyright © 2018 乐升平. All rights reserved.
//  github:https://github.com/SPStore/SPButton

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN


typedef NS_ENUM(NSInteger, SPButtonImagePosition) {
    SPButtonImagePositionLeft   = 0,     // 图片在文字左侧
    SPButtonImagePositionRight  = 1,     // 图片在文字右侧
    SPButtonImagePositionTop    = 2,     // 图片在文字上侧
    SPButtonImagePositionBottom = 3      // 图片在文字下侧
};

IB_DESIGNABLE
@interface SPButton : UIButton

- (instancetype)initWithImagePosition:(SPButtonImagePosition)imagePosition;

#if TARGET_INTERFACE_BUILDER // storyBoard/xib中设置
@property (nonatomic,assign) IBInspectable NSInteger imagePosition; // 图片位置
@property (nonatomic, assign) IBInspectable CGFloat imageTitleSpace; // 图片和文字之间的间距
#else // 纯代码设置
@property (nonatomic) SPButtonImagePosition imagePosition; // 图片位置
@property (nonatomic, assign) CGFloat imageTitleSpace; // 图片和文字之间的间距
#endif


@end


NS_ASSUME_NONNULL_END
