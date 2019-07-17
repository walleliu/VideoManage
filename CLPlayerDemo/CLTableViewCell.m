//
//  CLTableViewCell.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2017/8/4.
//  Copyright © 2017年 JmoVxia. All rights reserved.
//

#import "CLTableViewCell.h"
#import "UIView+CLSetRect.h"
#import <SDWebImage/SDWebImage.h>
#import <AVFoundation/AVFoundation.h>
#define CellHeight   300
#define ImageViewHeight 600

@interface CLTableViewCell ()

/**button*/
@property (nonatomic,strong) UIButton *button;
/**picture*/
@property (nonatomic,strong) UIImageView *pictureView;
//视频名称
@property (nonatomic,strong)UILabel *videoName;
//视频时长
@property (nonatomic,strong)UILabel *videoLength;
@end

@implementation CLTableViewCell
#pragma mark - 懒加载
/**button*/
- (UIButton *) button{
    if (_button == nil){
        _button = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 60, 60)];
        [_button setBackgroundImage:[self getPictureWithName:@"CLPlayBtn"] forState:UIControlStateNormal];
        [_button addTarget:self action:@selector(playAction:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}
-(UILabel *)videoName{
    if (_videoName == nil){
        _videoName = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CLscreenWidth, 30)];
        _videoName.textColor = [UIColor whiteColor];
        _videoName.font = [UIFont systemFontOfSize:20 weight:UIFontWeightBold];
        _videoName.textAlignment = NSTextAlignmentCenter;
    }
    return _videoName;
}
-(UILabel *)videoLength{
    if (_videoLength == nil){
        _videoLength = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CLscreenWidth-20, 30)];
        _videoLength.textColor = [UIColor whiteColor];
        _videoLength.font = [UIFont systemFontOfSize:17 weight:UIFontWeightBold];
        _videoLength.textAlignment = NSTextAlignmentRight;
    }
    return _videoLength;
}
/**pictureView*/
- (UIImageView *) pictureView{
    if (_pictureView == nil){
        _pictureView = [[UIImageView alloc] initWithFrame:CGRectMake(0, - (ImageViewHeight - CellHeight) * 0.5, CLscreenWidth, ImageViewHeight)];    }
    return _pictureView;
}
#pragma mark - 入口
-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        [self initUI];
    }
    return self;
}
- (void)initUI{
    //剪裁看不到的
    self.clipsToBounds       = YES;
    self.selectionStyle      = UITableViewCellSelectionStyleNone;
    [self.contentView addSubview:self.pictureView];
    [self.contentView addSubview:self.button];
    [self.contentView addSubview:self.videoName];
    [self.contentView addSubview:self.videoLength];
}
-(void)setModel:(CLModel *)model{
    _model = model;
//    __block UIImage *placeholderImage = [UIImage imageNamed:@"placeholder"];
//    __weak __typeof(self) weakSelf = self;
//    [[SDImageCache sharedImageCache] diskImageExistsWithKey:_model.pictureUrl completion:^(BOOL isInCache) {
//        __typeof(&*weakSelf) strongSelf = weakSelf;
//        if (isInCache) {
//            //本地存在图片,替换占位图片
//            placeholderImage = [[SDImageCache sharedImageCache] imageFromDiskCacheForKey:model.pictureUrl];
//        }
//        [strongSelf.pictureView sd_setImageWithURL:[NSURL URLWithString:model.pictureUrl] placeholderImage:placeholderImage];
//    }];
    self.pictureView.image = [self getScreenShotImageFromVideoPath:model.videoUrl];
    self.videoName.text = model.videoName;
    self.videoLength.text = [self getMMSSFromSS:[self getVideoTimeByUrlString:model.videoUrl]];

}
- (void)playAction:(UIButton *)button{
    if (_delegate && [_delegate respondsToSelector:@selector(cl_tableViewCellPlayVideoWithCell:)]){
        [_delegate cl_tableViewCellPlayVideoWithCell:self];
    }
}
- (UIImage *)getPictureWithName:(NSString *)name{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}
- (CGFloat)cellOffset{
    /*
     - (CGRect)convertRect:(CGRect)rect toView:(nullable UIView *)view;
     将rect由rect所在视图转换到目标视图view中，返回在目标视图view中的rect
     这里用来获取self在window上的位置
     */
    CGRect toWindow      = [self convertRect:self.bounds toView:self.window];
    //获取父视图的中心
    CGPoint windowCenter = self.superview.center;
    //cell在y轴上的位移
    CGFloat cellOffsetY  = CGRectGetMidY(toWindow) - windowCenter.y;
    //位移比例
    CGFloat offsetDig    = 2 * cellOffsetY / self.superview.frame.size.height ;
    //要补偿的位移,self.superview.frame.origin.y是tableView的Y值，这里加上是为了让图片从最上面开始显示
    CGFloat offset       = - offsetDig * (ImageViewHeight - CellHeight) / 2;
    //让pictureViewY轴方向位移offset
    CGAffineTransform transY = CGAffineTransformMakeTranslation(0,offset);
    _pictureView.transform   = transY;
    return offset;
}
-(void)layoutSubviews{
    [super layoutSubviews];
    _button.CLcenterX     = self.CLwidth/2.0;
    _button.CLcenterY     = self.CLheight/2.0;
    _pictureView.CLwidth  = self.CLwidth;
    _videoName.CLcenterY     = self.CLheight/2.0 + 50;
    _videoLength.CLcenterY     = self.CLheight-20;
}
//获取视频缩略图
- (UIImage *)getScreenShotImageFromVideoPath:(NSString *)filePath{
    
    UIImage *shotImage;
    //视频路径URL
    NSURL *fileURL = [NSURL fileURLWithPath:filePath];
    
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:fileURL options:nil];
    
    AVAssetImageGenerator *gen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    gen.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    
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
    NSString *format_time = [NSString stringWithFormat:@"%@:%@:%@",str_hour,str_minute,str_second];
    
    return format_time;
    
}


@end
