//
//  CMFirstChildViewController.m
//  personalProject
//
//  Created by mengran on 2018/8/7.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMFirstChildViewController.h"
#import "Masonry.h"
#import "CMSharedManage.h"

@interface CMFirstChildViewController ()
@property (nonatomic, strong) UIButton              *testBtn;
@end

@implementation CMFirstChildViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
    self.tableView.backgroundColor = [UIColor colorWithRed:(arc4random()%255)/255.0 green:(arc4random()%255)/255.0 blue:(arc4random()%255)/255.0 alpha:1];
    [self.view addSubview:self.testBtn];
    [self customLayout];
    if (self.cateIndex == 0) {
        self.tableView.hidden = YES;
    }else{
        self.tableView.hidden = NO;
    }
}

-(void)customLayout{
    [self.testBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.view).offset(-Get375Width(40));
        make.size.mas_equalTo(CGSizeMake(Get375Width(100), Get375Width(40)));
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)testBtnClick:(UIButton *)btn{
    NSString *routeStr = @"0001";
    NSString *UrlStr = [NSString stringWithFormat:@"http://m.suning.com/?adTypeCode=%@&adId=",routeStr];
    routerToTargetURL(UrlStr);
}

-(UIButton *)testBtn{
    if (!_testBtn) {
        _testBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_testBtn setTitle:@"路由跳转root" forState:UIControlStateNormal];
        [_testBtn setTitleColor:[UIColor colorWithHexString:@"#222222"] forState:UIControlStateNormal];
        _testBtn.titleLabel.font = [UIFont systemFontOfSize:CMFontSize(14)];
        _testBtn.backgroundColor = [UIColor colorWithHexString:@"#ffffff"];
        [_testBtn addTarget:self action:@selector(testBtnClick:) forControlEvents:UIControlEventTouchUpInside];
        
    }
    return _testBtn;
}

@end
