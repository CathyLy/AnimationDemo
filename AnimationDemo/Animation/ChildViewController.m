//
//  ChildViewController.m
//  AnimationDemo
//
//  Created by 刘婷 on 2017/7/18.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import "ChildViewController.h"

@interface ChildViewController ()
@property (nonatomic, strong) UILabel *privateTitleLabel;
@end

@implementation ChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self _updateAppearance];
    // Do any additional setup after loading the view.
}

- (void)setTitle:(NSString *)title {
    super.title = title;
    [self _updateAppearance];
}

- (void)setThemeColor:(UIColor *)themeColor {
    _themeColor = themeColor;
    [self _updateAppearance];
}

- (void)_updateAppearance {
    if ([self isViewLoaded]) {
        self.privateTitleLabel.text = self.title;
        self.view.backgroundColor = self.themeColor;
        self.view.tintColor = self.themeColor;
    }
}

- (void)loadView {
    
    self.privateTitleLabel = [[UILabel alloc] init];
    self.privateTitleLabel.backgroundColor = [UIColor clearColor];
    self.privateTitleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleHeadline];
    self.privateTitleLabel.textAlignment = NSTextAlignmentCenter;
    self.privateTitleLabel.numberOfLines = 0;
    [self.privateTitleLabel setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.view = [[UIView alloc] init];
    [self.view addSubview:self.privateTitleLabel];
//    self.view.frame = [UIScreen mainScreen].bounds;
    // Center label in view.
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.privateTitleLabel attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeWidth multiplier:0.6f constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.privateTitleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.privateTitleLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
}

@end
