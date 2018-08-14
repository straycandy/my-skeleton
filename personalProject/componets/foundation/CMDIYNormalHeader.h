//
//  SNDIYNormalHeader.h
//
//  Created by xzoscar on 16/01/22.
//  Copyright © 2016年 suning. All rights reserved.
//

#import "MJRefresh.h"

@interface CMDIYNormalHeader : MJRefreshHeader

@property (strong, nonatomic,readonly) UILabel     *label;
@property (strong, nonatomic,readonly) UIImageView *logoView;
@property (strong, nonatomic,readonly) UIImageView *eyesImageV; // 2种图片切换

+ (instancetype)headerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock;

@end
