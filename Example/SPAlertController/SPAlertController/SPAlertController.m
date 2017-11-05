//
//  SPAlertController.m
//  SPAlertController
//
//  Created by 乐升平 on 17/10/12.
//  Copyright © 2017年 iDress. All rights reserved.
//

#import "SPAlertController.h"

#define actionHeight 48.0
#define actionColor [UIColor colorWithWhite:1.0 alpha:0.8]
#define alertColor [UIColor colorWithWhite:1.0 alpha:0.5]

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


@interface SPAlertControllerActionCell : UITableViewCell
@property (nonatomic, strong) SPAlertAction *action;
@property (nonatomic, weak) UILabel *titleLabel;
@property (nonatomic, strong) NSMutableArray *titleLabelConstraints;
@end

@implementation SPAlertControllerActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        // 设置背景透明，默认是白色，白色会阻挡分割线的毛玻璃效果
        self.backgroundColor = [UIColor clearColor];
        // contentView默认是透明色，给一个颜色，更加突出分割线（contentView的高度比cell小0.5，0.5就是分割线的额高度）
        self.contentView.backgroundColor = actionColor;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        // 设置垂直方向的抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [titleLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [titleLabel sizeToFit];
        [self.contentView addSubview:titleLabel];
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
    UILabel *titleLabel = self.titleLabel;
    
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
    if (self.titleLabelConstraints) {
        [self.contentView removeConstraints:self.titleLabelConstraints];
        self.titleLabelConstraints = nil;
    }

    [titleLabelConstraints addObject:[NSLayoutConstraint constraintWithItem:titleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.contentView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"H:|-(>=0)-[titleLabel]-(>=0)-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
    [titleLabelConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[titleLabel]-0-|"] options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleLabel)]];
    [self.contentView addConstraints:titleLabelConstraints];
    self.titleLabelConstraints = titleLabelConstraints;
    [super updateConstraints];
}

+ (BOOL)requiresConstraintBasedLayout {
    return YES;
}


@end

@interface SPAlertController () <UIViewControllerTransitioningDelegate,UITableViewDataSource,UITableViewDelegate>

@property (nonatomic, weak) UIView *backgroundView;
@property (nonatomic, strong) NSMutableArray *backgroundViewConstraints;

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
@property (nonatomic, strong) NSMutableArray *alertViewConstraints;
@property (nonatomic, strong) NSMutableArray *effectViewConstraints;
@property (nonatomic, strong) NSMutableArray *headerBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *headerScrollViewConstraints;
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
@property (nonatomic, strong) NSMutableArray *actionTableViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerActionViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerActionViewContentViewConstraints;

// ---------------- 自定义view --------------
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIView *customTitleView;
@property (nonatomic, strong) UIView *customCenterView;
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

@property (nonatomic, assign) CGFloat customCenterViewH;
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
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:customView customTitleView:nil customCenterView:nil];
    return alertController;
}

+ (instancetype)alertControllerWithPreferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customTitleView:(nullable UIView *)customTitleView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:nil message:nil preferredStyle:preferredStyle animationType:animationType customView:nil customTitleView:customTitleView customCenterView:nil];
    return alertController;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customCenterView:(UIView *)customCenterView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:nil customTitleView:nil customCenterView:customCenterView];
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
        if (action.style == SPAlertActionStyleCancel) {
            self.cancelAction = action;
            [self createFooterActionView:action];
        }
        self.dataSource = self.cancelAction ? [array subarrayWithRange:NSMakeRange(0, array.count-1)].copy : array.copy;
    } else {
        if (self.actions.count <= 2) {
            [self createFooterActionView:action];
            // 当只有2个action时，不需要tableView，这里没有移除tableView，而是清空数据源，如果直接移除tableView，当大于2个action时又得加回来
            self.dataSource = nil;
        } else {
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
            if (weakSelf.actions.count <= 2) {
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
    [self.textFieldView addSubview:textField];
    
    NSMutableArray *array = self.textFields.mutableCopy;
    [array addObject:textField];
    self.textFields = array;
    
    UITextField *firstTextField = array.firstObject;
    // 成为第一响应者，这样一旦present出来后，键盘就会弹出
    [firstTextField becomeFirstResponder];
    
    if (configurationHandler) {
        configurationHandler(textField);
    }
    
    [self layoutViewConstraints];
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
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(UIView *)customView customTitleView:(UIView *)customTitleView customCenterView:(UIView *)customCenterView {
    
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
        [self setupViewsWithCustomView:customView customTitleView:customTitleView customCenterView:customCenterView];
        
        self.needBlur = YES;
        self.maxTopMarginForActionSheet = 0.0;
        self.maxMarginForAlert = 20.0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHide:) name:UIKeyboardDidHideNotification object:nil];
        
    }
    return self;
}

