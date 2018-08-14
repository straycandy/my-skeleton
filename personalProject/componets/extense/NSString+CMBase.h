//
//  NSString+CMBase.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (CMBase)
/**
 去除str首位空格

 @return 返回去除首位空格的str
 */
- (NSString *)trim;
- (NSDictionary*)queryDictionaryUsingEncodingQR:(NSStringEncoding)encoding;
- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding;
@end
