//
//  ShoppingCartCell.m
//  SPAlertController
//
//  Created by 乐升平 on 17/10/21.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "ShoppingCartCell.h"
#import "ShoppingCartItem.h"

@interface ShoppingCartCell()
@property (weak, nonatomic) IBOutlet UILabel *foodNmaeLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;

@end

@implementation ShoppingCartCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
}

- (void)setItem:(ShoppingCartItem *)item {
    _item = item;
    self.foodNmaeLabel.text = item.foodName;
    self.priceLabel.text = [self finallyFoodPrice:item.price];
}

- (IBAction)reduce:(UIButton *)sender {
    NSInteger i = [self.countLabel.text integerValue];
    i--;
    if (i < 1) {
        i = 1;
    } else {
        self.item.price = self.item.price - self.item.price / (i+1);
    }
    self.countLabel.text = [NSString stringWithFormat:@"%zd",i];
    self.priceLabel.text = [self finallyFoodPrice:self.item.price];

}

- (IBAction)add:(UIButton *)sender {
    NSInteger i = [self.countLabel.text integerValue];
    i++;
    self.item.price = self.item.price + self.item.price / (i-1);
    self.countLabel.text = [NSString stringWithFormat:@"%zd",i];
    self.priceLabel.text = [self finallyFoodPrice:self.item.price];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 最终的价格
- (NSString *)finallyFoodPrice:(float)price {

    // 新价格保留maxDecimalPlaces为位小数转成字符串
    NSString *priceString = [NSString stringWithFormat:@"%.5f",price];
    // 通过小数点进行分割,然后取小数部分
    NSArray *parts = [priceString componentsSeparatedByString:@"."];
    if (parts.count > 1) {
        // 取小数部分
        NSString *dot = parts[1];
        
        if ([dot hasSuffix:@"00000"]) {
            return [NSString stringWithFormat:@"¥%.0f",price];
        } else if ([dot hasSuffix:@"0000"]) {
            return [NSString stringWithFormat:@"¥%.1f",price];
        } else if ([dot hasSuffix:@"000"]) {
            return [NSString stringWithFormat:@"¥%.2f",price];
        } else if ([dot hasSuffix:@"00"]) {
            return [NSString stringWithFormat:@"¥%.3f",price];
        } else if ([dot hasSuffix:@"0"]) {
            return [NSString stringWithFormat:@"¥%.4f",price];
        } else {
            return priceString;
        }
    }
    return nil;
}


@end
