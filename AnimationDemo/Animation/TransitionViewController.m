//
//  TransitionViewController.m
//  AnimationDemo
//
//  Created by 刘婷 on 2017/7/18.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import "TransitionViewController.h"
#import "ChildViewController.h"
#import "AnimationManager.h"



@interface PrivateAnimatedTransition : NSObject <UIViewControllerAnimatedTransitioning>
@end

@implementation PrivateAnimatedTransition

static CGFloat const kChildViewPadding = 16;
static CGFloat const kDamping = 0.75;
static CGFloat const kInitialSpringVelocity = 0.5;

#pragma mark - UIViewControllerAnimatedTransitioning
//动画执行的时长
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.5;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    //上下文对象PrivateTransitionContext包含了参与过渡动画的视图
    
    UIViewController* toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    UIViewController* fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    
    
    BOOL goingRight = ([transitionContext initialFrameForViewController:toViewController].origin.x < [transitionContext finalFrameForViewController:toViewController].origin.x);
    
    CGFloat travelDistance = [transitionContext containerView].bounds.size.width + kChildViewPadding;
    CGAffineTransform travel = CGAffineTransformMakeTranslation (goingRight ? travelDistance : -travelDistance, 0);
    
    [[transitionContext containerView] addSubview:toViewController.view];
    toViewController.view.alpha = 0;
    //CGAffineTransformInvert反转
    toViewController.view.transform = CGAffineTransformInvert (travel);
    //kDamping参数代表弹性阻尼,阻尼值越接近0则弹性效果会越明显
    //kInitialSpringVelocity初始弹簧速率
    [UIView animateWithDuration:[self transitionDuration:transitionContext] delay:0 usingSpringWithDamping:kDamping initialSpringVelocity:kInitialSpringVelocity options:0x00 animations:^{
        fromViewController.view.transform = travel;
        fromViewController.view.alpha = 0;
        //重置初始化
        toViewController.view.transform = CGAffineTransformIdentity;
        toViewController.view.alpha = 1;
    } completion:^(BOOL finished) {
        fromViewController.view.transform = CGAffineTransformIdentity;
        [transitionContext completeTransition:![transitionContext transitionWasCancelled]];//通知UIKit动画执行完成
    }];
    
    
    /*
     UIView的关键帧动画 不需要借助Core Animation
     [UIView animateKeyframesWithDuration: delay: options: animations: completion:];
     */
}

@end



/*
 上下文是一个实现了UIViewControllerContextTransitioning协议的对象,它的作用在于为animateTransition方法提供必备的信息
 从上下文中获取到的信息应该是最新的信息
 */
@interface PrivateTransitionContext : NSObject <UIViewControllerContextTransitioning>
- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight;
@property (nonatomic, copy) void (^completionBlock)(BOOL didComplete);
@property (nonatomic, assign, getter=isAnimated) BOOL animated;
@property (nonatomic, assign, getter=isInteractive) BOOL interactive;
@property (nonatomic, strong) NSDictionary *privateViewControllers;

@property (nonatomic, assign) CGRect privateDisappearingFromRect;
@property (nonatomic, assign) CGRect privateAppearingFromRect;

@property (nonatomic, assign) CGRect privateDisappearingToRect;
@property (nonatomic, assign) CGRect privateAppearingToRect;

@property (nonatomic, weak) UIView *containerView;
@property (nonatomic, assign) UIModalPresentationStyle presentationStyle;
@end


@implementation PrivateTransitionContext

- (instancetype)initWithFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController goingRight:(BOOL)goingRight {
    NSAssert ([fromViewController isViewLoaded] && fromViewController.view.superview, @"The fromViewController view must reside in the container view upon initializing the transition context.");
    
    if ((self = [super init])) {
        self.presentationStyle = UIModalPresentationCustom;
        self.containerView = fromViewController.view.superview;
        self.privateViewControllers = @{
                                        UITransitionContextFromViewControllerKey:fromViewController,
                                        UITransitionContextToViewControllerKey:toViewController,
                                        };
        
        CGFloat travelDistance = (goingRight ? -self.containerView.bounds.size.width : self.containerView.bounds.size.width);
        self.privateDisappearingFromRect = self.privateAppearingToRect = self.containerView.bounds;
        self.privateDisappearingToRect = CGRectOffset (self.containerView.bounds, travelDistance, 0);
        self.privateAppearingFromRect = CGRectOffset (self.containerView.bounds, -travelDistance, 0);
    }
    
    return self;
}

