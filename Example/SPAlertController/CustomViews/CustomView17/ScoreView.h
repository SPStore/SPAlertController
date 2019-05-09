//
//  ScoreView.h
//  SPAlertController
//
//  Created by 乐升平 on 2018/12/24.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ScoreView : UIView
@property (nonatomic, copy) void(^finishButtonBlock)(void);

@end

NS_ASSUME_NONNULL_END
