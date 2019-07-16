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



@interface CLViewController ()<UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

/**tableView*/
@property (nonatomic,strong) UITableView *tableView;


/**数据源*/
@property (nonatomic, strong) NSMutableArray *dataArray;

@property (nonatomic, copy) NSString*fileName;
@end

@implementation CLViewController
-(NSArray *)dataArray{
    if (_dataArray == nil) {
        _dataArray = [[NSMutableArray alloc] init];
        NSArray *filePath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //获取Document文件的路径
        NSString *collectPath = filePath.lastObject;
        NSMutableArray *fileArr = [self visitDirectoryList:collectPath Isascending:YES];
        [fileArr enumerateObjectsUsingBlock:^(NSDictionary * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [self->_dataArray addObject:obj];
        }];
    }
    return _dataArray;
}
//获取沙盒文件 排序
- (NSMutableArray *)visitDirectoryList:(NSString *)path Isascending:(BOOL)isascending {
    NSArray *fileList  = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];  // 取得目录下所有文件列表
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
/**tableView*/
- (UITableView *) tableView{
    if (_tableView == nil){
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 64, CLscreenWidth, CLscreenHeight - 64 - 49) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.sectionFooterHeight = 0;
        _tableView.showsVerticalScrollIndicator = NO;
    }
    return _tableView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.title = @"分类";
    
    [self.view addSubview:self.tableView];
    self.automaticallyAdjustsScrollViewInsets = NO;
    UIButton *editBtn = [[UIButton alloc] init];
    [editBtn setTitle:@"创建文件夹" forState:UIControlStateNormal];
    [editBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [editBtn addTarget:self action:@selector(postVideoClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *editItem = [[UIBarButtonItem alloc] initWithCustomView:editBtn];
    self.navigationItem.rightBarButtonItem = editItem;
    // Do any additional setup after loading the view from its nib.
}

-(void)postVideoClick{
    //上传视频
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataArray.count;
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
    cell.textLabel.text = self.dataArray[indexPath.row][@"Name"];
    
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 50;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UpVideoViewController *upVideoVC = [UpVideoViewController new];
    upVideoVC.leibieName = self.dataArray[indexPath.row][@"Name"];
    [self.navigationController pushViewController:upVideoVC animated:YES];

}
#pragma mark --<UITextFieldDelegate>
-(void)textFieldDidEndEditing:(UITextField *)textField{
    NSLog(@"输出视频名称%@",textField.text);
    self.fileName = textField.text;
}
#pragma mark --------存入沙盒------------
- (void)WriteToBoxwithName:(NSString*)name{
    
    NSString * docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString * rarFilePath = [docsdir stringByAppendingPathComponent:name];//将需要创建的串拼接到后面
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDir = NO;
    // fileExistsAtPath 判断一个文件或目录是否有效，isDirectory判断是否一个目录
    BOOL existed = [fileManager fileExistsAtPath:rarFilePath isDirectory:&isDir];
    if ( !(isDir == YES && existed == YES) ) {//如果文件夹不存在
        [fileManager createDirectoryAtPath:rarFilePath withIntermediateDirectories:YES attributes:nil error:nil];
    }
    

}

@end