- (void)setupViewsWithCustomView:(UIView *)customView customTitleView:(UIView *)customTitleView customCenterView:(UIView *)customCenterView {
    UIView *backgroundView = [[UIView alloc] init];
    backgroundView.translatesAutoresizingMaskIntoConstraints = NO;
    backgroundView.backgroundColor = [UIColor blackColor];
    backgroundView.alpha = 0.0;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBackgroundView)];
    [backgroundView addGestureRecognizer:tap];
    [self.view addSubview:backgroundView];
    _backgroundView = backgroundView;
    
    UIView *alertView = [[UIView alloc] init];
    alertView.translatesAutoresizingMaskIntoConstraints = NO;
    // 设置白色透明度，会让毛玻璃效果变淡一些
    alertView.backgroundColor = alertColor;
    if (self.preferredStyle == SPAlertControllerStyleAlert) {
        alertView.layer.cornerRadius = 5;
        alertView.layer.masksToBounds = YES;
    }
    [self.view addSubview:alertView];
    _alertView = alertView;
    
    if (!customView) {
        UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *alertEffectView = [[UIVisualEffectView alloc] initWithEffect:effect];
        alertEffectView.translatesAutoresizingMaskIntoConstraints = NO;
        [alertView addSubview:alertEffectView];
        _alertEffectView = alertEffectView;
        
        UIView *headerBezelView = [[UIView alloc] init];
        // 如果布局使用的是autolayout，一定要将对应的控件设置translatesAutoresizingMaskIntoConstraints为NO
        headerBezelView.translatesAutoresizingMaskIntoConstraints = NO;
        [alertView addSubview:headerBezelView];
        _headerBezelView = headerBezelView;
        
        // 创建头部scrollView
        UIScrollView *headerScrollView = [[UIScrollView alloc] init];
        headerScrollView.translatesAutoresizingMaskIntoConstraints = NO;
        headerScrollView.showsHorizontalScrollIndicator = NO;
        [headerBezelView addSubview:headerScrollView];
        _headerScrollView = headerScrollView;
        
        UIView *headerScrollContentView = [[UIView alloc] init];
        headerScrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
        headerScrollContentView.backgroundColor = actionColor;
        [headerScrollView addSubview:headerScrollContentView];
        _headerScrollContentView = headerScrollContentView;
        if (!customTitleView) {
            UIView *titleView = [[UIView alloc] init];
            titleView.translatesAutoresizingMaskIntoConstraints = NO;
            [headerScrollContentView addSubview:titleView];
            _titleView = titleView;
            
            UIView *textFieldView = [[UIView alloc] init];
            textFieldView.translatesAutoresizingMaskIntoConstraints = NO;
            [headerScrollContentView addSubview:textFieldView];
            _textFieldView.backgroundColor = [UIColor redColor];
            _textFieldView = textFieldView;
            
            if (self.title.length) {
                self.titleLabel.text = self.title;
            }
            if (self.message.length) {
                self.detailTitleLabel.text = self.message;
            }
        } else {
            self.customTitleView = customTitleView;
        }

        UIView *actionBezelView = [[UIView alloc] init];
        // 如果布局使用的是autolayout，一定要将对应的控件设置translatesAutoresizingMaskIntoConstraints为NO
        actionBezelView.translatesAutoresizingMaskIntoConstraints = NO;
        [alertView addSubview:actionBezelView];
        _actionBezelView = actionBezelView;
        
        if (!customCenterView) {

            UIView *actionBezelContentView = [[UIView alloc] init];
            actionBezelContentView.translatesAutoresizingMaskIntoConstraints = NO;
            [actionBezelView addSubview:actionBezelContentView];
            _actionBezelContentView = actionBezelContentView;
            
            UITableView *actionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
            actionTableView.translatesAutoresizingMaskIntoConstraints = NO;
            actionTableView.showsHorizontalScrollIndicator = NO;
            actionTableView.alwaysBounceVertical = NO; // tableView内容没有超出contentSize时，禁止滑动
            actionTableView.backgroundColor = [UIColor clearColor];
            actionTableView.separatorColor = [UIColor clearColor];
            actionTableView.dataSource = self;
            actionTableView.delegate = self;
            [actionTableView registerClass:[SPAlertControllerActionCell class] forCellReuseIdentifier:NSStringFromClass([SPAlertControllerActionCell class])];
            [actionBezelContentView addSubview:actionTableView];
            _actionTableView = actionTableView;
        } else {
            self.customCenterView = customCenterView;
        }
        
        UIView *footerView = [[UIView alloc] init];
        footerView.translatesAutoresizingMaskIntoConstraints = NO;
        [_actionBezelView addSubview:footerView];
        _footerView = footerView;
        
        [self layoutViewConstraints];
    } else {
        self.customView = customView;
    }
}

