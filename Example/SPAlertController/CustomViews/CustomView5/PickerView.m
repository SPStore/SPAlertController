//
//  MyTitleView.m
//  SPAlertController
//
//  Created by Libo on 2017/11/5.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "PickerView.h"
#import "UIColor+DarkMode.h"

@interface PickerView() <UIPickerViewDelegate,UIPickerViewDataSource>

@property (nonatomic, strong) UIPickerView *pickerView;
@property (nonatomic, strong) UIToolbar *toolbar;

@end

@implementation PickerView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initialize];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [self addSubview:self.toolbar];
    [self addSubview:self.pickerView];
}

- (void)doneClick {
    if (self.doneClickedBlock) {
        self.doneClickedBlock();
    }
}

- (void)cancelClick {
    if (self.cancelClickedBlock) {
        self.cancelClickedBlock();
    }
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 2;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return @[@"男",@"女"][row];
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel *pickerLabel = (UILabel *)view;
    if (!pickerLabel) {
        pickerLabel = [[UILabel alloc] init];
        pickerLabel.adjustsFontSizeToFitWidth = YES;
        pickerLabel.textAlignment = NSTextAlignmentCenter;
        [pickerLabel setFont:[UIFont boldSystemFontOfSize:18]];
    }
    pickerLabel.text = [self pickerView:pickerView titleForRow:row forComponent:component];
    return pickerLabel;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 50;
}

- (UIPickerView *)pickerView {
    if (!_pickerView) {
        _pickerView = [[UIPickerView alloc] init];
        _pickerView.delegate = self;
        _pickerView.dataSource = self;
        _pickerView.backgroundColor = [UIColor colorPairsWithLightColor:[UIColor colorWithRed:239.0 / 255.0 green:239.0 / 255.0 blue:239.0 / 255.0 alpha:1.0] darkColor:[UIColor colorWithRed:44.0 / 255.0 green:44.0 / 255.0 blue:44.0 / 255.0 alpha:1.0]];
    }
    return _pickerView;
}

- (UIToolbar *)toolbar {
    
    if (!_toolbar) {
        UIBarButtonItem *doneBBI = [[UIBarButtonItem alloc]
                                    initWithTitle:@"确定"
                                    style:UIBarButtonItemStyleDone
                                    target:self
                                    action:@selector(doneClick)];
        
        UIBarButtonItem *cancelBBI = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(cancelClick)];
        UIBarButtonItem *flexibleBBI = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
        _toolbar = [[UIToolbar alloc] init];
        // 设置tollbar的背景色
        _toolbar.barTintColor = [UIColor alertBackgroundColor];
        NSArray *toolbarItems = [NSArray arrayWithObjects:cancelBBI, flexibleBBI, doneBBI, nil];
        [_toolbar setItems:toolbarItems];
    }
    return _toolbar;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.toolbar.frame = CGRectMake(0, 0, self.bounds.size.width, 40);
    self.pickerView.frame = CGRectMake(0, CGRectGetMaxY(self.toolbar.frame), self.bounds.size.width, self.bounds.size.height-40);
}

@end




