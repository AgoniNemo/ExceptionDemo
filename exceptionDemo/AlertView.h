//
//  AlertView.h
//  exceptionDemo
//
//  Created by Mjwon on 2017/5/9.
//  Copyright © 2017年 Nemo. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UIAlertController;
@interface AlertView : NSObject


/**
 *  弹出提示框
 *
 *  @param title             提示标题
 *  @param message           提示内容
 *  @param block             回调
 *  @param cancelButtonTitle 取消按钮
 *  @param otherButtonTitles 确定按钮
 *
 *  @return 返回本身
 */
+ (id)showAlertWithTitle:(NSString *)title
                 message:(NSString *)message
         completionBlock:(void (^)(NSUInteger buttonIndex))block
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
