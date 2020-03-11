//
//  ImageTableViewCell.m
//  CLPlayerDemo
//
//  Created by 刘永和 on 2020/2/26.
//  Copyright © 2020 JmoVxia. All rights reserved.
//

#import "ImageTableViewCell.h"
#import <AVFoundation/AVFoundation.h>
@interface ImageTableViewCell()
@property (weak, nonatomic) IBOutlet UIImageView *videoImageView;
@property (weak, nonatomic) IBOutlet UILabel *videoNameL;
@property (weak, nonatomic) IBOutlet UILabel *videoTimeL;
@property (weak, nonatomic) IBOutlet UILabel *videoSizeL;


@end


@implementation ImageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    
    // Configure the view for the selected state
}
-(void)setModel:(secondCellModel *)model{
    _model = model;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage * iii = [self getScreenShotImageFromVideoPath:model.flieUrl];
        if (iii) {
            dispatch_async(dispatch_get_main_queue(), ^{
                self.videoImageView.image = iii;
            });
        }
    });
    self.videoNameL.text = model.fileName;
    self.videoSizeL.text = model.fileSize;
    self.videoTimeL.text = [self getMMSSFromSS:[self getVideoTimeByUrlString:model.flieUrl]];
    //    self.videoLength.text = [self getMMSSFromSS:[self getVideoTimeByUrlString:model.videoUrl]];
}

//获取视频时长
- (NSInteger)getVideoTimeByUrlString:(NSString*)urlString {
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:urlString];
    AVURLAsset *avUrl = [AVURLAsset assetWithURL:fileURL];
    CMTime time = [avUrl duration];
    int seconds = ceil(time.value/time.timescale);
    return seconds;
}
//秒数转时间格式
-(NSString *)getMMSSFromSS:(NSInteger )seconds{
    
    //    NSInteger seconds = [totalTime integerValue];
    
    //format of hour
    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time;
    if ([str_hour isEqualToString:@"00"]) {
        format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    }else{
        format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    }

    
    return format_time;
    
}
//获取视频缩略图
- (UIImage *)getScreenShotImageFromVideoPath:(NSString *)filePath{
    
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(10.0, 600);
    
    NSError *error = nil;
    
    CMTime actualTime;
    
    CGImageRef image = [gen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    
    shotImage = [[UIImage alloc] initWithCGImage:image];
    
    CGImageRelease(image);
    UIImage*smailImage = [UIImage imageWithData:[self compressWithMaxLength:200 andImage:shotImage]];
    
    return smailImage;
    
}
/*
 *maxLengthKB 压缩到的大小
 *image 准备压缩的图片
 */
-(NSData *)compressWithMaxLength:(NSUInteger)maxLength andImage:(UIImage*)image{
    CGFloat compression = 1;
    NSData *data = UIImageJPEGRepresentation(image, compression);
    if (data.length < maxLength) return data;
    CGFloat max = 1;
    CGFloat min = 0;
    for (int i = 0; i < 6; ++i) {
        compression = (max + min) / 2;
        data = UIImageJPEGRepresentation(image, compression);
        if (data.length < maxLength * 0.9) {
            min = compression;
        } else if (data.length > maxLength) {
            max = compression;
        } else {
            break;
        }
    }
    return data;
}
@end
