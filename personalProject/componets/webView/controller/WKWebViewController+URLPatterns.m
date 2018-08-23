//
//  WKWebViewController+URLPatterns.m
//  SuningEBuy
//
//  Created by wangbin on 2018/3/23.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import "WKWebViewController+URLPatterns.h"
#import "CMRoutes.h"
#import "WebViewJavascriptBridgeBase.h"
#import "NSString+CMBase.h"
#import "NSArray+CMBase.h"
#import "CMCommonHeader.h"
#import <objc/message.h>

#define kSysCodeForManzuo                   @"manzuowap"
#define kURLSchemeSNBook                    @"com.suning.reader4iphone://"
//subook下载链接
#define kSNBookItunesLink       @"http://itunes.apple.com/cn/app/id568803051?l=en&mt=8"

#define kPassportTrustLoginUrl SN_URLDOMAINMANAGER_GET_MANAGER(@"kPassportTrustLoginUrl")

//激活易付宝成功通知
#define ActiveEfubaoSuccess @"activeEfubaoSuccess"

typedef enum {
    
    eUserUnLogin,         //用户未登录
    eLoginByPhoneUnBound, //手机登录、手机未绑定、易付宝未激活
    eLoginByEmailUnBound, //邮箱登录、邮箱未激活、手机位激活、易付宝未激活
    eLoginByEmailPhoneUnBound, //邮箱登录、邮箱已激活、手机未激活、易付宝未激活
    eLoginByPhoneUnActive,//手机登录、手机已绑定、易付宝未激活
    eLoginByEmailUnActive,//邮箱登录、邮箱已激活、手机已激活、易付宝未绑定
    eLoginByPhoneActive,  //手机登录、手机已绑定、易付宝已激活
    eLoginByEmailActive   //邮箱登录、邮箱已绑定、易付宝已激活
    
}eEfubaoStatus;

/*
 * WKWebViewController (URLPatterns)
 * webview和native交互，需要推入目标页面的 走页面路由，禁止如#import<XXXViewController>
 * ‘WKWebViewController (URLPatterns)’ 分类 用于匹配URL后,作出响应 常见案例如下
 * (1)web前端 登陆失效,截获passport 跳转到本地登录
 * (2)兼容旧的web前端和app的交互需求
 * @xzoscar
 */

@interface WKWebViewController ()

// 要监听的URL patterns
@property (nonatomic,strong) NSArray                 *URLPatterns;

@end

@implementation WKWebViewController (URLPatterns)

static char *URLPatternsKey = "URLPatternsKey";
-(void)setURLPatterns:(NSArray *)URLPatterns{
    objc_setAssociatedObject(self, URLPatternsKey, URLPatterns, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

-(NSArray *)URLPatterns{
    if (objc_getAssociatedObject(self, URLPatternsKey) == nil) {
        self.URLPatterns = [self loadURLPatterns];
    }
    
    return objc_getAssociatedObject(self, URLPatternsKey);
}

- (NSArray *)loadURLPatterns {
    return @[ // {{{
             @{@"regex" : @"isSNMobileLogin",
               @"action" : @"loginAction:"},
             
             @{@"regex" : @"nativeWebBackMethod",
               @"action" : @"handleBackMethod:"},
             
             @{@"regex": @"^ebuyweb://SNIOSWebViewBack$",
               @"action" : @"back2:"},
             
             @{@"regex": @"^ebuyweb://SNIOSWebViewShowNavBar$",
               @"action" : @"showNavBar:"},
             
             @{
                 @"regex" : @"^http(s)?://.*\?cart/cart4.html*",
                 @"action" : @"onRouteToCartFour:"
                 },
             
             @{@"regex": @"http(s)?://",
               @"action" : @"httpUrls:"},
             
             @{@"regex": @"://",
               @"action" : @"otherUrlSchemes:"},
             
             @{@"regex": @"^about:",
               @"action" : @"abouts:"},
             
             
             @{@"regex": @"^(redirect:back.*|backtoclient(:.*)?)$",
               @"regularOption" : @(NSRegularExpressionCaseInsensitive),
               @"action" : @"back:"}
             ];// }}}
}

/*
 * 检测URL,每个URL仅匹配一个selector函数，不会循环
 * @xzoscar
 */
- (BOOL)shouldValidateByURLPatternsWithURL:(NSURL *)URL {
    if (nil != URL) {
        NSString *URLString = URL.absoluteString;
        for (NSDictionary *pattern in self.URLPatterns) {
            NSString *regex = [pattern objectForKey:@"regex"];
            NSRegularExpressionOptions option = [[pattern objectForKey:@"regularOption"] integerValue];
            NSRegularExpression *exp = [[NSRegularExpression alloc] initWithPattern:regex options:option error:NULL];
            
            if ([exp numberOfMatchesInString:URLString
                                     options:NSMatchingReportCompletion
                                       range:NSMakeRange(0, URLString.length)] > 0) {
                NSString *action = [pattern objectForKey:@"action"];
                SEL selector = NSSelectorFromString(action);
                if ([self respondsToSelector:selector]) {
                    IMP imp = [self methodForSelector:selector];
                    BOOL (*func)(id, SEL, NSURL*) = (void *)imp;
                    BOOL should = func(self, selector, URL);
                    return should;
                }else{
                    return YES;
                }
            } // }}}
        }
    }
    return YES;
}

#pragma mark ---c
/**
 *  登录
 *
 *  @param url url
 *
 *  @return 是否加载url
 */
- (BOOL)loginAction:(NSURL *)url {
    __weak typeof(self) weakSelf = self;
    //检查是否登录
    BOOL logined = arc4random()%2 > 0;
    if (!logined) {
        //去登录，登录重构后，self.webView重新加载url
        //登录不成功，pop
        return NO;
    } else {
        return YES;
    }
}


/**
 *  处理返回方法
 *
 *  @param url url
 *
 *  @return 是否加载url
 */
- (BOOL)handleBackMethod:(NSURL *)url {
    NSString *urlString = [url absoluteString];
    NSRange range = [urlString rangeOfString:@"objc://nativeWebBackMethod/"];
    if (range.location == NSNotFound) {
//        self.backPolicy = SNWebViewBackDefault;
    } else {
        NSString *paramString = [urlString substringFromIndex:range.location + [@"objc://nativeWebBackMethod/" length]];
        //设置返回方式
//        self.backPolicy = [paramString intValue];
    }
    return NO;
}

/**
 *  返回
 *
 *  @param url url
 *
 *  @return 是否加载url
 */
- (BOOL)back2:(NSURL *)url {
    if (self.webView.canGoBack) {
        [self.webView goBack];
    }else{
        [self popToParentWithChcek];
    }
    return NO;
}

/**
 *  显示导航栏
 *
 *  @param url url
 *
 *  @return 是否加载url
 */
- (BOOL)showNavBar:(NSURL *)url {
    [self setCustomNavHeaderBarHidden:NO];
    return NO;
}

/**
 *  其他
 *
 *  @param url url
 *
 *  @return 是否加载url
 */
- (BOOL)otherUrlSchemes:(NSURL *)url {
    //其他url scheme,
    return YES;
}

- (BOOL)abouts:(NSURL *)url {
    return YES;
}

/**
 *  返回
 *
 *  @param url url
 *
 *  @return 是否加载url
 */
- (BOOL)back:(NSURL *)url {
    [self popToParentWithChcek];
    return NO;
}

@end
