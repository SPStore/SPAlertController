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
    self.priceLabel.text = [NSString stringWithFormat:@"¥%@",item.price];
}

- (IBAction)reduce:(UIButton *)sender {
    NSInteger i = [self.countLabel.text integerValue];
    i--;
    if (i <= 0) {
        i = 1;
    }
    float price = [self.item.price floatValue];
    price = price * i;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",i];
    self.priceLabel.text = [self finallyFoodPrice:price];
}

- (IBAction)add:(UIButton *)sender {
    NSInteger i = [self.countLabel.text integerValue];
    i++;
    float price = [self.item.price floatValue];
    price = price * i;
    self.countLabel.text = [NSString stringWithFormat:@"%zd",i];
    self.priceLabel.text = [NSString stringWithFormat:@"¥%.1f",price];
    self.priceLabel.text = [self finallyFoodPrice:price];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

// 最终的价格，这个方法的功能：如果价格有小数，先保留2位小数，如果小数部分全是0，直接取整，如果小数第1位非0第2位是0，则保留1位小数，如果小数的2位都非0，则保留2位小数
- (NSString *)finallyFoodPrice:(float)price {
    // 新价格保留2为小数转成字符串
    NSString *priceString = [NSString stringWithFormat:@"%.2f",price];
    // 通过小数点进行分割,然后取小数部分
    NSArray *parts = [priceString componentsSeparatedByString:@"."];
    if (parts.count > 1) {
        // 取小数部分
        NSString *dot = parts[1];
        // 小数部分转成数字
        NSInteger dotInteget = [dot integerValue];
        if (dotInteget == 0) { // 说明小数部分全为0,此时保留0位小数(取整)
            return [NSString stringWithFormat:@"¥%.0f",price];
        } else {
            // 对10求余
            NSInteger remainder = dotInteget % 10;
            if (remainder == 0) { // 说明dotInteget的末尾(第2位)是0,此时保留1为小数
                return [NSString stringWithFormat:@"¥%.1f",price];
            } else { // 说明dotInteget的末尾不是0,此时保留2为小数
                return priceString;
            }
        }
    }
    return nil;
}

@end
