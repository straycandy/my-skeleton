//
//  Preferences.m
//  SuningEBuy
//
//  Created by 刘坤 on 11-12-6.
//  Copyright (c) 2011年 Suning. All rights reserved.
//

#import "Preferences.h"
#import "UIDeviceHardware.h"
#import "IPAddress.h"
#include <sys/param.h>
#include <sys/mount.h>
#include <netinet/in.h>
//#include <sys/socket.h>
#import <CoreTelephony/CTTelephonyNetworkInfo.h>
#import <CoreTelephony/CTCarrier.h>
#import <AdSupport/ASIdentifierManager.h>
#import "SystemInfo.h"
#include <ifaddrs.h>
#include <arpa/inet.h>
#include <sys/sysctl.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <SystemConfiguration/CaptiveNetwork.h>
#import "CMCommonHeader.h"

@implementation Preferences
//屏幕分辨率
+ (NSString *)screenResolution
{
    // Available in iOS 4.0 and later
    UIScreen *MainScreen = [UIScreen mainScreen];
    CGSize Size = [MainScreen bounds].size;
    CGFloat scale = [MainScreen scale];
    CGFloat screenWidth = Size.width * scale;
    CGFloat screenHeight = Size.height * scale;
    
    NSString *resolutionStr=[NSString stringWithFormat:@"%dx%d",(int)screenHeight,(int)screenWidth];
    
    return resolutionStr;
}

+ (NSString *)bootTime{
    NSString * proc_useTiem;
    //指定名字参数，按照顺序第一个元素指定本请求定向到内核的哪个子系统，第二个及其后元素依次细化指定该系统的某个部分。
    //CTL_KERN，KERN_PROC,KERN_PROC_ALL 正在运行的所有进程
    int mib[4] = {CTL_KERN, KERN_PROC, KERN_PROC_PID, 0};
    size_t miblen = 4;
    //值-结果参数：函数被调用时，size指向的值指定该缓冲区的大小；函数返回时，该值给出内核存放在该缓冲区中的数据量
    //如果这个缓冲不够大，函数就返回ENOMEM错误
    size_t size;
    //返回0，成功；返回-1，失败
    int st = sysctl(mib, miblen, NULL, &size, NULL, 0);
    
    struct kinfo_proc * process = NULL;
    struct kinfo_proc * newprocess = NULL;
    do
    {
        size += size / 10;
        newprocess = realloc(process, size);
        if (!newprocess)
        {
            if (process)
            {
                free(process);
                process = NULL;
            }
            return @"";
        }
        process = newprocess;
        st = sysctl(mib, miblen, process, &size, NULL, 0);
        
    }
    while (st == -1 && errno == ENOMEM);
    if (st == 0)
    {
        if (size % sizeof(struct kinfo_proc) == 0)
        {
            int nprocess =(int) (size / sizeof(struct kinfo_proc));
            if (nprocess)
            {
                for (int i = nprocess - 1; i >= 0; i--)
                {
                    @autoreleasepool{
                        
                        //the process duration
                        double t = process->kp_proc.p_un.__p_starttime.tv_sec;
                        double mmt=process->kp_proc.p_un.__p_starttime.tv_usec;
//                        NSString *str = @"%Y-%m-%d %H:%M:%S";
                        
                        proc_useTiem = [self getDateStrFromTimeStep:t];
                        proc_useTiem =[proc_useTiem stringByAppendingString:[NSString stringWithFormat:@".%d",(int)mmt/1000]];
                    }
                    
                }
                free(process);
                process = NULL;
                return proc_useTiem;
                
            }
        }
    }
    return nil;
}

+(NSString *)getDateStrFromTimeStep:(double)timestep{
    
    NSDate *timestepDate = [NSDate dateWithTimeIntervalSince1970:timestep];
    
    //1377044552->2013-08-21 08:22:32
    
    
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    
    //NSTimeZone* timeZone = [NSTimeZone timeZoneWithName:@"Asia/Shanghai"];
    
    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];
    
    [formatter setTimeZone:timeZone];
    
    
    
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    
    
    
    return [formatter stringFromDate:timestepDate];
    
}


+ (NSString *)machineMemory
{
    unsigned long long bytesValue=[NSProcessInfo processInfo].physicalMemory;
    
    NSString *memoryStr=[NSString stringWithFormat:@"%lldMB",bytesValue/1024/1024];
    
    return memoryStr;
}
//可用空间
+ (NSString *) availableSpace{
    NSDictionary *fattributes = [[NSFileManager defaultManager] attributesOfFileSystemForPath:NSHomeDirectory() error:nil];
    NSNumber *availableSpaceNum=[fattributes objectForKey:NSFileSystemFreeSize];
    
    NSString *availableSpaceStr= [NSString stringWithFormat:@"%.0fMB",([availableSpaceNum doubleValue])/1024/1024];

    return availableSpaceStr;
}


