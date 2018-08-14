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

@interface secondPageViewController ()
@property (nonatomic, strong) UILabel                   *titleLabel;
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
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
}



-(void)updateViewConstraints{
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
    }];
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
        _titleLabel.font = [UIFont systemFontOfSize:CMFontSize(20)];
    }
    return _titleLabel;
}

@end
