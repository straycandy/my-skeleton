//
//  WKWebViewController+JSBridge.m
//  SuningEBuy
//
//  Created by wangbin on 2018/3/23.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import "WKWebViewController+JSBridge.h"
#import "CMCommonHeader.h"
#import "WebViewJSBridgeProtocol.h"
#import <AVFoundation/AVFoundation.h>
#import <UserNotifications/UserNotifications.h>
#import "BBAlertView.h"
#import "CMToast.h"
#import "UIViewController+CMToast.h"
#import "UIScrollView+MJRefresh.h"
#import "ABPeoplePickerHandler.h"
#import "MJRefreshHeader.h"
#import "WebImagePickerHandler.h"
#import "Preferences.h"

#define AESprivateKey   @"colaTicket@12345"
#define PBEprivateKey   @"suningebuy@12345"
#define kRetrieveParamEncodeSalt  @"sn201209"

#define suningCookieDomain @".suning.com"

@interface WKWebViewController ()<UIActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@end

/*
 * WKWebViewController
 * webview和native交互，需要推入目标页面的 走页面路由，禁止如#import<XXXViewController>
 * @xzoscar
 */


@implementation WKWebViewController (JSBridge)

/*
 * 注册所有js函数
 * (1)这里注册的js函数，前端可通过bridge.callHandler()调用
 * (2)如果想要通过birdge.copyToClipboard()方式调用，要在'WebViewJavascriptBridge.js'中提供便捷js
 * (3)前端也可以通过bridge注册js函数，来供给app调用
 * @xzoscar
 */
- (void)registerJavaScriptHandlers {
    // 复制文本
    [self.jsBridge registerHandler:@"copyToClipboard"
                           handler:[self copyToClipboardHandler]];
    
    // 提示弹出框
    [self.jsBridge registerHandler:@"showAlert"
                           handler:[self showAlertHandler]];
    // 提示文本
    [self.jsBridge registerHandler:@"showTip"
                           handler:[self showTipHandler]];
    // 设置导航栏颜色
    [self.jsBridge registerHandler:@"setBarColor"
                           handler:[self setBarColorHandler]];
    
    // 在safari中打开链接
    [self.jsBridge registerHandler:@"openLinkInSafari"
                           handler:[self openLinkInSafariHandler]];
    
    //打开app设置页
    [self.jsBridge registerHandler:@"openPhoneSettings"
                           handler:[self openPhoneSettingsHandler]];
    
    // 调用客户端通讯录
    [self.jsBridge registerHandler:@"addressBook"
                           handler:[self addressBookHandler]];
    // 客户端setNavigationHiden
    [self.jsBridge registerHandler:@"setNavigationHiden"
                           handler:[self setNavigationHidenHandler]];
    // 页面是否需要下拉刷新
    [self.jsBridge registerHandler:@"enablePullRefresh"
                           handler:[self enablePullRefreshHandler]];
    // 更新导航栏标题
    [self.jsBridge registerHandler:@"updateTitle"
                           handler:[self updateTitleHandler]];
    // 点击去拍照页面
    [self.jsBridge registerHandler:@"takePhoto"
                           handler:[self takePhotoHandler]];
    // 图片选择 alert action sheet
    [self.jsBridge registerHandler:@"openBestieFileChooser"
                           handler:[self openBestieFileChooserHandler]];
    // 上传单张图片
    [self.jsBridge registerHandler:@"openImageChooser"
                           handler:[self openImageChooserHandler]];
    // 上传多张图片
    [self.jsBridge registerHandler:@"uploadMultiplePictures"
                           handler:[self uploadMultiplePicturesHandler]];
    // 导航栏样式
    [self.jsBridge registerHandler:@"documentNavStyle"
                           handler:[self documentNavStyleHandler]];
    //碎屏险跳转cpa gjf
    [self.jsBridge registerHandler:@"gotoCPA"
                           handler:[self gotoCPAHandler]];
    
    //4.9.1获取相机权限
    [self.jsBridge registerHandler:@"SNGetCameraPermission"
                           handler:[self SNGetCameraPermissionHandler]];
    
    //开放全屏6.3.0
    [self.jsBridge registerHandler:@"callOpenWebViewFullScreen"
                           handler:[self callOpenWebViewFullScreenHandler]];
    

#warning 所有新增的jsbridge在这里添加native实现 6.4.0
    [self.jsHandler registerJavaScriptHandlers];
}

