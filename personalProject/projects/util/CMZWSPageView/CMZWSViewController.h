//
//  CMZWSViewController.h
//  CMZWSlideViewController
//
//  Created by square on 09/07/2015.
//  Copyright (c) 2015 square. All rights reserved.
//

#import "CMZWSPagingView.h"
#import "CMZWSSectionBar.h"
#import "CMCommomViewController.h"

@interface CMZWSViewController : CMCommomViewController <CMZWSPagingViewDataSource, CMZWSPagingViewDelegate, CMZWSSectionBarDelegate>

@property (nonatomic, readonly) CMZWSPagingView *pagingView;
@property (nonatomic, readonly) CMZWSSectionBar *sectionBar;

@property (nonatomic, strong) UIView *lineView;

/**
 Whether to use 3D effects scrolling to next page. Defaults to `NO`.
 */
@property(nonatomic, assign) BOOL useTransform3DEffects;

@property(nonatomic, assign) CGFloat menuHeight;

@property(nonatomic, copy) NSArray *menuTitles;

// This method could be overridden in subclasses to prepare some data source, The default is a nop.
- (void)loadData;

// This method could be invoked to refresh all subViews.
- (void)refreshViews;

// This method could be overridden in subclasses to create custom content view in page
- (UIViewController *)contentViewForPage:(CMZWSPage *)page atIndex:(NSInteger)index;

- (void)sectionBar:(CMZWSSectionBar *)sectionBar didSelectAtInedx:(NSUInteger)index;

@end