- (void)createFooterActionView:(SPAlertAction *)action {
    // 直接拿一个cell来创建,因为cell中有label，而且也方便统一处理
    SPAlertControllerActionCell *footerActionView = [[SPAlertControllerActionCell alloc] init];
    footerActionView.backgroundColor = actionColor;
    // 注意:footerActionView和它的contentView要同时为NO，如果contentView不为NO，系统默认是YES，contetnView是不会自动布局的，而且要手动对contentView布局
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
        if (self.actions.count <= 2) {
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

- (void)tapBackgroundView {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark - 布局
- (void)layoutViewConstraints {
    
    if (self.customView) {
        return;
    }
    CGFloat maxTopMarginForActionSheet = self.maxTopMarginForActionSheet;
    CGFloat maxMarginForAlert = self.maxMarginForAlert;
    
    UIView *backgroundView = self.backgroundView;
    UIView *alertView = self.alertView;
    UIView *alertEffectView = self.alertEffectView;
    UIView *headerBezelView = self.headerBezelView;
    UIScrollView *headerScrollView = self.headerScrollView;
    UIView *headerScrollContentView = self.headerScrollContentView;
    UIView *titleView = self.customTitleView ? self.customTitleView : self.titleView;
    UIView *textFieldView = self.textFieldView;
    UIView *actionBezelView = self.actionBezelView;
    UIView *actionBezelContentView = self.customCenterView ? self.customCenterView : self.actionBezelContentView;
    UIScrollView *actionTableView = self.actionTableView;
    UIView *footerView = self.footerView;
    
    // 预备相应控件的约束数组
    NSMutableArray *backgroundViewConstraints = [NSMutableArray array];
    NSMutableArray *alertViewConstraints = [NSMutableArray array];
    NSMutableArray *effectViewConstraints = [NSMutableArray array];
    NSMutableArray *headerBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *headerScrollViewConstraints = [NSMutableArray array];
    NSMutableArray *headerScrollContentViewConstraints = [NSMutableArray array];
    NSMutableArray *titleViewConstraints = [NSMutableArray array];
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
    NSMutableArray *texFieldViewConstraints = [NSMutableArray array];
    NSMutableArray *textFieldConstraints = [NSMutableArray array];
    NSMutableArray *actionBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *actionBezelContentViewConstraints = [NSMutableArray array];
    NSMutableArray *actionTableViewConstraints = [NSMutableArray array];
    NSMutableArray *footerViewConstraints = [NSMutableArray array];
    NSMutableArray *footerActionViewConstraints = [NSMutableArray array];
    
    // 移除存在的约束
    if (self.backgroundViewConstraints) {
        [self.view removeConstraints:backgroundViewConstraints];
        self.backgroundViewConstraints = nil;
    }
    if (self.alertViewConstraints) {
        [self.view removeConstraints:self.alertViewConstraints];
        self.alertViewConstraints = nil;
    }
    if (self.effectViewConstraints) {
        [alertView removeConstraints:self.effectViewConstraints];
        self.effectViewConstraints = nil;
    }
    if (self.headerBezelViewConstraints) {
        [alertView removeConstraints:self.headerBezelViewConstraints];
        self.headerBezelViewConstraints = nil;
    }
    if (self.headerScrollViewConstraints) {
        [headerBezelView removeConstraints:self.headerScrollViewConstraints];
        self.headerScrollViewConstraints = nil;
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
    if (self.actionTableViewConstraints) {
        [actionBezelView removeConstraints:self.actionTableViewConstraints];
        self.actionTableViewConstraints = nil;
    }
    if (self.footerViewConstraints) {
        [actionBezelView removeConstraints:self.footerViewConstraints];
        self.footerViewConstraints = nil;
    }
    if (self.footerActionViewConstraints) {
        [footerView removeConstraints:self.footerActionViewConstraints];
        self.footerActionViewConstraints = nil;
    }
    if (self.footerActionViewContentViewConstraints.count) {
        for (int i = 0; i < self.footerActionViewContentViewConstraints.count; i++) {
            NSMutableArray *contentViewConstraints = self.footerActionViewContentViewConstraints[i];
            if (self.footerView.subviews.count > i) {
                UIView *footerActionView = self.footerView.subviews[i];
                [footerActionView removeConstraints:contentViewConstraints];
                contentViewConstraints = nil;
            }
        }
        self.footerActionViewContentViewConstraints = nil;
    }
    
    [backgroundViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backgroundView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backgroundView)]];
    [backgroundViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[backgroundView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backgroundView)]];
    [self.view addConstraints:backgroundViewConstraints];
    
    CGFloat margin = 15;
    CGFloat footerTopMargin = self.cancelAction ? 6.0 : 0.0;
    CGFloat headerActionPadding = (!titleView.subviews.count || !self.actions.count) ? 0 : 0.5;
    // 计算actionBezelView的高度
    CGFloat actionBezelHeight = [self actionBezelHeight:footerTopMargin];
    
    if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
        [alertViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[alertView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(alertView)]];
        [alertViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=maxTopMarginForActionSheet)-[alertView]-0-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet)} views:NSDictionaryOfVariableBindings(alertView)]];
    } else if (self.preferredStyle == SPAlertControllerStyleAlert) {
        [alertViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==maxMarginForAlert)-[alertView]-(==maxMarginForAlert)-|" options:0 metrics:@{@"maxMarginForAlert":@(maxMarginForAlert)} views:NSDictionaryOfVariableBindings(alertView)]];
        [alertViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=maxMarginForAlert)-[alertView]-(>=maxMarginForAlert)-|" options:0 metrics:@{@"maxMarginForAlert":@(maxMarginForAlert)} views:NSDictionaryOfVariableBindings(alertView)]];
        [alertViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
        _alertConstraintCenterY = [NSLayoutConstraint constraintWithItem:alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:0];
        [alertViewConstraints addObject:_alertConstraintCenterY];
    }
    [self.view addConstraints:alertViewConstraints];
    
    [effectViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[alertEffectView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(alertEffectView)]];
    [effectViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[alertEffectView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(alertEffectView)]];
    [alertView addConstraints:effectViewConstraints];
    
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
    
    [headerScrollViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerScrollView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollView)]];
    [headerScrollViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[headerScrollView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollView)]];
    [headerBezelView addConstraints:headerScrollViewConstraints];
    
    // 设置actionScrollContentView的相关约束，值得注意的是不能仅仅设置上下左右间距为0就完事了，对于scrollView的contentView， autoLayout布局必须设置宽或高约束
    [headerScrollContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerScrollContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollContentView)]];
    [headerScrollContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[headerScrollContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollContentView)]];
    [headerScrollContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerScrollContentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerScrollView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
    if (self.titleLabel.text.length || self.detailTitleLabel.text.length) {
        // 保证headerScrollContentView的高度最小为actionHeight
        [titleViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerScrollContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionHeight]];
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
        [titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[titleView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView)]];
        [titleViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[titleView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(titleView)]];
        [titleViewConstraints addObject:[NSLayoutConstraint constraintWithItem:titleView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:titleView.bounds.size.height]];
        [headerScrollContentView addConstraints:titleViewConstraints];
    }

    // 先强制布局一次，否则下面拿到的CGRectGetMaxY(titleView.frame)还没有值
    [headerBezelView layoutIfNeeded];
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
    // 设置优先级，要比上面headerBezelViewContraintHeight的优先级低
    actionBezelViewHeightContraint.priority = 997.0f;
    if (self.actions.count) {
        // 计算最小高度
        CGFloat minActionHeight = [self minActionHeight:footerTopMargin];
        [actionBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:minActionHeight]];
    }
    [actionBezelViewConstraints addObject:actionBezelViewHeightContraint];
    [alertView addConstraints:actionBezelViewConstraints];
    
    [actionBezelContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionBezelContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionBezelContentView)]];
    [actionBezelContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[actionBezelContentView]-%f-[footerView]-0-|",footerTopMargin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionBezelContentView,footerView)]];
    [actionBezelView addConstraints:actionBezelContentViewConstraints];
    
    if (!self.customCenterView) {
        [actionTableViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionTableView)]];
        [actionTableViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[actionTableView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionTableView,footerView)]];
        [actionBezelContentView addConstraints:actionTableViewConstraints];
    }
    
    [footerViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[footerView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerView)]];
    [footerViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:[NSString stringWithFormat:@"V:|-0-[actionBezelContentView]-%f-[footerView]-0-|",footerTopMargin] options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerView,actionBezelContentView)]];
    // 这个条件判断需不需要footerView，不满足条件footerView的高度就给0
    if ((self.preferredStyle == SPAlertControllerStyleActionSheet && self.cancelAction) || (self.preferredStyle == SPAlertControllerStyleAlert && (self.actions.count <= 2) && self.actions.count)) {
        [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionHeight]];
    } else {
        // 不满足条件，高度置为0，注意给0和不给高度是两回事，给0至少footerView有一个高度约束，不给的话就没有高度约束，这会导致tableView的底部间距设置无效，从而导致tableView不显示
        [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0]];
    }
    [actionBezelView addConstraints:footerViewConstraints];
    
    NSArray *footerActionViews = footerView.subviews;
    if (footerActionViews.count && ((self.preferredStyle == SPAlertControllerStyleActionSheet && self.cancelAction) || (self.preferredStyle == SPAlertControllerStyleAlert && self.actions.count <= 2))) {
        [footerActionViews enumerateObjectsUsingBlock:^(SPAlertControllerActionCell *footerActionView, NSUInteger idx, BOOL * _Nonnull stop) {
            //  设置footerActionView的上下间距
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
            UIView *contentView = footerActionView.contentView;
            NSMutableArray *contentViewConstraints = [NSMutableArray array];
            [contentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentView)]];
            [contentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[contentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(contentView)]];
            [contentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:contentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:footerActionView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
            [footerActionView addConstraints:contentViewConstraints];
            [self.footerActionViewContentViewConstraints addObject:contentViewConstraints];
            
        }];
        [footerView addConstraints:footerActionViewConstraints];
    }
    
    // 强制布局，立刻产生frame
    [self.view layoutIfNeeded];
    // 如果有文本输入框，让头部scrollVIew自动滚动到最底端(这是为了当文字过多时，可以立即滚动到第一个输入框的位置)
    if (self.textFields.count) {
        UITextField *firstTextField = self.textFields.firstObject;
        [self.headerScrollView scrollRectToVisible:firstTextField.frame animated:YES];
    }
    
    self.backgroundViewConstraints = backgroundViewConstraints;
    self.alertViewConstraints = alertViewConstraints;
    self.effectViewConstraints = effectViewConstraints;
    self.headerBezelViewConstraints = headerBezelViewConstraints;
    self.headerScrollViewConstraints = headerScrollViewConstraints;
    self.headerScrollContentViewConstraints  = headerScrollContentViewConstraints;
    self.titleViewConstraints  = titleViewConstraints;
    self.titleLabelConstraints = titleLabelConstraints;
    self.textFieldViewConstraints = texFieldViewConstraints;
    self.textFieldConstraints = textFieldConstraints;
    self.actionBezelViewConstraints = actionBezelViewConstraints;
    self.actionBezelContentViewConstraints = actionBezelContentViewConstraints;
    self.actionTableViewConstraints = actionTableViewConstraints;
    self.footerViewConstraints = footerViewConstraints;
    self.footerActionViewConstraints = footerActionViewConstraints;
}

