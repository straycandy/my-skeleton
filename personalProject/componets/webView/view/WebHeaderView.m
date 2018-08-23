//
//  WebHeaderView.m
//  SuningEBuy
//
//  Created by sn－wahaha on 15/9/7.
//  Copyright (c) 2015年 Suning. All rights reserved.
//

#import "WebHeaderView.h"
#import "CMUIImageView.h"
#import "UIView+Additions.h"
#import "CMCommonHeader.h"
#import "UIControl+TapScope.h"
#import "UIImage-Extensions.h"

@interface WebHeaderView()

@property (nonatomic,strong)CMUIImageView *navigationImg;

@property (nonatomic,strong)UILabel *title;

@property (nonatomic,strong)UIButton *closeBtn;

@property (nonatomic,strong)CMUIImageView *navigationBackImg;

//头部右侧购物车按钮
@property(nonatomic,strong)UIButton *rightItemBtn;

@property (nonatomic,strong)UIButton *backBtn;

@property (nonatomic,strong)UIButton *moreBtn;

@end

@implementation WebHeaderView

-(CMUIImageView *)navigationImg{
    if (!_navigationImg) {
        _navigationImg = [[CMUIImageView alloc] initWithFrame:CGRectMake(0, 0+Top_SN_iPhoneX_SPACE, self.width, self.height)];
        [self addSubview:_navigationImg];
    }
    return _navigationImg;
}

-(CMUIImageView *)navigationBackImg{
    if (!_navigationBackImg) {
        _navigationBackImg = [[CMUIImageView alloc] initWithFrame:CGRectMake(0, 0+Top_SN_iPhoneX_SPACE, self.width, self.height)];
        [self addSubview:_navigationBackImg];
    }
    return _navigationBackImg;
}

-(UIButton *)backBtn{
    if (!_backBtn) {
        _backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _backBtn.frame = CGRectMake(15, 20+(44-20.5)/2+Top_SN_iPhoneX_SPACE, 20, 20);
        _backBtn.backgroundColor = [UIColor clearColor];
        _backBtn.hitEdgeInsets = UIEdgeInsetsMake(-10, -15, -10, -15);
        [_backBtn setImage:[UIImage streWidthImageNamed:@"nav_back_normal.png"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(gotoBack) forControlEvents:UIControlEventTouchUpInside];
        _backBtn.accessibilityLabel = @"返回";
        [self addSubview:_backBtn];
    }
    return _backBtn;
}

-(void)gotoBack {
    if (_onBackBlock) {
        _onBackBlock();
    }
}

-(void)moreClick {
    if (nil != _onMoreBlock) {
        _onMoreBlock();
    }
}

-(void)closeClick {
    if (nil != _onCloseBlock) {
        _onCloseBlock();
    }
}

-(void)rightItemBtnClick{
    if (nil != _onRightItemBlock) {
        _onRightItemBlock();
    }
}

- (UIButton *)moreBtn
{
    if (!_moreBtn)
    {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        _moreBtn.frame = CGRectMake(size.width-44, 20+Top_SN_iPhoneX_SPACE, 44, 44);
        [_moreBtn setBackgroundColor:[UIColor clearColor]];
        [_moreBtn setImage:[UIImage imageNamed:@"more_big_icon.png"]
                             forState:UIControlStateNormal];
        [_moreBtn addTarget:self action:@selector(moreClick) forControlEvents:UIControlEventTouchUpInside];
        _moreBtn.accessibilityLabel = @"更多";
        [self addSubview:_moreBtn];
    }
    return _moreBtn;
}

-(UIButton *)rightItemBtn{
    if (!_rightItemBtn) {
        _rightItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-74, 20+Top_SN_iPhoneX_SPACE, 30, 44)];
//        _rightItemBtn = [[UIButton alloc] initWithFrame:CGRectMake(kScreenWidth-88, 20+Top_SN_iPhoneX_SPACE, 44, 44)];
        [_rightItemBtn setImage:[UIImage imageNamed:@"top_moreview_web_shopcart"] forState:UIControlStateNormal];
        [_rightItemBtn addTarget:self action:@selector(rightItemBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_rightItemBtn];
    }
    return _rightItemBtn;
}

