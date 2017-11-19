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

#define ColorRGBA(r, g, b, a) [UIColor colorWithRed:(r)/255.0 green:(g)/255.0 blue:(b)/255.0 alpha:(a)]

#define lineColor [[UIColor grayColor] colorWithAlphaComponent:0.25]

#define normalColor [[UIColor whiteColor] colorWithAlphaComponent:0.65]
#define selectedColor [UIColor colorWithWhite:1 alpha:0.2]

#define actionHeight 49.0
#define lineWidth 0.5

#define isIPhoneX ([UIScreen mainScreen].bounds.size.height==812)
#define alertBottomMargin (([UIScreen mainScreen].bounds.size.height==812)||([UIScreen mainScreen].bounds.size.width==812) ? 34 : 0) // 适配iPhoneX

static NSString * const FOOTERCELL = @"footerCell";

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
        if (style == SPAlertActionStyleDestructive) {
            self.titleColor = [UIColor redColor];
        } else if (style == SPAlertActionStyleCancel) {
            self.titleColor = [UIColor blueColor];
        } else {
            self.titleColor = [UIColor blackColor];
        }
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
@property (nonatomic, strong) NSMutableArray *lineConstraints;
@end

@implementation SPAlertControllerActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        self.backgroundColor = [UIColor clearColor];
        // 取消选中高亮
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        UILabel *titleLabel = [[UILabel alloc] init];
        titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        // 设置垂直方向的抗压缩优先级,优先级越高越不容易被压缩,默认的优先级是750
        [titleLabel setContentCompressionResistancePriority:998.f forAxis:UILayoutConstraintAxisVertical];
        titleLabel.textAlignment = NSTextAlignmentCenter;
        titleLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
        [titleLabel sizeToFit];
        // footerCell指的是SPAlertControllerStyleActionSheet下的取消cell和SPAlertControllerStyleAlert下actions小于_maxNumberOfActionHorizontalArrangementForAlert时的cell
        // 这个cell因为要修改系统自带的布局，如果直接加在contentView上，修改contentView的布局很容易出问题，所以此时用不着contentView，而且这个cell跟tableView没有任何关系，就是一个普通的view
        if ([reuseIdentifier isEqualToString:FOOTERCELL]) {
            [self addSubview:titleLabel];
        } else {
            [self.contentView addSubview:titleLabel];
        }
        _titleLabel = titleLabel;
        
        _titleLabel.superview.backgroundColor = normalColor;

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

// 默认走带动画的setHighlighted
- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    if (highlighted) {
        // 高亮时设置contentView的白色0.2透明，如果用默认选中cell的样式或者直接设置self.selectedBackgroundView的颜色，则当cell高亮时分割线会跟着一起高亮， 分割线会看不见，所以只能对conntentView设置高亮，因为当有分割线存在时，contentView与cell之间上下是有间距的
        self.contentView.backgroundColor = selectedColor;
    } else {
        // 手指抬起时会来到这里
        self.backgroundColor = [UIColor clearColor];
        if (![self.reuseIdentifier isEqualToString:FOOTERCELL]) {
            self.contentView.backgroundColor = normalColor;
        } else {
            self.contentView.backgroundColor = [UIColor whiteColor];
        }
    }
}


- (void)updateConstraints {
    [super updateConstraints];

    UILabel *titleLabel = self.titleLabel;
    
    if (self.titleLabelConstraints) {
        [titleLabel.superview removeConstraints:self.titleLabelConstraints];
        self.titleLabelConstraints = nil;
    }
    if (self.lineConstraints) {
        [self.contentView removeConstraints:self.lineConstraints];
        self.lineConstraints = nil;
    }
    
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
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

@property (nonatomic, weak) UIView *alertView;
@property (nonatomic, weak) UIVisualEffectView *alertEffectView;

// ---------------- 关于头部控件 ---------------
@property (nonatomic, weak) UIView *headerBezelView;
@property (nonatomic, weak) UIView *headerView;
@property (nonatomic, weak) UIScrollView *headerScrollView;
@property (nonatomic, weak) UIView *headerScrollContentView; // autoLayout中需要在scrollView上再加一个view
@property (nonatomic, weak) UIView *titleView;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailTitleLabel;
@property (nonatomic, weak) UIView *textFieldView;
@property (nonatomic, weak) UIView *headerActionLine;

// ---------------- 关于头部控件的约束数组 -----------------
@property (nonatomic, strong) NSMutableArray *headerBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *headerViewConstraints;
@property (nonatomic, strong) NSMutableArray *headerScrollContentViewConstraints;
@property (nonatomic, strong) NSMutableArray *titleViewConstraints;
@property (nonatomic, strong) NSMutableArray *titleLabelConstraints;
@property (nonatomic, strong) NSMutableArray *textFieldViewConstraints;
@property (nonatomic, strong) NSMutableArray *textFieldConstraints;
@property (nonatomic, strong) NSMutableArray *headerActionLineConstraints;

// ---------------- 关于action控件 --------------
@property (nonatomic, weak) UIView *actionBezelView;
@property (nonatomic, weak) UIView *actionCenterView;
@property (nonatomic, weak) UITableView *actionTableView;
@property (nonatomic, weak) UIView *footerBezelView;
@property (nonatomic, weak) UIView *footerView;
@property (nonatomic, weak) UIView *footerTopLine;

// ---------------- 关于action控件的约束数组 -------------------
@property (nonatomic, strong) NSMutableArray *actionBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *actionCenterViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerBezelViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerCellConstraints;
@property (nonatomic, strong) NSMutableArray *footerViewConstraints;
@property (nonatomic, strong) NSMutableArray *footerTopLineConstraints;

// ---------------- 关于自定义view --------------
@property (nonatomic, strong) UIView *customView;
@property (nonatomic, strong) UIView *customHeaderView;
@property (nonatomic, strong) UIView *customCenterView;
@property (nonatomic, strong) UIView *customFooterView;

@property (nonatomic, assign) CGSize customViewSize;
@property (nonatomic, assign) CGSize customHeaderViewSize;
@property (nonatomic, assign) CGSize customCenterViewSize;
@property (nonatomic, assign) CGSize customFooterViewSize;
// ---------------- 关于自定义控件的约束数组 -------------------
@property (nonatomic, strong) NSMutableArray *customViewConstraints;

// action数组
@property (nonatomic) NSArray<SPAlertAction *> *actions;
// 取消样式的action数组
@property (nonatomic, strong) NSMutableArray *cancelActions;
// tableView的数据源,与actions数组息息相关
@property (nonatomic, strong) NSArray *dataSource;
// textFiled数组
@property (nonatomic) NSArray<UITextField *> *textFields;

@property (nonatomic, assign) SPAlertControllerStyle preferredStyle;
@property (nonatomic, assign) SPAlertAnimationType animationType;
// 底部的cell数组
@property (nonatomic, strong) NSMutableArray *footerCells;
// 底部的cell之间的分割线数组
@property (nonatomic, strong) NSMutableArray *footerLines;
// 键盘是否显示
@property (nonatomic, assign) BOOL keyboardShow;
// alert样式下的垂直中心约束
@property (nonatomic, strong) NSLayoutConstraint *alertConstraintCenterY;

@property (nonatomic, assign) SPBackgroundViewAppearanceStyle backgroundViewAppearanceStyle;
@property (nonatomic, assign) CGFloat backgroundViewAlpha;
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
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:customView customHeaderView:nil customCenterView:nil customFooterView:nil];
    return alertController;
}

