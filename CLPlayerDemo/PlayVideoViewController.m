//
//  PlayVideoViewController.m
//  CLPlayerDemo
//
//  Created by 刘永和 on 2020/3/11.
//  Copyright © 2020 JmoVxia. All rights reserved.
//

#import "PlayVideoViewController.h"

@interface PlayVideoViewController ()
/**CLplayer*/
@property (nonatomic, weak) CLPlayerView *playerView;
@end

@implementation PlayVideoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
    [self.view addSubview:playerView];
    _playerView = playerView;
    [playerView updateWithConfigure:^(CLPlayerViewConfigure *configure) {
        configure.topToolBarHiddenType = TopToolBarHiddenSmall;
        configure.fullStatusBarHiddenType = FullStatusBarHiddenAlways;
        configure.videoFillMode = VideoFillModeResizeAspect;
        configure.smallGestureControl = YES;
    }];
    //视频地址 本地
    playerView.url = [NSURL fileURLWithPath:self.videoPath];
    //网络
    //    [NSURL URLWithString:cell.model.videoUrl];
    
    //播放
    [playerView playVideo];
    //返回按钮点击事件回调
    [playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    //播放完成回调
    [playerView endPlay:^{
        //销毁播放器
        [self->_playerView destroyPlayer];
         self->_playerView = nil;
        NSLog(@"播放完成");
         [self.navigationController popViewControllerAnimated:YES];
    }];
    // Do any additional setup after loading the view.
}
-(void)viewWillDisappear:(BOOL)animated{
    [self->_playerView destroyPlayer];
    self->_playerView = nil;
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