//过渡开始和结束的时候每一个ViewController的frame
- (CGRect)initialFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingFromRect;
    } else {
        return self.privateAppearingFromRect;
    }
}

- (CGRect)finalFrameForViewController:(UIViewController *)viewController {
    if (viewController == [self viewControllerForKey:UITransitionContextFromViewControllerKey]) {
        return self.privateDisappearingToRect;
    } else {
        return self.privateAppearingToRect;
    }
}

- (UIViewController *)viewControllerForKey:(NSString *)key {
    return self.privateViewControllers[key];
}

- (void)completeTransition:(BOOL)didComplete {
    if (self.completionBlock) {
        self.completionBlock (didComplete);
    }
}
//非交互式,直接返回NO,因为不允许交互当然也就无法操作进度取消
- (BOOL)transitionWasCancelled { return NO; }
//非交互式,直接不进行操作,只有进行交互,下面3个协议方法才有意义,可参照系统给我们定义好的交互控制器
- (void)updateInteractiveTransition:(CGFloat)percentComplete {}
- (void)finishInteractiveTransition {}
- (void)cancelInteractiveTransition {}

@end




@interface Animation : NSObject<ContainerViewControllerDelegate>

@end

static CGFloat const kButtonSlotWidth = 64;
static CGFloat const kButtonSlotHeight = 44;

@interface TransitionViewController ()

@property (nonatomic, strong) NSArray *viewControllers;
@property (nonatomic, strong) UIView *privateButtonsView;
@property (nonatomic, strong) UIView *privateContainerView;
@property (nonatomic, strong) Animation *animation;

@end

@implementation TransitionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewControllers = [[self configureChildViewControllers] copy];
    [self initSubView];
    self.selectedViewController = (self.selectedViewController ?: self.viewControllers[0]);
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.animation = [[Animation alloc] init];
    //self.delegate = self.animation;
    
}

- (void)initSubView {
    
    // Add  container and buttons views.
    
    UIView *rootView = [[UIView alloc] init];
    rootView.backgroundColor = [UIColor blackColor];
    rootView.opaque = YES;
    
    self.privateContainerView = [[UIView alloc] init];
    self.privateContainerView.backgroundColor = [UIColor clearColor];
    self.privateContainerView.opaque = YES;
    
    self.privateButtonsView = [[UIView alloc] init];
    self.privateButtonsView.backgroundColor = [UIColor clearColor];
    self.privateButtonsView.tintColor = [UIColor colorWithWhite:1 alpha:0.75f];
    
    [self.privateContainerView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.privateButtonsView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [rootView addSubview:self.privateContainerView];
    [rootView addSubview:self.privateButtonsView];
    
    // Container view fills out entire root view.
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeHeight multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeLeft multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateContainerView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:rootView attribute:NSLayoutAttributeTop multiplier:1 constant:0]];
    
    // Place buttons view in the top half, horizontally centered.
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:[self.viewControllers count] * kButtonSlotWidth]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.privateContainerView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kButtonSlotHeight]];
    [rootView addConstraint:[NSLayoutConstraint constraintWithItem:self.privateButtonsView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.privateContainerView attribute:NSLayoutAttributeCenterY multiplier:0.4f constant:0]];
    
    [self _addChildViewControllerButtons];
    
    self.view = rootView;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}

- (UIViewController *)childViewControllerForStatusBarStyle {
    return self.selectedViewController;
}

