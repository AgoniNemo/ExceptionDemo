//
//  AlertView.m
//  exceptionDemo
//
//  Created by Mjwon on 2017/5/9.
//  Copyright © 2017年 Nemo. All rights reserved.
//

#import "AlertView.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

@implementation AlertView

+(id)showAlertWithTitle:(NSString *)title message:(NSString *)message completionBlock:(void (^)(NSUInteger))block cancelButtonTitle:(NSString *)cancelButtonTitle otherButtonTitles:(NSString *)otherButtonTitles, ...
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    
    [alert setValue:[self setMessageStyleForMsg:message] forKey:@"attributedMessage"];
    NSUInteger i = 0;
    if (cancelButtonTitle) {
        [alert addAction:[self createForTitle:cancelButtonTitle style:UIAlertActionStyleCancel action:^(UIAlertAction *action) {
            block(i);
        }]];
    }
    
    id eachObject;
    va_list argumentList;
    if (otherButtonTitles) {
        i ++;
        [alert addAction:[self createForTitle:otherButtonTitles style:UIAlertActionStyleDefault action:^(UIAlertAction *action) {
            block(i);
        }]];
        va_start(argumentList, otherButtonTitles);
        while ((eachObject = va_arg(argumentList, id))) {
            i ++;
            if ([eachObject isKindOfClass:[NSString class]]) continue;
            [alert addAction:[self createForTitle:eachObject style:UIAlertActionStyleDefault action:^(UIAlertAction *action) {
                block(i);
            }]];
        }
        va_end(argumentList);
    }
   
    
    [[UIApplication sharedApplication].delegate.window.rootViewController presentViewController:alert animated:YES completion:nil];
    
    return alert;
}
+(id)setMessageStyleForMsg:(NSString *)msg{

    NSMutableAttributedString *attAlert = [[NSMutableAttributedString alloc] initWithString:msg];
    [attAlert addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0, msg.length)];
    [attAlert addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:17] range:NSMakeRange(0, msg.length)];

    return attAlert;
}
+(id)createForTitle:(NSString *)title style:(UIAlertActionStyle)style action:(void (^ __nullable)(UIAlertAction *action))click{

    UIAlertAction *alertaAtion = [UIAlertAction actionWithTitle:title style:style handler:^(UIAlertAction * _Nonnull action) {
        click(action);
    }];
    
    return alertaAtion;
}
@end
