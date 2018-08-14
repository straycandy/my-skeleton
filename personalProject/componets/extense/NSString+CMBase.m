//
//  NSString+CMBase.m
//  personalProject
//
//  Created by mengran on 2018/7/29.
//  Copyright © 2018年 ggV5. All rights reserved.
//

#import "NSString+CMBase.h"

@implementation NSString (CMBase)
- (NSString *)trim
{
    return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

- (NSDictionary*)queryDictionaryUsingEncodingQR:(NSStringEncoding)encoding
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[[kvPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:encoding] trim];
            NSString* value = [[[kvPair objectAtIndex:1]
                                stringByReplacingPercentEscapesUsingEncoding:encoding] trim];
            if (value != nil && key != nil) {
                [pairs setObject:value forKey:key];
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}

- (NSDictionary*)queryDictionaryUsingEncoding:(NSStringEncoding)encoding
{
    NSCharacterSet* delimiterSet = [NSCharacterSet characterSetWithCharactersInString:@"&;"];
    NSMutableDictionary* pairs = [NSMutableDictionary dictionary];
    NSScanner* scanner = [[NSScanner alloc] initWithString:self];
    while (![scanner isAtEnd]) {
        NSString* pairString = nil;
        [scanner scanUpToCharactersFromSet:delimiterSet intoString:&pairString];
        [scanner scanCharactersFromSet:delimiterSet intoString:NULL];
        NSArray* kvPair = [pairString componentsSeparatedByString:@"="];
        if (kvPair.count == 2) {
            NSString* key = [[[kvPair objectAtIndex:0]
                              stringByReplacingPercentEscapesUsingEncoding:encoding] trim];
            NSString* value = [[[kvPair objectAtIndex:1]
                                stringByReplacingPercentEscapesUsingEncoding:encoding] trim];
            if (value != nil && key != nil) {
                [pairs setObject:value forKey:key];
            }
        }
    }
    
    return [NSDictionary dictionaryWithDictionary:pairs];
}
@end
