//
//  ABPeoplePickerHandler.h
//  SuningEBuy
//
//  Created by wangbin on 16/1/16.
//  Copyright © 2016年 苏宁易购. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMCommomViewController.h"

typedef void (^ABPeoplePickerCancelBlock)(void);
typedef void (^ABPeoplePickerDidPickPersonBlock)(NSString *name, NSString *phoneStr);

@interface ABPeoplePickerHandler : NSObject

/**
 *  选择通讯录
 *
 *  @param controller         controller
 *  @param cancelBlock        取消block
 *  @param didPickPersonBlock 选中block
 */
+ (void)pickInController:(CMCommomViewController *)controller
             cancelBlock:(ABPeoplePickerCancelBlock)cancelBlock
            didPickPersonBlock:(ABPeoplePickerDidPickPersonBlock)didPickPersonBlock;

@end