#pragma mark -- js函数回调业务处理
/**
 获取相机状态
 */
- (WVJBHandler)SNGetCameraPermissionHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString  *type =AVMediaTypeVideo;
        AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:type];
        if((authStatus == AVAuthorizationStatusDenied) || (authStatus ==AVAuthorizationStatusRestricted)){
            [weakSelf.webView evaluateJavaScript:@"cameraPession('false')" completionHandler:nil];
        } else {
            [weakSelf.webView evaluateJavaScript:@"cameraPession('true')" completionHandler:nil];
        }
    });
}

/*
 * copyToClipboardHandler
 * 复制到系统剪切版 callback
 * @xzoscar
 */
- (WVJBHandler)copyToClipboardHandler {
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *text = EncodeStringFromDic(data, @"text");
        if (text.length) {
            [[UIPasteboard generalPasteboard] setString:text];
            if (responseCallback) responseCallback(@{@"isSuccess": @YES});
        } else {
            if (responseCallback) responseCallback(@{@"isSuccess": @NO, @"error": @"empty str to copy"});
        }
    });
}



/**
 开放iPhone X全屏
 */
- (WVJBHandler)callOpenWebViewFullScreenHandler
{
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *dict = (NSDictionary *)data;
        NSString *open = EncodeStringFromDic(dict, @"isOpen");
        [weakSelf callOpenWebViewFullScreen:open.intValue];
        
    });
}

/*
 * showAlertHandler
 * 提示弹出框 callback
 * @xzoscar
 */
- (WVJBHandler)showAlertHandler {
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *message = EncodeStringFromDic(data, @"message");
        NSArray *buttons = EncodeArrayFromDic(data, @"buttons");
        
        BBAlertView *alert = [[BBAlertView alloc]
                              initWithTitle:nil
                              message:message
                              delegate:nil
                              cancelButtonTitle:[buttons safeObjectAtIndex:0]
                              otherButtonTitles:[buttons safeObjectAtIndex:1]];
        [alert setConfirmBlock:^{
            if (responseCallback) responseCallback(@{@"clickIndex": @1});
        }];
        
        [alert setCancelBlock:^{
            if (responseCallback) responseCallback(@{@"clickIndex": @0});
        }];
        [alert show];
    });
}

/*
 * showTipHandler
 * 提示文本 callback
 * @xzoscar
 */
- (WVJBHandler)showTipHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *message = EncodeStringFromDic(data, @"message");
        if (message.length) {
            [weakSelf toast:message];
        }
        if (responseCallback) responseCallback(@{@"isSuccess": message.length?@YES:@NO});
    });
}

/*
 * setBarColorHandler
 * 设置导航栏颜色 callback
 * @xzoscar
 */
- (WVJBHandler)setBarColorHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *colorString = EncodeStringFromDic(data, @"color");
        NSDictionary *dict = @{@"eBakground":colorString};
        [weakSelf setCustomNavStyleWithDictionary:dict];
    });
}

/*
 * openLinkInSafariHandler
 * 在safari中打开链接 callback
 * @xzoscar
 */
- (WVJBHandler)openLinkInSafariHandler {
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *url = EncodeStringFromDic(data, @"url");
        NSURL *requestUrl = [NSURL URLWithString:url];
        [[UIApplication sharedApplication] openURL:requestUrl];
    });
}


/**
 打开手机设置页
 */
- (WVJBHandler)openPhoneSettingsHandler {
    return (^(id data, WVJBResponseCallback responseCallback) {
        
            if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]]) {
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString]];
            }

    });
}

/*
 * addressBookHandler
 * 调用客户端通讯录 callback
 * @xzoscar
 */
- (WVJBHandler)addressBookHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        [ABPeoplePickerHandler pickInController:weakSelf cancelBlock:^{
            
        } didPickPersonBlock:^(NSString *name, NSString *phoneStr) {
            [weakSelf.webView evaluateJavaScript:[NSString stringWithFormat:@"getAddressBookInfo('%@;%@')",name,phoneStr] completionHandler:nil];
        }];
    });
}

/*
 * setNavigationHidenHandler
 * 客户端导航栏隐藏 callback
 * @xzoscar
 */
- (WVJBHandler)setNavigationHidenHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *traceId = EncodeStringFromDic(data, @"hasNavigation");
        [weakSelf setCustomNavHeaderBarHidden:![traceId boolValue]];
    });
}

/*
 * enablePullRefreshHandler
 * 页面是否需要下拉刷新 callback
 * @xzoscar
 */
