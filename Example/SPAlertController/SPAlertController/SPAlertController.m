//
//  SPAlertController.m
//  SPAlertController
//
//  Created by 乐升平 on 17/10/12. https://github.com/SPStore/SPAlertController
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "SPAlertController.h"

#define ScreenWidth [UIScreen mainScreen].bounds.size.width
#define ScreenHeight [UIScreen mainScreen].bounds.size.height

#define actionHeight 48.0
#define actionColor [UIColor colorWithWhite:1 alpha:0.8]
#define alertColor [UIColor colorWithWhite:1 alpha:0]

#define isIPhoneX ([UIScreen mainScreen].bounds.size.height==812)
#define alertBottomMargin isIPhoneX ? 34 : 0 // 适配iPhoneX


#pragma mark ---------------------------- SPAlertAction begin --------------------------------

@interface SPAlertAction()

@property (nullable, nonatomic) NSString *title;
@property (nonatomic, assign) SPAlertActionStyle style;
@property (nonatomic, copy) void (^handler)(SPAlertAction *action);
// 当在addAction之后设置action属性时,会回调这个block,设置相应控件的字体、颜色等
// 如果没有这个block，那使用时，只有在addAction之前设置action的属性才有效
@property (nonatomic, copy) void (^propertyEvent)(SPAlertAction *action);
@end

@implementation SPAlertAction

- (id)copyWithZone:(NSZone *)zone {
    SPAlertAction *action = [[[self class] alloc] init];
    action.title = [self.title copy];
    action.style = self.style;
    action.enabled = self.enabled;
    action.titleColor = self.titleColor;
    action.titleFont = self.titleFont;
    action.handler = self.handler;
    return action;
}

+ (instancetype)actionWithTitle:(nullable NSString *)title style:(SPAlertActionStyle)style handler:(void (^ __nullable)(SPAlertAction *action))handler {
    SPAlertAction *action = [[self alloc] initWithTitle:title style:(SPAlertActionStyle)style handler:handler];
    return action;
    
}

- (instancetype)initWithTitle:(nullable NSString *)title style:(SPAlertActionStyle)style handler:(void (^ __nullable)(SPAlertAction *action))handler {
    if (self = [super init]) {

        self.title = title;
        self.style = style;
        self.enabled = YES; // 默认能点击
        self.handler = handler;
    }
    return self;
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    if (self.propertyEvent) {
        self.propertyEvent(self);
    }
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    if (self.propertyEvent) {
        self.propertyEvent(self);
    }
}

- (void)setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (self.propertyEvent) {
        self.propertyEvent(self);
    }
}

@end

#pragma mark ---------------------------- SPAlertAction end --------------------------------

#pragma mark ---------------------------- SPAlertControllerActionCell begin --------------------------------

@interface SPAlertControllerActionCell : UITableViewCell
@property (nonatomic, strong) SPAlertAction *action;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *titleLabelConstraints;
@end

@implementation SPAlertControllerActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        // 设置垂直方向的抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [titleLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [titleLabel sizeToFit];
        // footerCell指的是SPAlertControllerStyleActionSheet下的取消cell和SPAlertControllerStyleAlert下actions小于_maxNumberOfActionHorizontalArrangementForAlert时的cell
        // 这个cell因为要修改系统自带的布局，如果直接加在contentView上，修改contentView的布局很容易出问题，所以此时用不着contentView，而且这个cell跟tableView没有任何关系，就是一个普通的view
        if ([reuseIdentifier isEqualToString:@"footerCell"]) {
            self.backgroundColor = actionColor;
            // contentView在此处没用了
            self.contentView.backgroundColor = [UIColor clearColor];
            [self addSubview:titleLabel];
        } else {
            // 设置背景透明，默认是白色，白色会阻挡分割线
            self.backgroundColor = [UIColor clearColor];
            // contentView默认是透明色，给一个颜色，更加突出分割线（contentView的高度比cell小0.5，0.5就是分割线的高度）
            self.contentView.backgroundColor = actionColor;
            [self.contentView addSubview:titleLabel];
        }
        _titleLabel = titleLabel;
        
        [self setNeedsUpdateConstraints];
    }
    return self;
}

- (void)setAction:(SPAlertAction *)action {
    _action = action;
    self.titleLabel.text = action.title;
    if (action.enabled) {
        self.titleLabel.textColor = action.titleColor;
        self.titleLabel.font = action.titleFont;
    } else {
        self.titleLabel.textColor = [UIColor lightGrayColor];
        self.titleLabel.font = [UIFont systemFontOfSize:17];
    }
    self.userInteractionEnabled = action.enabled;
    [self setNeedsUpdateConstraints];
}

- (void)updateConstraints {
    [super updateConstraints];

    UILabel *titleLabel = self.titleLabel;
    
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
    if (self.titleLabelConstraints) {
        [titleLabel.superview removeConstraints:self.titleLabelConstraints];
        self.titleLabelConstraints = nil;
    }

    [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:titleLabel.superview attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(>=0)-[titleLabel]-(>=0)-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
    [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[titleLabel]-0-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
    [titleLabel.superview addConstraints:titleLabelConstraints];
    self.titleLabelConstraints = titleLabelConstraints;

}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}


@end
#pragma mark ---------------------------- SPAlertControllerActionCell end --------------------------------


#pragma mark ---------------------------- SPAlertController begin --------------------------------

@interface SPAlertController () <UIViewControllerTransitioningDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, strong) UIView *alertView;
@property (nonatomic, weak) UIVisualEffectView *alertEffectView;

// ---------------- 头部控件 ---------------
@property (nonatomic, weak) UIView *headerBezelView;
@property (nonatomic, weak) UIScrollView *headerScrollView;
@property (nonatomic, weak) UIView *headerScrollContentView; // autoLayout中需要在scrollView上再加一个view
@property (nonatomic, weak) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailTitleLabel;
@property (nonatomic, weak) UIView *textFieldView;

// ---------------- 头部控件的约束数组 -----------------
@property (nonatomic, strong) NSMutableArray *headerBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *headerScrollContentViewConstraints;
@property (nonatomic, strong) NSMutableArray *titleViewConstraints;
@property (nonatomic, strong) NSMutableArray *titleLabelConstraints;
@property (nonatomic, strong) NSMutableArray *textFieldViewConstraints;
@property (nonatomic, strong) NSMutableArray *textFieldConstraints;

// ---------------- action控件 --------------
@property (nonatomic, weak) UIView *actionBezelView;
@property (nonatomic, weak) UIView *actionBezelContentView;
@property (nonatomic, weak) UITableView *actionTableView;
@property (nonatomic, weak) UIView *footerView;

// ---------------- action控件的约束数组 -------------------
@property (nonatomic, strong) NSMutableArray *actionBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *actionBezelContentViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerActionViewConstraints;

// ---------------- 自定义view --------------
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIView *customTitleView;
@property (nonatomic, strong) UIView *customCenterView;
@property (nonatomic, strong) UIView *customFooterView;

@property (nonatomic, assign) CGSize customViewSize;
@property (nonatomic, assign) CGSize customTitleViewSize;
@property (nonatomic, assign) CGSize customCenterViewSize;
@property (nonatomic, assign) CGSize customFooterViewSize;
// ---------------- action控件的约束数组 -------------------
@property (nonatomic, strong) NSMutableArray *customViewConstraints;

