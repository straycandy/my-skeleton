//
//  NSString+CMBase.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "NSString+CMBase.h"
#import "CMCommonHeader.h"

@implementation NSString (CMBase)
- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSDictionary*)queryDictionaryUsingEncodingQR:(NSStringEncoding)encoding
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding] trim];
            NSString* value = [[[kvPair objectAtIndex:1]
                                stringByReplacingPercentEscapesUsingEncoding:encoding] trim];
            if (value != nil && key != nil) {
                [pairs setObject:value forKey:key];
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[[kvPair objectAtIndex:0]
                              stringByReplacingPercentEscapesUsingEncoding:encoding] trim];
            NSString* value = [[[kvPair objectAtIndex:1]
                                stringByReplacingPercentEscapesUsingEncoding:encoding] trim];
            if (value != nil && key != nil) {
                [pairs setObject:value forKey:key];
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

- (NSString *)URLEncoding
{
    return [self stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSString *)URLEvalutionEncoding
{
    NSString * result = (__bridge_transfer NSString *)CFURLCreateStringByAddingPercentEscapes( kCFAllocatorDefault,
                                                                                              (CFStringRef)self,
                                                                                              NULL,
                                                                                              (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                              kCFStringEncodingUTF8 );
    return result;
    
}

/*
 * 取得一个串的 ‘separateString’之前部分
 * 2015/12/14
 * @xzoscar
 */
- (NSString *)prefixStringWithSeparate:(NSString *)separateString {
    if (!IsStrEmpty(separateString)) {
        NSRange range = [self rangeOfString:separateString];
        if (range.length > 0) {
            return [self substringToIndex:range.location];
        }
    }
    return self;
}

/*!
 @brief 单行字符串size计算,\
 Single line, no wrapping,Truncation based on the NSLineBreakMode.
 @return CGSzie()
 
 @since 5.0 version
 */
- (CGSize)sizeOfSingleLineWithFont:(UIFont *)font {
    UIFont *drawFont = font;
    if (nil == drawFont) {
        drawFont = [UIFont systemFontOfSize:14];
    }
    
    return ([self sizeWithAttributes:@{NSFontAttributeName:drawFont}]);
}

/*!
 @brief 推算字符串size
 
 @param font          default [UIFont systemFontOfSize:14] if nil
 @param size          限制尺寸
 @param lineBreakMode lineBreakMode description
 
 @return CGSzie()
 
 @since 5.0 version
 */
- (CGSize)sizeWithFont:(UIFont *)font limitedSize:(CGSize)size lineBreakMode:(NSLineBreakMode)lineBreakMode {
    CGSize retSize = CGSizeZero;
    NSDictionary *attr = @{NSFontAttributeName:(nil==font)?[UIFont systemFontOfSize:14]:font};
    CGRect  rect =[self boundingRectWithSize:size
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:attr
                                     context:nil];
    retSize = rect.size;
    return retSize;
}
@end
