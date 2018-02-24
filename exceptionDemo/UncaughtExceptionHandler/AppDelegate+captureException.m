//
//  AppDelegate+captureException.m
//  
//
//  Created by Mjwon on 2016/10/25.
//
//

#import "AppDelegate+captureException.h"
#import <mach/mach.h>
#include <execinfo.h>
#import <sys/signal.h>

NSString * const CrashFileDirectory = @"CrashFileDirectory"; //你的项目中自定义文件夹名

#define ERRORPATH  [NSString stringWithFormat:@"%@/error.log",[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject]]

@implementation AppDelegate (captureException)

-(void)captureApplication:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    NSSetUncaughtExceptionHandler(&UncaughtExceptionHandler);
    InstallSignalHandler();//信号量截断
}

void SignalExceptionHandler(int signal)
{
    NSMutableString *mstr = [[NSMutableString alloc] init];
    [mstr appendString:@"Stack:\n"];
    void* callstack[128];
    int i, frames = backtrace(callstack, 128);
    char** strs = backtrace_symbols(callstack, frames);
    for (i = 0; i <frames; ++i) {
        [mstr appendFormat:@"%s\n", strs[i]];
    }
    NSLog(@"%@",mstr);
    
    NSLog(@"文件夹创建成功");
    NSString *crashPath = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:CrashFileDirectory];
    NSString *filepath = [crashPath stringByAppendingPathComponent:@"Signal"];
    NSMutableDictionary *logs = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
    if (!logs) {
        logs = [[NSMutableDictionary alloc] init];
    }
    //日志信息
    NSDictionary *infos = @{@"Exception":mstr};
    [logs setObject:infos forKey:[NSString stringWithFormat:@"%@_crashLogs",@"CFBundleName"]];
    BOOL writeOK = [logs writeToFile:filepath atomically:YES];
    NSLog(@"write result = %d,filePath = %@",writeOK,filepath);

}
void signalExceptionHandler(int signal)
{
    NSMutableString *exceptionDescription = [NSMutableString string];
    [exceptionDescription appendFormat:@"reason:Signal %d was raise\n", signal];
    [exceptionDescription appendString:@"callStackSymbols:\n"];
    
    void *callstack[128];
    int frames = backtrace(callstack, 128);
    char **strs = backtrace_symbols(callstack, frames);
    for(int i = 0; i < frames; ++i)
    {
        [exceptionDescription appendFormat:@"%s\n", strs[i]];
    }
}
void InstallSignalHandler(void)
{
    /**
     SIGABRT–程序中止命令中止信号
     SIGALRM–程序超时信号
     SIGFPE–程序浮点异常信号
     SIGILL–程序非法指令信号
     SIGHUP–程序终端中止信号
     SIGINT–程序键盘中断信号
     SIGKILL–程序结束接收中止信号
     SIGTERM–程序kill中止信号
     SIGSTOP–程序键盘中止信号
     SIGSEGV–程序无效内存中止信号
     SIGBUS–程序内存字节未对齐中止信号
     SIGPIPE–程序Socket发送失败中止信号
     */
    signal(SIGHUP, SignalExceptionHandler);
    signal(SIGINT, SignalExceptionHandler);
    signal(SIGQUIT, SignalExceptionHandler);
    
    signal(SIGABRT, SignalExceptionHandler);
    signal(SIGILL, SignalExceptionHandler);
    signal(SIGSEGV, SignalExceptionHandler);
    signal(SIGFPE, SignalExceptionHandler);
    signal(SIGBUS, SignalExceptionHandler);
    signal(SIGPIPE, SignalExceptionHandler);
}


void UncaughtExceptionHandler(NSException *exception){
    if (exception == nil)return;
    NSArray *array = [exception callStackSymbols];
    NSString *reason = [exception reason];
    NSString *name  = [exception name];
    NSDictionary *dict = @{@"appException":@{@"exceptioncallStachSymbols":array,@"exceptionreason":reason,@"exceptionname":name}};
    if([AppDelegate writeCrashFileOnDocumentsException:dict]){
        NSLog(@"Crash logs write ok!");
    }
}