// action数组
@property (nonatomic) NSArray<SPAlertAction *> *actions;
// tableView的数据源,与actions数组息息相关
@property (nonatomic, strong) NSArray *dataSource;
// 取消的action
@property (nonatomic, strong) SPAlertAction *cancelAction;
// textFiled数组
@property (nonatomic) NSArray<UITextField *> *textFields;

@property (nonatomic, assign) SPAlertControllerStyle preferredStyle;
@property (nonatomic, assign) SPAlertAnimationType animationType;

@property (nonatomic, assign) BOOL keyboardShow;
@property (nonatomic, assign) NSLayoutConstraint *alertConstraintCenterY;

@end

@implementation SPAlertController
@synthesize title = _title;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType {

    SPAlertController *alertController = [self alertControllerWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:nil];
    
    return alertController;
}

+ (instancetype)alertControllerWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(UIView *)customView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:customView customTitleView:nil customCenterView:nil customFooterView:nil];
    return alertController;
}

+ (instancetype)alertControllerWithPreferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customTitleView:(nullable UIView *)customTitleView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:nil message:nil preferredStyle:preferredStyle animationType:animationType customView:nil customTitleView:customTitleView customCenterView:nil customFooterView:nil];
    return alertController;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customCenterView:(UIView *)customCenterView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:nil customTitleView:nil customCenterView:customCenterView customFooterView:nil];
    return alertController;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customFooterView:(UIView *)customFooterView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:nil customTitleView:nil customCenterView:nil customFooterView:customFooterView];
    return alertController;
}

- (void)addAction:(SPAlertAction *)action {
    
    if ([self.actions containsObject:action]) {
        return;
    }
    
    NSMutableArray *array = self.actions.mutableCopy;
    
    if (self.cancelAction && self.preferredStyle == SPAlertControllerStyleActionSheet) {
        // 如果在取消按钮已经存在的情况下，action又是取消按钮，直接报异常
        NSAssert(action.style != SPAlertActionStyleCancel, @"SPAlertController不允许多个取消按钮,你可以检查是否多次设置了SPAlertActionStyleCancel");
        NSInteger index = [self.actions indexOfObject:self.cancelAction];
        // 将这个action插入到cancelAction之前，目的是保证cancelAction永远处于数组最后一个位置
        [array insertObject:action atIndex:index];        
    } else {
        [array addObject:action];
    }
    self.actions = array;
    
    if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
        if (self.customCenterView && action.style != SPAlertActionStyleCancel) {
            NSLog(@"当自定义centerView时，SPAlertControllerStyleActionSheet下，除了取消样式的按钮之外，其余样式的按钮均不显示");
            [array removeObject:action];
            self.actions = array;
            [self layoutViewConstraints];
            return;
        }
        if (action.style == SPAlertActionStyleCancel && !self.customFooterView) {
            self.cancelAction = action;
            [self createFooterActionView:action];
        }
        self.dataSource = self.cancelAction ? [array subarrayWithRange:NSMakeRange(0, array.count-1)].copy : array.copy;
    } else {
        if (self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert && !self.customFooterView) {
            [self createFooterActionView:action];
            // 当只有_maxNumberOfActionHorizontalArrangementForAlert个action时，不需要tableView，这里没有移除tableView，而是清空数据源，如果直接移除tableView，当大于_maxNumberOfActionHorizontalArrangementForAlert个action时又得加回来
            self.dataSource = nil;
        } else {
            if (self.customCenterView) {
                NSLog(@"当自定义centerView时，SPAlertControllerStyleAlert下，action的个数最多只能是_maxNumberOfActionHorizontalArrangementForAlert个，超过_maxNumberOfActionHorizontalArrangementForAlert个的action将不显示");
                [array removeObject:action];
                self.actions = array;
                return;
            }
            self.dataSource = array.copy;
            for (NSInteger i = self.footerView.subviews.count-1; i >= 0; i--) {
                UIView *footerActionView = self.footerView.subviews[i];
                [footerActionView removeFromSuperview];
                footerActionView = nil;
            }
        }
    }
    __weak typeof(self) weakSelf = self;
    // 当外面在addAction之后再设置action的属性时，会回调这个block
    action.propertyEvent = ^(SPAlertAction *action) {
        if (weakSelf.preferredStyle == SPAlertControllerStyleActionSheet) {
            if (action.style == SPAlertActionStyleCancel) {
                // 注意这个cell是与tableView没有任何瓜葛的
                SPAlertControllerActionCell *footerCell = weakSelf.footerView.subviews.lastObject;
                footerCell.action = action;
            } else {
                // 刷新tableView
                [weakSelf.actionTableView reloadData];
            }
        } else {
            if (weakSelf.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert) {
                NSInteger index = [weakSelf.actions indexOfObject:action];
                SPAlertControllerActionCell *footerCell = weakSelf.footerView.subviews[index];
                footerCell.action = action;
            } else {
                [weakSelf.actionTableView reloadData];
            }
        }
        
    };
    // 刷新tableView
    [self.actionTableView reloadData];
    
    [self layoutViewConstraints];
    
}

- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField * _Nonnull))configurationHandler {
    
    UITextField *textField = [[UITextField alloc] init];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    // 系统的UITextBorderStyleLine样式线条过于黑，所以自己设置
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = [UIColor grayColor].CGColor;
    // 在左边设置一张view，充当光标左边的间距，否则光标紧贴textField不美观
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    textField.leftView.userInteractionEnabled = NO;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.font = [UIFont systemFontOfSize:14];
    
    NSMutableArray *array = self.textFields.mutableCopy;
    [array addObject:textField];
    self.textFields = array;
    if (configurationHandler) {
        configurationHandler(textField);
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPAlertControllerActionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SPAlertControllerActionCell class]) forIndexPath:indexPath];
    SPAlertAction *action = self.dataSource[indexPath.row];
    cell.action = action;
    return cell;
}

#pragma mark - TableView Method

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return actionHeight;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    // 设置cell分割线整宽
    // Remove seperator inset
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
    // Explictly set your cell's layout margins
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // 动画置为NO，如果动画为YES，当点击cell退出控制器时会有延迟,延迟时长时短
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    SPAlertAction *action = self.dataSource[indexPath.row];
    // 回调action的block
    if (action.handler) {
        action.handler(action);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Private
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(UIView *)customView customTitleView:(UIView *)customTitleView customCenterView:(UIView *)customCenterView customFooterView:(UIView *)customFooterView{
    
    if (self = [super init]) {
        
        // 是否视图控制器定义它呈现视图控制器的过渡风格（默认为NO）
        self.providesPresentationContextTransitionStyle = YES;
        self.definesPresentationContext = YES;
        self.modalPresentationStyle = UIModalPresentationCustom;
        self.transitioningDelegate = self;
        
        _title = title;
        _message = message;
        self.preferredStyle = preferredStyle;
        // 如果是默认动画，preferredStyle为alert时动画默认为fade，preferredStyle为actionShee时动画默认为raiseUp
        if (animationType == SPAlertAnimationTypeDefault) {
            if (self.preferredStyle == SPAlertControllerStyleAlert) {
                animationType= SPAlertAnimationTypeAlpha;
            } else if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
                animationType = SPAlertAnimationTypeRaiseUp;
            } else {
                animationType = SPAlertAnimationTypeRaiseUp;
            }
        }
        self.animationType = animationType;
        
        // 添加子控件
        [self setupViewsWithCustomView:customView customTitleView:customTitleView customCenterView:customCenterView customFooterView:customFooterView];
        
        self.needBlur = YES;
        self.cornerRadiusForAlert = 5;
        self.maxTopMarginForActionSheet = isIPhoneX ? 44 : 0;
        self.maxMarginForAlert = 20.0;
        self.maxNumberOfActionHorizontalArrangementForAlert = 2;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
    }
    return self;
}

