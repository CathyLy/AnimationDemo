//
//  TransitionViewController.h
//  AnimationDemo
//
//  Created by 刘婷 on 2017/7/18.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import <UIKit/UIKit.h>
@class TransitionViewController;
@protocol ContainerViewControllerDelegate <NSObject>
@optional

- (void)containerViewController:(TransitionViewController *)containerViewController didSelectViewController:(UIViewController *)viewController;

- (id <UIViewControllerAnimatedTransitioning>)containerViewController:(TransitionViewController *)containerViewController animationControllerForTransitionFromViewController:(UIViewController *)fromViewController toViewController:(UIViewController *)toViewController;
@end

@interface TransitionViewController : UIViewController

@property (nonatomic, assign) UIViewController *selectedViewController;
@property (nonatomic, weak) id<ContainerViewControllerDelegate>delegate;

@end
