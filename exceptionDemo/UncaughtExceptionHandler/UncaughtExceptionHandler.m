//
//  UncaughtExceptionHandler.m
//  exceptionDemo
//
//  Created by Mjwon on 2017/4/24.
//  Copyright © 2017年 Nemo. All rights reserved.
//

#import "UncaughtExceptionHandler.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#import "AppDelegate.h"
#import "XZCAlertView.h"
#import "ViewController.h"

NSString * const UncaughtExceptionHandlerSignalExceptionName = @"UncaughtExceptionHandlerSignalExceptionName";
NSString * const UncaughtExceptionHandlerSignalKey = @"UncaughtExceptionHandlerSignalKey";
NSString * const UncaughtExceptionHandlerAddressesKey = @"UncaughtExceptionHandlerAddressesKey";
//当前处理的异常个数
volatile int32_t UncaughtExceptionCount = 1;
//能够处理的最大异常个数
const int32_t UncaughtExceptionMaximum = 10;

const NSInteger UncaughtExceptionHandlerSkipAddressCount = 4;
const NSInteger UncaughtExceptionHandlerReportAddressCount = 5;

@interface UncaughtExceptionHandler ()<UIAlertViewDelegate>
{
    BOOL dismissed;
}
//计时器
@property (strong, nonatomic) NSTimer *countDurTimer;

@end

@implementation UncaughtExceptionHandler

+ (NSArray *)backtrace
{
    void* callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    
    int i;
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    for (
         i = UncaughtExceptionHandlerSkipAddressCount;
         i < UncaughtExceptionHandlerSkipAddressCount +
         UncaughtExceptionHandlerReportAddressCount;
         i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    free(strs);
    
    return backtrace;
}

- (void)alertView:(UIAlertView *)anAlertView clickedButtonAtIndex:(NSInteger)anIndex
{
    if (anIndex == 0)
    {
        dismissed = YES;
    }else{
        dismissed = NO;
        /**
        AppDelegate *app = [[UIApplication sharedApplication] delegate];
        app.mainViewController = [[MainTabBarController alloc] init];
        app.window.rootViewController =  app.mainViewController;
        [app.mainViewController exchangeTabbarHightFromSetSystemTextFont:nil];
        */
        NSLog(@"%@",[NSThread currentThread]);
        UIApplication *app = [UIApplication sharedApplication];
        if(app.applicationState == UIApplicationStateInactive){
            NSLog(@"程序在运行状态");
        }
        AppDelegate *a = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        ViewController *v = [[ViewController alloc] init];
        v.title = @"已经崩溃了";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:v];
        
        a.window.rootViewController = nav;
        
    }
}
// 保存一些用户的数据
- (void)validateAndSaveCriticalApplicationData
{
    NSLog(@"%s",__func__);
}
//捕获信号后的回调函数  由HandleException调用
- (void)handleException:(NSException *)exception
{
    [self validateAndSaveCriticalApplicationData];
    NSString *reason = [exception reason];
    NSString *name = [exception name];
    
    UIAlertView *alert =
    [[UIAlertView alloc]
      initWithTitle:@"提示"
      message:[NSString stringWithFormat:@"CRASH: %@ name:%@,\nReason: %@,\nStack Trace: %@,\n",exception,name,reason,[exception callStackSymbols]]
      delegate:self
      cancelButtonTitle:@"取消"
      otherButtonTitles:@"确定", nil];
    [alert show];
    
    //或者直接用代码，输入这个崩溃信息，以便在console中进一步分析错误原因
    //当接收到异常处理消息是，让程序开始runloop，防止程序死亡
    CFRunLoopRef runLoop = CFRunLoopGetCurrent();
    CFArrayRef allModes = CFRunLoopCopyAllModes(runLoop);
    
    while (!dismissed)
    {
        for (NSString *mode in (__bridge NSArray *)allModes)
        {
            CFRunLoopRunInMode((__bridge CFStringRef)mode, 0.001, false);
        }
    }
    
    NSLog(@"%s",__func__);
    CFRelease(allModes);
    
    NSSetUncaughtExceptionHandler(NULL);
    signal(SIGABRT, SIG_DFL);
    signal(SIGILL, SIG_DFL);
    signal(SIGSEGV, SIG_DFL);
    signal(SIGFPE, SIG_DFL);
    signal(SIGBUS, SIG_DFL);
    signal(SIGPIPE, SIG_DFL);
    
    if ([[exception name] isEqual:UncaughtExceptionHandlerSignalExceptionName])
    {
        kill(getpid(), [[[exception userInfo] objectForKey:UncaughtExceptionHandlerSignalKey] intValue]);
    }else{
        [exception raise];
    }
}

@end


//捕获信号后的回调函数
void HandleException(NSException *exception)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    NSMutableDictionary *userInfo =
    [NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:[exception name]
      reason:[exception reason]
      userInfo:userInfo]
     waitUntilDone:YES];
}

void SignalHandler(int signal)
{
    int32_t exceptionCount = OSAtomicIncrement32(&UncaughtExceptionCount);
    if (exceptionCount > UncaughtExceptionMaximum)
    {
        return;
    }
    
    NSMutableDictionary *userInfo =
    [NSMutableDictionary
     dictionaryWithObject:[NSNumber numberWithInt:signal]
     forKey:UncaughtExceptionHandlerSignalKey];
    
    NSArray *callStack = [UncaughtExceptionHandler backtrace];
    [userInfo
     setObject:callStack
     forKey:UncaughtExceptionHandlerAddressesKey];
    
    [[[UncaughtExceptionHandler alloc] init]
     performSelectorOnMainThread:@selector(handleException:)
     withObject:
     [NSException
      exceptionWithName:UncaughtExceptionHandlerSignalExceptionName
      reason:
      [NSString stringWithFormat:
       NSLocalizedString(@"Signal %d was raised.", nil),
       signal]
      userInfo:
      [NSDictionary
       dictionaryWithObject:[NSNumber numberWithInt:signal]
       forKey:UncaughtExceptionHandlerSignalKey]]
     waitUntilDone:YES];
}

//SIGABRT--程序中止命令中止信号
//SIGALRM--程序超时信号
//SIGFPE--程序浮点异常信号
//SIGILL--程序非法指令信号
//SIGHUP--程序终端中止信号
//SIGINT--程序键盘中断信号
//SIGKILL--程序结束接收中止信号
//SIGTERM--程序kill中止信号
//SIGSTOP--程序键盘中止信号
//SIGSEGV--程序无效内存中止信号
//SIGBUS--程序内存字节未对齐中止信号
//SIGPIPE--程序Socket发送失败中止信号
void InstallUncaughtExceptionHandler(void)
{
    NSSetUncaughtExceptionHandler(&HandleException);
    signal(SIGABRT, SignalHandler);
    signal(SIGILL, SignalHandler);
    signal(SIGSEGV, SignalHandler);
    signal(SIGFPE, SignalHandler);
    signal(SIGBUS, SignalHandler);
    signal(SIGPIPE, SignalHandler);
}
