//
//  CMRoutesProtocol.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


#define SN_ROUTE_GET_ROUTER(routes) \
NSObject<SNRoutesProtocol> *routes = [[JSObjection defaultInjector] getObject:@protocol(SNRoutesProtocol)];

#define kRouterUnrecognizedTypeCode             @"Unrecognized"
#define kRouterUnknownHttpUrlTypeCode           @"UnknownHttpUrl"
#define kRouterLotteryPayTypeCode               @"DGFQ"
#define kRouterScanLoginRegistTypeCode          @"ScanToLoginOrRegist"
#define kRouterDoNothingTypeCode                @"DoNothing"
#define kRouterPresentRouteShopCartTypeCode     @"1161" //模态进入购物车

typedef NS_ENUM(NSInteger, CMRouteSource) {
    CMRouteSourceNone               = 0,    //标识不是路由过来的
    CMRouteSourceDM                 = 1,    //DM单
    CMRouteSourceRemoteNotification = 2,    //远程推送
    CMRouteSourceScan               = 3,    //扫码
    CMRouteSourceOpenUrl            = 4,    //从别的应用跳过来的
    CMRouteSourceQuGuangGuang       = 5,    //去逛逛来的
    CMRouteSourceSomeUrl            = 6,    //自定义的Url
    CMRouteSourceSomeCode           = 7,    //自定义的adTypeCode
    CMRouteSourceWebController      = 8,    //webViewController
    CMRouteSourceNativeController   = 9,    //客户端原生controller
    CMRouteSourceScanHistory        = 10,   //扫描历史记录页面
    CMRouteSourceYunXinMessage        = 100,   //云信消息
};



//扫码登录或注册来源
typedef NS_ENUM(NSInteger, scanToLoginOrRegistType ) {
    ScanTypeNone      = 0,//默认为0，不是扫码登录、注册来源
    ScanTypeTV        = 1,//TV端二维码
    ScanTypePC        = 2,//PC端二维码
};

//SNRouteObject 页面路由信息封装
@protocol CMRoutesProtocol <NSObject>

@optional

@property (nullable,nonatomic, copy) NSString *adTypeCode; //活动类型, 普通URL: "UnknownUrl"; 未能识别: "Unrecognized";
@property (nullable,nonatomic, copy) NSString *adId; //活动ID

@property (nullable,nonatomic, copy) NSString *storeId;//门店id（门店布展二维码才有该字段）

@property (nullable,nonatomic, copy) NSString *originUrl; //url
@property (nullable,nonatomic, strong) NSDictionary *allParams; //所有的参数

@property (nonatomic, assign)  scanToLoginOrRegistType scanToLoginOrRegistSource;

@property (nonatomic, assign) CMRouteSource source;  //来源

@property (nonatomic, assign) BOOL isReady;     //是否准备完成，适用于需要提前接口检查的页面

@property (nullable,nonatomic, copy) void (^onCheckingBlock)(id<CMRoutesProtocol>  __nullable obj);   //接口检查开始
@property (nullable,nonatomic, copy) BOOL (^shouldRouteBlock)(id<CMRoutesProtocol> __nullable obj);  //即将跳转页面前回调
@property (nullable,nonatomic, copy) void (^didRouteBlock)(id<CMRoutesProtocol> __nullable obj);     //跳转完成后的方法

@property (nullable,nonatomic, copy) void (^doRouteBlock)(id<CMRoutesProtocol> __nullable obj);  //跳转的方法，优先级最高
@property (nullable,nonatomic, strong) UIViewController *targetController; //解析出来的controller，为nil则跳转到nav的rootController
@property (nonatomic, assign) NSUInteger defaultTabIndex;         //默认跳转的页面Index,
@property (nullable,nonatomic, strong) UINavigationController *navController; //进入目标controller的导航控制器,默认是nil,如果设置了，就用此nav进行跳转
@property (nullable,nonatomic, copy) NSString *errorMsg; //错误

//在presentNav里路由跳转时，如果presentNav没有conform SNRoutePresentProtocol协议，则默认会先执行dismiss操作
@property (nonatomic, assign) BOOL ignoreClearPresented;

//在presentNav里路由跳转时，如果presentNav confrom SNRoutePresentProtocol协议，则默认不先执行dismiss操作，如果需要dismiss则需要设置这个属性为YES
@property (nonatomic, assign) BOOL forceClearPresented;

- (BOOL)isErrorOrDoNothing;

@end


//SNRoutes  页面路由

@protocol SNRoutesProtocol <NSObject>

@optional
/**
 *  解析一个url类型的跳转
 *
 *  @param url              一个http的url，可以来源于二维码扫描或其他途径维护
 *  @param onCheckingBlock  接口检查即将开始
 *  @param shouldRouteBlock 即将跳转到指定的页面或场景的回调block
 *  @param didRouteBlock    跳转完毕后的回调block
 *  @param source           标示进入的来源，如推送、二维码扫描等，用于数据统计
 *
 */
- (void)handleURL:(NSString * __nullable)url
       onChecking:(void(^__nullable)(id<CMRoutesProtocol> __nullable obj))onCheckingBlock
      shouldRoute:(BOOL(^__nullable)(id<CMRoutesProtocol> __nullable obj))shouldRouteBlock
         didRoute:(void(^__nullable)(id<CMRoutesProtocol> __nullable obj))didRouteBlock
           source:(CMRouteSource)source;


