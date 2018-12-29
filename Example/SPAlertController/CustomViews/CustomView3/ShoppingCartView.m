//
//  ShoppingCartView.m
//  SPAlertController
//
//  Created by 乐升平 on 17/10/21.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "ShoppingCartView.h"
#import "ShoppingCartCell.h"
#import "ShoppingCartItem.h"

@interface ShoppingCartView() <UITableViewDelegate, UITableViewDataSource>
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) UILabel *topLabel;
@end

@implementation ShoppingCartView

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
    
    [self addSubview:self.topLabel];
    [self addSubview:self.tableView];
    
    NSArray *dataArr = [self getData];
    
    for (int i = 0; i < dataArr.count; i++) {
        ShoppingCartItem *item = [[ShoppingCartItem alloc] init];
        [item setValuesForKeysWithDictionary:dataArr[i]];
        [self.dataSource addObject:item];
    }
}

- (void)hideTopView {

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    ShoppingCartCell *cell = [tableView dequeueReusableCellWithIdentifier:@"shoppingCartCell" forIndexPath:indexPath];
    cell.item = self.dataSource[indexPath.row];
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    NSLog(@"----点到了cell");
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ShoppingCartCell class]) bundle:nil] forCellReuseIdentifier:@"shoppingCartCell"];
    }
    return _tableView;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [[UILabel alloc] init];
        _topLabel.backgroundColor = [UIColor whiteColor];
        _topLabel.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1];
        _topLabel.textAlignment = NSTextAlignmentCenter;
        _topLabel.text = @"购物车";

    }
    return _topLabel;
}

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
    }
    return _dataSource;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat topLabelY = 0.;
    if (@available(iOS 11.0, *)) {
        topLabelY = self.safeAreaInsets.top;
    } else {
        topLabelY = 20;
    }
    self.topLabel.frame = CGRectMake(0, topLabelY, self.bounds.size.width, 44);
    CGFloat tableViewY = CGRectGetMaxY(self.topLabel.frame);
    self.tableView.frame = CGRectMake(0, tableViewY, self.frame.size.width, self.frame.size.height-tableViewY);

}

- (NSArray *)getData {
    NSArray *dataArr = @[@{
                             @"foodName":@"鱼香肉丝",
                             @"price":@(21.5),
                             },
                         @{
                             @"foodName":@"辣椒炒肉",
                             @"price":@(18),
                             },
                         @{
                             @"foodName":@"梅干菜",
                             @"price":@(20.1),
                             },
                         @{
                             @"foodName":@"西红柿蛋汤",
                             @"price":@(12.306),
                             },
                         @{
                             @"foodName":@"红烧鲫鱼",
                             @"price":@(35.8),
                             },
                         @{
                             @"foodName":@"啤酒鸭",
                             @"price":@(29),
                             },
                         @{
                             @"foodName":@"宫爆鸡丁",
                             @"price":@(28),
                             },
                         @{
                             @"foodName":@"湖南一碗香",
                             @"price":@(37.5),
                             },
                         @{
                             @"foodName":@"鸡汤",
                             @"price":@(16),
                             },
                         @{
                             @"foodName":@"鸽子汤",
                             @"price":@(18.5),
                             },
                         @{
                             @"foodName":@"王老吉",
                             @"price":@(8),
                             },
                         @{
                             @"foodName":@"米饭",
                             @"price":@(2),
                             },
                         ];
    
    return dataArr;
}

@end



