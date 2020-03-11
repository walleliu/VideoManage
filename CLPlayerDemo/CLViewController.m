//
//  CLViewController.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/2.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLViewController.h"
#import "UIView+CLSetRect.h"

#import "UpVideoViewController.h"



@interface CLViewController ()<MMPhotoPickerDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

/**tableView*/
@property (nonatomic,strong) UITableView *tableView;


/**数据源*/
@property (nonatomic, strong) NSMutableArray *dataArray;
//打开相册
@property (strong, nonatomic)UINavigationController *navigation;
@property (nonatomic, copy) NSString*fileName;//文件夹名称
@property(nonatomic,copy)NSString*videoName;//视频名称
@end

@implementation CLViewController
-(NSArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
//        NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        //获取Document文件的路径
//        NSString *collectPath = filePath.lastObject;
        NSMutableArray *fileArr = [self visitDirectoryList:self.currentPath Isascending:YES];
        [fileArr enumerateObjectsUsingBlock:^(secondCellModel * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self->_dataArray addObject:obj];
        }];
    }
    return _dataArray;
}
//获取沙盒文件 排序
- (NSMutableArray *)visitDirectoryList:(NSString *)path Isascending:(BOOL)isascending {
    NSArray *fileList  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];  // 取得目录下所有文件列表
    
    NSMutableArray  *listArray = [NSMutableArray new];//最终数组

    for (NSString *fileName in fileList) {
        NSString     *filePath = [path stringByAppendingPathComponent:fileName];
        NSArray *subfileList  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:filePath error:nil];
//        NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];  // 获取文件信息
        secondCellModel *model = [secondCellModel new];
        if ([self isDirectory:fileName]) {
            model.fileType = 1;//文件夹
            model.fileName = fileName;//文件名字
            model.fileSize = [NSString stringWithFormat:@"%.2f MB  %zd个文件",[self folderSizeAtPath:filePath],subfileList.count];//文件大小
            [listArray addObject:model];
        }else{
            NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];  // 获取文件信息
            model.fileType = 2;
            model.flieUrl = [NSString stringWithFormat:@"%@/%@",path,fileName];
            model.fileName = [NSString stringWithFormat:@"%@",fileName];
            model.fileSize = [NSString stringWithFormat:@"%.2f MB",[fileInfo[NSFileSize] floatValue]/1024.0/1024.0];

            [listArray addObject:model];
        }
        
    }

    
    NSLog(@"visitDirectoryList = %@", listArray);

    return listArray;
}
//计算文件夹大小
- (float ) folderSizeAtPath:(NSString*) folderPath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:folderPath]) return 0;
    NSEnumerator *childFilesEnumerator = [[manager subpathsAtPath:folderPath] objectEnumerator];
    NSString* fileName;
    long long folderSize = 0;
    while ((fileName = [childFilesEnumerator nextObject]) != nil){
        NSString* fileAbsolutePath = [folderPath stringByAppendingPathComponent:fileName];
        folderSize += [self fileSizeAtPath:fileAbsolutePath];
    }
    return folderSize/(1000.0*1000.0);
}
- (long long) fileSizeAtPath:(NSString*) filePath{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}
/**tableView*/
- (UITableView *) tableView{
    if (_tableView == nil){
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, CLscreenWidth, CLscreenHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionFooterHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
        [_tableView registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"ImageTableViewCell"];
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.translucent = NO;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"分类";
    self.edgesForExtendedLayout = UIRectEdgeNone;
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(@0);
    }];
