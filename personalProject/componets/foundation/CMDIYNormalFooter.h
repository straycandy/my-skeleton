//
//  SNDIYNormalFooter.h
//  Demo
//
//  Created by xzoscar on 16/1/22.
//  Copyright © 2016年 苏宁易购. All rights reserved.
//

#import "MJRefreshAutoNormalFooter.h"

@interface CMDIYNormalFooter : MJRefreshAutoNormalFooter

// 没有更多数据时候的状态问题 default: @"没有更多数据"
@property (nonatomic,strong) NSString *noDataTextString;

+ (instancetype)footerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock;

@end