- (void)setupViewsWithCustomView:(UIView *)customView customTitleView:(UIView *)customTitleView customCenterView:(UIView *)customCenterView customFooterView:(UIView *)customFooterView {
    
    UIView *alertView = [[UIView alloc] init];
    alertView.frame = self.view.bounds;
    alertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:alertView];
    _alertView = alertView;
    
    if (!customView) { // 没有自定义整个对话框
        
        UIView *headerBezelView = [[UIView alloc] init];
        headerBezelView.translatesAutoresizingMaskIntoConstraints = NO;
        [alertView addSubview:headerBezelView];
        _headerBezelView = headerBezelView;
        
        // 创建头部scrollView
        UIScrollView *headerScrollView = [[UIScrollView alloc] init];
        headerScrollView.frame = headerBezelView.bounds;
        headerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        headerScrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            headerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [headerBezelView addSubview:headerScrollView];
        _headerScrollView = headerScrollView;
        
        UIView *headerScrollContentView = [[UIView alloc] init];
        headerScrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
        headerScrollContentView.backgroundColor = actionColor;
        [headerScrollView addSubview:headerScrollContentView];
        _headerScrollContentView = headerScrollContentView;
        if (!customTitleView) { // 不是自定义的titleView
            UIView *titleView = [[UIView alloc] init];
            titleView.translatesAutoresizingMaskIntoConstraints = NO;
            [headerScrollContentView addSubview:titleView];
            _titleView = titleView;
            
            UIView *textFieldView = [[UIView alloc] init];
            textFieldView.translatesAutoresizingMaskIntoConstraints = NO;
            [headerScrollContentView addSubview:textFieldView];
            _textFieldView = textFieldView;
            
            if (self.title.length) {
                self.titleLabel.text = self.title;
                [titleView addSubview:self.titleLabel];
            }
            if (self.message.length) {
                self.detailTitleLabel.text = self.message;
                [titleView addSubview:self.detailTitleLabel];
            }
        } else { // 是自定义的titleView
            self.customTitleView = customTitleView;
        }

        UIView *actionBezelView = [[UIView alloc] init];
        actionBezelView.translatesAutoresizingMaskIntoConstraints = NO;
        [alertView addSubview:actionBezelView];
        _actionBezelView = actionBezelView;
        
        if (!customCenterView) {
            UIView *actionBezelContentView = [[UIView alloc] init];
            actionBezelContentView.translatesAutoresizingMaskIntoConstraints = NO;
            [actionBezelView addSubview:actionBezelContentView];
            _actionBezelContentView = actionBezelContentView;
            
            UITableView *actionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            actionTableView.frame = actionBezelContentView.bounds;
            actionTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            actionTableView.showsHorizontalScrollIndicator = NO;
            actionTableView.alwaysBounceVertical = NO; // tableView内容没有超出contentSize时，禁止滑动
            actionTableView.backgroundColor = [UIColor clearColor];
            actionTableView.separatorColor = [UIColor clearColor];
            actionTableView.dataSource = self;
            actionTableView.delegate = self;
            if (@available(iOS 11.0, *)) {
                actionTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            } else {
                // Fallback on earlier versions
            }
            [actionTableView registerClass:[SPAlertControllerActionCell class] forCellReuseIdentifier:NSStringFromClass([SPAlertControllerActionCell class])];
            [actionBezelContentView addSubview:actionTableView];
            _actionTableView = actionTableView;
        } else {
            [self.actionBezelContentView removeFromSuperview];
            self.actionBezelContentView = nil;
            self.customCenterView = customCenterView;
        }
        
        if (!customFooterView) {
            UIView *footerView = [[UIView alloc] init];
            footerView.translatesAutoresizingMaskIntoConstraints = NO;
            [_actionBezelView addSubview:footerView];
            _footerView = footerView;
        } else {
            [self.footerView removeFromSuperview];
            self.footerView = nil;
            self.customFooterView = customFooterView;
        }
        [self layoutViewConstraints];
    } else {
        [self.alertView.subviews enumerateObjectsUsingBlock:^(__kindof UIView * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
            obj = nil;
        }];
        self.customView = customView;
    }
}

- (void)createFooterActionView:(SPAlertAction *)action {
    // 这个cell实际上就是一个普通的view，跟tableView没有任何关系，因为cell内部都有现成的控件和布局，直接用这个cell就好，没必要再去自定义一个view，需要注意的是，cell使用了自动布局,contentView会受到影响，看警告对症下药
    SPAlertControllerActionCell *footerActionView = [[SPAlertControllerActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"footerCell"];
    footerActionView.translatesAutoresizingMaskIntoConstraints = NO;
    footerActionView.contentView.translatesAutoresizingMaskIntoConstraints = NO;
    footerActionView.action = action;
    [self.footerView addSubview:footerActionView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFooterActionView:)];
    [footerActionView addGestureRecognizer:tap];
}

