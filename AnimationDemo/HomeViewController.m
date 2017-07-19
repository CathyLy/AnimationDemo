//
//  HomeViewController.m
//  AnimationDemo
//
//  Created by 刘婷 on 2017/7/18.
//  Copyright © 2017年 nothing. All rights reserved.
//

#import "HomeViewController.h"
#import "GroupViewController.h"
#import "TransitionViewController.h"
#import "InteraciveTransitionViewController.h"

@interface HomeViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *dataList;

@end

@implementation HomeViewController {
    UITableView *_tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"homeViewController";
    [self initTableView];
}

- (void)initTableView {
    CGSize size = [UIScreen mainScreen].bounds.size;
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0,size.width , size.height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"UITableViewCell"];
    [self.view addSubview:_tableView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.dataList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"UITableViewCell" forIndexPath:indexPath];
    cell.textLabel.text = self.dataList[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    Class class = NSClassFromString(self.dataList[indexPath.row]);
    UIViewController *nextVC = (UIViewController *)[[class alloc] init];
    nextVC.title = self.dataList[indexPath.row];
    //nextVC.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController pushViewController:nextVC animated:YES];
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
        [_dataList addObjectsFromArray:@[@"GroupViewController",@"TransitionViewController",@"InteraciveTransitionViewController"]];
    }
    return _dataList;
}

@end
