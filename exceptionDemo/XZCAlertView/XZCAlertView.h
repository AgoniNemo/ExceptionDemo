//
//  XZCAlertView.h
//  ChinaBlue
//
//  Created by open on 16/4/29.
//  Copyright © 2016年 LCB. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface XZCAlertView : UIAlertView


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
         completionBlock:(void (^)(NSUInteger buttonIndex, XZCAlertView *alertView))block
       cancelButtonTitle:(NSString *)cancelButtonTitle
       otherButtonTitles:(NSString *)otherButtonTitles, ...;

@end