+ (NSString *)IPAddress{
    NSString *address = @"";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    
    success = getifaddrs(&interfaces);
    
    if (success == 0) {  // 0 表示获取成功
        
        temp_addr = interfaces;
        while (temp_addr != NULL) {
            NSLog(@"ifa_name===%@",[NSString stringWithUTF8String:temp_addr->ifa_name]);
            // Check if interface is en0 which is the wifi connection on the iPhone
            if ([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"] || [[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"pdp_ip0"])
            {
                //如果是IPV4地址，直接转化
                if (temp_addr->ifa_addr->sa_family == AF_INET){
                    // Get NSString from C String
                    address = [self formatIPV4Address:((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr];
                }
                
                //如果是IPV6地址
                else if (temp_addr->ifa_addr->sa_family == AF_INET6){
                    address = [self formatIPV6Address:((struct sockaddr_in6 *)temp_addr->ifa_addr)->sin6_addr];
                    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) break;
                }
            }
            
            temp_addr = temp_addr->ifa_next;
        }
    }
    
    freeifaddrs(interfaces);
    
    //以FE80开始的地址是单播地址
    if (address && ![address isEqualToString:@""] && ![address.uppercaseString hasPrefix:@"FE80"]) {
        return address;
    } else {
        return @"127.0.0.1";
    }

}



+(NSString *)formatIPV6Address:(struct in6_addr)ipv6Addr{
    NSString *address = nil;
    
    char dstStr[INET6_ADDRSTRLEN];
    char srcStr[INET6_ADDRSTRLEN];
    memcpy(srcStr, &ipv6Addr, sizeof(struct in6_addr));
    if(inet_ntop(AF_INET6, srcStr, dstStr, INET6_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}


+(NSString *)formatIPV4Address:(struct in_addr)ipv4Addr{
    NSString *address = nil;
    
    char dstStr[INET_ADDRSTRLEN];
    char srcStr[INET_ADDRSTRLEN];
    memcpy(srcStr, &ipv4Addr, sizeof(struct in_addr));
    if(inet_ntop(AF_INET, srcStr, dstStr, INET_ADDRSTRLEN) != NULL){
        address = [NSString stringWithUTF8String:dstStr];
    }
    
    return address;
}

//广告标示符
+ (NSString *)idfa{
    NSString *idfa = [[[ASIdentifierManager sharedManager] advertisingIdentifier] UUIDString];
    return idfa;
}
//Vindor标示符
+ (NSString *)idfv{
    NSString *idfv = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    return idfv;
}
/*系统版本*/
+ (NSString *)osVersion{
    return [SystemInfo osVersion];
}
//是否越狱
+ (BOOL)isJailBroken{
    return [SystemInfo isJailBroken];
}
+ (NSString *)language
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSArray *languages = [defaults objectForKey:@"AppleLanguages"];
    NSString *currentLanguage = [languages objectAtIndex:0];
    
    return currentLanguage;
}

+ (NSString *)countryCode{
    
    NSLocale *locale = [NSLocale currentLocale];
    NSString *country = [locale localeIdentifier];
    
    return country;
}

+ (NSString *)networkType{
    NSString *netStatusStr = @"无网络";
    NetworkType retVal = kNetworkOff;
    retVal = [Preferences getNetworkType];
    if (retVal == kNetworkWifi) {
        netStatusStr = @"wifi";
    }
    else if (retVal == kNetworkWLan2G) {
        netStatusStr = @"2G";
    }
    else if (retVal == kNetworkWLan3G) {
        netStatusStr = @"3G";
    }
    else if (retVal == kNetworkLTE) {
        netStatusStr = @"4G";
    }
    return netStatusStr;
}

+ (NSString *)Carrier{
    if([[SystemInfo platform]isEqualToString: @"iPhone3,2"] )
    {
        return @"中国联通";
    }
    if (NSClassFromString(@"CTTelephonyNetworkInfo"))
    {
        CTTelephonyNetworkInfo *netinfo = [[CTTelephonyNetworkInfo alloc] init];
        if(netinfo != nil)
        {
            CTCarrier *carrier = [netinfo subscriberCellularProvider];
            if (carrier != nil)
            {
                return [carrier carrierName];
            }
            else
            {
                return @"";
            }
        }
        else
        {
            return @"";
        }
    }
    return @"";
}

+ (NetworkType)getNetworkType
{
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress); //创建测试连接的引用
    SCNetworkReachabilityFlags flags;
    SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    if ((flags & kSCNetworkReachabilityFlagsReachable) == 0) {
        return kNetworkOff;
    }
    NetworkType retVal = kNetworkOff;
    if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
    {
        retVal = kNetworkWifi;
    }
    if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0)) {
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0) {
            retVal = kNetworkWifi;
        }
    }
    if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN) {
        if((flags & kSCNetworkReachabilityFlagsReachable) == kSCNetworkReachabilityFlagsReachable) {
            if ((flags & kSCNetworkReachabilityFlagsTransientConnection) == kSCNetworkReachabilityFlagsTransientConnection)
            {
                retVal = kNetworkWLan3G;
                if (IOS7_OR_LATER) {
                    NetworkType tmpRetVal = kNetworkWLan3G;
                    tmpRetVal = [Preferences getCellularDataNetworkType];
                    if (tmpRetVal == kNetworkLTE||
                        tmpRetVal == kNetworkHRPD) {
                        retVal = kNetworkLTE;
                    }
                    else if (tmpRetVal == kNetworkCDMAEVDORev0 ||
                             tmpRetVal == kNetworkCDMAEVDORevA ||
                             tmpRetVal == kNetworkCDMAEVDORevB ||
                             tmpRetVal == kNetworkWCDMA ||
                             tmpRetVal == kNetworkHSDPA ||
                             tmpRetVal == kNetworkHSUPA) {
                        retVal = kNetworkWLan3G;
                    }
                    else if (tmpRetVal == kNetworkGPRS||
                             tmpRetVal == kNetworkEdge||
                             tmpRetVal == kNetworkCDMA1x){
                        retVal = kNetworkWLan2G;
                    }
                }
                if((flags & kSCNetworkReachabilityFlagsConnectionRequired) == kSCNetworkReachabilityFlagsConnectionRequired) {
                    retVal = kNetworkWLan2G;
                }
            }
        }
    }
    return retVal;
}

