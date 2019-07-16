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
@interface UpVideoViewController ()<MMPhotoPickerDelegate,UITextFieldDelegate>
/**数据源*/
@property (nonatomic, strong) NSMutableArray *arrayDS;
//打开相册
@property (strong, nonatomic)UINavigationController * navigation;
@property(nonatomic,copy)NSString*videoName;

@end

@implementation UpVideoViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = self.leibieName;
    UIButton *editBtn = [[UIButton alloc] init];
    [editBtn setTitle:@"上传" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(postVideoClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    self.navigationItem.rightBarButtonItem = editItem;
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
        
        //        NSData *JSONData = [NSData dataWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Date" ofType:@"json"]];
        //        NSArray *array = [NSJSONSerialization JSONObjectWithData:JSONData options:NSJSONReadingAllowFragments error:nil];
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
        
    }];
    
    //______________________________________________________________________________________________________
    // 将所有文件按照日期分成数组
    
    NSMutableArray  *listArray = [NSMutableArray new];//最终数组
    NSMutableArray  *tempArray = [NSMutableArray new];//每天文件数组
    NSDateFormatter *format    = [[NSDateFormatter alloc] init];
    format.dateFormat = @"yyyy-MM-dd";
    
    for (NSString *fileName in fileList) {
        NSString     *filePath = [path stringByAppendingPathComponent:fileName];
        NSDictionary *fileInfo = [[NSFileManager defaultManager] attributesOfItemAtPath:filePath error:nil];  // 获取文件信息
        
        NSMutableDictionary *fileDic = [NSMutableDictionary new];
        fileDic[@"Name"] = fileName;//文件名字
        fileDic[NSFileSize] = fileInfo[NSFileSize];//文件大小
        fileDic[NSFileCreationDate] = fileInfo[NSFileCreationDate];//时间
        
        if (tempArray.count > 0) {  // 获取日期进行比较, 按照 XXXX 年 XX 月 XX 日来装数组
            NSString *currDate = [format stringFromDate:fileInfo[NSFileCreationDate]];
            NSString *lastDate = [format stringFromDate:tempArray.lastObject[NSFileCreationDate]];
            
            if (![currDate isEqualToString:lastDate]) {
                [listArray addObject:tempArray];
                tempArray = [NSMutableArray new];
            }
        }
        [tempArray addObject:fileDic];
    }
    
    if (tempArray.count > 0) {  // 装载最后一个 array 数组
        [listArray addObject:tempArray];
    }
    
    NSLog(@"visitDirectoryList = %@", listArray);
    NSMutableArray*array = [NSMutableArray array];
    for (NSMutableArray*arr in listArray) {
        for (NSMutableDictionary *dic in arr) {
            [array addObject:dic];
        }
    }
    return array;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.arrayDS.count;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    //复用Cell
    static NSString *Identifier=@"UITableViewCell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:Identifier];
    if(!cell){
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:Identifier];
    }
    return cell;
}
//在willDisplayCell里面处理数据能优化tableview的滑动流畅性
- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([self.arrayDS[indexPath.row] isKindOfClass:[NSDictionary class]]) {
        cell.textLabel.text = [self.arrayDS[indexPath.row] objectForKey:@"Name"];
    }else{
        cell.textLabel.text = self.arrayDS[indexPath.row];
    }

}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CLTableViewViewController *tabVC = [CLTableViewViewController new];
    tabVC.leibieName = self.leibieName;
    tabVC.index = indexPath;
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
        NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *collectPath = filePath.lastObject;
        collectPath = [collectPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@",_leibieName]];
        NSString *path = [NSString stringWithFormat:@"%@/%@",collectPath,[self.arrayDS[indexPath.row] objectForKey:@"Name"]];
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
    controller.delegate = self;
    controller.showEmptyAlbum = YES;
    controller.showVideo = YES;
    controller.cropOption = NO;
    controller.singleOption = YES;
    controller.maxNumber = 6;
    
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
                NSData*data = [NSData dataWithContentsOfURL:[dict objectForKey:MMPhotoVideoURL]];
                [self WriteToBox:data withName:self.videoName];
                UIImage * image = [dict objectForKey:MMPhotoOriginalImage];
                if (!picker.isOrigin) { // 原图
                    NSData * imageData = UIImageJPEGRepresentation(image,1.0);
                    int size = (int)[imageData length]/1024;
                    if (size < 100) {
                        imageData = UIImageJPEGRepresentation(image, 0.5);
                    } else {
                        imageData = UIImageJPEGRepresentation(image, 0.1);
                    }
                    image = [UIImage imageWithData:imageData];
                }
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
    [imageData writeToFile:newPath atomically:YES];
    
}
#pragma mark --<UITextFieldDelegate>
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"输出视频名称%@",textField.text);
    self.videoName = textField.text;
}

@end