+ (NSString *)getCachesPath{
    
    return [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject];
}

+ (BOOL)writeCrashFileOnDocumentsException:(NSDictionary *)exception{
    
    NSDateFormatter * df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *time = [df stringFromDate:[NSDate date]];
    
    
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *crashname = [NSString stringWithFormat:@"%@_%@Crashlog.plist",time,infoDictionary[@"CFBundleName"]];
    NSString *crashPath = [[self getCachesPath] stringByAppendingPathComponent:CrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    
    //设备信息
    NSMutableDictionary *deviceInfos = [NSMutableDictionary dictionary];
    [deviceInfos setObject:[infoDictionary objectForKey:@"DTPlatformVersion"] forKey:@"DTPlatformVersion"];
    [deviceInfos setObject:[infoDictionary objectForKey:@"CFBundleShortVersionString"] forKey:@"CFBundleShortVersionString"];
    [deviceInfos setObject:[infoDictionary objectForKey:@"UIRequiredDeviceCapabilities"] forKey:@"UIRequiredDeviceCapabilities"];
    
    BOOL isSuccess = [manager createDirectoryAtPath:crashPath withIntermediateDirectories:YES attributes:nil error:nil];
    if (isSuccess) {
        NSLog(@"文件夹创建成功");
        NSString *filepath = [crashPath stringByAppendingPathComponent:crashname];
        NSMutableDictionary *logs = [NSMutableDictionary dictionaryWithContentsOfFile:filepath];
        if (!logs) {
            logs = [[NSMutableDictionary alloc] init];
        }
        //日志信息
        NSDictionary *infos = @{@"Exception":exception,@"DeviceInfo":deviceInfos};
        [logs setObject:infos forKey:[NSString stringWithFormat:@"%@_crashLogs",infoDictionary[@"CFBundleName"]]];
        BOOL writeOK = [logs writeToFile:filepath atomically:YES];
        NSLog(@"write result = %d,filePath = %@",writeOK,filepath);
        return writeOK;
    }else{
        return NO;
    }
}

+ (nullable NSArray *)getCrashLogs{
    
    NSString *crashPath = [[self getCachesPath] stringByAppendingPathComponent:CrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray *array = [manager contentsOfDirectoryAtPath:crashPath error:nil];
    NSMutableArray *result = [NSMutableArray array];
    if (array.count == 0) return nil;
    for (NSString *name in array) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:[crashPath stringByAppendingPathComponent:name]];
        [result addObject:dict];
    }
    return result;
}
+ (BOOL)clearCrashLogs{
    
    NSString *crashPath = [[self getCachesPath] stringByAppendingPathComponent:CrashFileDirectory];
    NSFileManager *manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:crashPath]) return YES; //如果不存在,则默认为删除成功
    NSArray *contents = [manager contentsOfDirectoryAtPath:crashPath error:NULL];
    if (contents.count == 0) return YES;
    NSEnumerator *enums = [contents objectEnumerator];
    NSString *filename;
    BOOL success = YES;
    while (filename = [enums nextObject]) {
        if(![manager removeItemAtPath:[crashPath stringByAppendingPathComponent:filename] error:NULL]){
            success = NO;
            break;
        }
    }
    return success;
}

#pragma mark - 捕获异常

void captureException(NSException *exception){
    
    NSArray *stackArr = [exception callStackSymbols];
    NSString *reasonStr = [exception reason];
    NSString *nameStr = [exception name];
    NSString *exceptionInfo = [NSString stringWithFormat:@"Exception reason：%@\nException name：%@\nException stack：%@",nameStr, reasonStr, stackArr];
    NSMutableArray *carshArr = [NSMutableArray arrayWithArray:stackArr];
    [carshArr insertObject:reasonStr atIndex:0];
    //保存到本地
    [exceptionInfo writeToFile:ERRORPATH atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"崩溃日志路径:%@",ERRORPATH);
    
}

@end