- (void)tapFooterActionView:(UITapGestureRecognizer *)tap {
    if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
        if (self.cancelAction.handler) {
            self.cancelAction.handler(self.cancelAction);
        }
    } else {
        if (self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert) {
            SPAlertControllerActionCell *footerActionView = (SPAlertControllerActionCell *)tap.view;
            NSInteger index = [self.footerView.subviews indexOfObject:footerActionView];
            SPAlertAction *action = [self.actions objectAtIndex:index];
            // 回调action的block
            if (action.handler) {
                action.handler(action);
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - 布局
- (void)layoutViewConstraints {
    
    if (self.customView) {
        return;
    }
    UIView *alertView = self.alertView;
    UIView *headerBezelView = self.headerBezelView;
    UIScrollView *headerScrollView = self.headerScrollView;
    UIView *headerScrollContentView = self.headerScrollContentView;
    UIView *titleView = self.customTitleView ? self.customTitleView : self.titleView;
    UIView *textFieldView = self.textFieldView;
    UIView *actionBezelView = self.actionBezelView;
    UIView *actionBezelContentView = self.customCenterView ? self.customCenterView : self.actionBezelContentView;
    UIView *footerView = self.customFooterView ? self.customFooterView : self.footerView;
    
    // 预备相应控件的约束数组
    NSMutableArray *headerBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *headerScrollContentViewConstraints = [NSMutableArray array];
    NSMutableArray *titleViewConstraints = [NSMutableArray array];
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
    NSMutableArray *texFieldViewConstraints = [NSMutableArray array];
    NSMutableArray *textFieldConstraints = [NSMutableArray array];
    NSMutableArray *actionBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *actionBezelContentViewConstraints = [NSMutableArray array];
    NSMutableArray *footerViewConstraints = [NSMutableArray array];
    NSMutableArray *footerActionViewConstraints = [NSMutableArray array];
    
    // 移除存在的约束
    if (self.headerBezelViewConstraints) {
        [alertView removeConstraints:self.headerBezelViewConstraints];
        self.headerBezelViewConstraints = nil;
    }
    if (self.headerScrollContentViewConstraints) {
        [headerScrollView removeConstraints:self.headerScrollContentViewConstraints];
        self.headerScrollContentViewConstraints = nil;
    }
    if (self.titleViewConstraints) {
        [headerScrollContentView removeConstraints:self.titleViewConstraints];
        self.titleViewConstraints = nil;
    }
    if (self.titleLabelConstraints) {
        [titleView removeConstraints:self.titleLabelConstraints];
        self.titleLabelConstraints = nil;
    }
    if (self.textFieldViewConstraints) {
        [headerScrollContentView removeConstraints:self.textFieldViewConstraints];
        self.textFieldViewConstraints = nil;
    }
    if (self.textFieldConstraints) {
        [textFieldView removeConstraints:self.textFieldConstraints];
        self.textFieldConstraints = nil;
    }
    if (self.actionBezelViewConstraints) {
        [alertView removeConstraints:self.actionBezelViewConstraints];
        self.actionBezelViewConstraints = nil;
    }
    if (self.actionBezelContentViewConstraints) {
        [actionBezelView removeConstraints:self.actionBezelContentViewConstraints];
        self.actionBezelContentViewConstraints = nil;
    }
    if (self.footerViewConstraints) {
        [actionBezelView removeConstraints:self.footerViewConstraints];
        self.footerViewConstraints = nil;
    }
    if (self.footerActionViewConstraints) {
        [footerView removeConstraints:self.footerActionViewConstraints];
        self.footerActionViewConstraints = nil;
    }
    
    CGFloat margin = 15;
    CGFloat footerTopMargin = self.cancelAction ? 6.0 : 0.0;
    CGFloat headerActionPadding = (!titleView.subviews.count || !self.actions.count) ? 0 : 0.5;
    
    // 计算好actionBezelView的高度, 本也可以让设置每个子控件都高度约束，以及顶底约束和子控件之间的间距，这样便可以把actionBezelView的高度撑起来，但是这里要比较一下actionBezelView和headerBezelView的高度优先级，所以父控件设置高度比较方便，谁的优先级高，谁展示的内容就更多
    CGFloat actionBezelHeight = [self actionBezelHeight:footerTopMargin];
    [headerBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerBezelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerBezelView)]];
    [headerBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[headerBezelView]-%f-[actionBezelView]-0-|",headerActionPadding] options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerBezelView,actionBezelView)]];
    // headerBezelView的高度最大为(self.view.bounds.size.height-itemHeight)
    [headerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:self.view.bounds.size.height-actionHeight]];
    // 暂时先初始化headerBezelView的高度约束
    NSLayoutConstraint *headerBezelViewContsraintHeight = [NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0];
    /// 设置优先级
    headerBezelViewContsraintHeight.priority = 998.0;
    [headerBezelViewConstraints addObject:headerBezelViewContsraintHeight];
    [alertView addConstraints:headerBezelViewConstraints];
    
    // 设置actionScrollContentView的相关约束，值得注意的是不能仅仅设置上下左右间距为0就完事了，对于scrollView的contentView， autoLayout布局必须设置宽或高约束
    [headerScrollContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerScrollContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollContentView)]];
    [headerScrollContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[headerScrollContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollContentView)]];
    [headerScrollContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerScrollContentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerScrollView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
    if (_titleLabel.text.length || _detailTitleLabel.text.length) {
        // 保证headerScrollContentView的高度最小为actionHeight
        [headerScrollContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerScrollContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionHeight]];
    }
    [headerScrollView addConstraints:headerScrollContentViewConstraints];
    
    if (!self.customTitleView) {
        [titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titleView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView)]];
        [titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleView]-0-[textFieldView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView,textFieldView)]];
        [headerScrollContentView addConstraints:titleViewConstraints];
        
        NSArray *labels = titleView.subviews;
        [labels enumerateObjectsUsingBlock:^(UILabel *label, NSUInteger idx, BOOL * _Nonnull stop) {
            // 左右间距
            [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==margin)-[label]-(==margin)-|"] options:0 metrics:@{@"margin":@(margin)} views:NSDictionaryOfVariableBindings(label)]];
            // 第一个子控件顶部间距
            if (idx == 0) {
                [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeTop multiplier:1.f constant:margin]];
            }
            // 最后一个子控件底部间距
            if (idx == labels.count - 1) {
                [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:titleView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-margin]];
            }
            // 子控件之间的垂直间距
            if (idx > 0) {
                NSLayoutConstraint *paddingConstraint = [NSLayoutConstraint constraintWithItem:label attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:labels[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:margin*0.5];
                [titleLabelConstraints addObject:paddingConstraint];
            }
        }];
        [titleView addConstraints:titleLabelConstraints];
        
        CGFloat textFieldViewHeight = 0;
        CGFloat textFieldMargin = 15;
        CGFloat textFiledHeight = 26;
        if (self.textFields.count) {
            textFieldViewHeight = self.textFields.count * textFiledHeight + textFieldMargin + 0.5 * textFieldMargin;
        }
        [texFieldViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[textFieldView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(textFieldView)]];
        [texFieldViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleView]-0-[textFieldView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView,textFieldView)]];
        [texFieldViewConstraints addObject:[NSLayoutConstraint constraintWithItem:textFieldView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:textFieldViewHeight]];
        [headerScrollContentView addConstraints:texFieldViewConstraints];
        
        NSArray *textFields = textFieldView.subviews;
        [textFields enumerateObjectsUsingBlock:^(UITextField *textField, NSUInteger idx, BOOL * _Nonnull stop) {
            // 左右间距
            [textFieldConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(==textFieldMargin)-[textField]-(==textFieldMargin)-|"] options:0 metrics:@{@"textFieldMargin":@(textFieldMargin)} views:NSDictionaryOfVariableBindings(textField)]];
            [textFieldConstraints addObject:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:textFiledHeight]];
            // 第一个子控件顶部间距
            if (idx == 0) {
                [textFieldConstraints addObject:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textFieldView attribute:NSLayoutAttributeTop multiplier:1.f constant:textFieldMargin*0.5]];
            }
            // 最后一个子控件底部间距
            if (idx == textFields.count - 1) {
                [textFieldConstraints addObject:[NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:textFieldView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-textFieldMargin]];
            }
            // 子控件之间的垂直间距
            if (idx > 0) {
                NSLayoutConstraint *paddingConstraint = [NSLayoutConstraint constraintWithItem:textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:textFields[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0];
                [textFieldConstraints addObject:paddingConstraint];
            }
        }];
        [textFieldView addConstraints:textFieldConstraints];
    } else {
        // 自定义titleView时，这里的titleView就是customTitleView
        [titleViewConstraints addObject:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customTitleViewSize.width]];
        [titleViewConstraints addObject:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:headerScrollContentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView)]];
        [titleViewConstraints addObject:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customTitleViewSize.height]];
        [headerScrollContentView addConstraints:titleViewConstraints];
    }

    // 先强制布局一次，否则下面拿到的CGRectGetMaxY(titleView.frame)还没有值
    [headerBezelView setNeedsLayout]; // 确保一定走layoutSubViews(异步)
    [headerBezelView layoutIfNeeded]; // 立即调用layoutSubViews
    // 设置headerBezelView的高度(这个高度同样可以通过计算titleLabel和detailTitleLabel的文字高度计算出来,但是那样计算出来的高度会有零点几的误差,只要差了一点,有可能scrollView即便内容没有超过contentSize,仍然能够滑动)
    CGRect rect;
    if (!self.customTitleView) {
        rect = self.textFields.count ? textFieldView.frame : titleView.frame;
    } else {
        rect = titleView.frame;
    }
    headerBezelViewContsraintHeight.constant = CGRectGetMaxY(rect);
    
    // ----------------------------------------------------------------------------
    
    [actionBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionBezelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionBezelView)]];
    [actionBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[headerBezelView]-%f-[actionBezelView]-0-|",headerActionPadding] options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionBezelView,headerBezelView)]];
    NSLayoutConstraint *actionBezelViewHeightContraint = [NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionBezelHeight];
    // 设置优先级，要比上面headerBezelViewContraintHeight的优先级低,这样当文字过多和action同时过多时，都超出了最大限制，此时优先展示文字
    actionBezelViewHeightContraint.priority = 997.0f;
        // 计算最小高度
    CGFloat minActionHeight = [self minActionHeight:footerTopMargin];
    NSLayoutConstraint *minActionHeightConstraint = [NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:minActionHeight];
    [actionBezelViewConstraints addObject:minActionHeightConstraint];
    
    [actionBezelViewConstraints addObject:actionBezelViewHeightContraint];
    [alertView addConstraints:actionBezelViewConstraints];
    
    // 如果customCenterView有值，actionBezelContentView就是customCenterView
    if (!self.customCenterView) {
        [actionBezelContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionBezelContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionBezelContentView)]];
    } else {
        [actionBezelContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionBezelContentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customCenterViewSize.width]];
        [actionBezelContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionBezelContentView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    }
    [actionBezelContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[actionBezelContentView]-%f-[footerView]-0-|",footerTopMargin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionBezelContentView,footerView)]];
    [actionBezelView addConstraints:actionBezelContentViewConstraints];
    
    if (!self.customFooterView) { // 不是自定义的footerView
        [footerViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[footerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerView)]];
        [footerViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[actionBezelContentView]-%f-[footerView]-0-|",footerTopMargin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerView,actionBezelContentView)]];
        // 这个条件判断需不需要footerView，不满足条件footerView的高度就给0
        if ((self.preferredStyle == SPAlertControllerStyleActionSheet && self.cancelAction) || (self.preferredStyle == SPAlertControllerStyleAlert && (self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert) && self.actions.count)) {
            [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionHeight]];
        } else {
            // 不满足条件，高度置为0，注意给0和不给高度是两回事，给0至少footerView有一个高度约束，不给的话就没有高度约束，这会导致tableView的底部间距设置无效，从而导致tableView不显示
            [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0]];
        }
        [actionBezelView addConstraints:footerViewConstraints];
        
        NSArray *footerActionViews = footerView.subviews;
        if (footerActionViews.count && ((self.preferredStyle == SPAlertControllerStyleActionSheet && self.cancelAction) || (self.preferredStyle == SPAlertControllerStyleAlert && self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert))) {
            [footerActionViews enumerateObjectsUsingBlock:^(SPAlertControllerActionCell *footerActionView, NSUInteger idx, BOOL * _Nonnull stop) {
                // 设置footerActionView的上下间距
                [footerActionViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[footerActionView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerActionView)]];
                // 第一个footerActionView的左间距
                if (idx == 0) {
                    [footerActionViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerActionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeLeft multiplier:1.f constant:0]];
                }
                // 最后一个itemView的右间距
                if (idx == footerActionViews.count-1) {
                    [footerActionViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerActionView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:footerView attribute:NSLayoutAttributeRight multiplier:1.f constant:-0]];
                }
                
                if (idx > 0) {
                    // 子控件之间的水平间距
                    [footerActionViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerActionView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:footerActionViews[idx - 1] attribute:NSLayoutAttributeRight multiplier:1.f constant:0.5]];
                    // 等宽
                    [footerActionViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerActionView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:footerActionViews[idx - 1] attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
                }
                // 在这里，这个cell的contentView没有任何作用，但是为了消除控制台打印的contentView应该给一个高度的警告，这里给一个0
                [footerActionView.contentView addConstraint:[NSLayoutConstraint constraintWithItem:footerActionView.contentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:0]];
            }];
            
            [footerView addConstraints:footerActionViewConstraints];
        }
    } else { // 是自定义的footerView
        // 自定义titleView时，这里的titleView就是customTitleView
        [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customFooterViewSize.width]];
        actionBezelView.backgroundColor = [UIColor redColor];
        actionBezelContentView.backgroundColor = [UIColor greenColor];
        if (!self.actions.count) { // 一个action都没有，也就是actionBezelContentView高度为0
            [footerViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0.5-[footerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerView)]];
        } else { // 有action，也就是actionBezelContentView必须要有高度，因此这里footerView要给高度，系统才能计算出actionBezelContentView的剩余空间
            [footerViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[actionBezelContentView]-%f-[footerView]-0-|",footerTopMargin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerView,actionBezelContentView)]];
            [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customFooterViewSize.height]];
        }
        [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];

        [actionBezelView addConstraints:footerViewConstraints];
    }
    
    // 强制布局，立刻产生frame
    [self.view layoutIfNeeded];
    // 如果有文本输入框，让头部scrollVIew自动滚动到最底端(这是为了当文字过多时，可以立即滚动到第一个输入框的位置)
    if (self.textFields.count) {
        UITextField *firstTextField = self.textFields.firstObject;
        [self.headerScrollView scrollRectToVisible:firstTextField.frame animated:YES];
    }
    
    self.headerBezelViewConstraints = headerBezelViewConstraints;
    self.headerScrollContentViewConstraints  = headerScrollContentViewConstraints;
    self.titleViewConstraints  = titleViewConstraints;
    self.titleLabelConstraints = titleLabelConstraints;
    self.textFieldViewConstraints = texFieldViewConstraints;
    self.textFieldConstraints = textFieldConstraints;
    self.actionBezelViewConstraints = actionBezelViewConstraints;
    self.actionBezelContentViewConstraints = actionBezelContentViewConstraints;
    self.footerViewConstraints = footerViewConstraints;
    self.footerActionViewConstraints = footerActionViewConstraints;
    
}