+ (instancetype)alertControllerWithPreferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customHeaderView:(nullable UIView *)customHeaderView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:nil message:nil preferredStyle:preferredStyle animationType:animationType customView:nil customHeaderView:customHeaderView customCenterView:nil customFooterView:nil];
    return alertController;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customCenterView:(UIView *)customCenterView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:nil customHeaderView:nil customCenterView:customCenterView customFooterView:nil];
    return alertController;
}

+ (instancetype)alertControllerWithTitle:(NSString *)title message:(NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customFooterView:(UIView *)customFooterView {
    // 创建控制器
    SPAlertController *alertController = [[SPAlertController alloc] initWithTitle:title message:message preferredStyle:preferredStyle animationType:animationType customView:nil customHeaderView:nil customCenterView:nil customFooterView:customFooterView];
    return alertController;
}

// 添加action
- (void)addAction:(SPAlertAction *)action {
    
    if ([self.actions containsObject:action]) {
        return;
    }
    
    NSMutableArray *array = self.actions.mutableCopy;
    // 一般来说取消样式的按钮不会太多,这里限制最多只能有5个取消样式的按钮
    NSAssert(self.cancelActions.count < 5, @"取消样式的按钮最多只能有5个");
    
    if (self.cancelActions.count && self.preferredStyle == SPAlertControllerStyleActionSheet) {
        if (action.style == SPAlertActionStyleCancel) { // 取消样式的按钮顺序排列
            [array addObject:action];
        } else {
            NSInteger index = [self.actions indexOfObject:self.cancelActions.firstObject];
            // 普通按钮插入取消样式按钮之前
            [array insertObject:action atIndex:index];
        }
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
            [self.cancelActions addObject:action];
            [self createFooterCellWithAction:action];
        }
        self.dataSource = self.cancelActions.count ? [array subarrayWithRange:NSMakeRange(0, array.count-self.cancelActions.count)].copy : array.copy;
    } else {
        if (self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert && !self.customFooterView) {
            [self createFooterCellWithAction:action];
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
        }
    }
    __weak typeof(self) weakSelf = self;
    __block NSInteger maxNumberOfActionHorizontalArrangementForAlert = _maxNumberOfActionHorizontalArrangementForAlert;
    // 当外面在addAction之后再设置action的属性时，会回调这个block
    action.propertyEvent = ^(SPAlertAction *action) {
        if (weakSelf.preferredStyle == SPAlertControllerStyleActionSheet) {
            if (action.style == SPAlertActionStyleCancel) {
                NSInteger index = [weakSelf.cancelActions indexOfObject:action];
                // 注意这个cell是与tableView没有任何瓜葛的
                SPAlertControllerActionCell *footerCell = [weakSelf.footerCells objectAtIndex:index];
                footerCell.action = action;
            } else {
                // 刷新tableView
                [weakSelf.actionTableView reloadData];
            }
        } else {
            if (weakSelf.actions.count <= maxNumberOfActionHorizontalArrangementForAlert) {
                NSInteger index = [weakSelf.actions indexOfObject:action];
                SPAlertControllerActionCell *footerCell = weakSelf.footerCells[index];
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

// 添加文本输入框
- (void)addTextFieldWithConfigurationHandler:(void (^)(UITextField * _Nonnull))configurationHandler {
    
    NSAssert(self.preferredStyle == SPAlertControllerStyleAlert, @"SPAlertControllerStyleActionSheet样式拒绝添加文本输入框");
    UITextField *textField = [[UITextField alloc] init];
    textField.translatesAutoresizingMaskIntoConstraints = NO;
    textField.backgroundColor = [UIColor whiteColor];
    // 系统的UITextBorderStyleLine样式线条过于黑，所以自己设置
    textField.layer.borderWidth = 0.5;
    textField.layer.borderColor = [UIColor grayColor].CGColor;
    // 在左边设置一张view，充当光标左边的间距，否则光标紧贴textField不美观
    textField.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 5, 0)];
    textField.leftView.userInteractionEnabled = NO;
    textField.leftViewMode = UITextFieldViewModeAlways;
    textField.font = [UIFont systemFontOfSize:14];
    // 去掉textField键盘上部的联想条
    textField.autocorrectionType = UITextAutocorrectionTypeNo;
    [textField addTarget:self action:@selector(textFieldDidEndOnExit:) forControlEvents:UIControlEventEditingDidEndOnExit];
    NSMutableArray *array = self.textFields.mutableCopy;
    [array addObject:textField];
    self.textFields = array;
    if (configurationHandler) {
        configurationHandler(textField);
    }
    [self layoutViewConstraints];
}

- (void)setBackgroundViewAppearanceStyle:(SPBackgroundViewAppearanceStyle)style alpha:(CGFloat)alpha {
    _backgroundViewAppearanceStyle = style;
    _backgroundViewAlpha = alpha;
}

#pragma mark TableView DataSource & Delagete
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SPAlertControllerActionCell *cell = [tableView dequeueReusableCellWithIdentifier:NSStringFromClass([SPAlertControllerActionCell class]) forIndexPath:indexPath];
    SPAlertAction *action = self.dataSource[indexPath.row];
    cell.action = action;
    return cell;
}

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
- (instancetype)initWithTitle:(nullable NSString *)title message:(nullable NSString *)message preferredStyle:(SPAlertControllerStyle)preferredStyle animationType:(SPAlertAnimationType)animationType customView:(UIView *)customView customHeaderView:(UIView *)customHeaderView customCenterView:(UIView *)customCenterView customFooterView:(UIView *)customFooterView{
    
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
        [self setupViewsWithCustomView:customView customHeaderView:customHeaderView customCenterView:customCenterView customFooterView:customFooterView];
        
        self.needDialogBlur = YES;
        self.backgroundViewAlpha = -1;
        self.tapBackgroundViewDismiss = YES;
        self.cornerRadiusForAlert = 5;
        self.maxTopMarginForActionSheet = isIPhoneX ? 44 : 0;
        self.maxMarginForAlert = 20.0;
        self.maxNumberOfActionHorizontalArrangementForAlert = 2;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];

    }
    return self;
}

#pragma mark 添加子控件
- (void)setupViewsWithCustomView:(UIView *)customView customHeaderView:(UIView *)customHeaderView customCenterView:(UIView *)customCenterView customFooterView:(UIView *)customFooterView {
    // 创建父view
    [self setupAlertView];
    if (!customView) { // 没有自定义整个对话框
        // 创建关于头部的子控件
        [self setupViewsOboutHeader:customHeaderView];
        
        // 创建头部和actionBezelView之间的分割线
        [self setupHeaderActionLine];
        
        // 创建关于普通action的子控件
        [self setupViewsAboutAction:customCenterView];
        
        // 创建footerView顶部分割线，这条分割线就是将普通样式的action和取消样式的action隔开
        [self setupVFooterTopLine];
        
        // 创建footerView
        [self setupFooterView:customFooterView];
        [self layoutViewConstraints];
    } else {
        [self.alertView.subviews enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [obj removeFromSuperview];
            obj = nil;
        }];
        self.customView = customView;
    }
}

