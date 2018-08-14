//
//  CMBaseService.h
//  personalProject
//
//  Created by mengran on 2018/8/7.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSString+CMBase.h"
#import "CMFoundation.h"

@interface CMBaseService : NSObject
/**
 测试方法，将str转成dic，方便测试

 @param jsonString 需要转换的json字符串
 @return 返回dic
 */
+ (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString;
@end