+ (NetworkType)getCellularDataNetworkType
{
    if (IOS7_OR_LATER) {
        CTTelephonyNetworkInfo *telephonyInfo = [CTTelephonyNetworkInfo new];
        NSString* wlanNetwork = telephonyInfo.currentRadioAccessTechnology;
        if (wlanNetwork == nil)
            return kNetworkOff;
        if([wlanNetwork isEqualToString:CTRadioAccessTechnologyGPRS ]) {
            return kNetworkGPRS;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyEdge]) {
            return kNetworkEdge;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyWCDMA]) {
            return kNetworkWCDMA;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyHSDPA]) {
            return kNetworkHSDPA;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyHSUPA]) {
            return kNetworkHSUPA;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
            return kNetworkCDMA1x;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0]) {
            return kNetworkCDMAEVDORev0;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA]) {
            return kNetworkCDMAEVDORevA;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB]) {
            return kNetworkCDMAEVDORevB;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyeHRPD]) {
            return kNetworkHRPD;
        }
        else if([wlanNetwork isEqualToString:CTRadioAccessTechnologyLTE]) {
            return kNetworkLTE;
        }
    }
    return kNetworkWLan;
}


//获取系统当前时间
+ (NSString *)systemTimeInfo{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMddHHmmssSSS"];
    
    NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    TT_RELEASE_SAFELY(dateFormatter);
    
    return [currentDateString trim];

}

+ (NSString *)yearMonthDay{
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyyMMdd"];
    
    NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    TT_RELEASE_SAFELY(dateFormatter);
    
    return currentDateString;
    
}

+ (NSString *)currentSystemTime
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSString *currentDateString = [dateFormatter stringFromDate:[NSDate date]];
    
    TT_RELEASE_SAFELY(dateFormatter);
    
    return currentDateString;
}

+ (NSString *)platform
{
    UIDeviceHardware *currentHardware = [[UIDeviceHardware alloc] init];
    
    NSString *platf = [currentHardware platformString];
    
    TT_RELEASE_SAFELY(currentHardware);
    
    return platf;
}


//获取外网ip地址，博客原文http://blog.csdn.net/favormm/article/details/6858330

+ (NSString *)getIMSI {
    
    CTTelephonyNetworkInfo *info = [[CTTelephonyNetworkInfo alloc] init];
    
    CTCarrier *carrier = [info subscriberCellularProvider];
    
    NSString *mcc = [carrier mobileCountryCode];
    NSString *mnc = [carrier mobileNetworkCode];
    
    NSString *imsi = [NSString stringWithFormat:@"%@%@", mcc, mnc];
    
    return imsi;
}

+ (NSString*)getWifiSSID
{
    NSArray *ifs = CFBridgingRelease((__bridge CFTypeRef)((__bridge id)CNCopySupportedInterfaces()));
    id info = nil;
    for (NSString *ifnam in ifs) {
        info = CFBridgingRelease((__bridge CFTypeRef)((__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifnam)));
        if (info && [info count]) {
            NSString *ssid=[info objectForKey:(__bridge NSString *)kCNNetworkInfoKeySSID];
            //NSString *bssid=[info objectForKey:(__bridge NSString *)kCNNetworkInfoKeyBSSID];
            //NSLog(@"interfaceName:%@ ssid:%@ bssid:%@",ifnam,ssid,bssid);
            return ssid;
        }
    }
    return nil;
}
@end
