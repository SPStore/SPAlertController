//
//  PickerView.h
//  SPAlertController
//
//  Created by Libo on 2017/11/15.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerView : UIView

@property (nonatomic, copy) void(^cancelClickedBlock)(void);
@property (nonatomic, copy) void(^doneClickedBlock)(void);

@end
