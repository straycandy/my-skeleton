//
//  WKWebViewController+JSBridge.h
//  SuningEBuy
//
//  Created by wangbin on 2018/3/23.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import "WKWebViewController.h"

/*
 * WKWebViewController
 * webview和native交互，需要推入目标页面的 走页面路由，禁止如#import<XXXViewController>
 * ‘WKWebViewController (JSBridge)’ 分类 用于提供js和前端交互
 * @xzoscar
 */

@interface WKWebViewController (JSBridge)

/*
 * 注册所有js函数
 * @xzoscar
 */
- (void)registerJavaScriptHandlers;

/**
 *  去订单中心
 */
- (void)jumpToOrderCenterBoard;

/**
 *  支付成功回调
 *
 *  @param orderPrice   订单价格
 *  @param productCode  商品编码
 *  @param orderId      订单编码
 *  @param isEnergySave 是否节能
 */
- (void)paySuccessedWithOrderPrice:(NSString *)orderPrice productCode:(NSString *)productCode orderId:(NSString *)orderId isEnergySave:(NSString *)isEnergySave;

@end
