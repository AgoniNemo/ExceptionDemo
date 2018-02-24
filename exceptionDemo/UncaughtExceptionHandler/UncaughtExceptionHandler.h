//
//  UncaughtExceptionHandler.h
//  exceptionDemo
//
//  Created by Mjwon on 2017/4/24.
//  Copyright © 2017年 Nemo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UncaughtExceptionHandler : NSObject

@end

void HandleException(NSException *exception);
void SignalHandler(int signal);

void InstallUncaughtExceptionHandler(void);
