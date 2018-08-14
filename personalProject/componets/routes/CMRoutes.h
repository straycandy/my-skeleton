//
//  CMRoutes.h
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMRoutesProtocol.h"

@interface CMRoutes : NSObject
+ (CMRoutes * __nullable )sharedInstance;

- (void)handleURL:(NSString * __nullable)url
       onChecking:(void(^ __nullable)(id<CMRoutesProtocol>  __nullable obj))onCheckingBlock
      shouldRoute:(BOOL (^ __nullable )(id<CMRoutesProtocol>  __nullable obj))shouldRouteBlock
         didRoute:(void (^ __nullable)(id<CMRoutesProtocol> __nullable obj))didRouteBlock
           source:(CMRouteSource)source
    navController:(UINavigationController * __nullable)navCon;

- (void)_handleURL:(NSString *)url
        onChecking:(void(^)(id<CMRoutesProtocol> __nullable obj))onCheckingBlock
       shouldRoute:(BOOL (^)(id<CMRoutesProtocol> __nullable obj))shouldRouteBlock
          didRoute:(void (^)(id<CMRoutesProtocol> __nullable obj))didRouteBlock
            source:(CMRouteSource)source
     navController:(UINavigationController *)navCon;
@end
