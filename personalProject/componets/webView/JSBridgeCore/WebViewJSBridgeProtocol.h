//
//  WKWebViewJSBridgeProtocol.h
//  SuningEBuy
//
//  Created by SN_Christ on 2018/8/10.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^WVJBResponseCallback)(id responseData);
typedef void (^WVJBHandler)(id data, WVJBResponseCallback responseCallback);

@protocol WKWebViewJSBridgeProtocol <NSObject>

- (void)registerHandler:(NSString*)handlerName handler:(WVJBHandler)handler;
- (void)callHandler:(NSString*)handlerName;
- (void)callHandler:(NSString*)handlerName data:(id)data;
- (void)callHandler:(NSString*)handlerName data:(id)data responseCallback:(WVJBResponseCallback)responseCallback;
- (void)reset;

@end
