//
//  secondCellModel.h
//  CLPlayerDemo
//
//  Created by 刘永和 on 2020/2/26.
//  Copyright © 2020 JmoVxia. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface secondCellModel : NSObject
@property (nonatomic, assign) NSInteger fileType;//1 文件夹 2 视频 3 图片
/////**视频属性*/
//@property (nonatomic, copy) NSString *videoTime;
/**文件url*/
@property (nonatomic, copy) NSString *flieUrl;

/**文件名称*/
@property (nonatomic, copy) NSString *fileName;

/**文件大小*/
@property (nonatomic, copy) NSString *fileSize;

/**文件夹包含数量*/
@property (nonatomic, copy) NSString *fileNum;

@end

NS_ASSUME_NONNULL_END
