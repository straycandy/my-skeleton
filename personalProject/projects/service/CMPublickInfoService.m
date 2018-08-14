//
//  CMPublickInfoService.m
//  personalProject
//
//  Created by mengran on 2018/8/7.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMPublickInfoService.h"
#import "CMCommonInfoDto.h"
@interface CMPublickInfoService()
@property (nonatomic, copy) CMPublicInfoServiceCompleteBlock   completeBlock;
@end

@implementation CMPublickInfoService
-(void)requestToGetCMPublicInfoWithCompleteBlock:(CMPublicInfoServiceCompleteBlock )block{
    self.completeBlock = block;
    
    [self startRequest];
}

-(void)startRequest{
    //模拟接口
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        NSDictionary *response = [CMBaseService dictionaryWithJsonString:@"{\"api\":\"zsqccgg\",\"code\":\"1\",\"data\":[{\"elementShowNumber\":0,\"elementType\":2,\"modelFullCode\":\"zsq_dbtk\",\"modelFullId\":23281,\"modelId\":4840,\"pmodelFullId\":0,\"sequence\":12},{\"elementShowNumber\":0,\"elementType\":2,\"modelFullCode\":\"zsq_xfq\",\"modelFullId\":23282,\"modelId\":4840,\"pmodelFullId\":0,\"sequence\":12},{\"elementShowNumber\":0,\"elementType\":3,\"modelFullCode\":\"snqgicon\",\"modelFullId\":25243,\"modelId\":5464,\"pmodelFullId\":0,\"sequence\":15,\"tag\":[{\"bakUrl\":\"\",\"color\":\"\",\"elementDesc\":\"1\",\"elementName\":\"掌上抢\",\"elementType\":3,\"imgUrl\":\"/uimg/cms/img/153363230266484655.png\",\"linkType\":-3,\"linkUrl\":\"\",\"modelFullId\":25243,\"picUrl\":\"/uimg/cms/img/153363230874986216.png\",\"productSpecialFlag\":\"\",\"sequence\":1,\"templateFullId\":981015,\"trickPoint\":\"\"},{\"bakUrl\":\"\",\"color\":\"\",\"elementDesc\":\"2\",\"elementName\":\"最后疯抢\",\"elementType\":3,\"imgUrl\":\"/uimg/cms/img/153363240150983148.png\",\"linkType\":-3,\"linkUrl\":\"\",\"modelFullId\":25243,\"picUrl\":\"/uimg/cms/img/153363240719386353.png\",\"productSpecialFlag\":\"\",\"sequence\":2,\"templateFullId\":981015,\"trickPoint\":\"\"},{\"bakUrl\":\"\",\"color\":\"\",\"elementDesc\":\"3\",\"elementName\":\"排行榜\",\"elementType\":3,\"imgUrl\":\"/uimg/cms/img/153363257607975741.png\",\"linkType\":-3,\"linkUrl\":\"\",\"modelFullId\":25243,\"picUrl\":\"/uimg/cms/img/153363258084864575.png\",\"productSpecialFlag\":\"\",\"sequence\":3,\"templateFullId\":981015,\"trickPoint\":\"\"},{\"bakUrl\":\"\",\"color\":\"\",\"elementDesc\":\"4\",\"elementName\":\"品牌抢\",\"elementType\":3,\"imgUrl\":\"/uimg/cms/img/153363262064465360.png\",\"linkType\":-3,\"linkUrl\":\"\",\"modelFullId\":25243,\"picUrl\":\"/uimg/cms/img/153363262654889638.png\",\"productSpecialFlag\":\"\",\"sequence\":4,\"templateFullId\":981015,\"trickPoint\":\"\"}]},{\"elementShowNumber\":0,\"elementType\":2,\"modelFullCode\":\"icon_bj\",\"modelFullId\":25244,\"modelId\":5465,\"pmodelFullId\":0,\"sequence\":16},{\"elementShowNumber\":0,\"elementType\":3,\"modelFullCode\":\"snqgyt\",\"modelFullId\":25245,\"modelId\":5466,\"pmodelFullId\":0,\"sequence\":17},{\"modelFullCode\":\"pageCode\",\"pageId\":74084,\"pagename\":\"掌上抢场次广告\"}],\"msg\":\"\",\"v\":\"1\",\"version\":27}"];
        if (response) {
            NSArray *nmpsggDataArray = EncodeArrayFromDic(response, @"resultData");
            if (nmpsggDataArray.count > 0) {
                NSArray *encodedNmpsggDataArray = [CMCommonInfoDto getCMCommonInfoDtoArrayWithDicArray:nmpsggDataArray];
                if (self.completeBlock) {
                    self.completeBlock(encodedNmpsggDataArray,YES,nil);
                }
            }else
            {
                if (self.completeBlock) {
                    self.completeBlock(nil,NO,nil);
                }
            }
        }
    });
}
@end