- (UIButton *)closeBtn
{
    if (!_closeBtn)
    {
        _closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
         _closeBtn.frame = CGRectMake(self.backBtn.right +20, 20+Top_SN_iPhoneX_SPACE, 44, 44);
        
        [_closeBtn setBackgroundColor:[UIColor clearColor]];
//        [_closeBtn setImage:[UIImage imageNamed:@"cancel_big_icon"] forState:UIControlStateNormal];
        [_closeBtn setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _closeBtn.tintColor = [UIColor colorWithRGBHex:0x353d44];
        [_closeBtn addTarget:self action:@selector(closeClick) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_closeBtn];

    }
    return _closeBtn;
}



-(UILabel *)title{
    if (!_title) {
        CGSize size = [UIScreen mainScreen].bounds.size;
        _title = [[UILabel alloc] initWithFrame:CGRectMake(self.closeBtn.right+5, 20+Top_SN_iPhoneX_SPACE, size.width, 44)];
        _title.frame = CGRectMake(self.closeBtn.right +10, 20+Top_SN_iPhoneX_SPACE, size.width-(self.closeBtn.right+10)*2, 44);
        _title.textAlignment = NSTextAlignmentCenter;
        _title.font = [UIFont systemFontOfSize:CMFontSize(17)];
        _title.textColor = [UIColor colorWithRGBHex:0x444444];
        _title.backgroundColor = [UIColor clearColor];
        [self addSubview:_title];
        
        UIView *bottomLine = [[UIView alloc] init];
        bottomLine.frame = CGRectMake(0, 63.5+Top_SN_iPhoneX_SPACE, size.width, 0.5);
        bottomLine.backgroundColor = [UIColor colorWithRGBHex:0xdcdcdc];
        [self addSubview:bottomLine];
    }
    return _title;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor colorWithRGBHex:0xf8f8f8];
        
        self.backBtn.hidden = NO;
        self.closeBtn.hidden = YES;
        self.moreBtn.hidden = YES;
        self.rightItemBtn.hidden = YES;
    
    }
    return self;
}

/**
 *  设置图片
 *
 *  @param imgurl 图片地址
 */
-(void)setHeaderImg:(NSString *)imgurl{
    self.navigationImg.imageURL = imgurl;
    self.title.hidden = YES;
    self.navigationImg.hidden = NO;
    self.navigationImg.frame = self.title.frame;
    [self bringSubviewToFront:self.backBtn];
    [self bringSubviewToFront:self.closeBtn];
    [self bringSubviewToFront:self.moreBtn];
    [self bringSubviewToFront:self.rightItemBtn];
}

/**
 *  设置title和字体
 *
 *  @param title title
 *  @param font  字体
 */
-(void)setHeaderTitle:(NSString *)title font:(UIFont *)font{
    self.title.text = title;
    self.title.font = font;
    self.title.hidden = NO;
}

/**
 *  设置背景图片、title和字体颜色
 *
 *  @param imgurl 图片地址
 *  @param title  title
 *  @param font   字体颜色
 */
-(void)setHeaderBackImg:(NSString *)imgurl title:(NSString *)title font:(UIFont *)font{
    self.title.hidden = YES;
    if (!IsStrEmpty(title)) {
        self.title.hidden = NO;
        self.title.text = title;
        self.title.font = font;
    }
    self.navigationBackImg.hidden = YES;
    self.navigationBackImg.frame = self.frame;
    if (!IsStrEmpty(imgurl)) {
        self.navigationBackImg.hidden = NO;
        self.navigationBackImg.imageURL = imgurl;
    }
    if (!self.title.hidden) {
        [self bringSubviewToFront:self.title];
    }
    [self bringSubviewToFront:self.backBtn];
    [self bringSubviewToFront:self.closeBtn];
    [self bringSubviewToFront:self.moreBtn];
    [self bringSubviewToFront:self.rightItemBtn];
}

