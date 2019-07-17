//
//  CLTableViewViewController.h
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CLTableViewViewController : UIViewController
@property (copy, nonatomic)  NSString *leibieName;
@property (strong,nonatomic) NSIndexPath *index;

@property(nonatomic,assign)NSInteger sortType;//0 创建时间 1 名称
@end
