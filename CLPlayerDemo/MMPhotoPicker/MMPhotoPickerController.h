//
//  MMPhotoPickerController.h
//  MMPhotoPicker
//
//  Created by LEA on 2017/11/10.
//  Copyright © 2017年 LEA. All rights reserved.
//
//  图库列表
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "MMPhotoPickerMacros.h"

#pragma mark - ################## MMPhotoPickerController

@protocol MMPhotoPickerDelegate;
@interface MMPhotoPickerController : UIViewController

// 说明：NOTE!!!
// 优先级 cropOption > singleOption > maxNumber
// cropOption = YES 时，不显示视频

// 是否回传原图 [可用于控制图片压系数]
@property (nonatomic, assign) BOOL isOrigin;
// 是否显示空相册 [默认NO]
@property (nonatomic, assign) BOOL showEmptyAlbum;
// 是否显示视频 [默认NO]
@property (nonatomic, assign) BOOL showVideo;
// 是否显示原图选项 [默认NO]
@property (nonatomic, assign) BOOL showOriginOption;
// 是否只选取一张 [默认NO]
@property (nonatomic, assign) BOOL singleOption;
// 是否选取一张且需要裁剪 [默认NO]
@property (nonatomic, assign) BOOL cropOption;
// 裁剪的大小[默认方形、屏幕宽度]
@property (nonatomic, assign) CGSize cropSize;
// 最大选择数目[默认9张、如果显示视频，也包括视频数量]
@property (nonatomic, assign) NSInteger maxNumber;

// 主色调[默认红色]
@property (nonatomic, strong) UIColor * mainColor;
// 选中的遮罩图片名称[默认为本控件内图片]
@property (nonatomic, copy) NSString * maskImgName;
// 原图选项选中图片名称[默认为本控件内图片]
@property (nonatomic, copy) NSString * markedImgName;

// 代理
@property (nonatomic, assign) id<MMPhotoPickerDelegate> delegate;

@end

@protocol MMPhotoPickerDelegate <NSObject>

@optional

/**
 info释义:
 返回的媒体数据是数组，数组单元为字典，字典中包含以下数据：

 资源类型 MMPhotoMediaType
 位置方向 MMPhotoLocation
 原始图片 MMPhotoOriginalImage
 视频路径 MMPhotoVideoURL

 */
- (void)mmPhotoPickerController:(MMPhotoPickerController *)picker didFinishPickingMediaWithInfo:(NSArray<NSDictionary *> *)info;
- (void)mmPhotoPickerControllerDidCancel:(MMPhotoPickerController *)picker;

@end

#pragma mark - ################## MMPhotoAlbum
@interface MMPhotoAlbum : NSObject

// 相册名称
@property (nonatomic, copy) NSString * name;
// 内含图片数量
@property (nonatomic, assign) NSInteger assetCount;
// 封面
@property (nonatomic, strong) PHAsset * coverAsset;
// 相册
@property (nonatomic, strong) PHAssetCollection * collection;

@end

#pragma mark - ################## MMPhotoAlbumCell
@interface MMPhotoAlbumCell : UITableViewCell

@end
