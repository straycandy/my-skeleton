//
//  CMZWSViewController.m
//  CMZWSlideViewController
//

#import "CMZWSViewController.h"
#import "UIView+Additions.h"
@interface CMZWSViewController ()

@end

@implementation CMZWSViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initSelf];
    }
    return self;
}

- (void)initSelf
{
    self.useTransform3DEffects = NO;
    
    if (!_sectionBar) {
        _sectionBar = [[CMZWSSectionBar alloc] init];
        _sectionBar.barDelegate = self;
        _sectionBar.menuInsets   = UIEdgeInsetsMake(0, 15, 0, 15);
        _sectionBar.backgroundColor = [UIColor whiteColor];
    }
    
    if (!_pagingView) {
        _pagingView = [[CMZWSPagingView alloc] init];
        _pagingView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        _pagingView.pagingDataSource = self;
        _pagingView.pagingDelegate = self;
    }
    
    if (!_lineView) {
        _lineView = [[UIView alloc] init];
        _lineView.backgroundColor = [UIColor colorWithHexString:@"#f2f2f2"];
    }
    [self.view addSubview:_lineView];

}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    [self loadData];
    
    [self refreshViews];
}

- (CGFloat)menuHeight
{
    if (!_menuHeight) {
        return 44.0f;
    }
    return _menuHeight;
}

#pragma mark - Public methods

- (void)loadData
{
    // do nothing
}

- (void)refreshViews
{
    _sectionBar.frame = CGRectMake(self.view.bounds.origin.x, (64+(iPhoneX?24
                                                                   :0)), self.view.bounds.size.width, self.menuHeight-1);
    [self.view addSubview:_sectionBar];
 
    _lineView.frame = CGRectMake(0, _sectionBar.bottom, kScreenWidth, 1);
    
    _pagingView.frame = CGRectMake(self.view.bounds.origin.x, _lineView.bottom, self.view.bounds.size.width, self.view.bounds.size.height - self.sectionBar.bottom);
    [self.view insertSubview:_pagingView belowSubview:_sectionBar];
    
    [_pagingView reloadPages];
    _sectionBar.titles = self.menuTitles;
}

#pragma mark - Override Methods

- (UIViewController *)contentViewForPage:(CMZWSPage *)page atIndex:(NSInteger)index
{
    // subclass could override
    return nil;
}

#pragma mark - CMZWSPagingViewDataSource

- (NSUInteger)numberOfPagesInPagingView:(CMZWSPagingView *)pagingView {
    return [[self menuTitles] count];
}

- (CMZWSPage *)pagingView:(CMZWSPagingView *)pagingView pageForIndex:(NSUInteger)index {
    CMZWSPage *page = [pagingView dequeueReusablePage];
    if (!page) {
        page = [CMZWSPage new];
    }
    
    return page;
}

#pragma mark - CMZWSPagingViewDelegate

- (void)pagingView:(CMZWSPagingView *)pagingView didRemovePage:(CMZWSPage *)page {
    if (pagingView.centerPage != page) {
        return;
    }
}

- (void)pagingView:(CMZWSPagingView *)pagingView willMoveToPage:(CMZWSPage *)page {
    page.contentView = [[self contentViewForPage:(CMZWSPage *)page atIndex:[pagingView indexOfPage:page]] view];
}

- (void)pagingView:(CMZWSPagingView *)pagingView didMoveToPage:(CMZWSPage *)page {
}

- (void)pagingViewLayoutChanged:(CMZWSPagingView *)pagingView {
    if (self.useTransform3DEffects) {
        [self transform3DEffects:pagingView];
    }
    
    [_sectionBar moveToMenuAtFloatIndex:pagingView.floatIndex animated:YES];
}

#pragma mark - CMZWSSectionBarDelegate

- (void)sectionBar:(CMZWSSectionBar *)sectionBar didSelectAtInedx:(NSUInteger)index
{
    [_pagingView moveToPageAtFloatIndex:index animated:YES];
}

- (void)didCreateItemView:(UIView *)itemView
{
    
}

#pragma mark - Private Methods

- (void)transform3DEffects:(CMZWSPagingView *)pagingView
{
    CGFloat ratio = .0, scale;
    for (CMZWSPage *page in pagingView.visiblePages) {
        ratio = [pagingView widthInSight:page] / CGRectGetWidth(page.frame);
        scale = .9 + ratio * .1;
        
        CATransform3D t = CATransform3DMakeScale(scale, scale, scale);
        
        page.layer.transform = t;
    }
}


@end
