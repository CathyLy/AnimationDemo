//
//  InteraciveTransitionViewController.m
//  AnimationDemo
//
//  Created by 刘婷 on 2017/7/19.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import "InteraciveTransitionViewController.h"
#import "ModalViewController.h"
#import "BouncePresentAnimation.h"
#import "NormalDismissAnimation.h"
#import "SwipeUpInteractiveTransition.h"

@interface InteraciveTransitionViewController ()<UIViewControllerTransitioningDelegate,ModalViewControllerDelegate>
@property (nonatomic, strong) BouncePresentAnimation *presentAnimation;
@property (nonatomic, strong) NormalDismissAnimation *dismissAnimation;
@property (nonatomic, strong) SwipeUpInteractiveTransition *transitionController;
@end

@implementation InteraciveTransitionViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.view.backgroundColor = [UIColor whiteColor];
        _presentAnimation = [BouncePresentAnimation new];
        _dismissAnimation = [NormalDismissAnimation new];
        _transitionController = [SwipeUpInteractiveTransition new];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    button.frame = CGRectMake(80.0, 210.0, 160.0, 40.0);
    [button setTitle:@"Click me" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];

}

- (void)buttonClicked:(UIButton *)btn {
    ModalViewController *mvc =  [[ModalViewController alloc] init];
    mvc.transitioningDelegate = self;
    mvc.delegate = self;
    [self.transitionController wireToViewController:mvc];
    [self presentViewController:mvc animated:YES completion:nil];
}

- (id <UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return self.presentAnimation;
}

-(id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return self.dismissAnimation;
}

-(id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.transitionController.interacting ? self.transitionController : nil;
}

-(void) modalViewControllerDidClickedDismissButton:(ModalViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
