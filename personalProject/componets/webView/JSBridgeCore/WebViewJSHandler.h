//
//  WKWebViewJSHandler.h
//  SuningEBuy
//
//  Created by SN_Christ on 2018/8/10.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WKWebViewJavascriptBridge.h"
@class WKWebViewController;

typedef NS_ENUM(NSUInteger,WKWebViewClass) {
    WKWebViewClassUI = 0,
    WKWebViewClassWK = 1
};

@interface WebViewJSHandler : NSObject

- (instancetype)initWithWebView:(id)webView jsBridge:(id<WKWebViewJSBridgeProtocol>)jsBridge mainVC:(WKWebViewController *)mainVC;

- (void)registerJavaScriptHandlers;

@end