// 布局自定义的view
- (void)layoutCustomView {

    UIView *alertView = self.alertView;
    UIView *customView = self.customView;
    
    NSMutableArray *customViewConstraints = [NSMutableArray array];
    if (self.customViewConstraints) {
        [alertView removeConstraints:self.customViewConstraints];
        self.customViewConstraints = nil;
    }
    [customViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[customView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(customView)]];
    [customViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[customView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(customView)]];
    [alertView addConstraints:customViewConstraints];

    self.customViewConstraints = customViewConstraints;
}

- (CGFloat)actionBezelHeight:(CGFloat)footerTopMargin {
    CGFloat actionBezelHeight = 0;
    // 计算actionBezelview的高度
    if (self.actions.count) {
        if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
            if (self.cancelAction) { // 有取消按钮肯定没有自定义footerView
                if (self.actions.count > 1) {
                    actionBezelHeight = self.actions.count*actionHeight+footerTopMargin;
                } else {
                    if (self.customCenterView) { // 当有自定义的customCenterView时，最多只会有1个action，在addAction:方法里做了处理
                        actionBezelHeight = actionHeight+footerTopMargin+_customCenterViewSize.height;
                    } else {
                        actionBezelHeight = actionHeight+footerTopMargin;
                    }
                }
            } else {
                if (self.customCenterView) {
                    actionBezelHeight = _customCenterViewSize.height;
                } else {
                    if (self.customFooterView) {
                        actionBezelHeight = self.actions.count*actionHeight+_customFooterViewSize.height;
                    } else {
                        actionBezelHeight = self.actions.count*actionHeight;
                    }
                }
            }
        } else if (self.preferredStyle == SPAlertControllerStyleAlert) {
            if (self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert) {
                if (!self.customCenterView) { // 当没有自定义的customCenterView时，最多只会有_maxNumberOfActionHorizontalArrangementForAlert个action，在addAction:方法里做了处理
                    if (self.customFooterView) {
                        actionBezelHeight = _customFooterViewSize.height + actionHeight;
                    } else {
                        actionBezelHeight = actionHeight;
                    }
                } else { // _maxNumberOfActionHorizontalArrangementForAlert个以上action且customCenterView有值
                    actionBezelHeight = _customCenterViewSize.height + actionHeight;
                }
            } else {
                if (self.customFooterView) {
                    actionBezelHeight = _customFooterViewSize.height+self.actions.count*actionHeight;
                } else {
                    actionBezelHeight = self.actions.count*actionHeight;
                }
            }
        }
    } else {
        if (self.customCenterView) {
            actionBezelHeight = _customCenterViewSize.height;
        } else {
            if (self.customFooterView) {
                actionBezelHeight = _customFooterViewSize.height;
            }
        }
    }
    return actionBezelHeight;
}