/**
 *  隐藏返回按钮
 *
 *  @param ishiden 是否隐藏
 */
-(void)hideCloseBtn:(BOOL) ishiden{
    self.closeBtn.hidden = ishiden;
}

/**
 *  设置字体颜色
 *
 *  @param color 颜色
 */
-(void)setHeaderTitleColor:(UIColor *)color{
    [self.title setTextColor:color];
}

/**
 *  设置返回按钮隐藏
 *
 *  @param hiden 是否隐藏
 */
-(void)setBackBtnHiden:(BOOL)hiden{
    self.backBtn.hidden = hiden;
}

/**
 *  设置更多按钮隐藏
 *
 *  @param hiden 是否隐藏
 */
-(void)setMoreBtnHiden:(BOOL)hiden{
    self.moreBtn.hidden = hiden;
}

/**
 设置购物车按钮隐藏
 
 @param hiden 是否隐藏
 */
-(void)setRightItemHiden:(BOOL)hiden {
    self.rightItemBtn.hidden = hiden;
}

-(void)setRightItemType:(WebHeaderViewRightItemType)aRightItemType {
    _rightItemType = aRightItemType;
    
    if (_rightItemType == WebHeaderViewRightItemTypeShare) {
        _rightItemBtn.contentEdgeInsets = UIEdgeInsetsMake(6, 6, 6, 6);
        [_rightItemBtn setImage:[UIImage imageNamed:@"top_moreview_web_share"] forState:UIControlStateNormal];
    } else {
        _rightItemBtn.contentEdgeInsets = UIEdgeInsetsMake(0, 0, 0, 0);
        [_rightItemBtn setImage:[UIImage imageNamed:@"top_moreview_web_shopcart"] forState:UIControlStateNormal];
    }
}

/*
 * 设置导航属性
 * 2016/4/13
 * @Marco start
 */
-(void)setBackBtnImageWithNormal:(NSString *)normal highlight:(NSString *)highlight
{
    
    [self.backBtn setImage:[UIImage imageNamed:normal]
                  forState:UIControlStateNormal];
    [self.backBtn setImage:[UIImage imageNamed:highlight]
                  forState:UIControlStateHighlighted];
}

/**
 *  设置返回按钮frame
 *
 *  @param btnWidth 按钮宽度
 */
-(void)setBackBtnFrame:(CGFloat)btnWidth
{
    
    [self.backBtn setFrame:CGRectMake(15, 20+(44-btnWidth)/2,btnWidth,btnWidth)];
}

/**
 *  设置更多按钮
 *
 *  @param normal    normal
 *  @param highlight 高亮
 */
-(void)setMoreBtnImageWithNormal:(NSString *)normal highlight:(NSString *)highlight
{
    [self.moreBtn setImage:[UIImage imageNamed:normal]
                  forState:UIControlStateNormal];
    [self.moreBtn setImage:[UIImage imageNamed:highlight]
                  forState:UIControlStateHighlighted];
}
/*
 * 恢复默认设置
 * 2016/4/13
 * @Marco end
 */

/*
 * 恢复默认设置
 * 2015/12/14
 * @xzoscar
 */
- (void)reset {
    if (nil != _title) {
        _title.font = [UIFont systemFontOfSize:19];
        _title.textColor = [UIColor colorWithRGBHex:0x353d44];
    }
    
    if (nil != _navigationImg) {
        _navigationImg.image = nil;
    }
    
    if (nil != _navigationBackImg) {
        _navigationBackImg.image = nil;
    }
}


/**
 设置而关闭按钮颜色

 @param color 颜色
 */
- (void)setCloseBtnColor:(UIColor *)color {
    [self.closeBtn setTitleColor:color forState:UIControlStateNormal];
}

@end
