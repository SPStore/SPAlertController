//
//  MyView.m
//  SPAlertController
//
//  Created by 乐升平 on 17/10/21.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "MyView.h"

@implementation MyView


- (void)awakeFromNib {
    [super awakeFromNib];
}

+ (instancetype)shareMyView {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

@end
