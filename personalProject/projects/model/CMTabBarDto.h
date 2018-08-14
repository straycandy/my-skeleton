//
//  CMTabBarDto.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMCommonHeader.h"

@interface CMTabBarDto : NSObject
/**
 本地高亮图片名字(如果没有网络图片，展示本地的)
 */
@property (nonatomic, copy) NSString                    *localHighLightImageName;
/**
 本地普通图片名字(如果没有网络图片，展示本地的)
 */
@property (nonatomic, copy) NSString                    *localNormalImageName;
/**
 本地tabBar名称
 */
@property (nonatomic, copy) NSString                    *localTabName;
/**
 tab高亮图片地址
 */
@property (nonatomic, copy) NSString                    *highLightImageURLStr;
/**
 tab普通图片地址
 */
@property (nonatomic, copy) NSString                    *normalImageURLStr;
/**
 tab名称
 */
@property (nonatomic, copy) NSString                    *tabName;


/**
 是哪个tab
 */
@property (nonatomic, assign) CMTabBarType              tabBarType;
@end
