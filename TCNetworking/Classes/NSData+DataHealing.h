//
//  NSData+DataHealing.h
//  TCNetworking
//
//  Created by 刘甜甜 on 2019/11/1.
//  Copyright © 2019 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSData (DataHealing)

- (NSData *)UTF8String;

- (NSData *)GB18030Data;

@end

NS_ASSUME_NONNULL_END
