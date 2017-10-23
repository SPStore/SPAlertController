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
    
    [self addSubview:self.tableView];
    
    NSArray *dataArr = [self getData];
    
    for (int i = 0; i < dataArr.count; i++) {
        ShoppingCartItem *item = [[ShoppingCartItem alloc] init];
        [item setValuesForKeysWithDictionary:dataArr[i]];
        [self.dataSource addObject:item];
    }
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

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 30)];
    label.backgroundColor = [UIColor colorWithRed:244.0/255.0 green:244.0/255.0 blue:244.0/255.0 alpha:1];
    label.textAlignment = NSTextAlignmentCenter;
    label.text = @"购物车";
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 44;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.bounces = NO;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerNib:[UINib nibWithNibName:NSStringFromClass([ShoppingCartCell class]) bundle:nil] forCellReuseIdentifier:@"shoppingCartCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataSource {
    
    if (!_dataSource) {
        _dataSource = [NSMutableArray array];
        
    }
    return _dataSource;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.tableView.frame = self.bounds;
}

- (NSArray *)getData {
    NSArray *dataArr = @[@{
                             @"foodName":@"鱼香肉丝",
                             @"price":@"21.5",
                             },
                         @{
                             @"foodName":@"辣椒炒肉",
                             @"price":@"18",
                             },
                         @{
                             @"foodName":@"梅干菜",
                             @"price":@"20",
                             },
                         @{
                             @"foodName":@"西红柿蛋汤",
                             @"price":@"12",
                             },
                         @{
                             @"foodName":@"红烧鲫鱼",
                             @"price":@"35",
                             },
                         @{
                             @"foodName":@"啤酒鸭",
                             @"price":@"29",
                             },
                         @{
                             @"foodName":@"宫爆鸡丁",
                             @"price":@"28",
                             },
                         @{
                             @"foodName":@"外婆菜",
                             @"price":@"17.025",
                             },
                         @{
                             @"foodName":@"王老吉",
                             @"price":@"8",
                             },
                         @{
                             @"foodName":@"米饭",
                             @"price":@"2",
                             },
                         ];
    
    return dataArr;
}

@end



