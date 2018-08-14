//
//  CMTabBarItem.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "CMTabBarItem.h"
#import "Masonry.h"
#import "CMUIImageView.h"

static NSString *const st_TabBarSelectColorStr = @"#ff2424";
static NSString *const st_TabBarNormalColorStr = @"#222222";
@interface CMTabBarItem ()
@property (nonatomic, strong) CMUIImageView                 *tabBarItemImage;
@property (nonatomic, strong) UILabel                       *tabBarItemNameLabel;

@property (nonatomic, strong) CMTabBarDto                   *currentDto;
@end
@implementation CMTabBarItem

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.tabBarItemImage];
        [self addSubview:self.tabBarItemNameLabel];
        [_tabBarItemImage mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self).offset(5);
            make.centerX.equalTo(self);
            make.size.mas_equalTo(CGSizeMake(54/2.0, 54/2.0));
        }];
        [_tabBarItemNameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.equalTo(self).offset(-2);
            make.centerX.equalTo(self);
        }];
    }
    return self;
}

-(void)updateWithDto:(CMTabBarDto *)tabBarDto{
    self.currentDto = tabBarDto;
    if (IsStrEmpty(self.currentDto.normalImageURLStr)) {
        self.tabBarItemImage.image = [UIImage imageNamed:self.currentDto.localNormalImageName];
    }else{
        self.tabBarItemImage.imageURL = self.currentDto.normalImageURLStr;
    }
    
    if (IsStrEmpty(self.currentDto.tabName)) {
        self.tabBarItemNameLabel.text = self.currentDto.localTabName;
    }else{
        self.tabBarItemNameLabel.text = self.currentDto.tabName;
    }
    self.tabBarItemNameLabel.text = self.currentDto.tabName;
}

-(void)itemClick{
    if (self.clickBlock) {
        self.clickBlock(self.tag);
    }
}

-(void)turnHighLight{
    if (IsStrEmpty(self.currentDto.highLightImageURLStr)) {
        self.tabBarItemImage.image = [UIImage imageNamed:self.currentDto.localHighLightImageName];
    }else{
        self.tabBarItemImage.imageURL = self.currentDto.highLightImageURLStr;
    }
    self.tabBarItemNameLabel.textColor = [UIColor colorWithHexString:st_TabBarSelectColorStr];
}
-(void)turnNormal{
    if (IsStrEmpty(self.currentDto.normalImageURLStr)) {
        self.tabBarItemImage.image = [UIImage imageNamed:self.currentDto.localNormalImageName];
    }else{
        self.tabBarItemImage.imageURL = self.currentDto.normalImageURLStr;;
    }
    self.tabBarItemNameLabel.textColor = [UIColor colorWithHexString:st_TabBarNormalColorStr];
}

- (CMUIImageView *)tabBarItemImage{
    if (!_tabBarItemImage) {
        _tabBarItemImage = [[CMUIImageView alloc]init];
        __weak typeof(self)weakSelf = self;
        _tabBarItemImage.clickBlock = ^{
            [weakSelf itemClick];
        };
    }
    return _tabBarItemImage;
}

- (UILabel *)tabBarItemNameLabel{
    if (!_tabBarItemNameLabel) {
        _tabBarItemNameLabel = [[UILabel alloc]init];
        _tabBarItemNameLabel.font = [UIFont systemFontOfSize:11];
    }
    return _tabBarItemNameLabel;
}

@end