// 布局自定义的view
- (void)layoutCustomView {
    
    CGFloat maxMarginForAlert = self.maxMarginForAlert;
    CGFloat maxTopMarginForActionSheet = self.maxTopMarginForActionSheet;
    
    UIView *backgroundView = self.backgroundView;
    UIView *alertView = self.alertView;
    UIView *customView = self.customView;
    
    NSMutableArray *backgroundViewConstraints = [NSMutableArray array];
    NSMutableArray *alertViewConstraints = [NSMutableArray array];
    NSMutableArray *customViewConstraints = [NSMutableArray array];
    
    if (self.backgroundViewConstraints) {
        [self.view removeConstraints:self.backgroundViewConstraints];
        self.backgroundViewConstraints = nil;
    }
    if (self.alertViewConstraints) {
        [self.view removeConstraints:self.alertViewConstraints];
        self.alertViewConstraints = nil;
    }
    if (self.customViewConstraints) {
        [alertView removeConstraints:self.customViewConstraints];
        self.customViewConstraints = nil;
    }
    
    [backgroundViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[backgroundView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backgroundView)]];
    [backgroundViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[backgroundView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(backgroundView)]];
    [self.view addConstraints:backgroundViewConstraints];
    
    CGRect customViewRect = customView.frame;
    CGFloat alertH = customViewRect.size.height;
    if (alertH > (self.view.bounds.size.height-2*maxMarginForAlert)) {
        alertH = (self.view.bounds.size.height-2*maxMarginForAlert);
    }
    if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
        [alertViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[alertView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(alertView)]];
        [alertViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=maxTopMarginForActionSheet)-[alertView]-0-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet)} views:NSDictionaryOfVariableBindings(alertView)]];
        
    } else {
        [alertViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-(==maxMarginForAlert)-[alertView]-(==maxMarginForAlert)-|" options:0 metrics:@{@"maxMarginForAlert":@(maxMarginForAlert)} views:NSDictionaryOfVariableBindings(alertView)]];
        [alertViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=maxMarginForAlert)-[alertView]-(>=maxMarginForAlert)-|" options:0 metrics:@{@"maxMarginForAlert":@(maxMarginForAlert)} views:NSDictionaryOfVariableBindings(alertView)]];
        [alertViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
    }
    [alertViewConstraints addObject:[NSLayoutConstraint constraintWithItem:alertView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:alertH]];
    [self.view addConstraints:alertViewConstraints];
    [customViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[customView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(customView)]];
    [customViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[customView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(customView)]];
    [alertView addConstraints:customViewConstraints];
    
    [self.view layoutIfNeeded];
    
    self.backgroundViewConstraints = backgroundViewConstraints;
    self.alertViewConstraints = alertViewConstraints;
    self.customViewConstraints = customViewConstraints;
}

- (CGFloat)actionBezelHeight:(CGFloat)footerTopMargin {
    CGFloat actionBezelHeight = 0;
    // 计算actionBezelview的高度
    if (self.actions.count) {
        if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
            if (self.cancelAction) {
                if (self.actions.count > 1) {
                    actionBezelHeight = self.actions.count*actionHeight+footerTopMargin;
                } else {
                    actionBezelHeight = actionHeight+footerTopMargin;
                }
            } else {
                actionBezelHeight = self.actions.count*actionHeight;
            }
        } else if (self.preferredStyle == SPAlertControllerStyleAlert) {
            if (self.actions.count <= 2) {
                if (!self.customCenterView) {
                    actionBezelHeight = actionHeight;
                } else { // 2个以下action且有自定义scrollView
                    actionBezelHeight = _customCenterViewH + actionHeight;
                }
            } else {
                actionBezelHeight = self.actions.count*actionHeight;
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
            minActionHeight = 3.5 * actionHeight;
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
    return minActionHeight;
}

#pragma mark - setter
- (void)setTitle:(NSString *)title {
    _title = [title copy];
    self.titleLabel.text = title;
    [self.view setNeedsUpdateConstraints];
}

- (void)setMessage:(NSString *)message {
    _message = [message copy];
    self.detailTitleLabel.text = message;
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
        self.alertView.backgroundColor = [UIColor lightGrayColor];
        self.alertEffectView.alpha = 0.0;
    } else {
        self.alertView.backgroundColor = alertColor;
        self.alertEffectView.alpha = 1.0;
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
        [self layoutViewConstraints];
    }
}

- (void)setAlertCornerRadius:(CGFloat)alertCornerRadius {
    _alertCornerRadius = alertCornerRadius;
    self.alertView.layer.cornerRadius = alertCornerRadius;
}

- (void)setOffsetY:(CGFloat)offsetY {
    _offsetY = offsetY;
    _alertConstraintCenterY.constant = -offsetY;
}

- (void)setCustomView:(UIView *)customView {
    _customView = customView;
    [customView layoutIfNeeded];
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.alertView addSubview:customView];
    [self layoutCustomView];
}

- (void)setCustomTitleView:(UIView *)customTitleView {
    _customTitleView = customTitleView;
    [customTitleView layoutIfNeeded];
    customTitleView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerScrollContentView addSubview:customTitleView];
}

