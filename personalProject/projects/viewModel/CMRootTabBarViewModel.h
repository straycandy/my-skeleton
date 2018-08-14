//
//  CMRootTabBarViewModel.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CMRootTabBarViewModel : NSObject
/**
 获取没数据时的tabBar数据
 
 @return SNMKZSQTabBarModel组成的array
 */
+ (NSArray *)getInitialTabBarInfo;

/**
 请求tabBar数据（回调后存在本地）
 */
-(void)requestToGetZSQCommonInfo;
@end
