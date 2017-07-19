//
//  GroupViewController.m
//  AnimationDemo
//
//  Created by 刘婷 on 2017/7/18.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import "GroupViewController.h"

@interface GroupViewController ()<CALayerDelegate>

@property (nonatomic, strong) UIButton *basicAniBtn;
@property (nonatomic, strong) UIButton *keyFrameAniBtn;
@property (nonatomic, strong) UIButton *groupAniBtn;

@end

@implementation GroupViewController{
    CALayer *_layer;
    CALayer *_subLayer;
    UIImageView *_imageView;
    UIImageView *_imageView1;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    [self initButton];
    [self initCALayer];
    [self initImageView];

}

- (void)initButton {
    CGFloat y = [UIScreen mainScreen].bounds.size.height - 50;
    self.basicAniBtn = [self createButtonWithTitle:@"basic" frame:CGRectMake(50, y, 90, 30) tag:1];
    [self.view addSubview:self.basicAniBtn];
    self.keyFrameAniBtn = [self createButtonWithTitle:@"keyFrame" frame:CGRectMake(150, y, 90, 30) tag:2];
    [self.view addSubview:self.keyFrameAniBtn];
    self.groupAniBtn = [self createButtonWithTitle:@"group" frame:CGRectMake(250, y, 90, 30) tag:3];
    [self.view addSubview:self.groupAniBtn];
}

- (UIButton *)createButtonWithTitle:(NSString *)title frame:(CGRect)frame tag:(NSInteger)tag{
    UIButton *btn = [[UIButton alloc] init];
    btn.frame = frame;
    [btn setBackgroundColor:[UIColor orangeColor]];
    btn.layer.cornerRadius = 2;
    btn.layer.masksToBounds = YES;
    [btn setTitle:title forState:UIControlStateNormal];
    btn.tag = tag;
    [btn addTarget:self action:@selector(ainimationClick:) forControlEvents:UIControlEventTouchUpInside];
    return btn;
}

- (void)initImageView {
    _imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"instructions1"]];
    _imageView.frame = CGRectMake(100, 80, 150, 150);
    _imageView.hidden = YES;
    [self.view addSubview:_imageView];
}

- (void)initCALayer {
    _layer = [[CALayer alloc] init];
    _layer.bounds = CGRectMake(100, 100, 40, 40);
    _layer.position = CGPointMake(50, 200);
    _layer.anchorPoint = CGPointMake(0, 0);
    _layer.backgroundColor = [UIColor orangeColor].CGColor;
    _layer.delegate = self;
    _layer.needsDisplayOnBoundsChange = YES;
    [self.view.layer addSublayer:_layer];
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    [self animations];
}

- (void)ainimationClick:(UIButton *)btn {
    [_layer removeAllAnimations];
    switch (btn.tag) {
        case 1:
            _imageView.hidden = YES;
            [self basicAnimation];
            break;
        case 2:
            _imageView.hidden = YES;
            [self frameAnimation];
            break;
        case 3:
            _imageView.hidden = NO;
            [self animations];
            break;
            
        default:
            break;
    }
}

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

- (void)basicAnimation {
    CABasicAnimation *animation = [CABasicAnimation animation];
    animation.keyPath = @"position.x";
    animation.fromValue = @77;
    animation.toValue = @455;
    animation.duration = 1;
    //时间函数,也可以使用 +functionWithControlPoints:::: 创建自己的 easing 函数
    animation.timingFunction = [CAMediaTimingFunction functionWithControlPoints:0.5:0.0 :0.9 :0.7];
    animation.fillMode = kCAFillModeForwards;//留在最终状态
    animation.removedOnCompletion = NO; //防止它被自动移除
    [_layer addAnimation:animation forKey:@"basic"];
}

- (void)frameAnimation {
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animation];
    animation.keyPath = @"position";
    CGRect rect = CGRectMake(0, 0, 300, 300);
    //创建一个圆形CGPath作为关键帧动画的path
    animation.path = CFAutorelease(CGPathCreateWithEllipseInRect(rect, NULL));
    animation.duration = 4;
    animation.additive = YES;
    animation.repeatCount = 10;
    animation.calculationMode = kCAAnimationPaced;//将会无视设置的keytimes
    animation.rotationMode = kCAAnimationRotateAuto;
    [_layer addAnimation:animation forKey:nil];
    
}

- (void)CATransition{
    CATransition *tran = [[CATransition alloc] init];
    tran.duration = 2;
    //tran.timingFunction = UIViewAnimationCurveEaseOut;
    tran.type = kCATransitionReveal;
    tran.subtype = kCATransitionFromBottom;
    [_layer addAnimation:tran forKey:nil];
}

- (void)dealloc {
    _layer.delegate = nil; //如果不把delegate 设置为nil pop的时候会crash
    [_layer removeAllAnimations];
    
}
@end