- (void)handleURL:(NSString *__nullable)url
       onChecking:(void(^__nullable)(id<CMRoutesProtocol> __nullable obj))onCheckingBlock
      shouldRoute:(BOOL (^__nullable)(id<CMRoutesProtocol> __nullable obj))shouldRouteBlock
         didRoute:(void (^__nullable)(id<CMRoutesProtocol> __nullable obj))didRouteBlock
           source:(CMRouteSource)source
    navController:(UINavigationController * __nullable)navCon;

/**
 *  <#Description#>
 *
 *  @param url              <#url description#>
 *  @param onCheckingBlock  <#onCheckingBlock description#>
 *  @param shouldRouteBlock <#shouldRouteBlock description#>
 *  @param didRouteBlock    <#didRouteBlock description#>
 *  @param source           <#source description#>
 *  @param navCon           <#navCon description#>
 *  @param style            0---push推入,  1---present展示
 */
- (void)handleURL:(NSString * __nullable)url
       onChecking:(void(^ __nullable)(id<CMRoutesProtocol>  __nullable obj))onCheckingBlock
      shouldRoute:(BOOL (^ __nullable )(id<CMRoutesProtocol>  __nullable obj))shouldRouteBlock
         didRoute:(void (^ __nullable)(id<CMRoutesProtocol> __nullable obj))didRouteBlock
           source:(CMRouteSource)source
    navController:(UINavigationController * __nullable)navCon style:(int)style;

/**
 *  解析一个url-scheme的跳转
 *
 *  @param openUrl          进入应用的原url
 *  @param onCheckingBlock  接口检查即将开始
 *  @param shouldRouteBlock 即将跳转到指定的页面或场景的回调block
 *  @param didRouteBlock    跳转完毕后的回调block
 *
 *  @return YES
 */
- (BOOL)handleOpenUrl:(NSURL *__nullable)openUrl
           onChecking:(void(^__nullable)(id<CMRoutesProtocol> __nullable obj))onCheckingBlock
          shouldRoute:(BOOL(^__nullable)(id<CMRoutesProtocol> __nullable obj))shouldRouteBlock
             didRoute:(void(^__nullable)(id<CMRoutesProtocol> __nullable obj))didRouteBlock;

/**
 *  解析并跳转一个自定义code类型的跳转
 *
 *  @param adTypeCode       活动类型   required
 *  @param adId             活动ID
 *  @param chanId           老规则中的抢购的频道ID
 *  @param qiangId          老规则中的抢购ID
 *  @param onCheckingBlock  接口检查即将开始
 *  @param shouldRouteBlock 即将跳转到指定的页面或场景的回调block
 *  @param didRouteBlock    跳转完毕后的回调block
 *  @param source           标示进入的来源，如推送、二维码扫描等，用于数据统计
 */
- (void)handleAdTypeCode:(NSString *__nullable)adTypeCode
                    adId:(NSString *__nullable)adId
                  chanId:(NSString *__nullable)chanId
                 qiangId:(NSString *__nullable)qiangId
              onChecking:(void(^__nullable)(id<CMRoutesProtocol> __nullable obj))onCheckingBlock
             shouldRoute:(BOOL(^__nullable)(id<CMRoutesProtocol> __nullable obj))shouldRouteBlock
                didRoute:(void(^__nullable)(id<CMRoutesProtocol> __nullable obj))didRouteBlock
                  source:(CMRouteSource)source;


#pragma mark - 全局页面路由

/**
 *    @brief    单纯的页面push,
 *
 *    @param     url     被推入页面的url
 *    @param     fromNav     从哪个NavigationController推入
 *    @param     animate     是否动画
 */
- (void)pushViewController:(NSString * __nullable)url params:(NSDictionary * __nullable)parmas fromNav:(UINavigationController *__nullable)fromNav Animate:(BOOL)animate;

/**
 *    @brief    单纯的页面Present
 *
 *    @param     url     被Present页面的url
 *    @param     parmas     额外的参数
 *    @param     fromViewController     从哪个ViewController进行Present
 *    @param     animate     是否动画
 *  @param  completion  完成后调用的block
 */
- (void)presentViewController:(NSString * __nullable)url params:(NSDictionary * __nullable)parmas fromViewController:(UIViewController * __nullable)fromViewController Animate:(BOOL)animate completion:(void (^ __nullable)(void))completion;

/**
 *    @brief    推入WebViewController
 *
 *    @param     url     webview要打开的url
 *    @param     parmas     传给webview的额外参数
 *    @param     fromNav     从哪个NavigationController推入
 *    @param     animate     是否动画
 */
- (void)pushWebViewController:(NSString * __nullable)url params:(NSDictionary * __nullable)parmas fromNav:(UINavigationController *__nullable)fromNav Animate:(BOOL)animate;

/**
 *    @brief  获取对应内部URL的ViewController
 *
 *    @param     url     内部url
 *    @param     parmas     传给ViewController的额外参数
 */
- (UIViewController * __nullable)getViewController:(NSString * __nullable)url params:(NSDictionary * __nullable)parmas;

@end






