//
//  CMTabBarItem.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CMCommonHeader.h"
#import "CMTabBarDto.h"
/**
 回调block
 */
typedef void (^SNMKZSQTabBarItemClickBlock)(NSInteger index);

@interface CMTabBarItem : UIView
@property (nonatomic, copy) SNMKZSQTabBarItemClickBlock     clickBlock;

-(void)updateWithDto:(CMTabBarDto *)tabBarDto;
-(void)turnHighLight;
-(void)turnNormal;


@end
