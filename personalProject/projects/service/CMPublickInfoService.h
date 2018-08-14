//
//  CMPublickInfoService.h
//  personalProject
//
//  Created by mengran on 2018/8/7.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMBaseService.h"

typedef void (^CMPublicInfoServiceCompleteBlock)(NSArray *cmsADArray,BOOL sucess,NSString *errorMessage);

/**
 公共配置接口
 */
@interface CMPublickInfoService : CMBaseService

-(void)requestToGetCMPublicInfoWithCompleteBlock:(CMPublicInfoServiceCompleteBlock )block;
@end
