//
//  MyView.h
//  SPAlertController
//
//  Created by 乐升平 on 17/10/21.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PassWordView.h"

@interface MyView : UIView

+ (instancetype)shareMyView;

@property (weak, nonatomic) IBOutlet PassWordView *passwordView;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end