- (void)setupAlertView {
    UIView *alertView = [[UIView alloc] init];
    alertView.frame = self.view.bounds;
    alertView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:alertView];
    _alertView = alertView;
}

- (void)setupViewsOboutHeader:(UIView *)customHeaderView {
    UIView *headerBezelView = [[UIView alloc] init];
    headerBezelView.translatesAutoresizingMaskIntoConstraints = NO;
    headerBezelView.backgroundColor = normalColor;
    [_alertView addSubview:headerBezelView];
    _headerBezelView = headerBezelView;
    
    if (!customHeaderView) { // 不是自定义的headerView
    
        UIView *headerView = [[UIView alloc] init];
        headerView.frame = headerBezelView.bounds;
        headerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [headerBezelView addSubview:headerView];
        _headerView = headerView;
        
        UIScrollView *headerScrollView = [[UIScrollView alloc] init];
        headerScrollView.frame = headerBezelView.bounds;
        headerScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        headerScrollView.showsHorizontalScrollIndicator = NO;
        if (@available(iOS 11.0, *)) {
            headerScrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [headerView addSubview:headerScrollView];
        _headerScrollView = headerScrollView;
        
        UIView *headerScrollContentView = [[UIView alloc] init];
        headerScrollContentView.translatesAutoresizingMaskIntoConstraints = NO;
        [headerScrollView addSubview:headerScrollContentView];
        _headerScrollContentView = headerScrollContentView;
        
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
    } else { // 是自定义的headerView
        [self.headerView removeFromSuperview];
        self.headerView = nil;
        self.customHeaderView = customHeaderView;
    }
}

- (void)setupHeaderActionLine {
    UIView *headerActionLine = [[UIView alloc] init];
    headerActionLine.translatesAutoresizingMaskIntoConstraints = NO;
    headerActionLine.backgroundColor = lineColor;
    [_alertView addSubview:headerActionLine];
    _headerActionLine = headerActionLine;
}

- (void)setupViewsAboutAction:(UIView *)customCenterView {
    UIView *actionBezelView = [[UIView alloc] init];
    actionBezelView.translatesAutoresizingMaskIntoConstraints = NO;
    [_alertView addSubview:actionBezelView];
    _actionBezelView = actionBezelView;
    
    if (!customCenterView) {
        UIView *actionCenterView = [[UIView alloc] init];
        actionCenterView.translatesAutoresizingMaskIntoConstraints = NO;
        [actionBezelView addSubview:actionCenterView];
        _actionCenterView = actionCenterView;
        
        UITableView *actionTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        actionTableView.frame = actionCenterView.bounds;
        actionTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        actionTableView.showsHorizontalScrollIndicator = NO;
        actionTableView.alwaysBounceVertical = NO; // tableView内容没有超出contentSize时，禁止滑动
        actionTableView.backgroundColor = [UIColor clearColor];
        actionTableView.separatorColor = lineColor;
        actionTableView.dataSource = self;
        actionTableView.delegate = self;
        if (@available(iOS 11.0, *)) {
            actionTableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
        [actionTableView registerClass:[SPAlertControllerActionCell class] forCellReuseIdentifier:NSStringFromClass([SPAlertControllerActionCell class])];
        [actionCenterView addSubview:actionTableView];
        _actionTableView = actionTableView;
    } else {
        [self.actionCenterView removeFromSuperview];
        self.actionCenterView = nil;
        self.customCenterView = customCenterView;
    }
}

- (void)setupVFooterTopLine {
    UIView *footerTopLine = [[UIView alloc] init];
    footerTopLine.translatesAutoresizingMaskIntoConstraints = NO;
    footerTopLine.backgroundColor = lineColor;
    [_actionBezelView addSubview:footerTopLine];
    _footerTopLine = footerTopLine;
}

- (void)setupFooterView:(UIView *)customFooterView  {
    
    UIView *footerBezelView = [[UIView alloc] init];
    footerBezelView.translatesAutoresizingMaskIntoConstraints = NO;
    [_actionBezelView addSubview:footerBezelView];
    _footerBezelView = footerBezelView;
    
    if (!customFooterView) { // 非自定义footerView
        
        UIView *footerView = [[UIView alloc] init];
        footerView.frame = footerBezelView.bounds;
        footerBezelView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        footerView.backgroundColor = normalColor;
        [footerBezelView addSubview:footerView];
        _footerView = footerView;
        
    } else { // 自定义footerView
        [self.footerView removeFromSuperview];
        self.footerView = nil;
        self.customFooterView = customFooterView;
    }
}

// 创建底部装载cell的footerView
- (void)createFooterCellWithAction:(SPAlertAction *)action {
    // 这个cell实际上就是一个普通的view，跟tableView没有任何关系，因为cell内部都有现成的控件和布局，直接用这个cell就好，没必要再去自定义一个view，需要注意的是，cell使用了自动布局,contentView会受到影响，看警告对症下药
    SPAlertControllerActionCell *footerCell = [[SPAlertControllerActionCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:FOOTERCELL];
    footerCell.translatesAutoresizingMaskIntoConstraints = NO;
    [footerCell.contentView removeFromSuperview]; // 移除后contentView仍然存在，还要将其置为nil，由于是只读的，故用KVC访问
    // 利用KVC去掉cell的contentView,如果不去掉，控制台会打印警告，意思是说contentView的高度不该为0，应该给一个合适的高度
    [footerCell setValue:nil forKey:@"_contentView"];
    footerCell.action = action;
    [self.footerBezelView addSubview:footerCell];
    [self.footerCells addObject:footerCell];
    
    // 之所以添加按钮不用单击手势，是因为按钮做高亮处理更方便
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = footerCell.bounds;
    button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    button.backgroundColor = [UIColor clearColor];
    [button addTarget:self action:@selector(clickedFooterCell:) forControlEvents:UIControlEventTouchUpInside];
    [button addTarget:self action:@selector(touchDownFooterCell:) forControlEvents:UIControlEventTouchDown | UIControlEventTouchDragInside];
    [button addTarget:self action:@selector(touchDragExitFooterCell:) forControlEvents:UIControlEventTouchDragExit | UIControlEventTouchUpOutside];
    [footerCell addSubview:button];
    
    if (self.actions.count > 1) {
        UIView *line = [UIView new];
        line.translatesAutoresizingMaskIntoConstraints = NO;
        line.backgroundColor = lineColor;
        [self.footerBezelView addSubview:line];
        [self.footerLines addObject:line];
    }
}

#pragma mark - 点击取消样式的action的方法
- (void)clickedFooterCell:(UIButton *)sender {
   
    if (self.preferredStyle == SPAlertControllerStyleActionSheet) {
        SPAlertControllerActionCell *footerCell = (SPAlertControllerActionCell *)sender.superview;
        NSInteger index = [self.footerCells indexOfObject:footerCell];
        SPAlertAction *action = [self.cancelActions objectAtIndex:index];
        // 回调action的block
        if (action.handler) {
            action.handler(action);
        }
    } else {
        if (self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert) {
            SPAlertControllerActionCell *footerCell = (SPAlertControllerActionCell *)sender.superview;
            NSInteger index = [self.footerCells indexOfObject:footerCell];
            SPAlertAction *action = [self.actions objectAtIndex:index];
            // 回调action的block
            if (action.handler) {
                action.handler(action);
            }
        }
    }
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)touchDownFooterCell:(UIButton *)sender {
    SPAlertControllerActionCell *footerCell = (SPAlertControllerActionCell *)sender.superview;
    footerCell.backgroundColor = [UIColor clearColor];
    sender.backgroundColor = selectedColor;
}

- (void)touchDragExitFooterCell:(UIButton *)sender {
    SPAlertControllerActionCell *footerCell = (SPAlertControllerActionCell *)sender.superview;
    footerCell.backgroundColor = normalColor;
    sender.backgroundColor = [UIColor clearColor];
}

#pragma mark - 布局
- (void)layoutViewConstraints {
    if (self.customView) {
        return;
    }
    // 头部布局
    [self layoutHeader];
    
    // 头部与actionBezelView之间的分割线布局
    [self layoutHeaderActionLine];
    
    // 普通的action子控件布局
    [self layoutCenter];
    
    // footerBezelView顶部的分割线布局,这条分割线将普通样式的action和取消样式的action分隔开来
    [self layoutFooterTopLine];

    // footerBezelView布局
    [self layoutFooter];
}

- (void)layoutHeader {
    
    UIView *alertView = self.alertView;
    UIView *headerBezelView = self.headerBezelView;
    UIView *headerView = self.customHeaderView ? self.customHeaderView : self.headerView;
    UIScrollView *headerScrollView = self.headerScrollView;
    UIView *headerScrollContentView = self.headerScrollContentView;
    UIView *titleView = self.titleView;
    UIView *textFieldView = self.textFieldView;
    UIView *headerActionLine = self.headerActionLine;
    
    NSMutableArray *headerBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *headerViewConstraints = [NSMutableArray array];
    NSMutableArray *headerScrollContentViewConstraints = [NSMutableArray array];
    NSMutableArray *titleViewConstraints = [NSMutableArray array];
    NSMutableArray *titleLabelConstraints = [NSMutableArray array];
    NSMutableArray *texFieldViewConstraints = [NSMutableArray array];
    NSMutableArray *textFieldConstraints = [NSMutableArray array];
    
    // 移除存在的约束,删除约束是为了更新约束
    if (self.headerBezelViewConstraints) {
        [alertView removeConstraints:self.headerBezelViewConstraints];
        self.headerBezelViewConstraints = nil;
    }
    if (self.headerViewConstraints) {
        [headerBezelView removeConstraints:self.headerViewConstraints];
        self.headerViewConstraints = nil;
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
    CGFloat margin = 15;
    
    [headerBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerBezelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerBezelView)]];
    [headerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:headerActionLine attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [headerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    // headerBezelView的高度最大为(self.view.bounds.size.height-itemHeight)
    [headerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationLessThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:ScreenHeight-actionHeight]];
    // 暂时先初始化headerView的高度约束
    NSLayoutConstraint *headerBezelViewContsraintHeight = [NSLayoutConstraint constraintWithItem:headerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0];
    /// 设置优先级
    headerBezelViewContsraintHeight.priority = 998.0;
    [headerBezelViewConstraints addObject:headerBezelViewContsraintHeight];
    [alertView addConstraints:headerBezelViewConstraints];
    
    if (!self.customHeaderView) { // 非自定义的headerView
        
        // 设置actionScrollContentView的相关约束，值得注意的是不能仅仅设置上下左右间距为0就完事了，对于scrollView的contentView， autoLayout布局必须设置宽或高约束
        [headerScrollContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerScrollContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollContentView)]];
        [headerScrollContentViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[headerScrollContentView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerScrollContentView)]];
        [headerScrollContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerScrollContentView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:headerScrollView attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
        if (_titleLabel.text.length || _detailTitleLabel.text.length) {
            // 保证headerScrollContentView的高度最小为actionHeight
            [headerScrollContentViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerScrollContentView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionHeight]];
        }
        [headerScrollView addConstraints:headerScrollContentViewConstraints];
    
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
        
        // 先强制布局一次，否则下面拿到的CGRectGetMaxY(titleView.frame)还没有值
        [headerBezelView layoutIfNeeded]; // 立即调用layoutSubViews
        CGRect rect;
        if (!self.customHeaderView) {
            rect = self.textFields.count ? textFieldView.frame : titleView.frame;
        } else {
            rect = titleView.frame;
        }
        // 设置headerView的高度(这个高度同样可以通过计算titleLabel和detailTitleLabel的文字高度计算出来,但是那样计算出来的高度会有零点几的误差,只要差了一点,有可能scrollView即便内容没有超过contentSize,仍然能够滑动)
        headerBezelViewContsraintHeight.constant = CGRectGetMaxY(rect);
        
        // 强制布局，立刻产生frame
        [self.view layoutIfNeeded];
        // 如果有文本输入框，让头部scrollVIew自动滚动到最底端(这是为了当文字过多时，可以立即滚动到第一个输入框的位置)
        if (self.textFields.count) {
            UITextField *firstTextField = self.textFields.firstObject;
            [headerScrollView scrollRectToVisible:firstTextField.frame animated:YES];
        }
    } else {
        // 自定义headerView时，这里的headerView就是customHeaderView
        [headerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customHeaderViewSize.width]];
        [headerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customHeaderViewSize.height]];
        [headerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:headerBezelView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [headerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:headerView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:headerBezelView attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0]];
        [headerBezelView addConstraints:headerViewConstraints];
    }
    
    self.headerBezelViewConstraints = headerBezelViewConstraints;
    self.headerViewConstraints = headerViewConstraints;
    self.headerScrollContentViewConstraints  = headerScrollContentViewConstraints;
    self.titleViewConstraints  = titleViewConstraints;
    self.titleLabelConstraints = titleLabelConstraints;
    self.textFieldViewConstraints = texFieldViewConstraints;
    self.textFieldConstraints = textFieldConstraints;
}