- (void)setCustomCenterView:(UIView *)customCenterView {
    _customCenterView = customCenterView;
    [customCenterView layoutIfNeeded];
    _customCenterViewH = _customCenterView.bounds.size.height;
    customCenterView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.actionBezelView addSubview:customCenterView];
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
        if (_detailTitleLabel) {
            [self.titleView insertSubview:_titleLabel belowSubview:_detailTitleLabel];
        } else {
            [self.titleView addSubview:_titleLabel];
        }
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
        [self.titleView addSubview:_detailTitleLabel];
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

- (NSMutableArray *)footerActionViewContentViewConstraints {
    if (!_footerActionViewContentViewConstraints) {
        _footerActionViewContentViewConstraints = [NSMutableArray array];
    }
    return _footerActionViewContentViewConstraints;
}

#pragma mark - 通知
- (void)keyboardWillShow:(NSNotification *)notification {
    
    if (!self.keyboardShow) { // 如果键盘是隐藏状态，本次弹出键盘才去改变alert的中心偏移，否则如果键盘已经是显示状态,什么都不做
        CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
        CGFloat keyboardEndY = keyboardEndFrame.origin.y;
        
        CGFloat diff = fabs((self.view.center.y-keyboardEndY*0.5));
        // 改变alertView的中心y值，以至于不被键盘遮挡
        self.offsetY = diff;
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


@end

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
    CGFloat alertViewHeight = CGRectGetHeight(alertController.alertView.frame);
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    switch (alertController.animationType) {
        case SPAlertAnimationTypeRaiseUp:
            [self raiseUpWhenPresentForController:alertController
                                       transition:transitionContext
                                  alertViewHeight:alertViewHeight
                                     screenHeight:screenHeight];
            break;
        case SPAlertAnimationTypeDropDown:
            [self dropDownWhenPresentForController:alertController
                                        transition:transitionContext
                                   alertViewHeight:alertViewHeight
                                      screenHeight:screenHeight];

            break;
        case SPAlertAnimationTypeAlpha:
            [self alphaWhenPresentForController:alertController transition:transitionContext alertViewHeight:alertViewHeight screenHeight:screenHeight];
            break;
        case SPAlertAnimationTypeExpand:
            [self expandWhenPresentForController:alertController transition:transitionContext alertViewHeight:alertViewHeight screenHeight:screenHeight];
            break;
        case SPAlertAnimationTypeShrink:
            [self shrinkWhenPresentForController:alertController transition:transitionContext alertViewHeight:alertViewHeight screenHeight:screenHeight];
            break;
        default:
            break;
    }
    
}

- (void)dismissAnimationTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
        SPAlertController *alertController = (SPAlertController *)[transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    CGFloat alertViewHeight = CGRectGetHeight(alertController.alertView.frame);
    CGFloat screenHeight = [UIScreen mainScreen].bounds.size.height;
    switch (alertController.animationType) {
        case SPAlertAnimationTypeRaiseUp:
            [self dismissCorrespondingRaiseUpForController:alertController
                                                transition:transitionContext
                                           alertViewHeight:alertViewHeight
                                              screenHeight:screenHeight];
            break;
        case SPAlertAnimationTypeDropDown:
            [self dismissCorrespondingDropDownForController:alertController
                                                 transition:transitionContext
                                            alertViewHeight:alertViewHeight
                                               screenHeight:screenHeight];
            break;

        case SPAlertAnimationTypeAlpha:
            [self dismissCorrespondingAlphaForController:alertController transition:transitionContext alertViewHeight:alertViewHeight screenHeight:screenHeight];
            break;
        case SPAlertAnimationTypeExpand:
            [self dismissCorrespondingExpandForController:alertController transition:transitionContext alertViewHeight:alertViewHeight screenHeight:screenHeight];
            break;
        case SPAlertAnimationTypeShrink:
            [self dismissCorrespondingShrinkForController:alertController transition:transitionContext alertViewHeight:alertViewHeight screenHeight:screenHeight];
            break;
        default:
            break;
    }
    
}

// 从底部忘上弹的present动画
- (void)raiseUpWhenPresentForController:(SPAlertController *)alertController
                             transition:(id<UIViewControllerContextTransitioning>)transitionContext
                        alertViewHeight:(CGFloat)alertViewHeight
                           screenHeight:(CGFloat)screenHeight {
    
    alertController.backgroundView.alpha = 0.0;
    alertController.alertView.transform = CGAffineTransformMakeTranslation(0, alertViewHeight);
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        alertController.backgroundView.alpha = 0.5;
        alertController.alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// 从底部往上弹对应的dismiss动画
- (void)dismissCorrespondingRaiseUpForController:(SPAlertController *)alertController
                             transition:(id<UIViewControllerContextTransitioning>)transitionContext
                        alertViewHeight:(CGFloat)alertViewHeight
                           screenHeight:(CGFloat)screenHeight {
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        alertController.backgroundView.alpha = 0.0;
        alertController.alertView.transform = CGAffineTransformMakeTranslation(0, alertViewHeight);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}


// 从顶部往下弹的present动画
- (void)dropDownWhenPresentForController:(SPAlertController *)alertController
                              transition:(id<UIViewControllerContextTransitioning>)transitionContext
                         alertViewHeight:(CGFloat)alertViewHeight
                            screenHeight:(CGFloat)screenHeight {
    alertController.backgroundView.alpha = 0.0;
    alertController.alertView.transform = CGAffineTransformMakeTranslation(0, -screenHeight);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        alertController.backgroundView.alpha = 0.5;
        alertController.alertView.transform = CGAffineTransformMakeTranslation(0, -(screenHeight-alertViewHeight));
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// 从顶部往下弹对应的dismiss动画
- (void)dismissCorrespondingDropDownForController:(SPAlertController *)alertController
                                      transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                 alertViewHeight:(CGFloat)alertViewHeight
                                    screenHeight:(CGFloat)screenHeight {
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] animations:^{
        alertController.backgroundView.alpha = 0.0;
        alertController.alertView.transform = CGAffineTransformMakeTranslation(0, -screenHeight);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// alpha值从0到1变化的present动画
- (void)alphaWhenPresentForController:(SPAlertController *)alertController
                             transition:(id<UIViewControllerContextTransitioning>)transitionContext
                        alertViewHeight:(CGFloat)alertViewHeight
                           screenHeight:(CGFloat)screenHeight {
    
    alertController.backgroundView.alpha = 0.0;
    alertController.alertView.alpha = 0.0;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.backgroundView.alpha = 0.5;
        alertController.alertView.alpha = 1.0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// alpha值从0到1变化对应的的dismiss动画
- (void)dismissCorrespondingAlphaForController:(SPAlertController *)alertController
                                       transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                  alertViewHeight:(CGFloat)alertViewHeight
                                     screenHeight:(CGFloat)screenHeight {
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.backgroundView.alpha = 0;
        alertController.alertView.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// 发散的prensent动画
- (void)expandWhenPresentForController:(SPAlertController *)alertController
                           transition:(id<UIViewControllerContextTransitioning>)transitionContext
                      alertViewHeight:(CGFloat)alertViewHeight
                         screenHeight:(CGFloat)screenHeight {
    
    alertController.backgroundView.alpha = 0.0;
    alertController.alertView.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.backgroundView.alpha = 0.5;
        alertController.alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 发散对应的dismiss动画
- (void)dismissCorrespondingExpandForController:(SPAlertController *)alertController
                                    transition:(id<UIViewControllerContextTransitioning>)transitionContext
                               alertViewHeight:(CGFloat)alertViewHeight
                                  screenHeight:(CGFloat)screenHeight {
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.backgroundView.alpha = 0;
        alertController.alertView.transform = CGAffineTransformMakeScale(0, 0);
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
        
    }];
}

// 收缩的present动画
- (void)shrinkWhenPresentForController:(SPAlertController *)alertController
                            transition:(id<UIViewControllerContextTransitioning>)transitionContext
                       alertViewHeight:(CGFloat)alertViewHeight
                          screenHeight:(CGFloat)screenHeight {
    
    alertController.backgroundView.alpha = 0.0;
    alertController.alertView.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.backgroundView.alpha = 0.5;
        alertController.alertView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 收缩对应的的dismiss动画
- (void)dismissCorrespondingShrinkForController:(SPAlertController *)alertController
                                     transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                alertViewHeight:(CGFloat)alertViewHeight
                                   screenHeight:(CGFloat)screenHeight {
    // 与发散对应的dismiss动画相同
    [self dismissCorrespondingExpandForController:alertController transition:transitionContext alertViewHeight:alertViewHeight screenHeight:screenHeight];
}

@end


