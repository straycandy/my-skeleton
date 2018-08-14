//
//  CMRefreshViewController.h
//  SuningEBuy
//
//  Created by mengran on 2018/5/29.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMCommomViewController.h"
#import "CMDIYNormalHeader.h"

typedef enum {
    CMRefreshSupportAll,    // 同时支持 下拉刷新、上拉加在更多
    CMRefreshSupportPull,   // 下拉刷新
    CMRefreshSupportPush,   // 上拉加在更多
    CMRefreshSupportNone    // 都不支持
}CMRefreshSupportType;

typedef enum {
    CMTriggerRefresh,
    CMTriggerLoadMore
}CMTriggerActionType;

@interface CMRefreshViewController : CMCommomViewController
@property (nonatomic, strong) NSMutableArray       *refDataArray; // default [NSMutableArray array]
@property (nonatomic, assign) UITableViewStyle     refTableStyle; // default UITableViewStylePlain
@property (nonatomic, assign) CMRefreshSupportType refreshSupportType;
/* 默认值
 * style = UITableViewStylePlain
 * separatorStyle = UITableViewCellSeparatorStyleNone
 * @xzoscar
 */
@property (nonatomic,strong) UITableView *tableView; // default not nil

/*
 * 子类中 务必实现的代理函数
 * @xzoscar
 */
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section;
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath;

@property (nonatomic, assign) NSInteger        currentPage;

@property (nonatomic, assign) NSInteger     pageSize;

@property (nonatomic, assign) NSInteger        totalPage;

@property (nonatomic, assign) NSInteger        totalCount;

@property (nonatomic, assign) BOOL            isLastPage;

@property (nonatomic, assign) BOOL            reloading;

@property (nonatomic, assign) BOOL          isLoading;

@property (nonatomic, assign) BOOL          isFromHead;

@property (nonatomic, assign) BOOL          isBackingToTop; //判断是否处在加载完成，恢复contentInset的状态

@property (nonatomic, strong) CMDIYNormalHeader *headerView;



-(id)initWithRefTableStyle:(UITableViewStyle)refreshStyle;

- (void)startRefreshLoading;

- (void)startMoreAnimation:(BOOL)animating;

- (void)dataSourceDidFinishLoadingNewData;

- (void)reloadTableViewDataSource;

- (BOOL)hasMore;

- (void)refreshData;

- (void)refreshDataComplete;

- (void)loadMoreData;

- (void)loadMoreDataComplete;
@end