- (CGFloat)minActionHeight:(CGFloat)footerTopMargin {
    CGFloat minActionHeight = 0;
    if (self.cancelAction) {
        if (self.actions.count > 3) { // 有一个取消按钮且其余按钮在3个或3个以上
            minActionHeight = 3.5*actionHeight+footerTopMargin;
        } else {
            minActionHeight = self.actions.count * actionHeight + footerTopMargin;
        }
    } else {
        if (self.actions.count > 3) { // 没有取消按钮，其余按钮在3个或3个以上
            if (self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert) {
                minActionHeight = minActionHeight;
            } else {
                minActionHeight = 3.5 * actionHeight;
            }
        } else {
            if (self.preferredStyle == SPAlertControllerStyleAlert) {
                if (self.actions.count) {
                    minActionHeight = actionHeight;
                }
            } else {
                minActionHeight = self.actions.count * actionHeight;
            }
        }
    }
    // 如果是自定义的footerView，高度还要在上面计算的基础上加上footerView的高度
    if (self.customFooterView) {
        minActionHeight = minActionHeight+_customFooterViewSize.height;
    }
    return minActionHeight;
}

#pragma mark - setter
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = title;
    if (!self.titleLabel.superview) {
        if (_detailTitleLabel) {
            [self.titleView insertSubview:_titleLabel belowSubview:_detailTitleLabel];
        } else {
            [self.titleView addSubview:_titleLabel];
        }
    }
    [self.view setNeedsUpdateConstraints];
}

- (void)setMessage:(NSString *)message {
    _message = [message copy];
    self.detailTitleLabel.text = message;
    if (!self.detailTitleLabel.superview) {
        [self.titleView addSubview:_detailTitleLabel];
    }
    [self.view setNeedsUpdateConstraints];
}

- (void)setTitleColor:(UIColor *)titleColor {
    _titleColor = titleColor;
    self.titleLabel.textColor = titleColor;
}

- (void)setTitleFont:(UIFont *)titleFont {
    _titleFont = titleFont;
    self.titleLabel.font = titleFont;
}

- (void)setMessageColor:(UIColor *)messageColor {
    _messageColor = messageColor;
    self.detailTitleLabel.textColor = messageColor;
}

- (void)setMessageFont:(UIFont *)messageFont {
    _messageFont = messageFont;
    self.detailTitleLabel.font = messageFont;
}

- (void)setNeedBlur:(BOOL)needBlur {
    _needBlur = needBlur;
    if (!needBlur) {
        self.alertView.backgroundColor = [UIColor colorWithDisplayP3Red:200.0/255.0 green:200.0/255.0 blue:200.0/255.0 alpha:1];
        [self.alertEffectView removeFromSuperview];
        self.alertEffectView = nil;
    } else {
        
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
        UIVisualEffectView *alertEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        alertEffectView.frame = self.alertView.bounds;
        alertEffectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.alertView insertSubview:alertEffectView atIndex:0];
    }
}

- (void)setMaxTopMarginForActionSheet:(CGFloat)maxTopMarginForActionSheet {
    _maxTopMarginForActionSheet = maxTopMarginForActionSheet;
    if (self.customView) {
        [self layoutCustomView];
    } else {
        [self layoutViewConstraints];
    }
}

- (void)setMaxMarginForAlert:(CGFloat)maxMarginForAlert {
    _maxMarginForAlert = maxMarginForAlert;
    if (self.customView) {
        [self layoutCustomView];
    } else {
        // 检查一下customTitleViewSize和customCenterView的宽度是否大于了新的对话框的宽度
        if (self.preferredStyle == SPAlertControllerStyleAlert) {
            if (_customTitleViewSize.width >= ScreenWidth-2*maxMarginForAlert) {
                _customTitleViewSize.width = ScreenWidth-2*maxMarginForAlert;
            }
            if (_customCenterViewSize.width >= ScreenWidth-2*maxMarginForAlert) {
                _customCenterViewSize.width = ScreenWidth-2*maxMarginForAlert;
            }
            if (_customFooterViewSize.width >= ScreenWidth-2*maxMarginForAlert) {
                _customFooterViewSize.width = ScreenWidth-2*maxMarginForAlert;
            }
        } else {
            if (_customTitleViewSize.width >= ScreenWidth) {
                _customTitleViewSize.width = ScreenWidth;
            }
            if (_customCenterViewSize.width >= ScreenWidth) {
                _customCenterViewSize.width = ScreenWidth;
            }
            if (_customFooterViewSize.width >= ScreenWidth) {
                _customFooterViewSize.width = ScreenWidth;
            }
        }
        
        [self layoutViewConstraints];
    }
}

- (void)setMaxNumberOfActionHorizontalArrangementForAlert:(NSInteger)maxNumberOfActionHorizontalArrangementForAlert {
    _maxNumberOfActionHorizontalArrangementForAlert = maxNumberOfActionHorizontalArrangementForAlert;
    if (self.customFooterView) {
        _maxNumberOfActionHorizontalArrangementForAlert = -1;
    }
}

- (void)setCornerRadiusForAlert:(CGFloat)cornerRadiusForAlert {
    _cornerRadiusForAlert = cornerRadiusForAlert;
    if (self.preferredStyle == SPAlertControllerStyleAlert) {
        self.view.layer.cornerRadius = cornerRadiusForAlert;
        self.view.layer.masksToBounds = YES;
    }
}

- (void)setOffsetYForAlert:(CGFloat)offsetYForAlert {
    _offsetYForAlert = offsetYForAlert;
}

- (void)setCustomView:(UIView *)customView {
    _customView = customView;
    [customView layoutIfNeeded];
    _customViewSize = customView.frame.size;
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.alertView addSubview:customView];
    [self layoutCustomView];
}

- (void)setCustomTitleView:(UIView *)customTitleView {
    _customTitleView = customTitleView;
    [customTitleView layoutIfNeeded];
    _customTitleViewSize = customTitleView.bounds.size;
    if (_customTitleViewSize.width <= 0 || _customTitleViewSize.width >= ScreenWidth-2*_maxMarginForAlert) {
        _customTitleViewSize.width = ScreenWidth-2*_maxMarginForAlert;
    }
    if (_customTitleViewSize.height <= 0) {
        NSLog(@"你的customTitleView高度为小于等于0,请设置一个高度");
    }
    customTitleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerScrollContentView addSubview:customTitleView];
}

