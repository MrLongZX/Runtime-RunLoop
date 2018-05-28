//
//  ViewController.m
//  Runloop-性能优化，加载大图
//
//  Created by codepgq on 2017/2/28.
//  Copyright © 2017年 pgq. All rights reserved.
//

#import "RunLoopListViewController.h"
#import "PQRunloop.h"
#import "Utils.h"

/*
 不知道为啥 创建table后 创建 0 到 13 位置的cell , runloop从第8个位置开始添加图片
 优点：相对不进行优化，要顺畅很多
 缺点：由于添加图片有先后顺序，左侧图片最后添加，滑动时左侧图片位置会出现空白到展示的模糊过程，快速滑动会出现空白
 */

/*
 文章：https://juejin.im/entry/58b93b72ac502e006bdf7527
 思想：
 1 加载图片的代码保存起来，不要直接执行，用一个数组保存
 block
 2 监听我们的Runloop循环
 CFRunloop CFRunloopObserver
 3 每次Runloop循环就让它从数组里面去一个加载图片等任务出来执行
 */

static NSString *CellIdentifier = @"CellIdentifier";

@interface RunLoopListViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UITableView *tableView;

@end


@implementation RunLoopListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"RunLoop 优化列表";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.tableView];
}

#pragma MARK - Talbeview Delegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 100;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 155;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    // 先赋值将要显示的indexPath
    cell.willShowIndexpath = indexPath;
    
    // 先移除
    for (NSInteger i = 1; i <= 5; i++) {
        [[cell.contentView viewWithTag:i] removeFromSuperview];
    }
    // 添加文字
    [self addLabel:cell indexPath:indexPath];
    
#if 1 // 是否开启Runloop优化
    
    // 使用优化
    __weak __typeof(self)weakSelf = self;
    [[PQRunloop shareInstance] addTask:^BOOL{
        if (![cell.willShowIndexpath isEqual:indexPath]) {
            return NO;
        }
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf addCenterImg:cell];
        return YES;
    } withId:indexPath];
    
    [[PQRunloop shareInstance] addTask:^BOOL{
        if (![cell.willShowIndexpath isEqual:indexPath]) {
            return NO;
        }
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf addRightImg:cell];
        return YES;
    } withId:indexPath];
    
    [[PQRunloop shareInstance] addTask:^BOOL{
        if (![cell.willShowIndexpath isEqual:indexPath]) {
            return NO;
        }
        __strong __typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf addLeftImg:cell indexPath:indexPath];
        return YES;
    } withId:indexPath];
#else
    // 不使用优化
    [self addCenterImg:cell];
    [self addRightImg:cell];
    [self addLeftImg:cell indexPath:indexPath];
    
#endif
    return cell;
}

/**
 创建一个Label
 
 @param cell cell
 @param indexPath 用来拼接
 */
- (void)addLabel:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSString * text = [NSString stringWithFormat:@"%zd - Runloop性能优化：一次绘制一张图片。", indexPath.row];
    UILabel *label = [Utils createLabelWithFrame:CGRectMake(5, 5, 300, 25) tag:1 text:text textColor:[UIColor orangeColor]];
    
    [cell.contentView addSubview:label];
}


/**
 添加中间图片
 
 @param cell cell
 */
- (void)addCenterImg:(UITableViewCell *)cell
{
    UIImageView *imageView = [Utils createImageWithFrame:CGRectMake(105, 20, 85, 85) tag:2];
    [cell.contentView addSubview:imageView];
}


/**
 添加右边图片
 
 @param cell cell
 */
- (void)addRightImg:(UITableViewCell *)cell
{
    UIImageView *imageView = [Utils createImageWithFrame:CGRectMake(200, 20, 85, 85) tag:3];
    [cell.contentView addSubview:imageView];
}


/**
 添加左边图片和 label
 
 @param cell cell
 @param indexPath 用来拼接字符串使用
 */
- (void)addLeftImg:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath
{
    NSString *text = [NSString stringWithFormat:@"%zd - 在Runloop中一次循环绘制所有的点，这里显示加载大图，使得绘制的点增多，从而导致Runloop的点一次循环时间增长，从而导致UI卡顿。", indexPath.row];
    
    UILabel *label = [Utils createLabelWithFrame:CGRectMake(5, 99, [UIScreen mainScreen].bounds.size.width - 10, 50) tag:4 text:text textColor:[UIColor colorWithRed:0.2 green:100.f/255.f blue:0 alpha:1]];
    
    UIImageView *imageView = [Utils createImageWithFrame:CGRectMake(5, 20, 85, 85) tag:5];
    [cell.contentView addSubview:label];
    [cell.contentView addSubview:imageView];
}

#pragma mark - 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height) style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.backgroundColor = [UIColor whiteColor];
        //_tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    }
    return _tableView;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    [[PQRunloop shareInstance] removeAllTasks];
}

@end
