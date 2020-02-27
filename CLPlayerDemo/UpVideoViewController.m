//
//  UpVideoViewController.m
//  CLPlayerDemo
//
//  Created by 刘永和 on 2019/7/16.
//  Copyright © 2019 JmoVxia. All rights reserved.
//

#import "UpVideoViewController.h"
#import "MMPhotoPickerController.h"//上传视频
#import "CLTableViewViewController.h"//查看视频

#import "ImageTableViewCell.h"
#import "secondCellModel.h"

@interface UpVideoViewController ()<MMPhotoPickerDelegate,UITextFieldDelegate>
/**数据源*/
@property (nonatomic, strong) NSMutableArray *arrayDS;
//打开相册
@property (strong, nonatomic)UINavigationController * navigation;
@property(nonatomic,copy)NSString*videoName;


@property(nonatomic,assign)NSInteger sortType;//0 创建时间 1 名称
@end

@implementation UpVideoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.leibieName;
    self.sortType = 0;//默认 创建时间
    UIButton *editBtn = [[UIButton alloc] init];
    [editBtn setTitle:@"上传" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(postVideoClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    self.navigationItem.rightBarButtonItem = editItem;
    [self.tableview registerNib:[UINib nibWithNibName:@"ImageTableViewCell" bundle:nil] forCellReuseIdentifier:@"UITableViewCell"];
    // Do any additional setup after loading the view from its nib.
}

-(void)postVideoClick{
    //上传视频
    [self pickerClicked];
}
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
        [fileArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
     
            [self->_arrayDS addObject:obj];
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
//    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
//    //获取Document文件的路径
//    NSString *collectPath = filePath.lastObject;
    
    NSMutableArray  *listArray = [NSMutableArray new];//最终数组
    for (NSString *fileName in fileList) {
        NSString     *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];  // 获取文件信息
        
//        NSMutableDictionary *fileDic = [NSMutableDictionary new];
//        fileDic[@"Name"] = fileName;//文件名字
//        fileDic[NSFileSize] = fileInfo[NSFileSize];//文件大小
//        fileDic[NSFileCreationDate] = fileInfo[NSFileCreationDate];//时间
        secondCellModel *model = [secondCellModel new];
//        model.pictureUrl = [NSString stringWithFormat:@"%@/%@",path,fileName];
        model.videoUrl = [NSString stringWithFormat:@"%@/%@",path,fileName];
        model.videoName = [NSString stringWithFormat:@"%@",fileName];
        model.videoSize = [NSString stringWithFormat:@"%.2f MB",[fileInfo[NSFileSize] floatValue]/1024.0/1024.0];
//        model.videoTime = [NSString stringWithFormat:@"%@",fileInfo[NSFileCreationDate]];
        [listArray addObject:model];
    }
    
    NSLog(@"详细列表visitDirectoryList = %@", listArray);

    return listArray;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayDS.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //复用Cell
    static NSString *Identifier=@"UITableViewCell";
    ImageTableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    if(!cell){
        cell=[[ImageTableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
        
    }
    return cell;
}
//在willDisplayCell里面处理数据能优化tableview的滑动流畅性
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    ImageTableViewCell * myCell = (ImageTableViewCell *)cell;

    if ([self.arrayDS[indexPath.row] isKindOfClass:[secondCellModel class]]) {
        myCell.model = self.arrayDS[indexPath.row];

    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 80;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CLTableViewViewController *tabVC = [CLTableViewViewController new];
    tabVC.leibieName = self.leibieName;
    tabVC.index = indexPath;
    tabVC.sortType = _sortType;
    [self.navigationController pushViewController:tabVC animated:YES];
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
        secondCellModel *deleteModel = self.arrayDS[indexPath.row];
        NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *collectPath = filePath.lastObject;
        collectPath = [collectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",self.leibieName]];
        NSString *path = [NSString stringWithFormat:@"%@/%@",collectPath,deleteModel.videoName ];
        [[NSFileManager defaultManager] removeItemAtPath:path error:nil];
        self.arrayDS = nil;
        [self.tableview reloadData];
    }];
    
    [alertC addAction:actionCancel];
    [alertC addAction:actionOK];
    [self presentViewController:alertC animated:YES completion:nil];
    
}

#pragma mark 让tableView处于编辑状态（设置可以进行编辑）

- (void)setEditing:(BOOL)editing animated:(BOOL)animated

{
    
    [super setEditing:editing animated:animated];
    
    [self.tableview setEditing:!self.tableview.isEditing animated:YES];
    
}

#pragma mark 设置可以进行编辑

-(BOOL)tableView:(UITableView*)tableView canEditRowAtIndexPath:(NSIndexPath*)indexPath{
    
    return YES;
    
}

#pragma mark 设置编辑的样式

-(UITableViewCellEditingStyle)tableView:(UITableView*)tableView editingStyleForRowAtIndexPath:(NSIndexPath*)indexPath{
    
    return  UITableViewCellEditingStyleDelete;
    
}

#pragma mark  修改编辑按钮文字

-(NSString*)tableView:(UITableView*)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath*)indexPath{
    
    return @"Delete";
    
}
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
                    self.arrayDS = nil;
                    [self.tableview reloadData];
                });
            });
        }];
        [alertC addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            self.videoName = textField.text;
            textField.delegate = self;
        }];
        
        [alertC addAction:actionCancel];
        [alertC addAction:actionOK];
        
        [_navigation presentViewController:alertC animated:YES completion:nil];
    });
    
    
    
}

- (void)mmPhotoPickerControllerDidCancel:(MMPhotoPickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark --------存入沙盒------------
- (void)WriteToBox:(NSData *)imageData withName:(NSString*)name{
    
    NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    //获取Document文件的路径
    NSString *collectPath = filePath.lastObject;
    collectPath = [collectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_leibieName]];
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if (![fileManager fileExistsAtPath:collectPath]) {
        
        [fileManager createDirectoryAtPath:collectPath withIntermediateDirectories:YES attributes:nil error:nil];
        
    }
    
    //    //拼接新路径
    NSString *newPath = [collectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4",name]];
    NSLog(@"++%@",newPath);
    BOOL writeSuccess  = [imageData writeToFile:newPath atomically:YES];
}
#pragma mark --<UITextFieldDelegate>
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"输出视频名称%@",textField.text);
    self.videoName = textField.text;
}
#pragma mark -- buttonAction

- (IBAction)creatTimeButton:(UIButton *)sender {
    NSLog(@"按创建时间排序");
    self.sortType = 0;
    self.arrayDS = nil;
    [self.tableview reloadData];
}
- (IBAction)nameButton:(UIButton *)sender {
    NSLog(@"按名称排序");
    self.sortType = 1;
    self.arrayDS = nil;
    [self.tableview reloadData];
}


@end
