//
//  ViewController.m
//  exceptionDemo
//
//  Created by Mjwon on 2017/4/24.
//  Copyright © 2017年 Nemo. All rights reserved.
//

#import "ViewController.h"
#import "TestViewController.h"
#import "AlertView.h"


@interface ViewController ()
{
    BOOL b;
}
@property (nonatomic ,weak) UIButton *rightBtn;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    UIButton *rightBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    rightBtn.frame = CGRectMake(0, 0, 23, 23);
    [rightBtn setImage:[UIImage imageNamed:@"more_white"] forState:UIControlStateNormal];
    [rightBtn addTarget:self action:@selector(rightBtnAction) forControlEvents:UIControlEventTouchUpInside];
    _rightBtn = rightBtn;
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:_rightBtn];
    self.navigationItem.rightBarButtonItem = item;

   
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{

    [AlertView showAlertWithTitle:nil message:@"内容" completionBlock:^(NSUInteger buttonIndex) {
        
        NSLog(@"%ld",buttonIndex);
        
    } cancelButtonTitle:@"取消" otherButtonTitles:@"确定",nil];
    
//    UIAlertAction *a = [UIAlertAction actionWithTitle:@"hh" style:UIAlertActionStyleDestructive handler:nil];
//    [action addAction:a];

     /**
    b = !b;
    
    _rightBtn.hidden = b;
     TestViewController *t = [[TestViewController alloc] init];
     [self.navigationController pushViewController:t animated:YES];*/

}
-(void)rightBtnAction{

    TestViewController *t = [[TestViewController alloc] init];
    [self.navigationController pushViewController:t animated:YES];
    NSLog(@"%s",__func__);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