//    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *editBtn = [[UIButton alloc] init];
    [editBtn setTitle:@"创建文件夹" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(postVideoClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    self.navigationItem.rightBarButtonItem = editItem;
    // Do any additional setup after loading the view from its nib.
}

-(void)postVideoClick{
    // 创建YCMenuAction
    YCMenuAction *action = [YCMenuAction actionWithTitle:@"创建文件夹" image:nil handler:^(YCMenuAction *action) {
        NSLog(@"点击了%@",action.title);
        [self crateDirectoryAlter];
    }];
    YCMenuAction *action1 = [YCMenuAction actionWithTitle:@"上传视频" image:nil handler:^(YCMenuAction *action) {
        NSLog(@"点击了%@",action.title);
        [self pickerClicked];
    }];
  

    // 创建YCMenuView(根据关联点或者关联视图)
    YCMenuView *view = [YCMenuView menuWithActions:@[action,action1] width:140 relyonView:self.navigationItem.rightBarButtonItem];
    
    // 自定义设置
    view.menuColor = [UIColor whiteColor];
    view.separatorColor = [UIColor whiteColor];
    view.maxDisplayCount = 5;  // 最大展示数量（其他的需要滚动才能看到）
    view.offset = 0; // 关联点和弹出视图的偏移距离
    view.textColor = [UIColor blackColor];
    view.textFont = [UIFont systemFontOfSize:16];
    view.menuCellHeight = 40;
    view.dismissOnselected = YES;
    view.dismissOnTouchOutside = YES;
    
    // 显示
    [view show];
    
}
//创建文件夹
-(void)crateDirectoryAlter{
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"填写名称" message:@"请输入文件夹名称" preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
        [self WriteToBoxwithName:self.fileName];
        self.dataArray = nil;
        [self.tableView reloadData];
    }];
    [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        self.fileName = textField.text;
        textField.delegate = self;
    }];
    
    [alertC addAction:actionCancel];
    [alertC addAction:actionOK];
    [self presentViewController:alertC animated:YES completion:nil];
}
//上传视频
#pragma mark - click
- (void)pickerClicked
{
    // 优先级 cropOption > singleOption > maxNumber
    // cropOption = YES 时，不显示视频
    MMPhotoPickerController * controller = [[MMPhotoPickerController alloc] init];
    controller.isOrigin = YES;
    controller.delegate = self;
    controller.showEmptyAlbum = NO;
    controller.showVideo = YES;
    controller.cropOption = NO;
    controller.singleOption = YES;
    controller.maxNumber = 1;
    
    _navigation = [[UINavigationController alloc] initWithRootViewController:controller];
    [_navigation.navigationBar setBackgroundImage:[UIImage imageNamed:@"default_bar"] forBarMetrics:UIBarMetricsDefault];
    _navigation.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: [UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:19.0]};
    _navigation.navigationBar.barStyle = UIBarStyleBlackOpaque;
    _navigation.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController presentViewController:_navigation animated:YES completion:nil];
}

#pragma mark - MMPhotoPickerDelegate
- (void)mmPhotoPickerController:(MMPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSArray *)info
{
    dispatch_async(dispatch_get_main_queue(), ^{
        //    [self.infoArray removeAllObjects];
        UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"填写名称" message:@"请输入视频名称" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
        UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"确定");
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                
                // 图片压缩一下，不然大图显示太慢
                for (int i = 0; i < [info count]; i ++)
                {
                    NSMutableDictionary * dict = [NSMutableDictionary dictionaryWithDictionary:[info objectAtIndex:i]];
                    
                    NSData*data = [NSData dataWithContentsOfFile:[dict objectForKey:MMPhotoVideoURL]];
                    [self WriteToBox:data withName:self.videoName];
                    UIImage * image = [dict objectForKey:MMPhotoOriginalImage];
                    
                    [dict setObject:image forKey:MMPhotoOriginalImage];
                    //                [self.infoArray addObject:dict];
                }
                
                GCD_MAIN(^{ // 主线程
                    //                [self.collectionView reloadData];
                    [picker dismissViewControllerAnimated:YES completion:nil];
                    [self.tableView reloadData];
                });
            });
        }];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            self.videoName = textField.text;
            textField.delegate = self;
        }];
        
        [alertC addAction:actionCancel];
        [alertC addAction:actionOK];
        
        [self->_navigation presentViewController:alertC animated:YES completion:nil];
    });
    
    
    
}

