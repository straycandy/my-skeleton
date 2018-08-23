//
//  WKWebViewJSHandler.m
//  SuningEBuy
//
//  Created by SN_Christ on 2018/8/10.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import "WebViewJSHandler.h"
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "CMCommonHeader.h"
#import "WKWebViewController.h"

@interface WebViewJSHandler ()

//SNWKWebViewController或者WKWebViewController,在需要传参ViewController的时候会用到的
@property (weak, nonatomic) WKWebViewController *mainVC;

@property (weak, nonatomic) id<WKWebViewJSBridgeProtocol> jsBridge;

//webView的类型，可能是UIWebView或者WKWebView
@property (assign, nonatomic) WKWebViewClass webViewClass;

@property (weak, nonatomic) UIWebView *uiWebView;

@property (weak, nonatomic) WKWebView *wkWebView;

@end

@implementation WebViewJSHandler

- (instancetype)initWithWebView:(id)webView jsBridge:(id<WKWebViewJSBridgeProtocol>)jsBridge mainVC:(WKWebViewController *)mainVC {
    self = [super init];
    if (self) {
        if ([webView isKindOfClass:[UIWebView class]]) {
            self.webViewClass = WKWebViewClassUI;
            self.uiWebView = (UIWebView *)webView;
        } else if ([webView isKindOfClass:[WKWebView class]]) {
            self.webViewClass = WKWebViewClassWK;
            self.wkWebView = (WKWebView *)webView;
        }
        
        self.jsBridge = jsBridge;
        self.mainVC = mainVC;
    }
    return self;
}

- (void)registerJavaScriptHandlers {
    //开启文字转语音操作 6.4.0
//    [self.jsBridge registerHandler:@"startSpeakText"
//                           handler:[self startSpeakTextHandle]];

}

#pragma mark - 公共方法

- (void)evaluateJavaScript:(NSString *)javaScriptString completionHandler:(void (^ _Nullable)(_Nullable id, NSError * _Nullable error))completionHandler {
    if (self.webViewClass == WKWebViewClassWK) {
        [self.wkWebView evaluateJavaScript:javaScriptString completionHandler:completionHandler];
    } else if (self.webViewClass == WKWebViewClassUI) {
        [self.uiWebView stringByEvaluatingJavaScriptFromString:javaScriptString];
    }
}

#pragma mark - 语音文字互转相关

/**
 使用Siri文字转语音handler 6.4.0
 */
- (WVJBHandler)startSpeakTextHandle
{
//    __weak typeof(self) weakSelf = self;
//    return (^(id data, WVJBResponseCallback responseCallback) {
//        NSDictionary *dict = (NSDictionary *)data;
//        NSString *text = EncodeStringFromDic(dict, @"text");
//        SNIFlySpeechManager *speechMgr = [SNIFlySpeechManager sharedManager];
//        [speechMgr startSpeaking:text with:^(id result, BOOL keepAlive) {
//            NSDictionary *dict = (NSDictionary *)result;
//            NSString *callbackType = EncodeStringFromDic(dict, @"callbackType");
//            NSString *evalJS = [NSString stringWithFormat:@"speechSynthesizeResult(%@)",callbackType];
//            dispatch_async(dispatch_get_main_queue(), ^{
//                [weakSelf evaluateJavaScript:evalJS completionHandler:^(id result, NSError * error) {
//
//                }];
//            });
//        }];
//    });
    return nil;
}

@end
