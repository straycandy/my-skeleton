//
//  CMCommonInfoDto.m
//  SuningEBuy
//
//  Created by mengran on 2018/5/28.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import "CMCommonInfoDto.h"
#import "NSObject+YYModel.h"

@implementation CMCommonInfoTagDto

@end

@implementation CMCommonInfoDto

+(NSArray *)getCMCommonInfoDtoArrayWithDicArray:(NSArray *)dicArray{
    NSMutableArray *tempArray = [[NSMutableArray alloc]init];
    for (NSDictionary *tempDic in dicArray) {
        CMCommonInfoDto *dto = [CMCommonInfoDto getZSQCommonInfoWithDic:tempDic];
        [tempArray addObject:dto];
    }
    return [NSArray arrayWithArray:tempArray];
}

+(CMCommonInfoDto *)getZSQCommonInfoWithDic:(NSDictionary *)dic{
    CMCommonInfoDto *dto = [CMCommonInfoDto modelWithJSON:dic];
    if (!dto) {
        return [CMCommonInfoDto new];
    }
    return dto;
}

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"tags" : [CMCommonInfoTagDto class]};
}
@end
