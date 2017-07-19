//
//  SwipeUpInteractiveTransition.m
//  AnimationDemo
//
//  Created by 刘婷 on 2017/7/19.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import "SwipeUpInteractiveTransition.h"

@interface SwipeUpInteractiveTransition()
@property (nonatomic, assign) BOOL shouldComplete;
@property (nonatomic, strong) UIViewController *presentingVC;
@end

@implementation SwipeUpInteractiveTransition

-(void)wireToViewController:(UIViewController *)viewController
{
    self.presentingVC = viewController;
    [self prepareGestureRecognizerInView:viewController.view];
}

- (void)prepareGestureRecognizerInView:(UIView *)view {
    UIPanGestureRecognizer *gesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleGesture:)];
    [view addGestureRecognizer:gesture];
}

- (void)handleGesture:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:pan.view.superview];
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            self.interacting = YES;
            [self.presentingVC dismissViewControllerAnimated:YES completion:nil];
            break;
        case UIGestureRecognizerStateChanged:
        {
            CGFloat fraction = translation.y / 400.0;
            fraction = fminf(fmax(fraction, 0), 1);
            self.shouldComplete = (fraction > 0.5);
             [self updateInteractiveTransition:fraction];
        }
            break;
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled:
            self.interacting = NO;
            if (!self.shouldComplete || pan.state == UIGestureRecognizerStateCancelled) {
                [self cancelInteractiveTransition];
            } else {
                [self finishInteractiveTransition];
            }
            break;
        default:
            break;
    }
}

- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}

@end