- (void)mmPhotoPickerControllerDidCancel:(MMPhotoPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark -------UItableviewDelegate------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    secondCellModel *model = self.dataArray[indexPath.row];
    if (model.fileType == 2) {
        static NSString *Identifier=@"ImageTableViewCell";
        ImageTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
        if(!cell){
            cell=[[ImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
            
        }
        return cell;
    }else {
        //复用Cell
        static NSString *Identifier=@"UITableViewCell";
        UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
        if(!cell){
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:Identifier];
        }
        
        return cell;
    }
    
    
}

-(void)tableView:(UITableView*)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath*)indexPath{
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        
        [self deleteSelectIndexPath: indexPath];
        
    }
    
}
- (void)deleteSelectIndexPath:(NSIndexPath  *)indexPath{
    
    UIAlertController *alertC = [UIAlertController alertControllerWithTitle:@"是否删除此数据" message:nil preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:nil];
    UIAlertAction *actionOK = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"确定");
        //获取Document文件的路径
//        NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//        NSString *collectPath = filePath.lastObject;
        secondCellModel *model = self.dataArray[indexPath.row];
        NSString * filePath = [self.currentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",model.fileName]];
        NSString *path = [NSString stringWithFormat:@"%@",filePath];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        self.dataArray = nil;
        [self.tableView reloadData];
    }];
    
    [alertC addAction:actionCancel];
    [alertC addAction:actionOK];
    [self presentViewController:alertC animated:YES completion:nil];
    
}

//在willDisplayCell里面处理数据能优化tableview的滑动流畅性
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    secondCellModel *model = self.dataArray[indexPath.row];
    if (model.fileType == 2) {
        ImageTableViewCell * myCell = (ImageTableViewCell *)cell;
        myCell.model = model;
    }else{
        cell.textLabel.text = model.fileName;
        cell.detailTextLabel.text = model.fileSize;
    }
    
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    secondCellModel *model = self.dataArray[indexPath.row];
    
    
    if ([self isDirectory:model.fileName]) {
        //文件夹
        CLViewController *tabVC = [CLViewController new];
        tabVC.currentPath = [NSString stringWithFormat:@"%@/%@",self.currentPath,model.fileName];
        [self.navigationController pushViewController:tabVC animated:YES];
    }else{
        //视频
        PlayVideoViewController *playVC = [PlayVideoViewController new];
        playVC.videoPath = [NSString stringWithFormat:@"%@/%@",self.currentPath,model.fileName];
        [self.navigationController pushViewController:playVC animated:YES];
    }
    

}


#pragma mark --<UITextFieldDelegate>
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"输出文件夹名称%@",textField.text);
    self.fileName = textField.text;
    self.videoName = textField.text;
}
#pragma mark --------存入沙盒 文件夹------------
- (void)WriteToBoxwithName:(NSString*)name{
    
    NSString * rarFilePath = [self.currentPath stringByAppendingPathComponent:name];//将需要创建的串拼接到后面
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    

}
#pragma mark --------存入沙盒  视频------------
- (void)WriteToBox:(NSData *)imageData withName:(NSString*)name{

    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:self.currentPath]) {
        
        [fileManager createDirectoryAtPath:self.currentPath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    //    //拼接新路径
    NSString *newPath = [self.currentPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",name]];
    NSLog(@"++%@",newPath);
    [imageData writeToFile:newPath atomically:YES];
}

#pragma mark --------辅助方法------------
- (BOOL)isDirectory:(NSString *)name
{
    NSString *filePath = [NSString stringWithFormat:@"%@/%@",self.currentPath,name];
  NSNumber *isDirectory;
  NSURL *fileUrl = [NSURL fileURLWithPath:filePath];
  [fileUrl getResourceValue:&isDirectory forKey:NSURLIsDirectoryKey error:nil];
  return isDirectory.boolValue;
}
@end