- (void)layoutHeaderActionLine {
    
    UIView *alertView = self.alertView;
    UIView *headerBezelView = self.customHeaderView ? self.customHeaderView : self.headerBezelView;
    UIView *actionBezelView = self.actionBezelView;
    UIView *headerActionLine = self.headerActionLine;
    
    NSMutableArray *headerActionLineConstraints = [NSMutableArray array];
    
    if (self.headerActionLineConstraints) {
        [alertView removeConstraints:self.headerActionLineConstraints];
        self.headerActionLineConstraints = nil;
    }
    CGFloat headerActionPadding = (!headerBezelView.subviews.count || !self.actions.count) ? 0 : lineWidth;
    [headerActionLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[headerActionLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(headerActionLine)]];
    [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerBezelView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [headerActionLineConstraints addObject:[NSLayoutConstraint constraintWithItem:headerActionLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:headerActionPadding]];
    [alertView addConstraints:headerActionLineConstraints];
    self.headerActionLineConstraints = headerActionLineConstraints;

}

- (void)layoutCenter {
    UIView *alertView = self.alertView;
    UIView *headerActionLine = self.headerActionLine;
    UIView *actionBezelView = self.actionBezelView;
    UIView *actionCenterView = self.customCenterView ? self.customCenterView : self.actionCenterView;
    UIView *footerTopLine = self.footerTopLine;
    
    NSMutableArray *actionBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *actionCenterViewConstraints = [NSMutableArray array];
    
    if (self.actionBezelViewConstraints) {
        [alertView removeConstraints:self.actionBezelViewConstraints];
        self.actionBezelViewConstraints = nil;
    }
    if (self.actionCenterViewConstraints) {
        [actionBezelView removeConstraints:self.actionCenterViewConstraints];
        self.actionCenterViewConstraints = nil;
    }
    // 间距为5，实际上会5.5的高度，因为tableView最后一条分割线跟headerActionLine混合在一起
    CGFloat footerTopMargin = [self footerTopMargin];
    // 计算好actionBezelView的高度, 本也可以让设置每个子控件都高度约束，以及顶底约束和子控件之间的间距，这样便可以把actionBezelView的高度撑起来，但是这里要比较一下actionBezelView和headerView的高度优先级，所以父控件设置高度比较方便，谁的优先级高，谁展示的内容就更多
    CGFloat actionBezelHeight = [self actionBezelHeight:footerTopMargin];
    
    [actionBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionBezelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionBezelView)]];
    [actionBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:headerActionLine attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [actionBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:alertView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    NSLayoutConstraint *actionBezelViewHeightContraint = [NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionBezelHeight];
    // 设置优先级，要比上面headerViewContraintHeight的优先级低,这样当文字过多和action同时过多时，都超出了最大限制，此时优先展示文字
    actionBezelViewHeightContraint.priority = 997.0f;
    // 计算最小高度
    CGFloat minActionHeight = [self minActionHeight:footerTopMargin];

    NSLayoutConstraint *minActionHeightConstraint = [NSLayoutConstraint constraintWithItem:actionBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:minActionHeight];
    [actionBezelViewConstraints addObject:minActionHeightConstraint];
    
    [actionBezelViewConstraints addObject:actionBezelViewHeightContraint];
    [alertView addConstraints:actionBezelViewConstraints];
    
    if (!self.customCenterView) {
        [actionCenterViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[actionCenterView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(actionCenterView)]];
    } else {  // 如果customCenterView有值，actionCenterView就是customCenterView
        [actionCenterViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionCenterView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customCenterViewSize.width]];
        [actionCenterViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionCenterView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
    }
    [actionCenterViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionCenterView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerTopLine attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [actionCenterViewConstraints addObject:[NSLayoutConstraint constraintWithItem:actionCenterView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];

    [actionBezelView addConstraints:actionCenterViewConstraints];
    
    self.actionBezelViewConstraints = actionBezelViewConstraints;
    self.actionCenterViewConstraints = actionCenterViewConstraints;
}

- (void)layoutFooterTopLine {
    
    UIView *actionBezelView = self.actionBezelView;
    UIView *actionCenterView = self.customCenterView ? self.customCenterView : self.actionCenterView;
    UIView *footerBezelView = self.footerBezelView;
    UIView *footerTopLine = self.footerTopLine;
    
    NSMutableArray *footerTopLineConstraints = [NSMutableArray array];
    if (self.footerTopLineConstraints) {
        [actionBezelView removeConstraints:self.footerTopLineConstraints];
        self.footerTopLineConstraints = nil;
    }
    // 没有取消按钮意味着没有非自定义的footerView，如果有自定义的footerView，顶部依然会有0.5的间距，那个间距是tableVeiw最后一条分割线
    CGFloat footerTopMargin = [self footerTopMargin];
    
    [footerTopLineConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[footerTopLine]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerTopLine)]];
    [footerTopLineConstraints addObject:[NSLayoutConstraint constraintWithItem:footerTopLine attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:actionCenterView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [footerTopLineConstraints addObject:[NSLayoutConstraint constraintWithItem:footerTopLine attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeTop multiplier:1.0f constant:0]];
    [footerTopLineConstraints addObject:[NSLayoutConstraint constraintWithItem:footerTopLine attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:footerTopMargin]];
    [actionBezelView addConstraints:footerTopLineConstraints];
    
    self.footerTopLineConstraints = footerTopLineConstraints;

}

- (void)layoutFooter {
    UIView *actionBezelView = self.actionBezelView;
    UIView *footerTopLine = self.footerTopLine;
    UIView *footerBezelView = self.footerBezelView;
    UIView *footerView = self.customFooterView ? self.customFooterView : self.footerView;
    
    NSMutableArray *footerBezelViewConstraints = [NSMutableArray array];
    NSMutableArray *footerViewConstraints = [NSMutableArray array];
    NSMutableArray *footerCellConstraints = [NSMutableArray array];
    
    if (self.footerBezelViewConstraints) {
        [actionBezelView removeConstraints:self.footerBezelViewConstraints];
        self.footerBezelViewConstraints = nil;
    }
    if (self.footerViewConstraints) {
        [footerBezelView removeConstraints:self.footerViewConstraints];
        self.footerViewConstraints = nil;
    }
    if (self.footerCellConstraints) {
        [footerBezelView removeConstraints:self.footerCellConstraints];
        self.footerCellConstraints = nil;
    }

    [footerBezelViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[footerBezelView]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerBezelView)]];
    [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerTopLine attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:actionBezelView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:0]];
    
    // 这个条件判断需不需要footerBezelView
    if ((self.preferredStyle == SPAlertControllerStyleActionSheet && self.cancelActions.count) || (self.preferredStyle == SPAlertControllerStyleAlert && (self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert) && self.actions.count)) { // 需要footerBezelView
        if (self.preferredStyle == SPAlertControllerStyleAlert) { // alert样式
            if (!self.customFooterView) { // 不是自定义的footerView
                [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionHeight]];
            } else { // 是自定义的footerView
                [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:_customFooterViewSize.height]];
            }
        } else { // actionSheet样式
            [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:actionHeight*self.cancelActions.count]];
        }
    } else { // 不需要footerView
        if (self.customFooterView) { // 自定义的footerView
            [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:_customFooterViewSize.height]];
        } else {
            [footerBezelViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerBezelView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f constant:0]];
        }
    }
    [actionBezelView addConstraints:footerBezelViewConstraints];
    
    if (!self.customFooterView) { // 不是自定义的footerView
        
        NSArray *footerCells = self.footerCells;
        if (footerCells.count && ((self.preferredStyle == SPAlertControllerStyleActionSheet && self.cancelActions.count) || (self.preferredStyle == SPAlertControllerStyleAlert && self.actions.count <= _maxNumberOfActionHorizontalArrangementForAlert))) {
            [footerCells enumerateObjectsUsingBlock:^(SPAlertControllerActionCell *footerCell, NSUInteger idx, BOOL * _Nonnull stop) {
                if (self.preferredStyle == SPAlertControllerStyleAlert) {
                    // 设置footerCell的上下间距
                    [footerCellConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[footerCell]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerCell)]];
                    // 第一个footerCell的左间距
                    if (idx == 0) {
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeLeft multiplier:1.f constant:0]];
                    }
                    // 最后一个footerCell的右间距
                    if (idx == footerCells.count-1) {
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeRight multiplier:1.f constant:-0]];
                    }
                    
                    if (idx > 0) {
                        // 取出分割线
                        UIView *line = self.footerLines[idx-1];
                        // 分割线左边距
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:footerCells[idx - 1] attribute:NSLayoutAttributeRight multiplier:1.f constant:0]];
                        // 分割线右边距
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:footerCells[idx] attribute:NSLayoutAttributeLeft multiplier:1.f constant:0]];
                        // 分割线上下间距
                        [footerCellConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[line]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(line)]];
                        // 分割线宽度
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:lineWidth]];
                        // cell的右边距
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCells[idx-1] attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.footerLines[idx - 1] attribute:NSLayoutAttributeLeft multiplier:1.f constant:0]];
                        // cell的左距
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.footerLines[idx - 1] attribute:NSLayoutAttributeRight multiplier:1.f constant:0]];
                        // cell等宽
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:footerCells[idx - 1] attribute:NSLayoutAttributeWidth multiplier:1.f constant:0]];
                    }
                } else {
                    // 设置footerCell的左右间距
                    [footerCellConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[footerCell]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(footerCell)]];
                    // 第一个footerCell的顶部间距
                    if (idx == 0) {
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeTop multiplier:1.f constant:0]];
                    }
                    // 最后一个footerCell的底部间距
                    if (idx == footerCells.count-1) {
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeBottom multiplier:1.f constant:-0]];
                    }
                    
                    if (idx > 0) {
                        // 取出分割线
                        UIView *line = self.footerLines[idx-1];
                        // 分割线的顶部间距
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerCells[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0]];
                        // 分割线的底部间距
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerCells[idx] attribute:NSLayoutAttributeTop multiplier:1.f constant:0]];
                        // 分割线的左右间距
                        [footerCellConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[line]-0-|" options:0 metrics:nil views:NSDictionaryOfVariableBindings(line)]];
                        // 分割线的高度
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:line attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.f constant:lineWidth]];
                        // cell的底部间距
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCells[idx-1] attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.footerLines[idx - 1] attribute:NSLayoutAttributeTop multiplier:1.f constant:0]];
                        // cell的顶部间距
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.footerLines[idx - 1] attribute:NSLayoutAttributeBottom multiplier:1.f constant:0]];
                        // cell等高
                        [footerCellConstraints addObject:[NSLayoutConstraint constraintWithItem:footerCell attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:footerCells[idx - 1] attribute:NSLayoutAttributeHeight multiplier:1.f constant:0]];
                    }
                }
            }];
            [footerBezelView addConstraints:footerCellConstraints];
        }
    } else { // 是自定义的footerView
        // 自定义footerView时，这里的footerView就是customFooterView
        [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:_customFooterViewSize.width]];
        [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
        [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
        [footerViewConstraints addObject:[NSLayoutConstraint constraintWithItem:footerView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:footerBezelView attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
        [footerBezelView addConstraints:footerViewConstraints];
    }
    self.footerBezelViewConstraints = footerBezelViewConstraints;
    self.footerViewConstraints = footerViewConstraints;
    self.footerCellConstraints = footerCellConstraints;
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
            if (self.cancelActions.count) { // 有取消按钮肯定没有自定义footerView
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
    if (self.cancelActions.count) {
        if ((self.actions.count-self.cancelActions.count) > 3) { // 有取消按钮且其余按钮个数在3个或3个以上
            // 让其余按钮至少显示2个半
            minActionHeight = self.cancelActions.count*actionHeight+2.5*actionHeight+footerTopMargin;
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

- (CGFloat)footerTopMargin {
    CGFloat footerTopMargin = 0;
    if (self.actions.count) {
        if (self.cancelActions.count) {
            footerTopMargin = 5.0f;
        } else {
            footerTopMargin = 0;
        }
    } else {
        footerTopMargin = 0.5;
    }
    return footerTopMargin;
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

- (void)setNeedDialogBlur:(BOOL)needDialogBlur {
    _needDialogBlur = needDialogBlur;
    if (!needDialogBlur) {
        self.alertView.backgroundColor = [UIColor whiteColor];
        [self.alertEffectView removeFromSuperview];
        self.alertEffectView = nil;
        
    } else {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        UIVisualEffectView *alertEffectView = [[UIVisualEffectView alloc] initWithEffect:blur];
        alertEffectView.layer.masksToBounds = YES;
        alertEffectView.frame = self.alertView.bounds;
        alertEffectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        [self.alertView insertSubview:alertEffectView atIndex:0];
        _alertEffectView = alertEffectView;
        
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
        // 检查一下customView的宽度是否大于了新的对话框的宽度
        if (self.preferredStyle == SPAlertControllerStyleAlert) {
            if (_customViewSize.width >= ScreenWidth-2*maxMarginForAlert) {
                _customViewSize.width = ScreenWidth-2*maxMarginForAlert;
            }
        } else {
            if (_customViewSize.width >= ScreenWidth) {
                _customViewSize.width = ScreenWidth;
            }
        }
        [self layoutCustomView];
    } else {
        // 检查一下customHeaderViewSize和customCenterView的宽度是否大于了新的对话框的宽度
        if (self.preferredStyle == SPAlertControllerStyleAlert) {
            if (_customHeaderViewSize.width >= ScreenWidth-2*maxMarginForAlert) {
                _customHeaderViewSize.width = ScreenWidth-2*maxMarginForAlert;
            }
            if (_customCenterViewSize.width >= ScreenWidth-2*maxMarginForAlert) {
                _customCenterViewSize.width = ScreenWidth-2*maxMarginForAlert;
            }
            if (_customFooterViewSize.width >= ScreenWidth-2*maxMarginForAlert) {
                _customFooterViewSize.width = ScreenWidth-2*maxMarginForAlert;
            }
        } else {

            if (_customHeaderViewSize.width >= ScreenWidth) {
                _customHeaderViewSize.width = ScreenWidth;
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

// 这个set方法，只要键盘的高度有所变化就会调用，每次键盘高度变化时都要更新对话框的垂直中心
- (void)setOffsetYForAlert:(CGFloat)offsetYForAlert {
    _offsetYForAlert = offsetYForAlert;
    _alertConstraintCenterY.constant = offsetYForAlert;
    SPAlertPresentationController *presentationVc = (SPAlertPresentationController *)self.presentationController;
    // 再次布局,按住option键查看containerViewWillLayoutSubviews时，提示说更新约束用containerViewDidLayoutSubviews，也确实如果直接调用containerViewWillLayoutSubviews有时会闪退
    [presentationVc containerViewDidLayoutSubviews];
}

- (void)setCustomView:(UIView *)customView {
    _customView = customView;
    [customView layoutIfNeeded];
    _customViewSize = customView.frame.size;
    if (_customViewSize.width <= 0 || _customViewSize.width >= ScreenWidth-2*_maxMarginForAlert) {
        _customViewSize.width = ScreenWidth-2*_maxMarginForAlert;
    }
    if (_customViewSize.height <= 0) {
        NSLog(@"你的_customViewSize高度为小于等于0,请设置一个高度");
    }
    customView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.alertView addSubview:customView];
    [self layoutCustomView];
}

- (void)setCustomHeaderView:(UIView *)customHeaderView {
    _customHeaderView = customHeaderView;
    [customHeaderView layoutIfNeeded];
    _customHeaderViewSize = customHeaderView.bounds.size;
    if (_customHeaderViewSize.width <= 0 || _customHeaderViewSize.width >= ScreenWidth-2*_maxMarginForAlert) {
        _customHeaderViewSize.width = ScreenWidth-2*_maxMarginForAlert;
    }
    if (_customHeaderViewSize.height <= 0) {
        NSLog(@"你的customHeaderView高度为小于等于0,请设置一个高度");
    }
    customHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerBezelView addSubview:customHeaderView];
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
    [self.footerBezelView addSubview:customFooterView];
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

- (NSMutableArray *)footerCells {
    
    if (!_footerCells) {
        _footerCells = [NSMutableArray array];
    }
    return _footerCells;
}

- (NSMutableArray *)footerLines {
    
    if (!_footerLines) {
        _footerLines = [NSMutableArray array];
    }
    return _footerLines;
}

- (NSArray<SPAlertAction *> *)actions {
    if (!_actions) {
        _actions = [NSArray array];
    }
    return _actions;
}

- (NSMutableArray *)cancelActions {
    if (!_cancelActions) {
        _cancelActions = [NSMutableArray array];
    }
    return _cancelActions;
}


- (NSArray<UITextField *> *)textFields {
    if (!_textFields) {
        _textFields = [NSArray array];
    }
    return _textFields;
}

#pragma amrk - TextField Action
// 这个方法是实现点击回车切换到下一个textField，如果没有下一个，会自动退出键盘. 不能在代理方法里实现，因为如果设置了代理，外界就不能成为textFiled的代理了，通知也监听不到回车
- (void)textFieldDidEndOnExit:(UITextField *)textField {
    NSInteger index = [self.textFields indexOfObject:textField];
    if (self.textFields.count > index+1) {
        UITextField *nextTextField = [self.textFields objectAtIndex:index+1];
        [textField resignFirstResponder];
        [nextTextField becomeFirstResponder];
    }
}

#pragma mark - 通知
- (void)keyboardWillChange:(NSNotification *)notification {
    CGRect keyboardEndFrame = [notification.userInfo[UIKeyboardFrameEndUserInfoKey] CGRectValue];
    CGFloat keyboardEndY = keyboardEndFrame.origin.y;
    CGFloat diff = fabs((ScreenHeight-keyboardEndY)*0.5);
    // 改变alertView的中心y值，以至于不被键盘遮挡
    self.offsetYForAlert = -diff;
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

@interface SPOverlayView: UIView
@property (nonatomic, strong) UIView *presentedView;
@property (nonatomic, assign) SPAlertController *alertController;
@property (nonatomic, strong) UIVisualEffectView *effectView;
@property (nonatomic, assign) CGFloat cornerRadiusForAlert;
- (void)redrawWithView:(UIView *)view alertController:(SPAlertController *)alertController;
@end

@implementation SPOverlayView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {

    }
    return self;
}
- (void)setAppearanceStyle:(SPBackgroundViewAppearanceStyle)appearanceStyle alpha:(CGFloat)alpha {
    switch (appearanceStyle) {
        case SPBackgroundViewAppearanceStyleTranslucent: {
            [self.effectView removeFromSuperview];
            self.effectView = nil;
            if (alpha < 0) {
                alpha = 0.5;
            }
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:alpha];
            self.alpha = 0;
        }
            break;
        case SPBackgroundViewAppearanceStyleBlurExtraLight: {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            [self createVisualEffectViewWithBlur:blur alpha:alpha];
        }
            break;
        case SPBackgroundViewAppearanceStyleBlurLight: {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            [self createVisualEffectViewWithBlur:blur alpha:alpha];
        }
            break;
        case SPBackgroundViewAppearanceStyleBlurDark: {
            UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
            [self createVisualEffectViewWithBlur:blur alpha:alpha];
        }
            break;
        default:
            break;
    }
}

- (void)createVisualEffectViewWithBlur:(UIBlurEffect *)blur alpha:(CGFloat)alpha {
    self.backgroundColor = [UIColor clearColor];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    effectView.frame = self.bounds;
    effectView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    effectView.userInteractionEnabled = NO;
    effectView.alpha = alpha;
    [self addSubview:effectView];
    _effectView = effectView;
}

- (void)redrawWithView:(UIView *)view alertController:(SPAlertController *)alertController {
    _presentedView = view;
    _alertController = alertController;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    // 黑色带透明时进行镂空
    if (self.alertController.backgroundViewAppearanceStyle == SPBackgroundViewAppearanceStyleTranslucent && self.alertController.needDialogBlur && !self.alertController.textFields.count) {
        _cornerRadiusForAlert = (self.alertController.preferredStyle==SPAlertControllerStyleActionSheet)? 0 : self.alertController.cornerRadiusForAlert;
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGRect rectIntersection = CGRectIntersection(self.frame, self.presentedView.frame);
        UIBezierPath *bezierPath = [UIBezierPath bezierPathWithRoundedRect:rectIntersection
                                                              cornerRadius:_cornerRadiusForAlert];
        CGContextSetFillColorWithColor(ctx, [[UIColor clearColor] CGColor]);
        CGContextAddPath(ctx, bezierPath.CGPath);
        CGContextSetBlendMode(ctx, kCGBlendModeClear);
        CGContextFillPath(ctx);
    }
}

@end

#pragma mark ---------------------------- SPAlertPresentationController begin --------------------------------

@interface SPAlertPresentationController()
@property (nonatomic, weak) SPOverlayView *overlayView;
@property (nonatomic, strong) NSMutableArray *presentedViewConstraints;
@end

@implementation SPAlertPresentationController

- (instancetype)initWithPresentedViewController:(UIViewController *)presentedViewController presentingViewController:(UIViewController *)presentingViewController {
    if (self = [super initWithPresentedViewController:presentedViewController presentingViewController:presentingViewController]) {
        self.presentedView.translatesAutoresizingMaskIntoConstraints = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willChangeStatusBarOrientation:) name:UIApplicationWillChangeStatusBarOrientationNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didChangeStatusBarOrientation:) name:UIApplicationDidChangeStatusBarOrientationNotification object:nil];
    }
    return self;
}

- (void)willChangeStatusBarOrientation:(NSNotification *)notification {

    // 将要旋转时立即将镂空的地方补齐,这是为了防止旋转的过程中,镂空的洞是可见的,体验不好
    [self.overlayView redrawWithView:nil alertController:nil];
}

- (void)didChangeStatusBarOrientation:(NSNotification *)notification {

    // 延迟0.3秒再镂空,之所以延迟，是因为实际上界面还没有最终切换到肉眼所看到的横(竖)屏,就开始走这个方法,也就意味着界面还没有旋转停止下来就开始镂空，这样又可以看到镂出来的洞
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        SPAlertController *alertController = (SPAlertController *)self.presentedViewController;
        CGFloat cornerRadius = 0;
        if (alertController.preferredStyle == SPAlertControllerStyleAlert) {
            cornerRadius = alertController.cornerRadiusForAlert;
        }
        [self.overlayView redrawWithView:self.presentedView alertController:alertController];
    });
    
}

- (void)containerViewWillLayoutSubviews {
    [super containerViewWillLayoutSubviews];
    if (!self.presentedView.superview) {
        return;
    }
    [self updateConstraints];
}

- (void)containerViewDidLayoutSubviews {
    [super containerViewDidLayoutSubviews];
}

- (void)presentationTransitionWillBegin {
    [super presentationTransitionWillBegin];
    SPAlertController *alertController = (SPAlertController *)self.presentedViewController;

    SPOverlayView *overlayView = [[SPOverlayView alloc] init];
    overlayView.frame = self.containerView.bounds;
    overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [overlayView setAppearanceStyle:alertController.backgroundViewAppearanceStyle alpha:alertController.backgroundViewAlpha];
    [self.containerView addSubview:overlayView];
    _overlayView = overlayView;

    if (alertController.tapBackgroundViewDismiss) {
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapOverlayView)];
        [_overlayView addGestureRecognizer:tap];
    }
    
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

// 这不是系统的方法
- (void)updateConstraints {
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
                [presentedViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(==maxTopMarginForActionSheet)-[presentedView]-(>=alertBottomMargin)-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet),@"alertBottomMargin":@(alertBottomMargin)} views:NSDictionaryOfVariableBindings(presentedView)]];
            } else {
                [presentedViewConstraints addObjectsFromArray:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-(>=maxTopMarginForActionSheet)-[presentedView]-(==alertBottomMargin)-|" options:0 metrics:@{@"maxTopMarginForActionSheet":@(maxTopMarginForActionSheet),@"alertBottomMargin":@(alertBottomMargin)} views:NSDictionaryOfVariableBindings(presentedView)]];
            }
        } else if (alertController.preferredStyle == SPAlertControllerStyleAlert) {
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:(MIN(ScreenWidth, ScreenHeight)-2*maxMarginForAlert)]];
            [presentedViewConstraints addObject: [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0]];
            NSLayoutConstraint *topConstraints = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0f constant:topMarginForAlert];
            // 这个地方给一个优先级是为了给垂直中心的y值让步,假如垂直中心y达到某一个值的时候(特别是有文本输入框时，旋转到横屏后，留给对话框的控件比较小)，以至于对话框的顶部或底部间距小于了topMarginForAlert，此时便会有约束冲突
            topConstraints.priority = 999.f;
            [presentedViewConstraints addObject:topConstraints];
            NSLayoutConstraint *bottomConstraints = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-bottomMarginForAlert];
            [presentedViewConstraints addObject:bottomConstraints];
            alertController.alertConstraintCenterY = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:alertController.offsetYForAlert];
            [presentedViewConstraints addObject:alertController.alertConstraintCenterY];
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
            NSLayoutConstraint *topConstraints = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationGreaterThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeTop multiplier:1.0f constant:topMarginForAlert];
            [presentedViewConstraints addObject:topConstraints];
            NSLayoutConstraint *bottomConstraints = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationLessThanOrEqual toItem:self.containerView attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-bottomMarginForAlert];
            [presentedViewConstraints addObject:bottomConstraints];

            [presentedViewConstraints addObject:[NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterX multiplier:1.0f constant:0]];
            alertController.alertConstraintCenterY = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.containerView attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:alertController.offsetYForAlert];
            [presentedViewConstraints addObject:alertController.alertConstraintCenterY];
        }
        NSLayoutConstraint *heightConstraints = [NSLayoutConstraint constraintWithItem:presentedView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0 constant:alertH];
        heightConstraints.priority = 999;
        [presentedViewConstraints addObject:heightConstraints];
    }
    [self.containerView addConstraints:presentedViewConstraints];

    self.presentedViewConstraints = presentedViewConstraints;
}



