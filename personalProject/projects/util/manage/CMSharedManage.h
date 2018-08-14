//
//  CMSharedManage.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

void routerToTargetURL(NSString * targetURL);

@interface CMSharedManage : NSObject

+ (UINavigationController *)selectedNavi;
+ (CMSharedManage *)shared;
- (NSArray *)getTabBarInfoArray;
@end
