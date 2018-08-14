//
//  CMTabBar.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMTabBar.h"
#import "CMTabBarItem.h"
#import "Masonry.h"
#import "CMUIImageView.h"
#import "CMSharedManage.h"

@interface CMTabBar()
@property (nonatomic, strong) NSMutableArray    *tabBarItemsArray;
@property (nonatomic, strong) CMTabBarItem      *currentSelectItem;
@property (nonatomic, assign) NSInteger         currentIndex;
@end
@implementation CMTabBar
-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        _currentIndex = -1;
        _tabBarItemsArray = [[NSMutableArray alloc]init];
        [self layoutTabBarItemsWithFrame:frame];
    }
    return self;
}

/**
 布局
 */
-(void)layoutTabBarItemsWithFrame:(CGRect)frame{
    NSArray *tabBarDtoArray = [[CMSharedManage shared] getTabBarInfoArray];
    CGFloat width = frame.size.width;
    CGFloat height = frame.size.height;
    NSInteger count = tabBarDtoArray.count;
    CGFloat itemsWidth = width/count;
    CGFloat itemsHeight = height;
    for (NSInteger i = 0; i < count; i++) {
        CMTabBarItem *item = [[CMTabBarItem alloc]initWithFrame:CGRectMake(itemsWidth*i, 0, itemsWidth, itemsHeight)];
        __weak typeof(self)weakSelf = self;
        item.clickBlock = ^(NSInteger index) {
            [weakSelf clickIndex:index];
        };
        item.tag = i;
        CMTabBarDto *dto = [tabBarDtoArray objectAtIndex:i];
        [item updateWithDto:dto];
        [_tabBarItemsArray addObject:item];
        [self addSubview:item];
    }
}

-(void)clickIndex:(NSInteger )index{
    [self selectIndex:index];
    if (self.clickBlock) {
        self.clickBlock(index);
    }
}

-(void)selectIndex:(NSInteger)index{
    if (_currentIndex == index) {
        return;
    }
    _currentIndex = index;
    if (!IsStrEmpty([self.routeDic objectForKey:[NSNumber numberWithInteger:index]])) {
        return;
    }
    CMTabBarItem *item = [_tabBarItemsArray objectAtIndex:index];
    if (item) {
        [self.currentSelectItem turnNormal];
        self.currentSelectItem = item;
        [self.currentSelectItem turnHighLight];
    }
}

@end
