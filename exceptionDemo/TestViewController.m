//
//  TestViewController.m
//  exceptionDemo
//
//  Created by Mjwon on 2017/4/24.
//  Copyright © 2017年 Nemo. All rights reserved.
//

#import "TestViewController.h"

typedef struct Test
{
    int a;
    int b;
}Test;

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor redColor];
    
    float f = 300.0;
    
    NSString *fs = [NSString stringWithFormat:@"%f.f",f];
    
    
    
    
    
//    Test *pTest = {(Test*)1};
//    free(pTest);
//    pTest->a = 5;
    
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSArray *arr = [NSArray array];
    [arr objectAtIndex:2];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
