//
//  WKWebViewController.h
//  personalProject
//
//  Created by mengran on 2018/8/20.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>
#import "WKWebViewJavascriptBridge.h"
#import "WebViewJSHandler.h"
#import "WebHeaderView.h"

@interface WKWebViewController : UIViewController
@property(nonatomic, strong) WKWebViewJavascriptBridge *jsBridge;
@property (nonatomic, strong) WKWebView     *webView;
@property (nonatomic,strong) NSString *defaultColorStr;
@property(nonatomic, strong) WebViewJSHandler *jsHandler;
// 自定义导航栏
@property(nonatomic, strong) WebHeaderView *mNavHeaderView;


-(void)popToParentWithChcek;
- (id)initWithURLString:(NSString *)URLString paras:(NSDictionary *)paras;
- (void)setCustomNavStyleWithDictionary:(NSDictionary *)styleInfo;
//隐藏导航栏
- (void)setCustomNavHeaderBarHidden:(BOOL)bHidden;
/**
 开放iPhone X全屏
 */
- (void)callOpenWebViewFullScreen:(BOOL)open;
/**
 下拉刷新
 */
- (void)onRefreshHeaderViewAction;
@end