- (void)setCustomCenterView:(UIView *)customCenterView {
    _customCenterView = customCenterView;
    [customCenterView layoutIfNeeded];
    _customCenterViewSize = customCenterView.bounds.size;
    if (_customCenterViewSize.width <= 0 || _customCenterViewSize.width >= ScreenWidth-2*_maxMarginForAlert) {
        _customCenterViewSize.width = ScreenWidth-2*_maxMarginForAlert;
    }
    if (_customCenterViewSize.height <= 0) {
        NSLog(@"你的customCenterView高度为小于等于0,请设置一个高度");
    }
    customCenterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionBezelView addSubview:customCenterView];
}

- (void)setCustomFooterView:(UIView *)customFooterView {
    _customFooterView = customFooterView;
    [customFooterView layoutIfNeeded];
    _customFooterViewSize = customFooterView.bounds.size;
    if (_customFooterViewSize.width <= 0 || _customFooterViewSize.width >= ScreenWidth-2*_maxMarginForAlert) {
        _customFooterViewSize.width = ScreenWidth-2*_maxMarginForAlert;
    }
    if (_customFooterViewSize.height <= 0) {
        NSLog(@"你的customFooterView高度为小于等于0,请设置一个高度");
    }
    customFooterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionBezelView addSubview:customFooterView];
}

#pragma mark - getter

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        _titleLabel.numberOfLines = 0;
        _titleLabel.font = [UIFont boldSystemFontOfSize:17];
        // 设置垂直方向的抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [_titleLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        [_titleLabel sizeToFit];
        
    }
    return _titleLabel;
}

- (UILabel *)detailTitleLabel {
    if (!_detailTitleLabel) {
        _detailTitleLabel = [[UILabel alloc] init];
        _detailTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _detailTitleLabel.textAlignment = NSTextAlignmentCenter;
        _detailTitleLabel.numberOfLines = 0;
        _detailTitleLabel.font = [UIFont systemFontOfSize:14];
        _detailTitleLabel.alpha = 0.5;
        // 设置垂直方向的抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [_detailTitleLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        [_detailTitleLabel sizeToFit];
    }
    return _detailTitleLabel;
}

- (NSArray<SPAlertAction *> *)actions {
    if (!_actions) {
        _actions = [NSArray array];
    }
    return _actions;
}

- (NSArray<UITextField *> *)textFields {
    if (!_textFields) {
        _textFields = [NSArray array];
    }
    return _textFields;
}

#pragma mark - 通知
- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (!self.keyboardShow) { // 如果键盘是隐藏状态，本次弹出键盘才去改变alert的中心偏移，否则如果键盘已经是显示状态,什么都不做
        CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardEndY = keyboardEndFrame.origin.y;
        
        CGFloat diff = fabs((self.view.center.y-keyboardEndY*0.5));
        // 改变alertView的中心y值，以至于不被键盘遮挡
        self.offsetYForAlert = -diff;
    }
    self.keyboardShow = YES;
}

- (void)keyboardDidHide:(NSNotification *)notification {
    self.keyboardShow = NO;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [SPAlertAnimation animationIsPresenting:YES];
}

- (nullable id <UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    [self.view endEditing:YES];
    return [SPAlertAnimation animationIsPresenting:NO];
}

- (nullable UIPresentationController *)presentationControllerForPresentedViewController:(UIViewController *)presented presentingViewController:(nullable UIViewController *)presenting sourceViewController:(UIViewController *)source NS_AVAILABLE_IOS(8_0) {
    return [[SPAlertPresentationController alloc] initWithPresentedViewController:presented presentingViewController:presenting];
}

@end

#pragma mark ---------------------------- SPAlertController end --------------------------------

#pragma mark ---------------------------- SPAlertPresentationController begin --------------------------------

@interface SPAlertPresentationController()
@property (nonatomic, strong) UIView *overlayView;
@property (nonatomic, strong) NSMutableArray *presentedViewConstraints;
@end

@implementation SPAlertPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        self.presentedView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return self;
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    
    SPAlertController *alertController = (SPAlertController *)self.presentedViewController;
    CGFloat maxTopMarginForActionSheet = alertController.maxTopMarginForActionSheet;
    CGFloat maxMarginForAlert = alertController.maxMarginForAlert;
    CGFloat topMarginForAlert = isIPhoneX ? (maxMarginForAlert+44):maxMarginForAlert;
    CGFloat bottomMarginForAlert = isIPhoneX ? (maxMarginForAlert+34):maxMarginForAlert;
    
    UIView *presentedView = self.presentedView;
    
    NSMutableArray *presentedViewConstraints = [NSMutableArray array];
    if (self.presentedViewConstraints) {
        [self.containerView removeConstraints:self.presentedViewConstraints];
        self.presentedViewConstraints = nil;
    }
    UIView *customView = alertController.customView;
    if (!customView) { // 非自定义
        if (alertController.preferredStyle == SPAlertControllerStyleActionSheet) {
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:ScreenWidth]];
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            if (alertController.animationType == SPAlertAnimationTypeDropDown) {
                [presentedViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[presentedView]-(>=alertBottomMargin)-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet),@"alertBottomMargin":@(alertBottomMargin)} views:NSDictionaryOfVariableBindings(presentedView)]];
            } else {
                [presentedViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=maxTopMarginForActionSheet)-[presentedView]-(==alertBottomMargin)-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet),@"alertBottomMargin":@(alertBottomMargin)} views:NSDictionaryOfVariableBindings(presentedView)]];
            }
        } else if (alertController.preferredStyle == SPAlertControllerStyleAlert) {
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:(MIN(ScreenWidth, ScreenHeight)-2*maxMarginForAlert)]];
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0f constant:topMarginForAlert]];
            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-bottomMarginForAlert]];
            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:alertController.offsetYForAlert]];
            NSLog(@"--- %f",alertController.offsetYForAlert);
        }
    } else { // 自定义
        CGFloat alertH = alertController.customViewSize.height;
        CGFloat alertW = alertController.customViewSize.width;
        if (alertH > (self.containerView.bounds.size.height-maxTopMarginForActionSheet)) {
            alertH = (self.containerView.bounds.size.height-(topMarginForAlert+bottomMarginForAlert));
        }
        if (alertController.preferredStyle == SPAlertControllerStyleActionSheet) {
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:alertW]];
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            if (alertController.animationType == SPAlertAnimationTypeDropDown) {
                [presentedViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==maxTopMarginForActionSheet)-[presentedView]-(>=alertBottomMargin)-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet),@"alertBottomMargin":@(alertBottomMargin)} views:NSDictionaryOfVariableBindings(presentedView)]];
            } else {
                [presentedViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=maxTopMarginForActionSheet)-[presentedView]-(==alertBottomMargin)-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet),@"alertBottomMargin":@(alertBottomMargin)} views:NSDictionaryOfVariableBindings(presentedView)]];
            }
            
        } else {
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:alertW]];
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0f constant:topMarginForAlert]];
            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-bottomMarginForAlert]];
            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:alertController.offsetYForAlert]];
        }
        [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:alertH]];
    }
    [self.containerView addConstraints:presentedViewConstraints];
    
    self.presentedViewConstraints = presentedViewConstraints;
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    
    UIView *overlayView = [[UIView alloc] init];
    overlayView.frame = self.containerView.bounds;
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    overlayView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    overlayView.alpha = 0;
    [self.containerView addSubview:overlayView];
    _overlayView = overlayView;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOverlayView)];
    [overlayView addGestureRecognizer:tap];
    
    SPAlertController *alertController = (SPAlertController *)self.presentedViewController;
    for (int i = 0; i < alertController.textFields.count; i++) {
        UITextField *textField = alertController.textFields[i];
        [alertController.textFieldView addSubview:textField];
        if (i == 0) {
            [textField becomeFirstResponder];
        }
    }
    [alertController layoutViewConstraints];
}

