//
//  WKWebViewController.m
//  personalProject
//
//  Created by mengran on 2018/8/20.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "WKWebViewController.h"
#import <WebKit/WebKit.h>
#import "CMCommonHeader.h"
#import "Masonry.h"
#import "CMToast.h"
#import "JLRoutes.h"
#import "NJKWebViewProgressView.h"
#import "WKWebViewController+JSBridge.h"

@interface WKWebViewController ()<WKNavigationDelegate,WKUIDelegate>
@property (nonatomic, copy) NSString        *URLStr;


// 加载进度条
@property (nonatomic,strong) NJKWebViewProgressView  *mProgressView;
@end

@implementation WKWebViewController
+(void)load{
    [JLRoutes addRoute:kWKWebViewVC handler:^id(NSDictionary *parameters) {
        NSString *urlStr = EncodeStringFromDic(parameters, kWKWebViewVC_URLStr);
        WKWebViewController *vc = [[WKWebViewController alloc] initWithURLString:urlStr paras:nil];
        
        return vc;
    }];
}


- (id)initWithURLString:(NSString *)URLString paras:(NSDictionary *)paras {
    if (self = [self init]) {
        if (!IsStrEmpty(URLString) && [URLString hasPrefix:@"//"]) {
            URLString = [NSString stringWithFormat:@"http:%@", URLString];
        }
        self.URLStr = URLString;
        
        [self.view addSubview:self.mNavHeaderView];
        [self.view addSubview:self.webView];
        [self.view addSubview:self.mProgressView];
        
#ifdef __IPHONE_11_0
        if (@available(iOS 11.0, *)) {
            if ([self.webView.scrollView respondsToSelector:@selector(setContentInsetAdjustmentBehavior:)]) {
                self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
            }
        }
#endif
        
        [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.mNavHeaderView.mas_bottom);
            make.left.right.bottom.equalTo(self.view);
        }];
        [self customLoadHtmlStr:self.URLStr];
        // !!!!    启动jsbridge引擎；注册js函数      !!!!
        [self registerJavaScriptHandlers];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)customLoadHtmlStr:(NSString *)str{
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:str]]];
}

/*
 * 重写基类的onBack函数
 */
- (void)onBack:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)popToParentWithChcek{
    //可以加上check判断
    
    [self onBack:nil];
}

- (void)setCustomNavHeaderBarHidden:(BOOL)bHidden{
    self.mNavHeaderView.hidden = bHidden;
}

/*
 * 配置自定义导航栏
 * 目前该接口仅在jsbridge - documentNavigationStyle()函数回调中调用
 * @para styleInfo:约定key如下 \
 *                dTitle,eTitle,eImage,eFontSize,\
 eFontColor,eBakground,eBakgIos6,eBakImage
 * @xzoscar
 */
