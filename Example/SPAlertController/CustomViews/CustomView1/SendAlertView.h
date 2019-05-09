//
//  SendAlertView.h
//  SPAlertController
//
//  Created by 乐升平 on 2018/12/24.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SendAlertView : UIView

+ (instancetype)shareSendAlertView;

@property (nonatomic, copy) UIImage *contentImage;

@property (nonatomic, copy) void(^keyboardWillShow)(CGFloat value);
@property (nonatomic, copy) void(^textViewHeightDidChange)(CGFloat offset);
@property (nonatomic, copy) void(^textViewDidEndEditting)(void);


@end

NS_ASSUME_NONNULL_END
