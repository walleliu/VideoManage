//
//  RootViewController.m
//  CLPlayerDemo
//
//  Created by 刘永和 on 2019/7/16.
//  Copyright © 2019 JmoVxia. All rights reserved.
//

#import "RootViewController.h"
#import "CLViewController.h"
#import "CLPlayerDemo-Swift.h"
@interface RootViewController ()
@property (weak, nonatomic) IBOutlet UITextField *ipLabel;
@property (weak, nonatomic) IBOutlet UITextField *portLabel;

@end

@implementation RootViewController


- (IBAction)buttonAction:(UIButton *)sender {
    NSLog(@"按钮连接");
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"错误" message:@"无法连接此IP地址，请重新输入" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
        
    }];

    [alertC addAction:actionCancel];
    [alertC addAction:actionOK];
    [self presentViewController:alertC animated:YES completion:nil];
}
- (IBAction)gotoWeb:(UITapGestureRecognizer *)sender {
    NSLog(@"进入web");
    WebViewController *webVC = [WebViewController new];
    [self.navigationController pushViewController:webVC animated:YES];
    
}
- (IBAction)tap:(UITapGestureRecognizer *)sender {
    NSLog(@"tap点击");
    CLViewController *tabVC = [CLViewController new];
    [self.navigationController pushViewController:tabVC animated:YES];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"智能家居";
    [[UINavigationBar appearance] setTranslucent:NO];
    // Do any additional setup after loading the view from its nib.
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