- (void)_addChildViewControllerButtons {
    
    [self.viewControllers enumerateObjectsUsingBlock:^(UIViewController *childViewController, NSUInteger idx, BOOL *stop) {
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *icon = [childViewController.tabBarItem.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:icon forState:UIControlStateNormal];
        UIImage *selectedIcon = [childViewController.tabBarItem.selectedImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        [button setImage:selectedIcon forState:UIControlStateSelected];
        
        button.tag = idx;
        [button addTarget:self action:@selector(_buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
        
        [self.privateButtonsView addSubview:button];
        [button setTranslatesAutoresizingMaskIntoConstraints:NO];
        
        [self.privateButtonsView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.privateButtonsView attribute:NSLayoutAttributeLeading multiplier:1 constant:(idx + 0.5f) * kButtonSlotWidth]];
        [self.privateButtonsView addConstraint:[NSLayoutConstraint constraintWithItem:button attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.privateButtonsView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    }];
}

- (void)_buttonTapped:(UIButton *)button {
    UIViewController *selectedViewController = self.viewControllers[button.tag];
    self.selectedViewController = selectedViewController;
    
    if ([self.delegate respondsToSelector:@selector (containerViewController:didSelectViewController:)]) {
        [self.delegate containerViewController:self didSelectViewController:selectedViewController];
    }
}

-(void)setSelectedViewController:(UIViewController *)selectedViewController {
    NSParameterAssert (selectedViewController);
    [self _transitionToChildViewController:selectedViewController];
    _selectedViewController = selectedViewController;
    [self _updateButtonSelection];
}

- (void)_updateButtonSelection {
    [self.privateButtonsView.subviews enumerateObjectsUsingBlock:^(UIButton *button, NSUInteger idx, BOOL *stop) {
        button.selected = (self.viewControllers[idx] == self.selectedViewController);
    }];
}

- (void)_transitionToChildViewController:(UIViewController *)toViewController {
    
    UIViewController *fromViewController = ([self.childViewControllers count] > 0 ? self.childViewControllers[0] : nil);
    if (toViewController == fromViewController || ![self isViewLoaded]) {
        return;
    }

    
    UIView *toView = toViewController.view;
    [toView setTranslatesAutoresizingMaskIntoConstraints:YES];
    toView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    toView.frame = self.privateContainerView.bounds;
    
    [fromViewController willMoveToParentViewController:nil];
    [self addChildViewController:toViewController];
    
    if (!fromViewController) {
        [self.privateContainerView addSubview:toViewController.view];
        [toViewController didMoveToParentViewController:self];
        return;
    }

    
    id<UIViewControllerAnimatedTransitioning>animator = nil;
    if ([self.delegate respondsToSelector:@selector (containerViewController:animationControllerForTransitionFromViewController:toViewController:)]) {
        animator = [self.delegate containerViewController:self animationControllerForTransitionFromViewController:fromViewController toViewController:toViewController];
    }
    animator = (animator ?: [[PrivateAnimatedTransition alloc] init]);
    
    NSUInteger fromIndex = [self.viewControllers indexOfObject:fromViewController];
    NSUInteger toIndex = [self.viewControllers indexOfObject:toViewController];
    PrivateTransitionContext *transitionContext = [[PrivateTransitionContext alloc] initWithFromViewController:fromViewController toViewController:toViewController goingRight:toIndex > fromIndex];
    
    transitionContext.animated = YES;
    transitionContext.interactive = NO;
    transitionContext.completionBlock = ^(BOOL didComplete) {
        // 因为是非交互式,所以fromVC可以直接直接remove出its parent's children controllers array
        [fromViewController.view removeFromSuperview];
        [fromViewController removeFromParentViewController];
        [toViewController didMoveToParentViewController:self];
    
        if ([animator respondsToSelector:@selector (animationEnded:)]) {
            [animator animationEnded:didComplete];
        }
        self.privateButtonsView.userInteractionEnabled = YES;
    };
    
    self.privateButtonsView.userInteractionEnabled = NO;
    // 转场动画需要以转场上下文为依托,因为我们是自定义的Context,所以要手动设置
    [animator animateTransition:transitionContext];
}

- (NSArray *)configureChildViewControllers {
    NSMutableArray *childViewControllers = [[NSMutableArray alloc] initWithCapacity:3];
    NSArray *configurations = @[
                                @{@"title": @"First", @"color": [UIColor colorWithRed:0.4f green:0.8f blue:1 alpha:1]},
                                @{@"title": @"Second", @"color": [UIColor colorWithRed:1 green:0.4f blue:0.8f alpha:1]},
                                @{@"title": @"Third", @"color": [UIColor colorWithRed:1 green:0.8f blue:0.4f alpha:1]},
                                ];
    
    for (NSDictionary *configuration in configurations) {
        ChildViewController *childViewController = [[ChildViewController alloc] init];
        
        childViewController.title = configuration[@"title"];
        childViewController.themeColor = configuration[@"color"];
        childViewController.tabBarItem.image = [UIImage imageNamed:configuration[@"title"]];
        childViewController.tabBarItem.selectedImage = [UIImage imageNamed:[configuration[@"title"] stringByAppendingString:@" Selected"]];
        
        [childViewControllers addObject:childViewController];
    }
    return childViewControllers;
}

@end


@implementation Animation

- (instancetype)init {
    if (self = [super init]) {
        
    }
    return self;
}

#pragma mark - ContainerViewControllerDelegate Protocol

- (id <UIViewControllerAnimatedTransitioning>)containerViewController:(TransitionViewController *)containerViewController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController {
    return [[AnimationManager alloc] init];
}

@end
