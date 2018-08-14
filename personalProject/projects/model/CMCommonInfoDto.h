//
//  CMCommonInfoDto.h
//  SuningEBuy
//
//  Created by mengran on 2018/5/28.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMCommonHeader.h"

@interface CMCommonInfoTagDto : NSObject
@property (nonatomic, copy) NSString        *linkUrl;
@property (nonatomic, copy) NSString        *tagName;
@property (nonatomic, copy) NSString        *tagText;
@property (nonatomic, copy) NSString        *picUrl;
@property (nonatomic, copy) NSString        *pid;
@property (nonatomic, copy) NSString        *tid;
@property (nonatomic, copy) NSString        *imgUrl;
@property (nonatomic, copy) NSString        *tagColor;
@property (nonatomic, copy) NSString        *waplinkUrl;
@property (nonatomic, copy) NSNumber        *tagSequence;
@property (nonatomic, copy) NSString        *tagDsc;

@end

@interface CMCommonInfoDto : NSObject
@property (nonatomic, copy) NSString        *modelSpecialTag;
@property (nonatomic, copy) NSString        *modelText;
@property (nonatomic, copy) NSArray         *tags;
@property (nonatomic, copy) NSString        *modelCode;
@property (nonatomic, copy) NSString        *modelLinkUrl;
/**
 模板背景色
 */
@property (nonatomic, copy) NSString        *bcolor;
/**
 是否展示 0：不展示 1：展示
 */
@property (nonatomic, copy) NSString        *isDisplay;




/**
 批量解析

 @param dicArray 里面是数据dic的array
 @return 解析后对应的里面是CMCommonInfoDto的array
 */
+(NSArray *)getCMCommonInfoDtoArrayWithDicArray:(NSArray *)dicArray;

/**
 单个解析

 @param dic 单个数据dic
 @return CMCommonInfoDto
 */
+(CMCommonInfoDto *)getZSQCommonInfoWithDic:(NSDictionary *)dic;

@end
