//
//  CMRoutesObject.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMRoutesProtocol.h"

@interface CMRoutesObject : NSObject
@property (nonatomic, strong) NSDictionary      *allParams;     //所有的参数的dic
@property (nonatomic, copy) NSString            *adTypeCode;    //活动类型, 普通URL: "UnknownUrl"; 未能识别: "Unrecognized";
@property (nonatomic, copy) NSString            *adId;          //活动ID
@property (nonatomic, copy) NSString            *originUrl;     //url
@property (nonatomic, assign) CMRouteSource     source;         //来源
@property (nonatomic, copy) void (^onCheckingBlock)(CMRoutesObject *obj);   //接口检查开始
@property (nonatomic, copy) BOOL (^shouldRouteBlock)(CMRoutesObject *obj);  //即将跳转页面前回调
@property (nonatomic, copy) void (^didRouteBlock)(CMRoutesObject *obj);     //跳转完成后的方法
@property (nonatomic, copy) void (^doRouteBlock)(CMRoutesObject *obj);      //跳转的方法，优先级最高
@property (nonatomic, strong) UIViewController *targetController; //解析出来的controller，为nil则跳转到nav的rootController
@property (nonatomic, strong) UINavigationController *navController; //进入目标controller的导航控制器,默认是nil,如果设置了，就用此nav进行跳转
@property (nonatomic, copy) NSString *errorMsg; //错误
@property (nonatomic, assign) BOOL isReady;     //是否准备完成，适用于需要提前接口检查的页面
//是否是present，默认是No
@property (nonatomic,assign) BOOL bPresentModel;
@property (nonatomic, assign) NSUInteger defaultTabIndex;         //默认跳转的页面Index,


/**
 *  　路由初始化
 *
 *  @param url    url
 *  @param source 来源
 *
 */
- (instancetype)initWithURLString:(NSString *)url
                           source:(CMRouteSource)source;
@end
