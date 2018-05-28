//
//  ViewController.m
//  RunLoopDemo
//
//  Created by 苏友龙 on 2018/5/24.
//  Copyright © 2018年 guimi. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self getRunLoopObject];
}

- (void)getRunLoopObject
{
    // NSRunLoop
    NSRunLoop *main = [NSRunLoop mainRunLoop];
    NSRunLoop *current = [NSRunLoop currentRunLoop];
    
    
    // CFRunLoop
    CFRunLoopRef mainRef = CFRunLoopGetMain();
    CFRunLoopRef currentRef = CFRunLoopGetCurrent();
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(showLog) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
    NSLog(@"%@",[NSRunLoop mainRunLoop]);
}

- (void)showLog
{
    NSLog(@"%@",[NSDate date]);
}

- (void)performSelectorAction
{
    // 主线程执行
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self performSelectorOnMainThread:@selector(showLog) withObject:nil waitUntilDone:YES];
    });
    
    // 主线程执行 指定model
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self performSelectorOnMainThread:@selector(showLog) withObject:nil waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
    });
    
    // 当前线程
    [self performSelector:@selector(showLog) withObject:nil afterDelay:2];
    
    // 当前线程 指定model
    [self performSelector:@selector(showLog) withObject:nil afterDelay:2 inModes:@[NSRunLoopCommonModes]];
    
    // 指定线程
    [self performSelector:@selector(showLog) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES];
    
    // 指定线程 指定model
    [self performSelector:@selector(showLog) onThread:[NSThread mainThread] withObject:nil waitUntilDone:YES modes:@[NSRunLoopCommonModes]];
}

// 自定义source
- (void)customSource
{
    
}

//- (void)testForCustomSource
//{
//    NSLog(@"start thread ......");
//
//    NSRunLoop *myRunLoop = [NSRunLoop currentRunLoop];
//
//    // 设置 observe的运行环境
//    CFRunLoopObserverContext context = {0,(__bridge void*)(self),NULL,NULL,NULL};
//
//    // 创建 observer对象
//    CFRunLoopObserverRef observer = CFRunLoopObserverCreate(kCFAllocatorDefault, kCFRunLoopAllActivities, YES, 0, &myRunLoopObserver, &context);
//
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
























