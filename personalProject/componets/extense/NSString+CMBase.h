//
//  NSString+CMBase.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (CMBase)
/**
 去除str首位空格

 @return 返回去除首位空格的str
 */
- (NSString *)trim;
- (NSDictionary*)queryDictionaryUsingEncodingQR:(NSStringEncoding)encoding;
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;
- (NSString *)URLEncoding;
- (NSString *)URLEvalutionEncoding;
/*
 * 取得一个串的 ‘separateString’之前部分
 * 2015/12/14
 * @xzoscar
 */
- (NSString *)prefixStringWithSeparate:(NSString *)separateString;

/*!
 @brief 单行字符串size计算,\ Single line, no wrapping
 */
- (CGSize)sizeOfSingleLineWithFont:(UIFont *)font;

/*!
 @brief 推算字符串size
 */
- (CGSize)sizeWithFont:(UIFont *)font
           limitedSize:(CGSize)size
         lineBreakMode:(NSLineBreakMode)lineBreakMode;
@end
