//
//  SNDIYNormalFooter.m
//  Demo
//
//  Created by xzoscar on 16/1/22.
//  Copyright © 2016年 苏宁易购. All rights reserved.
//

#import "CMDIYNormalFooter.h"

@implementation CMDIYNormalFooter

+ (instancetype)footerWithRefreshingBlock:(MJRefreshComponentRefreshingBlock)refreshingBlock {
   CMDIYNormalFooter *footer = [super footerWithRefreshingBlock:refreshingBlock];
    footer.noDataTextString = @"没有更多数据";
    return footer;
}

- (void)setNoDataTextString:(NSString *)noDataTextString {
    _noDataTextString = noDataTextString;
    [self setTitle:noDataTextString forState:MJRefreshStateNoMoreData];
}

@end
