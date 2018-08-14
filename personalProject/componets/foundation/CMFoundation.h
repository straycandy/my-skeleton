//
//  CMFoundation.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+CMBase.h"
extern NSString* EncodeStringFromDic(NSDictionary *dic, NSString *key);
extern NSNumber* EncodeNumberFromDic(NSDictionary *dic, NSString *key);
extern NSDictionary *EncodeDicFromDic(NSDictionary *dic, NSString *key);
extern NSArray      *EncodeArrayFromDic(NSDictionary *dic, NSString *key);
extern NSArray      *EncodeArrayFromDicUsingParseBlock(NSDictionary *dic, NSString *key, id(^parseBlock)(NSDictionary *innerDic));
@interface CMFoundation : NSObject

@end
