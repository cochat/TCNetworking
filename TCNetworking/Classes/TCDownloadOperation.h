//
//  TCDownloadOperation.h
//  TCNetworking
//
//  Created by 陈 胜 on 16/5/23.
//  Copyright © 2016年 陈胜. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TCFileDownloader.h"
#import "TCBaseAPIClient.h"

@interface TCDownloadOperation : NSOperation

@property (nonatomic, strong) TCBaseAPIClient *client;

/**
 *  创建一个下载Operation
 *
 *  @param URLString   下载路径
 *  @param progress    进度回调
 *  @param destination 存储路径回调
 *  @param success     成功回调
 *  @param failure     失败回调
 *  @param cancel      取消回调
 *
 *  @return TCDownloadOperation对象
 */
- (instancetype)initWithURL:(NSString *)URLString
                   progress:(TCDownloadProgressBlock)progress
                destination:(TCDownloadDestinationBlock)destination
                    success:(TCDownloadSuccessBlock)success
                    failure:(TCDownloadFailureBlock)failure
                     cancel:(TCDownloadCancelBlock)cancel;

@end
