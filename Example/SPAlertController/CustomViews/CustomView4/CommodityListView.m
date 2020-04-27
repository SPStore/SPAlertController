//
//  CommodityListView.m
//  SPAlertController
//
//  Created by 乐升平 on 17/10/22.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "CommodityListView.h"
#import "UIColor+DarkMode.h"

@interface CommodityListView()
@property (nonatomic, weak) UIScrollView *scrollView;
@property (nonatomic, strong) NSMutableArray *imageViews;
@end

@implementation CommodityListView

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
    
    self.backgroundColor = [UIColor alertBackgroundColor];
    
    NSArray *images = @[@"image0.jpg",@"image1.jpg",@"image2.jpg",@"image3.jpg",@"image4.jpg",@"image5.jpg",@"image6.jpg",@"image7.jpg",@"image8.jpg",@"image9.jpg"];
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    scrollView.backgroundColor = [UIColor alertBackgroundColor];
    scrollView.showsVerticalScrollIndicator = NO;
    [self addSubview:scrollView];
    _scrollView = scrollView;
    
    for (int i = 0; i < images.count; i++) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.image = [UIImage imageNamed:images[i]];
        imageView.backgroundColor = [UIColor redColor];
        [scrollView addSubview:imageView];
        [self.imageViews addObject:imageView];
    }
}

- (NSMutableArray *)imageViews {
    
    if (!_imageViews) {
        _imageViews = [NSMutableArray array];
        
    }
    return _imageViews;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    self.scrollView.frame = self.bounds;

    CGFloat imageViewW = self.bounds.size.width/2-20;
    CGFloat imageViewH = self.bounds.size.height;
    CGFloat imageViewY = 0;
    if (@available(iOS 11.0, *)) {
        imageViewY = self.safeAreaInsets.top;
    }
    UIImageView *lastImageView;
    for (int i = 0; i < self.imageViews.count; i++) {
        UIImageView *imageView = self.imageViews[i];
        imageView.frame = CGRectMake((imageViewW +10) * i, imageViewY, imageViewW, imageViewH);
        if (i == self.imageViews.count-1) {
            lastImageView = imageView;
        }
    }
    self.scrollView.contentSize = CGSizeMake(CGRectGetMaxX(lastImageView.frame), 0);
}

@end