- (void)tapOverlayView {
    [self.presentedViewController dismissViewControllerAnimated:YES completion:^{}];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end

#pragma mark ---------------------------- SPAlertPresentationController end --------------------------------


#pragma mark ---------------------------- SPAlertAnimation begin --------------------------------

@interface SPAlertAnimation()
@property (nonatomic, assign) BOOL presenting;
@property (nonatomic, assign) CGFloat delayTime;
@end

@implementation SPAlertAnimation

- (instancetype)initWithPresenting:(BOOL)isPresenting {
    if (self = [super init]) {
        self.presenting = isPresenting;
        _delayTime = 0.22;
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
    SPOverlayView *overlayView = presentedController.overlayView;

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
    SPOverlayView *overlayView = presentedController.overlayView;
    
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
                        controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
    
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.y = ScreenHeight;
    alertController.view.frame = controlViewFrame;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [overlayView redrawWithView:alertController.view alertController:alertController];
    });
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = ScreenHeight-controlViewSize.height-alertBottomMargin;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 从底部往上弹对应的dismiss动画
- (void)dismissCorrespondingRaiseUpForController:(SPAlertController *)alertController
                             transition:(id<UIViewControllerContextTransitioning>)transitionContext
                        controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
    [overlayView redrawWithView:nil alertController:nil];
    
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
                         controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
    
    CGRect controlViewFrame = alertController.view.frame;
    controlViewFrame.origin.y = -controlViewSize.height;
    alertController.view.frame = controlViewFrame;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [overlayView redrawWithView:alertController.view alertController:alertController];
    });

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect controlViewFrame = alertController.view.frame;
        controlViewFrame.origin.y = alertController.maxTopMarginForActionSheet;
        alertController.view.frame = controlViewFrame;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 从顶部往下弹对应的dismiss动画
