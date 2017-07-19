//
//  BouncePresentAnimation.m
//  AnimationDemo
//
//  Created by 刘婷 on 2017/7/19.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import "BouncePresentAnimation.h"

@implementation BouncePresentAnimation

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 1;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {

    UIViewController *toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    CGRect rect = [UIScreen mainScreen].bounds;
    CGRect finalFrame = [transitionContext finalFrameForViewController:toVC];
    toVC.view.frame = CGRectOffset(finalFrame, 0, rect.size.height);
    UIView *containerView = [transitionContext containerView];
    [containerView addSubview:toVC.view];
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    toVC.view.alpha = 0;
    [UIView animateWithDuration:duration delay:0 usingSpringWithDamping:0.6 initialSpringVelocity:0 options:UIViewAnimationOptionCurveLinear animations:^{
        toVC.view.frame = finalFrame;
        toVC.view.alpha = 1;
    } completion:^(BOOL finished) {
              [transitionContext completeTransition:YES];
    }];
}

@end
