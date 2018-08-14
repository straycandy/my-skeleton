//
//  CMRootTabBarViewController.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMRootTabBarViewController.h"
#import "CMRootTabBarViewModel.h"
#import "CMCommonHeader.h"
#import "CMSharedManage.h"
#import "JLRoutes.h"
#import "CMRoutes.h"
#import "SDWebImageManager.h"

//viewController
#import "CMFirstViewController.h"
#import "CMSecondViewController.h"
#import "CMThirdViewController.h"
#import "CMFourthViewController.h"
//view
#import "CMTabBar.h"
#import "CMUIImageView.h"
//model
#import "CMTabBarDto.h"

static NSString *const st_CMTab_First           = @"st_CMTab_First";
static NSString *const st_CMTab_Sec             = @"st_CMTab_Sec";
static NSString *const st_CMTab_third           = @"st_CMTab_third";
static NSString *const st_CMTab_fourth          = @"st_CMTab_fourth";

static NSString *const st_TabBarSelectColorStr = @"#ff2424";
static NSString *const st_TabBarNormalColorStr = @"#222222";

@interface CMRootTabBarViewController()
/**
 底部自定义tabBar
 */
@property (nonatomic, strong) CMTabBar                  *tabBarView;
/**
 储存各个VC的一个dic
 */
@property (nonatomic, strong) NSMutableDictionary       *viewDic;
/**
 viewDic的Key组成的array
 */
@property (nonatomic, strong) NSMutableArray            *viewKeyArray;
@property (nonatomic, strong) CMRootTabBarViewModel     *viewModel;
/**
 某个页面配置成页面路由跳转后，将其index设置成key，路由地址设置成value，加到这个dic里面
 */
@property (nonatomic, strong) NSMutableDictionary       *routeDic;

@end
@implementation CMRootTabBarViewController
+(void)load{
    [JLRoutes addRoute:kCMRootTabBarVC handler:^id(NSDictionary *parameters) {
        CMRootTabBarViewController *vc = [[CMRootTabBarViewController alloc] init];
//        vc.xxx = xxx;
        return vc;
    }];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.hidesBottomBarWhenPushed = YES;
        self.edgesForExtendedLayout = UIRectEdgeNone;
        // 强制隐藏系统导航栏
        self.navigationController.navigationBarHidden = YES;
        //设置自定义的tabBarView
//        [self.view addSubview:self.tabBarView];
//        self.tabBar.hidden = YES;
    }
    return self;
}
// 重写系统函数
- (void)setSelectedIndex:(NSUInteger)index {
    [super setSelectedIndex:index];
    [self.tabBarView selectIndex:index];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.viewDic = [[NSMutableDictionary alloc]init];
    self.routeDic = [[NSMutableDictionary alloc]init];
    self.viewKeyArray = [[NSMutableArray alloc]init];
    self.view.backgroundColor = [UIColor colorWithHexString:@"#fcfcfc"];
    
    [self customSetChildViewControllers];
    [self cStarToRequestCommonADInfo];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

#pragma mark -
#pragma mark --------requestStart--------
-(void)cStarToRequestCommonADInfo{
    [self.viewModel requestToGetZSQCommonInfo];
}

#pragma mark -
#pragma mark --------childViewController--------
/**
 设置子vc
 */
-(void)customSetChildViewControllers{
    NSArray *tabBarInfoArray = [[CMSharedManage shared] getTabBarInfoArray];
    NSMutableArray *viewControllers = [[NSMutableArray alloc]init];
    __weak typeof(self)weakSelf = self;
    [tabBarInfoArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger i, BOOL * _Nonnull stop) {
        CMTabBarDto *tabBarDto = [tabBarInfoArray objectAtIndex:i];
        CMCommomViewController *viewController;
        NSString *viewKey;
        switch (tabBarDto.tabBarType) {
            case CMTabBarType_First:
            {
                viewController = [[CMFirstViewController alloc]init];
                viewKey = st_CMTab_First;
            }
                break;
            case CMTabBarType_second:
            {
                viewController = [[CMSecondViewController alloc]init];
                viewKey = st_CMTab_Sec;
            }
                break;
            case CMTabBarType_third:
            {
                viewController = [[CMThirdViewController alloc]init];
                viewKey = st_CMTab_third;
            }
                break;
            case CMTabBarType_fourth:
            {
                viewController = [[CMFourthViewController alloc]init];
                viewKey = st_CMTab_fourth;
            }
                break;
            default:
                break;
        }
        
        [weakSelf.viewDic setObject:viewController forKey:viewKey];
        [weakSelf.viewKeyArray addObject:viewKey];
        viewController.currentViewDataDto = tabBarDto;
        
        UINavigationController *navi = [[UINavigationController alloc]initWithRootViewController:viewController];
        navi.hidesBottomBarWhenPushed = YES;
        navi.navigationBar.hidden = YES;
        [viewControllers addObject:navi];
        [self customSetViewController:navi withTabBarDto:tabBarDto];
        viewController.view.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
    }];
    self.tabBarView.routeDic = self.routeDic;
    self.viewControllers = [NSArray arrayWithArray:viewControllers];
}

#pragma mark -
#pragma mark --------custom--------
/**
 设置每个vc系统的tabBarItem
 */
-(void)customSetViewController:(UINavigationController *)VC withTabBarDto:(CMTabBarDto *)currentDto{
    NSArray *tempArray = [NSArray arrayWithObjects:currentDto.normalImageURLStr,currentDto.highLightImageURLStr,nil];
    CMLoadImages(tempArray, ^(NSArray *imagesArray) {
        UIImage *normalImage = [imagesArray safeObjectAtIndex:0]?:[UIImage imageNamed:currentDto.localNormalImageName];
        normalImage = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        UIImage *highLightImage = [imagesArray safeObjectAtIndex:1]?:[UIImage imageNamed:currentDto.localHighLightImageName];
        highLightImage = [highLightImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
        VC.tabBarItem = [[UITabBarItem alloc]initWithTitle:currentDto.tabName image:normalImage selectedImage:highLightImage];
        NSDictionary *normalColor = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:st_TabBarNormalColorStr] forKey:NSForegroundColorAttributeName];
        [VC.tabBarItem setTitleTextAttributes:normalColor forState:UIControlStateNormal];
        NSDictionary *selectColor = [NSDictionary dictionaryWithObject:[UIColor colorWithHexString:st_TabBarSelectColorStr] forKey:NSForegroundColorAttributeName];
        [VC.tabBarItem setTitleTextAttributes:selectColor forState:UIControlStateSelected];
    });
    
}

#pragma mark -
#pragma mark --------property init--------
-(CMTabBar *)tabBarView{
    if (!_tabBarView) {
        _tabBarView = [[CMTabBar alloc] initWithFrame:CGRectMake(0, kScreenHeight - 49 - Bottom_SN_iPhoneX_SPACE, kScreenWidth, 49)];
        __weak typeof(self)weakSelf = self;
        _tabBarView.clickBlock = ^(NSInteger index) {
            //如果配置成了页面路由，则不用选中那个index，直接路由跳转
            NSString *urlStr = [weakSelf.routeDic objectForKey:[NSNumber numberWithInteger:index]];
            if (!IsStrEmpty(urlStr)) {
                routerToTargetURL(urlStr);
            }else{
                weakSelf.selectedIndex = index;
            }
        };
        _tabBarView.delegate = self;
        _tabBarView.backgroundColor = [UIColor whiteColor];
        [_tabBarView selectIndex:0];
    }
    return _tabBarView;
}
@end
