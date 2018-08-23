//
//  Preferences.h
//  SuningEBuy
//
//  Created by 刘坤 on 11-12-6.
//  Copyright (c) 2011年 Suning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
typedef enum
{
    kNetworkOff = 0,
    kNetworkWifi,
    kNetworkWLan,//如果不能获取到更详细的,将统一返回该值(iOS7以上才能获取到)
    kNetworkWLan2G,
    kNetworkWLan3G,
    kNetworkGPRS,
    kNetworkEdge,
    kNetworkWCDMA,
    kNetworkHSDPA,
    kNetworkHSUPA,
    kNetworkCDMA1x,
    kNetworkCDMAEVDORev0,
    kNetworkCDMAEVDORevA,
    kNetworkCDMAEVDORevB,
    kNetworkHRPD,
    kNetworkLTE,
}NetworkType;
@interface Preferences : NSObject
//屏幕分辨率
+ (NSString *)screenResolution;
//开机时间
+ (NSString *)bootTime;
//机器内存
+ (NSString *)machineMemory;
//可用空间
+ (NSString *)availableSpace;
/**获取IP来源*/
+ (NSString *)IPAddress;

//广告标示符
+ (NSString *)idfa;
//Vindor标示符
+ (NSString *)idfv;
/*系统版本*/
+ (NSString *)osVersion;
/*是否越狱*/
+ (BOOL)isJailBroken;
//当前设置语言
+ (NSString *)language;
//国家编码
+ (NSString *)countryCode;
//网络类型(返回无网络/wifi/2g/3g/4g)
+ (NSString *)networkType;
//网络类型(NetworkType类型)
+ (NetworkType)getNetworkType;
//运营商
+ (NSString *)Carrier;


+ (NSString *)systemTimeInfo;

//获取当前手机时间
+ (NSString *)currentSystemTime;

+ (NSString *)yearMonthDay;

//获取设备硬件名称
+ (NSString *)platform;

/**
 * 获取IMSI
 * 4.8.6版本添加
 @return IMSI
 */
+ (NSString *)getIMSI;


/**
 获取wifiSSID

 @return wifiSSID
 */
+ (NSString*)getWifiSSID;

@end
