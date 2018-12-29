//
//  PopView.h
//  SPAlertController
//
//  Created by Libo on 2018/12/23.
//  Copyright © 2018 乐升平. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface PopView : UIView

- (instancetype)initWithImages:(NSArray<NSString *> *)images
                        titles:(NSArray<NSString *> *)titles
            clickedButtonBlock:(void(^)(NSInteger index))clickedButtonBlock
                   cancelBlock:(void(^)(PopView *popView))cancelBlock;

@property (nonatomic, copy) void(^tapBackgroundBlock)(PopView *popView);

- (void)open;

- (void)close;

@end

NS_ASSUME_NONNULL_END