- (WVJBHandler)enablePullRefreshHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        // 添加下拉刷新
        weakSelf.webView.scrollView.mj_header = [MJRefreshHeader headerWithRefreshingBlock:^{
            [weakSelf onRefreshHeaderViewAction];
        }];
    });
}

/*
 * updateTitleHandler
 * 更新导航栏标题 callback
 * @xzoscar
 */
- (WVJBHandler)updateTitleHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *title = EncodeStringFromDic(data, @"title");
        [weakSelf.mNavHeaderView setHeaderTitle:title font:[UIFont systemFontOfSize:16]];
    });
}

/*
 * takePhotoHandler
 * 点击去拍照页面 callback
 * @xzoscar
 */
- (WVJBHandler)takePhotoHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *pictureUrl = EncodeStringFromDic(data, @"picUrl");
        NSString *title = EncodeStringFromDic(data, @"title");
        int picSize = [EncodeStringFromDic(data, @"picSize") intValue];
//        SNWebTakePhotoViewController *readerController = [[SNWebTakePhotoViewController alloc] initWithTitle:title picUrl:pictureUrl picSize:picSize];
//        readerController.delegate = weakSelf;
//        SNNavigationController *nav = [[SNNavigationController alloc] initWithRootViewController:readerController];
//        [weakSelf presentViewController:nav animated:YES completion:nil];
    });
}

//SNWebTakePhotoViewControllerDelegate
- (void)takePhotoFinishedWithResult:(NSString *)result {
    if (!IsStrEmpty(result)) {
        NSString *str =[NSString stringWithFormat:@"uploadSuccess(\"%@\");",result];
        [self.webView evaluateJavaScript:str completionHandler:nil];
    }
}

/*
 * openBestieFileChooserHandler
 * 图片选择 alert action sheet callback
 * @xzoscar
 */
- (WVJBHandler)openBestieFileChooserHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        // 已经上传的张数
        NSString *choosedCount = EncodeStringFromDic(data,@"choosedCount");
        if (nil != choosedCount
            && [choosedCount isKindOfClass:[NSString class]]) {
            if (choosedCount.integerValue >= 5) {
                [weakSelf toast:@""];
                return;
            }
        }
        
        // {"choosedCount":choosedCount,"descText":descText,"images":images}
        //        weakSelf.gmsDictionary = data;
        [WebImagePickerHandler pickImageInController:weakSelf pictureUrl:nil multiplePictures:NO cancelBlock:^{
            
        } didPickImageBlock:^(NSString *filePath, NSString *url) {
            //            SNPMGuimiShowSendViewController *ctrler = [[SNPMGuimiShowSendViewController alloc] init];
            //            ctrler.firstImgFileURL              = filenamed;
            //            //{"choosedCount":choosedCount,"descText":descText,"images":images}
            //            ctrler.gmsDictionary                = self.gmsDictionary;
            //            ctrler.sendSuccessBlock = ^ {
            //                NSString *jsfc = [NSString stringWithFormat:@"sendGuiMiShowSuccess();"];
            //
            //                NSString *tmpStr = [weakSelf.webView stringByEvaluatingJavaScriptFromString:jsfc];
            //                DLog(@"%@",tmpStr);
            //            };
            //            AuthManagerNavViewController *nav = [[AuthManagerNavViewController alloc] initWithRootViewController:ctrler];
            //            [weakSelf presentViewController:nav animated:YES completion:nil];
        }];
    });
}

/*
 * openImageChooserHandler
 * 上传单张图片
 * @xzoscar
 */
- (WVJBHandler)openImageChooserHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSDictionary *pictureUrl = EncodeDicFromDic(data,@"pictureUrl");
        NSString *picture = EncodeStringFromDic(pictureUrl, @"pictureUrl");
        // {"choosedCount":choosedCount,"descText":descText,"images":images}
        
        [WebImagePickerHandler pickImageInController:weakSelf pictureUrl:picture multiplePictures:NO cancelBlock:^{
            
        } didPickImageBlock:^(NSString *filePath, NSString *url) {
            if (url) {
                NSString *str =[NSString stringWithFormat:@"uploadSuccess(\"%@\");",url];
                [weakSelf.webView evaluateJavaScript:str completionHandler:nil];
            }
        }];
    });
}

/*
 * uploadMultiplePicturesHandler
 * 上传多张图片
 * @xzoscar
 */
