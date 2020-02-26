//
//  CLTableViewViewController.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLTableViewViewController.h"
#import "CLPlayerView.h"
#import "CLTableViewCell.h"
#import "CLModel.h"
#import "UIView+CLSetRect.h"
#import <SDWebImage/SDWebImage.h>

#import <Masonry/Masonry.h>

static NSString *CLTableViewCellIdentifier = @"CLTableViewCellIdentifier";

@interface CLTableViewViewController () <UITableViewDelegate, UITableViewDataSource, CLTableViewCellDelegate, UIScrollViewDelegate>

/**tableView*/
@property (nonatomic, strong) UITableView *tableView;
/**数据源*/
@property (nonatomic, strong) NSMutableArray *arrayDS;
/**CLplayer*/
@property (nonatomic, weak) CLPlayerView *playerView;
/**记录Cell*/
@property (nonatomic, assign) UITableViewCell *cell;
@property (nonatomic,assign)BOOL hasFinishLayouSubview;
@end

@implementation CLTableViewViewController
#pragma mark - 懒加载
/**数据源*/
- (NSMutableArray *) arrayDS{
    if (_arrayDS == nil){
        _arrayDS = [[NSMutableArray alloc] init];
        NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //获取Document文件的路径
        NSString *collectPath = filePath.lastObject;
        collectPath = [collectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_leibieName]];
        NSMutableArray *fileArr = [self visitDirectoryList:collectPath Isascending:YES];
        
//        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Date" ofType:@"json"]];
//        NSArray *array = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
        [fileArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CLModel *model = [CLModel new];
            model.pictureUrl = [NSString stringWithFormat:@"%@/%@",collectPath,[obj objectForKey:@"Name"]];
            model.videoUrl = [NSString stringWithFormat:@"%@/%@",collectPath,[obj objectForKey:@"Name"]];
            model.videoName = [NSString stringWithFormat:@"%@",[obj objectForKey:@"Name"]];
//            [model setValuesForKeysWithDictionary:obj];
            [self->_arrayDS addObject:model];
        }];
    }
    return _arrayDS;
}
//获取沙盒文件 排序
- (NSMutableArray *)visitDirectoryList:(NSString *)path Isascending:(BOOL)isascending {
    NSArray *fileList  = [[NSFileManager defaultManager] subpathsAtPath:path];  // 取得目录下所有文件列表
    fileList = [fileList sortedArrayUsingComparator:^(NSString *firFile, NSString *secFile) {  // 将文件列表排序
        if (self->_sortType == 0) {
            //时间排序
            NSString *firPath = [path stringByAppendingPathComponent:firFile];  // 获取前一个文件完整路径
            NSString *secPath = [path stringByAppendingPathComponent:secFile];  // 获取后一个文件完整路径
            NSDictionary *firFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:firPath error:nil];  // 获取前一个文件信息
            NSDictionary *secFileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:secPath error:nil];  // 获取后一个文件信息
            id firData = [firFileInfo objectForKey:NSFileCreationDate];  // 获取前一个文件创建时间
            id secData = [secFileInfo objectForKey:NSFileCreationDate];  // 获取后一个文件创建时间
            
            if (isascending) {
                return [firData compare:secData];  // 升序
            } else {
                return [secData compare:firData];  // 降序
            }
        }else if (self->_sortType == 1) {
            //名称排序
            if (isascending) {
                return [firFile compare:secFile];  // 升序
            } else {
                return [secFile compare:firFile];  // 降序
            }
        }else{
            //默认 名称排序
            if (isascending) {
                return [firFile compare:secFile];  // 升序
            } else {
                return [secFile compare:firFile];  // 降序
            }
        }
        
    }];
    
    //______________________________________________________________________________________________________
    // 将所有文件按照日期分成数组
    
    NSMutableArray  *listArray = [NSMutableArray new];//最终数组
   
    
    for (NSString *fileName in fileList) {
        NSString     *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];  // 获取文件信息
        
        NSMutableDictionary *fileDic = [NSMutableDictionary new];
        fileDic[@"Name"] = fileName;//文件名字
        fileDic[NSFileSize] = fileInfo[NSFileSize];//文件大小
        fileDic[NSFileCreationDate] = fileInfo[NSFileCreationDate];//时间
        
        [listArray addObject:fileDic];
    }
    
    NSLog(@"visitDirectoryList = %@", listArray);

    return listArray;
}
/**tableView*/
- (UITableView *) tableView{
    if (_tableView == nil){
        _tableView = [[UITableView alloc] init];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle=UITableViewCellSeparatorStyleNone;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerClass:[CLTableViewCell class] forCellReuseIdentifier:CLTableViewCellIdentifier];
    }
    return _tableView;
}
#pragma mark - 视图加载完毕
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initUI];
    
    
}
-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [_playerView destroyPlayer];
}
- (void)initUI{
    self.navigationItem.title = _leibieName;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.tableView];
    
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
}


