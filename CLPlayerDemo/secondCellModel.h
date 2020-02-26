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
/////**图片url*/
//@property (nonatomic, copy) NSString *videoTime;
/**视频url*/
@property (nonatomic, copy) NSString *videoUrl;

/**视频名称*/
@property (nonatomic, copy) NSString *videoName;

/**视频大小*/
@property (nonatomic, copy) NSString *videoSize;

@end

NS_ASSUME_NONNULL_END
