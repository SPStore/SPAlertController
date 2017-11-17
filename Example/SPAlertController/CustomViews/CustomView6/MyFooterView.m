//
//  MyFooterView.m
//  SPAlertController
//
//  Created by Libo on 2017/11/13.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "MyFooterView.h"

@implementation MyFooterView

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

+ (instancetype)shareMyFooterView {
    return [[[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil] lastObject];
}

@end