- (void)presentationTransitionDidEnd:(BOOL)completed {
    [super presentationTransitionDidEnd:completed];

}

- (void)dismissalTransitionWillBegin {
    [super dismissalTransitionWillBegin];
}

- (void)dismissalTransitionDidEnd:(BOOL)completed {
    [super dismissalTransitionDidEnd:completed];
    if (completed) {
        [_overlayView removeFromSuperview];
        _overlayView = nil;
    }
}

- (CGRect)frameOfPresentedViewInContainerView{
    return self.presentedView.frame;
}

- (void)tapOverlayView {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{}];
}

@end

#pragma mark ---------------------------- SPAlertPresentationController end --------------------------------


#pragma mark ---------------------------- SPAlertAnimation begin --------------------------------

@interface SPAlertAnimation()
@property (nonatomic, assign) BOOL presenting;
@end

@implementation SPAlertAnimation

- (instancetype)initWithPresenting:(BOOL)isPresenting {
    if (self = [super init]) {
        self.presenting = isPresenting;
    }
    return self;
}

+ (instancetype)animationIsPresenting:(BOOL)isPresenting {
    return [[self alloc] initWithPresenting:isPresenting];
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(nullable id <UIViewControllerContextTransitioning>)transitionContext {
    return 0.25f;
}

- (void)animateTransition:(id <UIViewControllerContextTransitioning>)transitionContext {
    if (self.presenting) {
        [self presentAnimationTransition:transitionContext];
    } else {
        [self dismissAnimationTransition:transitionContext];
    }
}

- (void)presentAnimationTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    SPAlertController *alertController = (SPAlertController *)[transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGSize controlViewSize = alertController.view.bounds.size;
    
    // 获取presentationController，注意不是presentedController
    SPAlertPresentationController *presentedController = (SPAlertPresentationController *)alertController.presentationController;
    UIView *overlayView = presentedController.overlayView;

    switch (alertController.animationType) {
        case SPAlertAnimationTypeRaiseUp:
            [self raiseUpWhenPresentForController:alertController
                                       transition:transitionContext
                                  controlViewSize:controlViewSize
                                      overlayView:overlayView];
            break;
        case SPAlertAnimationTypeDropDown:
            [self dropDownWhenPresentForController:alertController
                                        transition:transitionContext
                                   controlViewSize:controlViewSize
                                       overlayView:overlayView];

            break;
        case SPAlertAnimationTypeAlpha:
            [self alphaWhenPresentForController:alertController
                                     transition:transitionContext
                                controlViewSize:controlViewSize
                                    overlayView:overlayView];
            break;
        case SPAlertAnimationTypeExpand:
            [self expandWhenPresentForController:alertController
                                      transition:transitionContext
                                 controlViewSize:controlViewSize
                                     overlayView:overlayView];
            break;
        case SPAlertAnimationTypeShrink:
            [self shrinkWhenPresentForController:alertController
                                      transition:transitionContext
                                 controlViewSize:controlViewSize
                                     overlayView:overlayView];
            break;
        default:
            break;
    }
    
}

- (void)dismissAnimationTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    SPAlertController *alertController = (SPAlertController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGSize controlViewSize = alertController.view.bounds.size;
    // 获取presentationController，注意不是presentedController
    SPAlertPresentationController *presentedController = (SPAlertPresentationController *)alertController.presentationController;
    UIView *overlayView = presentedController.overlayView;
    
    switch (alertController.animationType) {
        case SPAlertAnimationTypeRaiseUp:
            [self dismissCorrespondingRaiseUpForController:alertController
                                                transition:transitionContext
                                           controlViewSize:controlViewSize
                                               overlayView:overlayView];
            break;
        case SPAlertAnimationTypeDropDown:
            [self dismissCorrespondingDropDownForController:alertController
                                                 transition:transitionContext
                                            controlViewSize:controlViewSize
                                                overlayView:overlayView];
            break;

        case SPAlertAnimationTypeAlpha:
            [self dismissCorrespondingAlphaForController:alertController
                                              transition:transitionContext
                                         controlViewSize:controlViewSize
                                             overlayView:overlayView];
            break;
        case SPAlertAnimationTypeExpand:
            [self dismissCorrespondingExpandForController:alertController
                                               transition:transitionContext
                                          controlViewSize:controlViewSize
                                              overlayView:overlayView];
            break;
        case SPAlertAnimationTypeShrink:
            [self dismissCorrespondingShrinkForController:alertController
                                               transition:transitionContext
                                          controlViewSize:controlViewSize
                                              overlayView:overlayView];
            break;
        default:
            break;
    }
    
}

// 从底部忘上弹的present动画
- (void)raiseUpWhenPresentForController:(SPAlertController *)alertController
                             transition:(id<UIViewControllerContextTransitioning>)transitionContext
                        controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.y = ScreenHeight;
    alertController.view.frame = controlViewFrame;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = ScreenHeight-controlViewSize.height;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// 从底部往上弹对应的dismiss动画
- (void)dismissCorrespondingRaiseUpForController:(SPAlertController *)alertController
                             transition:(id<UIViewControllerContextTransitioning>)transitionContext
                        controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = ScreenHeight;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}


// 从顶部往下弹的present动画
- (void)dropDownWhenPresentForController:(SPAlertController *)alertController
                              transition:(id<UIViewControllerContextTransitioning>)transitionContext
                         controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.y = -controlViewSize.height;
    alertController.view.frame = controlViewFrame;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = 0;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// 从顶部往下弹对应的dismiss动画
- (void)dismissCorrespondingDropDownForController:(SPAlertController *)alertController
                                      transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                 controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = -controlViewSize.height;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// alpha值从0到1变化的present动画
- (void)alphaWhenPresentForController:(SPAlertController *)alertController
                             transition:(id<UIViewControllerContextTransitioning>)transitionContext
                        controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    
    alertController.view.alpha = 0;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.alpha = 1.0;
        overlayView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// alpha值从0到1变化对应的的dismiss动画
- (void)dismissCorrespondingAlphaForController:(SPAlertController *)alertController
                                       transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                  controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.alpha = 0;
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// 发散的prensent动画
- (void)expandWhenPresentForController:(SPAlertController *)alertController
                           transition:(id<UIViewControllerContextTransitioning>)transitionContext
                      controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {

    alertController.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:20 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformIdentity;
        overlayView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 发散对应的dismiss动画
- (void)dismissCorrespondingExpandForController:(SPAlertController *)alertController
                                    transition:(id<UIViewControllerContextTransitioning>)transitionContext
                               controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformMakeScale(0, 0);
        overlayView.alpha = 0.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// 收缩的present动画
- (void)shrinkWhenPresentForController:(SPAlertController *)alertController
                            transition:(id<UIViewControllerContextTransitioning>)transitionContext
                       controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
   
    alertController.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformIdentity;
        overlayView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 收缩对应的的dismiss动画
- (void)dismissCorrespondingShrinkForController:(SPAlertController *)alertController
                                     transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                controlViewSize:(CGSize)controlViewSize overlayView:(UIView *)overlayView {
    // 与发散对应的dismiss动画相同
    [self dismissCorrespondingExpandForController:alertController transition:transitionContext controlViewSize:controlViewSize overlayView:overlayView ];
}

@end

#pragma mark ---------------------------- SPAlertAnimation end --------------------------------