- (void)setCustomNavStyleWithDictionary:(NSDictionary *)styleInfo {
    if (nil != styleInfo
        && [styleInfo isKindOfClass:[NSDictionary class]]) {
        {
            
            NSString *dTitle        = EncodeStringFromDic(styleInfo,@"dTitle");
            NSString *eTitle        = EncodeStringFromDic(styleInfo,@"eTitle");
            NSString *eImage        = EncodeStringFromDic(styleInfo,@"eImage");
            NSString *eFontSize     = EncodeStringFromDic(styleInfo,@"eFontSize");
            NSString *eFontColor    = EncodeStringFromDic(styleInfo,@"eFontColor");
            NSString *eBakground    = EncodeStringFromDic(styleInfo,@"eBakground");
            NSString *eBakImage     = EncodeStringFromDic(styleInfo,@"eBakImage");
            NSString *eIconStyle   = EncodeStringFromDic(styleInfo,@"eIconStyle");
            
            CGFloat font = IsStrEmpty(eFontSize)?16:[eFontSize floatValue]/2;
            font = (font == .0f) ? 16.0f : font;
            UIFont *fontObj = [UIFont systemFontOfSize:font];
            
            NSString *colorStr =  IsStrEmpty(_defaultColorStr)?(IsStrEmpty(eFontColor)?@"0xffffff":eFontColor):(_defaultColorStr);
            UIColor *titleColor =[UIColor colorWithHexString:colorStr];
            
            [self.mNavHeaderView reset]; // reset
            
            if (!IsStrEmpty(dTitle)) {
                [self.mNavHeaderView setHeaderTitle:[dTitle prefixStringWithSeparate:@":"] font:fontObj];
            }
            
            if (!IsStrEmpty(eTitle)) {  // （标题仅取冒号前部分）
                [self.mNavHeaderView setHeaderTitle:[eTitle prefixStringWithSeparate:@":"] font:fontObj];
                [self.mNavHeaderView setHeaderTitleColor:titleColor];
            }
            
            if (!IsStrEmpty(_defaultColorStr)&&IsStrEmpty(eTitle))
            {
                [self.mNavHeaderView setHeaderTitleColor:titleColor];
            }
            
            // 导航栏背景色
            if(!IsStrEmpty(eBakground)){
                self.mNavHeaderView.backgroundColor = [UIColor colorWithHexString:eBakground];
            }
            // 导航栏logo图片 ?
            if (!IsStrEmpty(eImage)) {
                [self.mNavHeaderView setHeaderImg:eImage];
            }
            // 导航栏背景图片 ?
            if (!IsStrEmpty(eBakImage)) {
                [self.mNavHeaderView setHeaderBackImg:eBakImage
                                                title:[eTitle prefixStringWithSeparate:@":"]
                                                 font:fontObj];
                [self.mNavHeaderView setHeaderTitleColor:titleColor];
            }
            
            //设置返回按钮和更多按钮的颜色 0黑色 1白色
            if (!IsStrEmpty(eIconStyle)) {
                if ([eIconStyle isEqualToString:@"1"]) { //白色 //nav_back_white_normal@2xmore_big_white_icon@2x
                    [self.mNavHeaderView setBackBtnImageWithNormal:@"nav_back_white_normal.png" highlight:@"nav_back_white_normal.png"];
                    [self.mNavHeaderView setMoreBtnImageWithNormal:@"more_big_white_icon.png" highlight:@"more_big_white_icon.png"];
                    [self.mNavHeaderView setCloseBtnColor:[UIColor whiteColor]];
                } else { //默认的
                    [self.mNavHeaderView setBackBtnImageWithNormal:@"nav_back_normal.png" highlight:@"nav_back_normal.png"];
                    [self.mNavHeaderView setMoreBtnImageWithNormal:@"more_big_icon.png" highlight:@"more_big_icon.png"];
                    [self.mNavHeaderView setCloseBtnColor:[UIColor blackColor]];
                }
            }else {
                [self.mNavHeaderView setBackBtnImageWithNormal:@"nav_back_normal.png" highlight:@"nav_back_normal.png"];
                [self.mNavHeaderView setMoreBtnImageWithNormal:@"more_big_icon.png" highlight:@"more_big_icon.png"];
                [self.mNavHeaderView setCloseBtnColor:[UIColor blackColor]];
                
            }
            
            
        }
    }
}

/**
 开放iPhone X全屏
 */
- (void)callOpenWebViewFullScreen:(BOOL)open{
    
}

#pragma mark refreshView
/*
 * webview页面 app自定义刷新
 * @xzoscar
 */
- (void)onRefreshHeaderViewAction {
    [self.webView reload];
}

#pragma mark observe
- (void)observeValueForKeyPath:(NSString*)keyPath ofObject:(id)object change:(NSDictionary*)change context:(void*)context {
    if (object==self.webView
        && [keyPath isEqualToString:@"estimatedProgress"]) {
        [self webViewUpdateProgress:[change[NSKeyValueChangeNewKey] doubleValue]];
    } else if (object==self.webView
               && [keyPath isEqualToString:@"title"]) {
        NSString *title = change[NSKeyValueChangeNewKey];
        if (!IsStrEmpty(title)) {
            [self setDocumentNavStyle];
        }
    }
}

/*
 * webview加载进度回调
 * @xzoscar
 */
-(void)webViewUpdateProgress:(float)progress {
    //重新开始
    if (fabs(progress-0.1) < FLT_EPSILON) {
        progress = .0f;
    }
    
    [self.mProgressView setProgress:progress animated:YES];
}

- (void)setDocumentNavStyle {
    // 6.1版本 wkwebview goback不会走didFinishNavigation回调，改为title改变设置导航栏样式
    // 获取前端document对导航栏的配置 @xzoscar
    NSString *javascript = @""
    "if (window.SNNativeClient && window.SNNativeClient.documentNavStyle) {"
    "window.SNNativeClient.documentNavStyle();"
    "}";
    [self.webView evaluateJavaScript:javascript completionHandler:nil];
}
#pragma mark -
#pragma mark --------interacting--------
//显示一个JS的Alert（与JS交互）
- (void)webView:(WKWebView *)webView runJavaScriptAlertPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(void))completionHandler{
    NSLog(@"弹窗alert");
    NSLog(@"%@",message);
    NSLog(@"%@",frame);
    [CMToast toast:message];
    completionHandler();
}

