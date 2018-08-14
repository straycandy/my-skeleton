//
//  CMRootTabBarViewModel.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMRootTabBarViewModel.h"
#import "CMCommonHeader.h"
#import "CMTabBarDto.h"
//service
#import "CMPublickInfoService.h"
@interface CMRootTabBarViewModel()
@property (nonatomic, strong) CMPublickInfoService          *publickService;
@end
@implementation CMRootTabBarViewModel
/**
 本地没tabBar数据时，获取的默认items
 
 @return itemsArray
 */
+ (NSArray *)getInitialTabBarInfo{
    CMTabBarDto *zsqItems = [[CMTabBarDto alloc]init];
    zsqItems.localHighLightImageName = @"SNMKZSQ_BottomIcon_SNRush_HighLighted";
    zsqItems.localNormalImageName = @"SNMKZSQ_BottomIcon_SNRush_Normal";
    zsqItems.tabName = @"掌上抢";
    zsqItems.tabBarType = CMTabBarType_First;
    
    CMTabBarDto *finalRushItems = [[CMTabBarDto alloc]init];
    finalRushItems.localHighLightImageName = @"SNMKZSQ_BottomIcon_FinalRush_HighLighted";
    finalRushItems.localNormalImageName = @"SNMKZSQ_BottomIcon_FinalRush_Normal";
    finalRushItems.tabName = @"最后疯抢";
    finalRushItems.tabBarType = CMTabBarType_second;
    
    CMTabBarDto *rankingListItems = [[CMTabBarDto alloc]init];
    rankingListItems.localHighLightImageName = @"SNMKZSQ_BottomIcon_RankingList_HighLighted";
    rankingListItems.localNormalImageName = @"SNMKZSQ_BottomIcon_RankingList_Normal";
    rankingListItems.tabName = @"排行榜";
    rankingListItems.tabBarType = CMTabBarType_third;
    
    CMTabBarDto *brandRushItems = [[CMTabBarDto alloc]init];
    brandRushItems.localHighLightImageName = @"SNMKZSQ_BottomIcon_BrandRush_HighLighted";
    brandRushItems.localNormalImageName = @"SNMKZSQ_BottomIcon_BrandRush_Normal";
    brandRushItems.tabName = @"品牌抢";
    brandRushItems.tabBarType = CMTabBarType_fourth;
    
    NSArray *array = [NSArray arrayWithObjects:zsqItems,finalRushItems,rankingListItems,brandRushItems, nil];
    return array;
}
#pragma mark -
#pragma mark --------requestStart--------
-(void)requestToGetZSQCommonInfo{
    __weak typeof(self)weakSelf = self;
    [self.publickService requestToGetCMPublicInfoWithCompleteBlock:^(NSArray *cmsADArray, BOOL sucess, NSString *errorMessage) {
        if (sucess) {
            [weakSelf managePublicInfoWithItemsArray:cmsADArray];
        }else{
            
        }
    }];
}

#pragma mark -
#pragma mark --------requestManage--------
-(void)managePublicInfoWithItemsArray:(NSArray *)dataArray{
    
}
#pragma mark -
#pragma mark --------property--------
-(CMPublickInfoService *)publickService{
    if (!_publickService) {
        _publickService = [[CMPublickInfoService alloc]init];
    }
    return _publickService;
}
@end