- (void)dismissCorrespondingDropDownForController:(SPAlertController *)alertController
                                      transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                 controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
    [overlayView redrawWithView:nil alertController:nil];

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
                        controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
    
    alertController.view.alpha = 0;
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [overlayView redrawWithView:alertController.view alertController:alertController];
    });
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.alpha = 1;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// alpha值从0到1变化对应的的dismiss动画
- (void)dismissCorrespondingAlphaForController:(SPAlertController *)alertController
                                       transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                  controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
    [overlayView redrawWithView:nil alertController:nil];
    
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
                      controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {

    alertController.view.transform = CGAffineTransformMakeScale(0.5, 0.5);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [overlayView redrawWithView:alertController.view alertController:alertController];
    });

    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 usingSpringWithDamping:0.6 initialSpringVelocity:20 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformIdentity;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 发散对应的dismiss动画
- (void)dismissCorrespondingExpandForController:(SPAlertController *)alertController
                                    transition:(id<UIViewControllerContextTransitioning>)transitionContext
                               controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
    [overlayView redrawWithView:nil alertController:nil];
    
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
                       controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
   
    alertController.view.transform = CGAffineTransformMakeScale(1.1, 1.1);
    
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:alertController.view];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_delayTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [overlayView redrawWithView:alertController.view alertController:alertController];
    });
    
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0.0 options:UIViewAnimationOptionCurveLinear animations:^{
        alertController.view.transform = CGAffineTransformIdentity;
        overlayView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:YES];
    }];
}

// 收缩对应的的dismiss动画
- (void)dismissCorrespondingShrinkForController:(SPAlertController *)alertController
                                     transition:(id<UIViewControllerContextTransitioning>)transitionContext
                                controlViewSize:(CGSize)controlViewSize overlayView:(SPOverlayView *)overlayView {
    // 与发散对应的dismiss动画相同
    [self dismissCorrespondingExpandForController:alertController transition:transitionContext controlViewSize:controlViewSize overlayView:overlayView ];
}

@end

#pragma mark ---------------------------- SPAlertAnimation end --------------------------------

