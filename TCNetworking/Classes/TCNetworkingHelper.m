//
//  TCNetworkingHelper.m
//  TCNetworking
//
//  Created by 陈 胜 on 16/5/23.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import "TCNetworkingHelper.h"
#import "NSData+DataHealing.h"

@implementation TCNetworkingHelper

/**
 *  解析后台返回的数据
 *
 *  @param responseObject 后台返回数据
 *
 *  @return 返回解析之后的字符串数据
 */
+ (NSString *)parseResponse:(id)responseObject {
    NSData *responseData = [(NSData *)responseObject UTF8String];
    NSString *response = [[NSString alloc] initWithData:responseData
                                               encoding:NSUTF8StringEncoding];
    if (!response) {
        responseData = [(NSData *)responseObject GB18030Data];
        unsigned long encode = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
        response = [[NSString alloc] initWithData:responseData encoding:encode];
    }
    response = [self replaceBlack:response];
    
    return response;
}

+ (NSString *)replaceBlack:(NSString *)string {
    if (!string) {
        return @"";
    }
    NSMutableString *tmpString = [NSMutableString stringWithString:string];
    NSString *regular = @"([\\x00-\\x09\\x0b\\x0c\\x0e-\\x1f\\x7f])";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regular
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:nil];
    NSArray *arrayOfAllMatches = [regex matchesInString:tmpString options:0 range:NSMakeRange(0, [tmpString length])];
    NSString *substringForMatch = [NSString string];
    for (NSTextCheckingResult *match in arrayOfAllMatches) {
        substringForMatch = [tmpString substringWithRange:match.range];
    }
    [tmpString replaceOccurrencesOfString:substringForMatch
                               withString:@""
                                  options:NSBackwardsSearch
                                    range:NSMakeRange(0, [tmpString length])];
    return tmpString;
}


@end