- (WVJBHandler)uploadMultiplePicturesHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *picture = EncodeStringFromDic(data, @"pictureUrl");
        
        [WebImagePickerHandler pickImageInController:weakSelf pictureUrl:picture multiplePictures:YES cancelBlock:^{
            
        } didPickImageBlock:^(NSString *filePath, NSString *url) {
            if (url) {
                NSString *str =[NSString stringWithFormat:@"uploadSuccess(\"%@\");",url];
                [weakSelf.webView evaluateJavaScript:str completionHandler:nil];
            }
        }];
    });
}



- (void)webViewLoadJavaScriptMethod:(NSString *)method {
    [self.webView evaluateJavaScript:[NSString stringWithFormat:@"%@()", method] completionHandler:nil];
}

/*
 * documentNavStyleHandler
 * 前端配置的导航栏样式
 * data key :dTitle,eTitle,eImage,eFontSize,eFontColor,eBakground,eBakgIos6,eBakImage;
 * @xzoscar
 */
- (WVJBHandler)documentNavStyleHandler {
    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        [weakSelf setCustomNavStyleWithDictionary:data];
    });
}

/**
 *  设置cocokie
 *
 *  @param name  name
 *  @param value value
 */
- (void)setCookieName:(NSString *)name withValue:(NSString *)value {
    if (value.length||name.length) {
        return;
    }
    
    NSDictionary *cookieProperty = [[NSDictionary alloc] initWithObjectsAndKeys:
                                    suningCookieDomain, NSHTTPCookieDomain,
                                    suningCookieDomain, NSHTTPCookieOriginURL,
                                    @"/", NSHTTPCookiePath,
                                    name, NSHTTPCookieName,
                                    value, NSHTTPCookieValue, nil];
    NSHTTPCookie *cookie = [NSHTTPCookie cookieWithProperties:cookieProperty];
    
    [[NSHTTPCookieStorage sharedHTTPCookieStorage] setCookie:cookie];
}

/**
 *  碎屏险
 */
- (WVJBHandler)gotoCPAHandler {
    //to do//
    //    __weak typeof(self) weakSelf = self;
    return (^(id data, WVJBResponseCallback responseCallback) {
        //        @strongify(self);
        //        SNMBNewInviteFriendViewController *invite = [[SNMBNewInviteFriendViewController alloc] init];
        //        [[context topNavigation] pushViewController:invite animated:YES];
    });
}

/**
 *  获取客户端网络信息
 *
 *  @return
 */
- (WVJBHandler)getNetworkInfoHandler {
    return (^(id data, WVJBResponseCallback responseCallback) {
        NSString *opratorName = @"unknown";
        NSString *carrier = [Preferences Carrier];
        if ([carrier isEqualToString:@"中国移动"]) {
            opratorName = @"CMCC";
        }
        if ([carrier isEqualToString:@"中国联通"]) {
            opratorName = @"CUCC";
        }
        if ([carrier isEqualToString:@"中国电信"]) {
            opratorName = @"CTC";
        }
        
        NSString *networkType = [Preferences networkType];
        if ([networkType isEqualToString:@"无网络"]) {
            networkType = @"unknown";
        }
        if ([networkType isEqualToString:@"wifi"]) {
            networkType = @"WIFI";
        }
        
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        [dict setValue:opratorName forKey:@"opratorName"];
        [dict setValue:networkType forKey:@"networkType"];
//        NSString *result = [dict JSONRepresentation];
        NSString *result = @"";
        if (responseCallback) {
            responseCallback(result);
        }
    });
}



