//
//  NSArray+CMBase.m
//  personalProject
//
//  Created by mengran on 2018/8/14.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "NSArray+CMBase.h"

@implementation NSArray (CMBase)
- (id)safeObjectAtIndex:(NSUInteger)index
{
    if (self.count > index)
    {
        return [self objectAtIndex:index];
    }
    return nil;
}
@end
