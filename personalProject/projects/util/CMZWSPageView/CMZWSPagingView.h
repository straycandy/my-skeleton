//
//  CMZWSPagingView.h
//

#import <UIKit/UIKit.h>

@interface CMZWSPage : UIView {
    NSUInteger _index;
}

@property(nonatomic, strong) UIView *contentView;

@end

@protocol CMZWSPagingViewDelegate;
@protocol CMZWSPagingViewDataSource;

@interface CMZWSPagingView : UIScrollView<UIScrollViewDelegate> {
    BOOL _scrollInfinitelyEnabled;

    NSUInteger _numberOfPages;

    NSMutableSet *_visiblePages;
    NSMutableSet *_recycledPages;

    CMZWSPage *_centerPage;

    __weak id<CMZWSPagingViewDelegate> _pagingDelegate;
    __weak id<CMZWSPagingViewDataSource> _pagingDataSource;

    __weak id _actualDelegate;
}

@property(nonatomic, assign) BOOL scrollInfinitelyEnabled;

@property(nonatomic, weak) id<CMZWSPagingViewDelegate> pagingDelegate;
@property(nonatomic, weak) id<CMZWSPagingViewDataSource> pagingDataSource;

@property(nonatomic, readonly) CMZWSPage *centerPage;
@property(nonatomic, readonly) NSSet *visiblePages;

// it will be pre-fetched content and cached for next page
@property(nonatomic, getter=isPreload) BOOL preload;

- (NSUInteger)indexOfPage:(CMZWSPage *)page;
- (NSUInteger)indexOfCenterPage;

- (CMZWSPage *)pageAtLocation:(CGPoint)location;

- (CGFloat)widthInSight:(CMZWSPage *)page;

- (float)floatIndex;
- (void)moveToPageAtFloatIndex:(float)index animated:(BOOL)animated;

- (CMZWSPage *)dequeueReusablePage;
- (void)reloadPages;

@end

@protocol CMZWSPagingViewDataSource

@required
- (NSUInteger)numberOfPagesInPagingView:(CMZWSPagingView *)pagingView;
- (CMZWSPage *)pagingView:(CMZWSPagingView *)pagingView pageForIndex:(NSUInteger)index;

@end

@protocol CMZWSPagingViewDelegate

- (void)pagingView:(CMZWSPagingView *)pagingView didRemovePage:(CMZWSPage *)page;
- (void)pagingView:(CMZWSPagingView *)pagingView willMoveToPage:(CMZWSPage *)page;
- (void)pagingView:(CMZWSPagingView *)pagingView didMoveToPage:(CMZWSPage *)page;
- (void)pagingViewLayoutChanged:(CMZWSPagingView *)pagingView;

@end
