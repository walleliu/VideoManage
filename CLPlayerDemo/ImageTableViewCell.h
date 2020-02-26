//
//  ImageTableViewCell.h
//  CLPlayerDemo
//
//  Created by 刘永和 on 2020/2/26.
//  Copyright © 2020 JmoVxia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "secondCellModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface ImageTableViewCell : UITableViewCell
/**model*/
@property (nonatomic, copy) secondCellModel *model;
@end

NS_ASSUME_NONNULL_END
