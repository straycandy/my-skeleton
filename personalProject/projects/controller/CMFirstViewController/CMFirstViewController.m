//
//  CMFirstViewController.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMFirstViewController.h"
#import "CMFirstChildViewController.h"

@interface CMFirstViewController ()
@property (nonatomic, strong) NSMutableDictionary          *viewDic;
@end

@implementation CMFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.menuTitles = [NSArray arrayWithObjects:@"121",@"呵呵",@"很6",@"发生减肥啦",@"45613", nil];
    self.pagingView.preload = YES;
    [self refreshViews];
}

- (UIViewController *)contentViewForPage:(CMZWSPage *)page atIndex:(NSInteger)index
{
    NSString *indexStr = [NSString stringWithFormat:@"%zd", index];
    if (![self.viewDic objectForKey:indexStr]) {
        CMFirstChildViewController *viewController = [[CMFirstChildViewController alloc]init];
        viewController.cateIndex = index;
        [self addChildViewController:viewController];
        [self.viewDic setObject:viewController forKey:indexStr];
        return viewController;
    }else{
        return [self.viewDic objectForKey:indexStr];
    }
}


- (void)pagingView:(CMZWSPagingView *)pagingView didMoveToPage:(CMZWSPage *)page
{
    [super pagingView:pagingView didMoveToPage:page];
}

- (void)sectionBar:(CMZWSSectionBar *)sectionBar didSelectAtInedx:(NSUInteger)index
{
    [super sectionBar:sectionBar didSelectAtInedx:index];
}



/**
 *  viewDic 储存view的字典
 *
 *  @return NSMutableDictionary
 */
-(NSMutableDictionary *)viewDic
{
    if (!_viewDic) {
        _viewDic = [[NSMutableDictionary alloc] init];
    }
    return _viewDic;
}

@end