//- (WVJBHandler)aliPayWithOrderInfoHandler {
//    __weak typeof(self) weakSelf = self;
//    return (^(id data, WVJBResponseCallback responseCallback) {
//        NSString *orderInfo = EncodeStringFromDic(data, @"orderInfo");
//        NSString *isShowPayLoading = EncodeStringFromDic(data, @"isShowPayLoading");
//
//        SNSL_GetAlipayInstance(alipayInatance)
//        alipayInatance.payResultBlock = ^(BOOL isSuccess, NSString * errorCode, NSString * errorMsg){
//            if (isSuccess) {
//                [weakSelf.webView evaluateJavaScript:@"payResult('success')" completionHandler:nil];
//            }else{
//                if ([errorCode isEqualToString:@"6001"]) {
//                    [weakSelf.webView evaluateJavaScript:@"payResult('cancel')" completionHandler:nil];
//                }else{
//                    [weakSelf.webView evaluateJavaScript:@"payResult('fail')" completionHandler:nil];
//                }
//            }
//        };
//        [alipayInatance startAlipayWithInfo:orderInfo showLoading:isShowPayLoading.boolValue];
//
//        if (responseCallback) responseCallback(@{@"isSuccess": @YES});
//    });
//}
////微信支付
//- (WVJBHandler)weixinPayWithOrderInfoHandler {
//
//    __weak typeof(self) weakSelf = self;
//    return (^(id data, WVJBResponseCallback responseCallback) {
//
//        NSString *paramStr = @"";
//        if ([data isKindOfClass:[NSString class]]) {
//
//            paramStr = (NSString *)data;
//        }
//        NSData *jsonData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData
//                                                            options:NSJSONReadingMutableContainers
//                                                              error:nil];
//        SN_SNWeiXinManager(weiXinPayManager);
//        [weiXinPayManager requestOrderDict:dict payCallback:^(NSInteger code, NSString *errorMsg, NSString *returnKey) {
//
//            if (code == WXSuccess) {
//
//                [weakSelf.webView evaluateJavaScript:@"payResult('success')" completionHandler:nil];
//            } else {
//                if (code == WXErrCodeUserCancel) {
//                    [weakSelf.webView evaluateJavaScript:@"payResult('cancel')" completionHandler:nil];
//                } else {
//                    [weakSelf.webView evaluateJavaScript:@"payResult('fail')" completionHandler:nil];
//                }
//            }
//        }];
//        if (responseCallback) responseCallback(@{@"isSuccess": @YES});
//    });
//}
////微信支付 Wap
//- (WVJBHandler)wxPayWap {
//
//    __weak typeof(self) weakSelf = self;
//    return (^(id data, WVJBResponseCallback responseCallback) {
//
//        NSString *paramStr = @"";
//        if ([data isKindOfClass:[NSString class]]) {
//
//            paramStr = (NSString *)data;
//        }
//        NSData *jsonData = [paramStr dataUsingEncoding:NSUTF8StringEncoding];
//        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:nil];
//
//        NSString *orderId = EncodeStringFromDic(dict, @"orderId");
//
//        NSString *payFlag = EncodeStringFromDic(dict, @"payFlag");
//
//        if ([@"1" isEqualToString:payFlag] && ![WXApi isWXAppInstalled]) { //一单一付微信没有安装,使用易付宝支付
//
//            SNSL_PAY_VIEWCONTROLLER(vc)
//            if (vc != nil) {
//
//                [weakSelf presentViewController:vc animated:NO completion:nil];
//                [vc startPaySDKWithVC:weakSelf orderId:orderId complete:^(BOOL isSuccess, NSString *errMsg, SNSLPayResultType actionType) {
//
//                    if (isSuccess && actionType == 0) { //取消支付
//
//                        [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"payResult('cancel')"];
//                    } else if (isSuccess && actionType == 1) { //支付成功
//
//                        [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"payResult('success')"];
//
//                    } else {
//
//                        [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"payResult('fail')"];
//                    }
//                }];
//            }
//        } else if (![WXApi isWXAppInstalled]) {
//
//            BBAlertView *installAlert = [[BBAlertView alloc] initWithTitle:@"" message:@"抱歉，您尚未安装微信，请安装最新版本微信客户端。" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles:nil];
//            [installAlert show];
//        } else {
//
//            SN_SNWeiXinManager(weiXinPayManager);
//            [weiXinPayManager requestOrder:orderId payFlag:payFlag  payCallback:^(NSInteger code, NSString *errorMsg, NSString *returnKey) {
//
//                if (code == WXSuccess) {
//
//                    [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"payResult('success')"];
//                } else {
//
//                    if (code == WXErrCodeUserCancel) {
//
//                        [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"payResult('cancel')"];
//                    } else {
//
//                        [weakSelf.webView stringByEvaluatingJavaScriptFromString:@"payResult('fail')"];
//                    }
//                }
//            }];
//        }
//        if (responseCallback) responseCallback(@{@"isSuccess": @YES});
//    });
//}

- (UINavigationController *)getNextTopNav:(UIViewController *)ctr
{
    if ([ctr isKindOfClass:[UINavigationController class]]) {
        return (UINavigationController *)ctr;
    }else{
        if (ctr.nextResponder!=nil) {
            return [self getNextTopNav:(UIViewController *)ctr.nextResponder];
        }else{
            return nil;
        }
    }
}
@end
