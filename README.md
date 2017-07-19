#### UIBezierPath
    UIBezierPath对象是 CGPathRef数据类型的封装

#### UIBezierPath的几种绘制
    1.绘制带有圆角的矩形
    UIBezierPath *pPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(10, 250, 100, 40) cornerRadius:5];
    2.绘制圆弧
    UIBezierPath *ovalPath = [UIBezierPath bezierPathWithArcCenter:CGPointMake(100, 300) radius:40 startAngle:0 endAngle:- M_PI_2 clockwise:YES];
    3.绘制贝塞尔曲线
    - (void)drawRect:(CGRect)rect {
    UIBezierPath *quadCurvePath = [UIBezierPath bezierPath];
    [[UIColor redColor] set];
    [quadCurvePath moveToPoint:CGPointMake(20, 100)];
    quadCurvePath.lineWidth = 5;
    quadCurvePath.lineCapStyle = kCGLineJoinRound;
    
    [quadCurvePath addQuadCurveToPoint:CGPointMake(120, 100) controlPoint:CGPointMake(0, 0)];
    [quadCurvePath stroke];
    
    //
    //[quadCurvePath addCurveToPoint:CGPointMake(280, 50) controlPoint1:CGPointMake(100, 0) controlPoint2:CGPointMake(150, 170)]; 
    }
    
    
### Core Animation
    Core Animation是一个复合引擎，它的职责就是尽可能快地组合屏幕上不同的可视内容，这个内容是被分解成独立的图层，
    存储在一个叫做图层树的体系之中。于是这个树形成了UIKit以及在iOS应用程序当中你所能在屏幕上看见的一切的基础
#### CALayer 
![image](https://raw.githubusercontent.com/CathyLy/imageForSource/master/CALayer.jpeg)
    每一个UIView 都有一个CALayer实例的图层属性,实际上关联的图层才是真正用来在屏幕上显示和做动画.
    UIView仅仅是对它的一个封装,提供了一些iOS类似于处理触摸的具体功能，以及Core Animation底层方法的高级接口。
    //除了视图层级和图层树之外,还存在呈现树和渲染树
    
    UIView中没有提供的CALayer的功能:
     1.阴影，圆角，带颜色的边框
     2.3D变换
     3.非矩形范围
     4.透明遮罩
     5.多级非线性动画
     
    当UIView创建了它的宿主图层时，它就会自动地把图层的delegate设置为它自己，并提供了一个-displayLayer:的实现

### 图层几何学

### 基本动画
    - (void)basicAnimation {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.x";
    animation.fromValue = @77;
    animation.toValue = @455;
    animation.duration = 1;
    //时间函数,也可以使用 +functionWithControlPoints:::: 创建自己的 easing 函数
    //animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5:0.0 :0.9 :0.7];
    animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    animation.fillMode = kCAFillModeForwards;//留在最终状态
    animation.removedOnCompletion = NO; //防止它被自动移除
    [_layer addAnimation:animation forKey:@"basic"];
    }
    
### CAKeyframeAnimation
    1.实现shake
    - (void)frameAnimation {
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position.x";
    animation.values = @[@0,@10,@(-10),@10,@0];//定义了应该到的位置
    animation.keyTimes = @[@0,@(1/6.0),@(3/6.0),@(5/6.0),@1]; //指定关键帧动画发生的时间
    animation.duration = 0.6;
    //使CoreAnimation在更新presentation layer 之前将动画的值添加到model layer中去
    //使我们能够对所有形式的需要更新的元素重用相同的动画，且无需提前知道它们的位置
    animation.additive = YES;
    [_layer addAnimation:animation forKey:nil];
    }
    2.实现圆周运行

### GroupViewController
    - (void)animations {
    CABasicAnimation *zPosition = [CABasicAnimation animation];
    zPosition.keyPath = @"zPosition";
    zPosition.fromValue = @-1;
    zPosition.toValue = @1;
    zPosition.duration = 1.2;

    CAKeyframeAnimation *rotation = [CAKeyframeAnimation animation];
    rotation.keyPath = @"transform.rotation";
    rotation.values = @[@0,@0.14,@0];
    rotation.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    
    CAKeyframeAnimation *position = [CAKeyframeAnimation animation];
    position.keyPath = @"position";
    position.values = @[[NSValue valueWithCGPoint:CGPointZero],
                        [NSValue valueWithCGPoint:CGPointMake(110, -20)],
                        [NSValue valueWithCGPoint:CGPointZero]];
    
    position.timingFunctions = @[[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut],
                                 [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut]];
    position.additive = YES;
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[zPosition,rotation,position];
    group.duration = 1.2;
    //group.beginTime = 0.5;
    [_imageView.layer addAnimation:group forKey:nil];
    _imageView.layer.zPosition = 1;

    }

    - (void)groupAnimation {
    //基本动画
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"transform.scale";
    animation.toValue = @0.1;
    
    CAKeyframeAnimation *frameAnim = [CAKeyframeAnimation animation];
    frameAnim.keyPath = @"position";
    frameAnim.path = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(0, 0, 300, 300)].CGPath;
    
    //关键帧动画
    CAAnimationGroup *groupAnimation = [[CAAnimationGroup alloc] init];
    groupAnimation.duration = 2;
    groupAnimation.fillMode = kCAFillModeForwards;
    groupAnimation.removedOnCompletion = NO;
    groupAnimation.animations = @[animation,frameAnim];
    [_layer addAnimation:groupAnimation forKey:@""];
    }
    
### 转场动画
     简要介绍:iOS7中提供了API支持View Controller之间的转场动画,有以下主要五个组件
![image](https://raw.githubusercontent.com/CathyLy/imageForSource/master/animationTransition.png)
    
    1.动画控制器,遵从 UIViewControllerAnimatedTransitioning 协议,并且负责实际执行动画
    2.交互控制器,UIViewControllerInteractiveTransitioning 协议来控制可交互式的转场
    3.转场代理
    4.转场上下文:定义了转场时需要的元数据，比如在转场过程中所参与的视图控制器和视图的相关属性 
      转场上下文对象遵从 UIViewControllerContextTransitioning 协议，并且这是由系统负责生成和提供的
    5.转场协调器

#### 一.不可交互的转场

demo的github地址[https://github.com/CathyLy/AnimationDemo](http://note.youdao.com/)
##### 1.UIViewControllerAnimatedTransitioning
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
    
    
##### 2.UIViewControllerContextTransitioning 转场上下文
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
    
#### 二.交互式的转场动画
     1.UIViewControllerTransitioningDelegate 
     在需要VC切换的时候系统会像实现了这个接口的对象询问是否需要使用自定义的切换效果
     1.首先需要得到参与切换的两个ViewController的信息,使用context的方法拿到它们的参照
     2.
     - (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return self.presentAnimation;
    }
    - (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return self.dismissAnimation;
    }
    - (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.transitionController.interacting ? self.transitionController : nil;
    }
    
    UIPercentDrivenInteractiveTransition类
    实现了UIViewControllerInteractiveTransitioning协议,可以用百分比来控制交互切换的工程,使用某些手势来完成交互式的转移
    - (void)updateInteractiveTransition:(CGFloat)percentComplete;//更新百分比,一般通过手势识别的长度之类的来计算一个值
    - (void)cancelInteractiveTransition;//报告交互取消,返回切换前的状态
    - (void)finishInteractiveTransition;//报告交互完成,更新到切换后的状态
    
    UIViewControllerInteractiveTransitioning
    

    


    








   
   
    