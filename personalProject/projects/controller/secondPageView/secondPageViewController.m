//
//  secondPageViewController.m
//  personalProject
//
//  Created by mengran on 2018/8/6.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "secondPageViewController.h"
#import "CMRoutes.h"
#import "JLRoutes.h"
#import "Masonry.h"
#import "CMCommonHeader.h"
#import "CMSharedManage.h"
#import "NSString+CMBase.h"

@interface secondPageViewController ()
@property (nonatomic, strong) UILabel                   *titleLabel;

@property (nonatomic, strong) UIButton                  *testBtn;
@end

@implementation secondPageViewController
+(void)load{
    [JLRoutes addRoute:ksecondPageVC handler:^id(NSDictionary *parameters) {
        secondPageViewController *vc = [[secondPageViewController alloc] init];
        return vc;
    }];
}

- (instancetype)init{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
        [self.view addSubview:self.titleLabel];
        [self.view addSubview:self.testBtn];
        [self updateViewConstraints];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

-(void)updateViewConstraints{
    [super updateViewConstraints];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view.mas_top).offset(Get375Width(40));
    }];
    
    [self.testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(Get375Width(150), Get375Width(30)));
    }];
}

- (void)testBtnClick{
    self.hidesBottomBarWhenPushed = YES;
    NSString *routeStr = @"0003";
    NSString *http = @"https://www.suning.com";
    NSString *UrlStr = [NSString stringWithFormat:@"http://m.suning.com/?adTypeCode=%@&adId=4&urlStr=%@",routeStr,[http URLEvalutionEncoding]];
    routerToTargetURL(UrlStr);
    self.hidesBottomBarWhenPushed = NO;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(UILabel *)titleLabel{
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc]init];
        _titleLabel.text = @"通过路由跳转的页面";
        _titleLabel.textColor = [UIColor redColor];
        _titleLabel.font = [UIFont systemFontOfSize:CMFontSize(15)];
    }
    return _titleLabel;
}

-(UIButton *)testBtn{
    if (!_testBtn) {
        _testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_testBtn addTarget: self action:@selector(testBtnClick) forControlEvents:UIControlEventTouchUpInside];
        _testBtn.backgroundColor = [UIColor redColor];
        [_testBtn setTitle:@"跳转webView" forState:UIControlStateNormal];
        [_testBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _testBtn;
}

@end