//弹出一个输入框（与JS交互的）
- (void)webView:(WKWebView *)webView runJavaScriptTextInputPanelWithPrompt:(NSString *)prompt defaultText:(nullable NSString *)defaultText initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(NSString * __nullable result))completionHandler{
    NSLog(@"弹窗输入框");
    NSLog(@"%@",prompt);
    NSLog(@"%@",defaultText);
    NSLog(@"%@",frame);
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:prompt message:defaultText preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *a1 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        //这里必须执行不然页面会加载不出来
        completionHandler(@"");
    }];
    UIAlertAction *a2 = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"%@",
             [alert.textFields firstObject].text);
        completionHandler([alert.textFields firstObject].text);
    }];
    [alert addAction:a1];
    [alert addAction:a2];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        NSLog(@"%@",textField.text);
    }];
    [self presentViewController:alert animated:YES completion:nil];
}

//显示一个确认框（JS的）
- (void)webView:(WKWebView *)webView runJavaScriptConfirmPanelWithMessage:(NSString *)message initiatedByFrame:(WKFrameInfo *)frame completionHandler:(void (^)(BOOL result))completionHandler{
    NSLog(@"弹窗确认框");
    NSLog(@"%@",message);
    NSLog(@"%@",frame);
    
    
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:message message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(NO);
    }];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        completionHandler(YES);
    }];
    [alertController addAction:cancelAction];
    [alertController addAction:okAction];
    [self presentViewController:alertController animated:YES completion:nil];
}
#pragma mark -
#pragma mark --------property--------
-(WKWebView *)webView{
    if (!_webView) {
        _webView = [[WKWebView alloc]init];
        _webView.navigationDelegate = self;
        _webView.UIDelegate = self;
        _webView.allowsBackForwardNavigationGestures = YES;
        // 进度条和title通知
        [_webView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        [_webView addObserver:self forKeyPath:@"title" options:NSKeyValueObservingOptionNew context:NULL];
    }
    return _webView;
}

/*
 * 自定义导航栏
 * @xzoscar
 */
- (WebHeaderView *)mNavHeaderView {
    if (nil == _mNavHeaderView) {
        _mNavHeaderView = [[WebHeaderView alloc] init];
        //        _mNavHeaderView.translatesAutoresizingMaskIntoConstraints = NO;
        
        CGSize sz = [UIScreen mainScreen].bounds.size;
        _mNavHeaderView.frame = CGRectMake(.0f, .0f, sz.width, 64.0f+Top_SN_iPhoneX_SPACE);
        
        __weak typeof(self) weakSelf = self;
        _mNavHeaderView.onBackBlock  = ^ {
            [weakSelf onBack:nil];
            
        };
        _mNavHeaderView.onCloseBlock = ^ {
            [weakSelf onBack:nil];
        };
        _mNavHeaderView.onMoreBlock  = ^ {
//            [weakSelf moreButtonClick];
        };
        _mNavHeaderView.onRightItemBlock  = ^ {
//            if (weakSelf.mNavHeaderView.rightItemType == WebHeaderViewRightItemTypeShare) {
//                [weakSelf share];
//            } else {
//                [weakSelf shopCartBtnClick];
//            }
        };
    }
    return _mNavHeaderView;
}

- (NJKWebViewProgressView *)mProgressView {
    if (nil == _mProgressView) {
        CGFloat progressBarHeight = 2.f;
        CGSize size = [UIScreen mainScreen].bounds.size;
        CGRect barFrame = CGRectMake(.0f,(64.0f+Top_SN_iPhoneX_SPACE-progressBarHeight),size.width,progressBarHeight);
        _mProgressView = [[NJKWebViewProgressView alloc] initWithFrame:barFrame];
        //5.7注释，使用手动设置frame
        //        _mProgressView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleTopMargin;
        
        _mProgressView.progress = .0f; // default .0f
        _mProgressView.backgroundColor = [UIColor clearColor];
    }
    return _mProgressView;
}

/*
 * javascript birdge
 * @xzoscar
 */
- (WKWebViewJavascriptBridge *)jsBridge {
    if (nil == _jsBridge) {
        _jsBridge = [WKWebViewJavascriptBridge bridgeForWebView:self.webView];
        [_jsBridge setWebViewDelegate:self];
    }
    return _jsBridge;
}

- (WebViewJSHandler *)jsHandler {
    if (nil == _jsHandler) {
        _jsHandler = [[WebViewJSHandler alloc] initWithWebView:self.webView jsBridge:self.jsBridge mainVC:self];
    }
    return _jsHandler;
}

@end
