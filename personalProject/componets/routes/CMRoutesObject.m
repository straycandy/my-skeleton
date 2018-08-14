//
//  CMRoutesObject.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMRoutesObject.h"
#import "CMCommonHeader.h"

#define kURLSchemeSuningEBuy                @"com.personalProject.CM://"

@implementation CMRoutesObject
- (instancetype)initWithURLString:(NSString *)url source:(CMRouteSource)source
{
    self = [super init];
    if (self) {
        self.originUrl = url;
        self.source = source;
        [self parseUrl:url];
    }
    return self;
}

- (void)parseUrl:(NSString *)url
{
    //url判空
    if (IsStrEmpty(url)) {
        return;
    }
    
    //"//"开头的url进行兼容
    if ([url hasPrefix:@"//"])
    {
        url = [NSString stringWithFormat:@"http:%@", url];
    }
    
    //去掉两端的空格
    url = [url trim];
    
    //检验是否是正常的url
    NSRegularExpression *regularEx = [NSRegularExpression regularExpressionWithPattern:@"^http(s)?://" options:NSRegularExpressionCaseInsensitive error:NULL];
    BOOL isHTTPUrl = [regularEx numberOfMatchesInString:url options:NSMatchingReportCompletion range:NSMakeRange(0, url.length)];
    
    NSRegularExpression *regularShceme = [NSRegularExpression regularExpressionWithPattern:@"^com.suning.SuningEBuy://" options:NSRegularExpressionCaseInsensitive error:NULL];
    
    //扫码登录匹配
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",@"^http(s)?://.*\?token=.*&acTag=.*"];
    
    if (isHTTPUrl)
    {
        //判断参数中是否包含adTypeCode， 不包含默认为未知Url:
        //去除多余的空格
        url = [url stringByReplacingOccurrencesOfString:@" " withString:@""];
        NSDictionary *paramDic;
        if (IsStrEmpty([[NSURL URLWithString:url] query]))
        {
            NSRange range = [url rangeOfString:@"?"];
            
            if (range.location == NSNotFound)
            {
                paramDic = nil;
                
            }else{
                
                url = [url substringFromIndex:range.location+1];
                
                paramDic = [url queryDictionaryUsingEncodingQR:NSUTF8StringEncoding];
            }
        }else{
            
            paramDic = [[[NSURL URLWithString:url] query] queryDictionaryUsingEncodingQR:NSUTF8StringEncoding];
        }
        
        self.allParams = paramDic;

        //adTypeCode可从"adTypeCode" 或 "utm_term" 中解析：
        NSString *adTypeCode = EncodeStringFromDic(paramDic, @"adTypeCode").trim;
        
        if (adTypeCode.length)
        {
            //获取adId
            NSString *adId = EncodeStringFromDic(paramDic, @"adId").trim;
            if (!adId.length) {
                adId = EncodeStringFromDic(paramDic, @"utm_content");
            }
            self.adTypeCode = adTypeCode;
            
            self.adId = adId;
            
            
            if ((self.source == CMRouteSourceScan || self.source == CMRouteSourceScanHistory)&&([adTypeCode intValue] == 1019||[adTypeCode intValue] == 1020||[adTypeCode intValue] == 1050))
            {
                NSString *mtsId = EncodeStringFromDic(paramDic, @"mtsid").trim;
                
                //1019，1020，1050老代码是写的mtsid,现在也支持adId
                NSString *adId = EncodeStringFromDic(paramDic, @"adId").trim;
                
                if (mtsId.length > 0)
                {
                    self.adId = mtsId;
                    
                }
                else if (adId.length > 0) {
                    self.adId = adId;
                }
                else {
                    self.adTypeCode = @"1002";
                    
                    NSRange range = [self.originUrl rangeOfString:@"?"];
                    
                    if (range.location == NSNotFound)
                    {
                        self.adTypeCode = kRouterUnrecognizedTypeCode;
                        
                        return;
                    }else{
                        
                        self.adId = [self.originUrl substringToIndex:range.location];
                    }
                }
            }
        }else if ([predicate evaluateWithObject:url]) {
            //扫码登录打开的
            self.adTypeCode = kRouterScanLoginRegistTypeCode;
        }
        else
        {
            self.adTypeCode = kRouterUnknownHttpUrlTypeCode;
        }
    }
    //通过OpenURL打开
    else if ([regularShceme numberOfMatchesInString:url options:NSMatchingReportCompletion range:NSMakeRange(0, url.length)])
    {
        self.source = CMRouteSourceOpenUrl;
        NSString *urlWithoutScheme = [url substringFromIndex:[kURLSchemeSuningEBuy length]];
        NSRange range = [urlWithoutScheme rangeOfString:@"?"];
        if (range.location == NSNotFound)
        {
            //do nothing
            self.adTypeCode = kRouterDoNothingTypeCode;
        }
        else
        {
            NSString *result = [urlWithoutScheme substringFromIndex:range.location+1];
            NSDictionary *paramDic = [result queryDictionaryUsingEncoding:NSUTF8StringEncoding];
            self.allParams = paramDic;
        }
    }
    else
    {
        //未识别
        self.adTypeCode = kRouterUnrecognizedTypeCode;
    }
}
@end
