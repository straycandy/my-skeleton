//
//  WKWebViewController+URLPatterns.h
//  SuningEBuy
//
//  Created by wangbin on 2018/3/23.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import "WKWebViewController.h"

/*
 * WKWebViewController (URLPatterns)
 * webview和native交互，需要推入目标页面的 走页面路由，禁止如#import<XXXViewController>
 * ‘WKWebViewController (URLPatterns)’ 分类 用于匹配URL后,作出响应 常见案例如下
 * (1)web前端 登陆失效,截获passport 跳转到本地登录
 * (2)兼容旧的web前端和app的交互需求
 * @xzoscar
 */

@interface WKWebViewController (URLPatterns)

/*
 * 初始化 URL Patterns
 * @xzoscar
 */
- (NSArray *)loadURLPatterns;

/*
 * 检测URL,每个URL仅匹配一个selector函数，不会循环
 * @xzoscar
 */
- (BOOL)shouldValidateByURLPatternsWithURL:(NSURL *)URL;

@end
