//
//  WebHeaderView.h
//  SuningEBuy
//
//  Created by sn－wahaha on 15/9/7.
//  Copyright (c) 2015年 Suning. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger) {
    WebHeaderViewRightItemTypeShopCart = 0,   //购物车
    WebHeaderViewRightItemTypeShare           //分享
} WebHeaderViewRightItemType;

@interface WebHeaderView : UIView

//返回block
@property (nonatomic,copy) dispatch_block_t onBackBlock;

//更多block
@property (nonatomic,copy) dispatch_block_t onMoreBlock;

//关闭block
@property (nonatomic,copy) dispatch_block_t onCloseBlock;

//关闭block
@property (nonatomic,copy) dispatch_block_t onRightItemBlock;

//owner
@property (nonatomic,weak) id ower;

//导航栏右侧更多左边按钮类型，购物车和分享
@property (nonatomic,assign) WebHeaderViewRightItemType rightItemType;

/**
 *  设置title和字体
 *
 *  @param title title
 *  @param font  字体
 */
-(void)setHeaderTitle:(NSString *)title font:(UIFont *)font;

/**
 *  设置图片
 *
 *  @param imgurl 图片地址
 */
-(void)setHeaderImg:(NSString *)imgurl;

/**
 *  隐藏返回按钮
 *
 *  @param ishiden 是否隐藏
 */
-(void)hideCloseBtn:(BOOL) ishiden;

/**
 *  设置字体颜色
 *
 *  @param color 颜色
 */
-(void)setHeaderTitleColor:(UIColor *)color;

/**
 *  设置背景图片、title和字体颜色
 *
 *  @param imgurl 图片地址
 *  @param title  title
 *  @param font   字体颜色
 */
-(void)setHeaderBackImg:(NSString *)imgurl title:(NSString *)title font:(UIFont *)font;

/**
 *  设置返回按钮隐藏
 *
 *  @param hiden 是否隐藏
 */
-(void)setBackBtnHiden:(BOOL)hiden;

/**
 *  设置更多按钮隐藏
 *
 *  @param hiden 是否隐藏
 */
-(void)setMoreBtnHiden:(BOOL)hiden;

/**
 设置右侧更多左边按钮隐藏
 
 @param hiden 是否隐藏
 */
-(void)setRightItemHiden:(BOOL)hiden;
    
/*
 * 设置导航属性
 * 2016/4/13
 * @Marco start
 */
-(void)setBackBtnImageWithNormal:(NSString *)normal highlight:(NSString *)highlight;

/**
 *  设置返回按钮frame
 *
 *  @param btnWidth 按钮宽度
 */
-(void)setBackBtnFrame:(CGFloat)btnWidth;

/**
 *  设置更多按钮
 *
 *  @param normal    normal
 *  @param highlight 高亮
 */
-(void)setMoreBtnImageWithNormal:(NSString *)normal highlight:(NSString *)highlight;

/*
 * 恢复默认设置
 * 2015/12/14
 * @xzoscar
 */
- (void)reset;


/**
 设置关闭按钮颜色

 @param color 颜色
 */
- (void)setCloseBtnColor:(UIColor *)color;


@end