#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.arrayDS.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    CLTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CLTableViewCellIdentifier forIndexPath:indexPath];
    cell.delegate = self;
    return cell;
}
#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 300;
}
//在willDisplayCell里面处理数据能优化tableview的滑动流畅性，cell将要出现的时候调用
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    CLTableViewCell * myCell = (CLTableViewCell *)cell;
    myCell.model = self.arrayDS[indexPath.row];
    //Cell开始出现的时候修正偏移量，让图片可以全部显示
    [myCell cellOffset];
    //第一次加载动画
    [[SDImageCache sharedImageCache] diskImageExistsWithKey:myCell.model.pictureUrl completion:^(BOOL isInCache) {
        if (!isInCache) {
            //主线程
            CATransform3D rotation;//3D旋转
            rotation = CATransform3DMakeTranslation(0 ,50 ,20);
            //逆时针旋转
            rotation = CATransform3DScale(rotation, 0.8, 0.9, 1);
            rotation.m34 = 1.0/ -600;
            myCell.layer.shadowColor = [[UIColor blackColor]CGColor];
            myCell.layer.shadowOffset = CGSizeMake(10, 10);
            myCell.alpha = 0;
            myCell.layer.transform = rotation;
            [UIView beginAnimations:@"rotation" context:NULL];
            //旋转时间
            [UIView setAnimationDuration:0.6];
            myCell.layer.transform = CATransform3DIdentity;
            myCell.alpha = 1;
            myCell.layer.shadowOffset = CGSizeMake(0, 0);
            [UIView commitAnimations];
        }
    }];
    
    if([indexPath row] == ((NSIndexPath*)[[tableView indexPathsForVisibleRows] lastObject]).row){
        dispatch_async(dispatch_get_main_queue(),^{
            if (!_hasFinishLayouSubview) {
                _hasFinishLayouSubview = YES;
                [self.tableView scrollToRowAtIndexPath:_index atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
            }
        });
    }
}
//cell离开tableView时调用
- (void)tableView:(UITableView *)tableView didEndDisplayingCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    //因为复用，同一个cell可能会走多次
    if ([_cell isEqual:cell]) {
        //区分是否是播放器所在cell,销毁时将指针置空
        [_playerView destroyPlayer];
        _cell = nil;
    }
}
#pragma mark - 点击播放代理
- (void)cl_tableViewCellPlayVideoWithCell:(CLTableViewCell *)cell{
    //记录被点击的Cell
    _cell = cell;
    //销毁播放器
    [_playerView destroyPlayer];
    CLPlayerView *playerView = [[CLPlayerView alloc] initWithFrame:CGRectMake(0, 0, cell.CLwidth, cell.CLheight)];
    _playerView = playerView;
    [cell.contentView addSubview:_playerView];

    [_playerView updateWithConfigure:^(CLPlayerViewConfigure *configure) {
        configure.topToolBarHiddenType = TopToolBarHiddenSmall;
        configure.fullStatusBarHiddenType = FullStatusBarHiddenFollowToolBar;
        configure.videoFillMode = VideoFillModeResizeAspect;
        configure.smallGestureControl = YES;
    }];
    //视频地址 本地
    _playerView.url = [NSURL fileURLWithPath:cell.model.videoUrl];
    //网络
//    [NSURL URLWithString:cell.model.videoUrl];
    
    //播放
    [_playerView playVideo];
    //返回按钮点击事件回调
    [_playerView backButton:^(UIButton *button) {
        NSLog(@"返回按钮被点击");
    }];
    //播放完成回调
    [_playerView endPlay:^{
        //销毁播放器
        [self->_playerView destroyPlayer];
        self->_playerView = nil;
        self->_cell = nil;
        NSLog(@"播放完成");
    }];
}
#pragma mark - 滑动代理
- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    // visibleCells 获取界面上能显示出来了cell
    NSArray<CLTableViewCell *> *array = [self.tableView visibleCells];
    //enumerateObjectsUsingBlock 类似于for，但是比for更快
    [array enumerateObjectsUsingBlock:^(CLTableViewCell * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj cellOffset];
    }];
}
#pragma mark - 布局
-(void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    self.tableView.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    
    
}

@end
