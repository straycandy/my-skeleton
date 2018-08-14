//
//  CMRefreshViewController.m
//  SuningEBuy
//
//  Created by mengran on 2018/5/29.
//  Copyright © 2018年 苏宁易购. All rights reserved.
//

#import "CMRefreshViewController.h"
#import "CMDIYNormalHeader.h"
#import "CMUIImageView.h"
#import "CMCommonHeader.h"
#import "UIColor+CMBase.h"
#import "CMDIYNormalFooter.h"

@interface CMRefreshViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) CMDIYNormalFooter *footerView;
@end

@implementation CMRefreshViewController

-(id)init
{
    self = [super init];
    
    if (self) {
        self.refreshSupportType = CMRefreshSupportNone;
        self.refTableStyle = UITableViewStylePlain;
        self.currentPage = 1;
        self.pageSize  = 10;
        self.isLastPage  = YES;
    }
    return self;
}

-(id)initWithRefTableStyle:(UITableViewStyle)refreshStyle
{
    self = [super init];
    
    if (self) {
        self.refreshSupportType = CMRefreshSupportNone;
        self.refTableStyle = refreshStyle;
        self.currentPage = 1;
        self.pageSize  = 10;
        self.isLastPage  = YES;
    }
    return self;
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.refDataArray = [NSMutableArray array];
    [self.view addSubview:self.tableView];
    self.tableView.estimatedRowHeight = 0;
    self.tableView.estimatedSectionHeaderHeight = 0;
    self.tableView.estimatedSectionFooterHeight = 0;
    if (@available(iOS 11.0, *)) {
        [self.tableView setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    } else {
        // Fallback on earlier versions
    }
}

- (BOOL)isSupportRefreshPull {
    return ((_refreshSupportType==CMRefreshSupportAll
             ||_refreshSupportType==CMRefreshSupportPull))?YES:NO;
}

- (BOOL)isSupportPushLoadMore {
    return ((_refreshSupportType==CMRefreshSupportAll
             ||_refreshSupportType==CMRefreshSupportPush))?YES:NO;
}

- (void)setRefreshSupportType:(CMRefreshSupportType)refreshSupportType{
    _refreshSupportType = refreshSupportType;
    
    if([self isSupportRefreshPull]) {
        self.tableView.mj_header = self.headerView;
    }
    
    //    if ([self isSupportPushLoadMore]) {
    //        self.tableView.mj_footer = self.footerView;
    //    }
}

- (CMDIYNormalHeader *)headerView{
    if (_headerView == nil) {
        __weak typeof(self)weakSelf = self;
        _headerView = [CMDIYNormalHeader headerWithRefreshingBlock:^{
            [weakSelf refreshData];
        }];
        _headerView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
        
//        UIImageView *titleImgView = [[UIImageView alloc] initWithFrame:CGRectMake((kScreenWidth-499/2)/2, -133/2, 499/2, 133/2)];
//        titleImgView.image = [UIImage imageNamed:@""];
        
//        UIView *background = [[UIView alloc] initWithFrame:CGRectMake(0, -82, kScreenWidth, 82)];
//        background.backgroundColor = UIColorFromRGB(0xf2f2f2);
//        
//        [_headerView addSubview:background];
//        [_headerView addSubview:titleImgView];
        
    }
    return _headerView;
}

- (CMDIYNormalFooter *)footerView{
    if (_footerView == nil) {
        __weak typeof(self)weakSelf = self;
        _footerView = [CMDIYNormalFooter footerWithRefreshingBlock:^{
            [weakSelf loadMoreData];
        }];
    }
    return _footerView;
}

- (UITableView *)tableView {
    if (nil == _tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:_refTableStyle];
        _tableView.dataSource = self;
        _tableView.delegate   = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView setFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight-(64+44+50)-(iPhoneX?(24):0))];
        _tableView.backgroundColor = [UIColor colorWithHexString:@"f2f2f2"];
    }
    return _tableView;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    return nil;
}

- (void)startRefreshLoading{
    [self.tableView.mj_header beginRefreshing];
}

- (void)startMoreAnimation:(BOOL)animating{
    [self.tableView.mj_footer beginRefreshing];
}

- (void)reloadTableViewDataSource{
    _isFromHead = YES;
    [self refreshData];
}

- (BOOL)hasMore{
    return !self.isLastPage;
}

- (void)setIsLastPage:(BOOL)isLastPage{
    _isLastPage = isLastPage;
    if (isLastPage) {
        MJRefreshFooter *footer = [MJRefreshFooter footerWithRefreshingBlock:nil];
        footer.mj_h = 0;
        self.tableView.mj_footer = footer;
        //        self.tableView.mj_footer = nil;//[MJRefreshFooter footerWithRefreshingBlock:nil];
        [self.footerView noDataTextString];
    }
    else{
        self.tableView.mj_footer = self.footerView;
    }
}

/*子类实现*/
- (void)refreshData{
    self.isFromHead = YES;
    self.isLoading = YES;
}

/*子类实现*/
- (void)refreshDataComplete{
    self.isLoading = NO;
    [self.tableView.mj_header endRefreshing];
    //[self dataSourceDidFinishLoadingNewData];
}

/*子类实现*/
- (void)loadMoreData{
    self.isFromHead = NO;
    self.isLoading = YES;
}

/*子类实现*/
- (void)loadMoreDataComplete{
    self.isLoading = NO;
    [self.tableView.mj_footer endRefreshing];
}

- (void)doneLoadingTableViewData{
    //  model should call this when its done loading
    [self dataSourceDidFinishLoadingNewData];
}

-(void)dataSourceDidFinishLoadingNewData
{
    
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
