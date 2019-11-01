//
//  NSData+DataHealing.m
//  TCNetworking
//
//  Created by 刘甜甜 on 2019/11/1.
//  Copyright © 2019 陈胜. All rights reserved.
//

#import "NSData+DataHealing.h"

@implementation NSData (DataHealing)
- (NSData *)UTF8String {
    NSUInteger length = [self length];
    if (length == 0) return self;
    // Replaces all broken sequences by � character and returns NSData with valid UTF-8 bytes.
#if DEBUG
    int warningsCounter = 10;
#endif
    //  bits
    //  7       U+007F      0xxxxxxx
    //  11       U+07FF      110xxxxx    10xxxxxx
    //  16      U+FFFF      1110xxxx    10xxxxxx    10xxxxxx
    //  21      U+1FFFFF    11110xxx    10xxxxxx    10xxxxxx    10xxxxxx
    //  26      U+3FFFFFF   111110xx    10xxxxxx    10xxxxxx    10xxxxxx    10xxxxxx
    //  31      U+7FFFFFFF  1111110x    10xxxxxx    10xxxxxx    10xxxxxx    10xxxxxx    10xxxxxx
    
#define b00000000 0x00
#define b10000000 0x80
#define b11000000 0xc0
#define b11100000 0xe0
#define b11110000 0xf0
#define b11111000 0xf8
#define b11111100 0xfc
#define b11111110 0xfe
    
    static NSString* replacementCharacter = @"�";
    NSData* replacementCharacterData = [replacementCharacter dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableData* resultData = [NSMutableData dataWithCapacity:[self length]];
    
    const char *bytes = [self bytes];
    
    
    static const NSUInteger bufferMaxSize = 1024;
    char buffer[bufferMaxSize]; // not initialized, but will be filled in completely before copying to resultData
    NSUInteger bufferIndex = 0;
    
#define FlushBuffer() if (bufferIndex > 0) { \
[resultData appendBytes:buffer length:bufferIndex]; \
bufferIndex = 0; \
}
#define CheckBuffer() if ((bufferIndex+5) >= bufferMaxSize) { \
[resultData appendBytes:buffer length:bufferIndex]; \
bufferIndex = 0; \
}
    
    NSUInteger byteIndex = 0;
    BOOL invalidByte = NO;
    while (byteIndex < length)
    {
        char byte = bytes[byteIndex];
        
        // ASCII character is always a UTF-8 character
        if ((byte & b10000000) == b00000000) // 0xxxxxxx
        {
            CheckBuffer();
            buffer[bufferIndex++] = byte;
        }
        else if ((byte & b11100000) == b11000000) // 110xxxxx 10xxxxxx
        {
            if (byteIndex+1 >= length) {
                FlushBuffer();
                return resultData;
            }
            char byte2 = bytes[++byteIndex];
            if ((byte2 & b11000000) == b10000000)
            {
                // This 2-byte character still can be invalid. Check if we can create a string with it.
                unsigned char tuple[] = {byte, byte2};
                CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 2, kCFStringEncodingUTF8, false);
                if (cfstr)
                {
                    CFRelease(cfstr);
                    CheckBuffer();
                    buffer[bufferIndex++] = byte;
                    buffer[bufferIndex++] = byte2;
                }
                else
                {
                    invalidByte = YES;
                }
            }
            else
            {
                invalidByte = YES;
            }
        }
        else if ((byte & b11110000) == b11100000) // 1110xxxx 10xxxxxx 10xxxxxx
        {
            if (byteIndex+2 >= length) {
                FlushBuffer();
                return resultData;
            }
            char byte2 = bytes[++byteIndex];
            char byte3 = bytes[++byteIndex];
            if ((byte2 & b11000000) == b10000000 &&
                (byte3 & b11000000) == b10000000)
            {
                // This 3-byte character still can be invalid. Check if we can create a string with it.
                unsigned char tuple[] = {byte, byte2, byte3};
                CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 3, kCFStringEncodingUTF8, false);
                if (cfstr)
                {
                    CFRelease(cfstr);
                    CheckBuffer();
                    buffer[bufferIndex++] = byte;
                    buffer[bufferIndex++] = byte2;
                    buffer[bufferIndex++] = byte3;
                }
                else
                {
                    invalidByte = YES;
                }
            }
            else
            {
                invalidByte = YES;
            }
        }
        else if ((byte & b11111000) == b11110000) // 11110xxx 10xxxxxx 10xxxxxx 10xxxxxx
        {
            if (byteIndex+3 >= length) {
                FlushBuffer();
                return resultData;
            }
            char byte2 = bytes[++byteIndex];
            char byte3 = bytes[++byteIndex];
            char byte4 = bytes[++byteIndex];
            if ((byte2 & b11000000) == b10000000 &&
                (byte3 & b11000000) == b10000000 &&
                (byte4 & b11000000) == b10000000)
            {
                // This 4-byte character still can be invalid. Check if we can create a string with it.
                unsigned char tuple[] = {byte, byte2, byte3, byte4};
                CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 4, kCFStringEncodingUTF8, false);
                if (cfstr)
                {
                    CFRelease(cfstr);
                    CheckBuffer();
                    buffer[bufferIndex++] = byte;
                    buffer[bufferIndex++] = byte2;
                    buffer[bufferIndex++] = byte3;
                    buffer[bufferIndex++] = byte4;
                }
                else
                {
                    invalidByte = YES;
                }
            }
            else
            {
                invalidByte = YES;
            }
        }
        else if ((byte & b11111100) == b11111000) // 111110xx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
        {
            if (byteIndex+4 >= length) {
                FlushBuffer();
                return resultData;
            }
            char byte2 = bytes[++byteIndex];
            char byte3 = bytes[++byteIndex];
            char byte4 = bytes[++byteIndex];
            char byte5 = bytes[++byteIndex];
            if ((byte2 & b11000000) == b10000000 &&
                (byte3 & b11000000) == b10000000 &&
                (byte4 & b11000000) == b10000000 &&
                (byte5 & b11000000) == b10000000)
            {
                // This 5-byte character still can be invalid. Check if we can create a string with it.
                unsigned char tuple[] = {byte, byte2, byte3, byte4, byte5};
                CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 5, kCFStringEncodingUTF8, false);
                if (cfstr)
                {
                    CFRelease(cfstr);
                    CheckBuffer();
                    buffer[bufferIndex++] = byte;
                    buffer[bufferIndex++] = byte2;
                    buffer[bufferIndex++] = byte3;
                    buffer[bufferIndex++] = byte4;
                    buffer[bufferIndex++] = byte5;
                }
                else
                {
                    invalidByte = YES;
                }
            }
            else
            {
                invalidByte = YES;
            }
        }
        else if ((byte & b11111110) == b11111100) // 1111110x 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx 10xxxxxx
        {
            if (byteIndex+5 >= length) {
                FlushBuffer();
                return resultData;
            }
            char byte2 = bytes[++byteIndex];
            char byte3 = bytes[++byteIndex];
            char byte4 = bytes[++byteIndex];
            char byte5 = bytes[++byteIndex];
            char byte6 = bytes[++byteIndex];
            if ((byte2 & b11000000) == b10000000 &&
                (byte3 & b11000000) == b10000000 &&
                (byte4 & b11000000) == b10000000 &&
                (byte5 & b11000000) == b10000000 &&
                (byte6 & b11000000) == b10000000)
            {
                // This 6-byte character still can be invalid. Check if we can create a string with it.
                unsigned char tuple[] = {byte, byte2, byte3, byte4, byte5, byte6};
                CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 6, kCFStringEncodingUTF8, false);
                if (cfstr)
                {
                    CFRelease(cfstr);
                    CheckBuffer();
                    buffer[bufferIndex++] = byte;
                    buffer[bufferIndex++] = byte2;
                    buffer[bufferIndex++] = byte3;
                    buffer[bufferIndex++] = byte4;
                    buffer[bufferIndex++] = byte5;
                    buffer[bufferIndex++] = byte6;
                }
                else
                {
                    invalidByte = YES;
                }
                
            }
            else
            {
                invalidByte = YES;
            }
        }
        else
        {
            invalidByte = YES;
        }
        
        if (invalidByte)
        {
#if DEBUG
            if (warningsCounter)
            {
                warningsCounter--;
                //NSLog(@"NSData dataByHealingUTF8Stream: broken byte encountered at index %d", byteIndex);
            }
#endif
            invalidByte = NO;
            FlushBuffer();
            [resultData appendData:replacementCharacterData];
        }
        
        byteIndex++;
    }
    FlushBuffer();
    return resultData;
}

- (NSData *)GB18030Data {
    NSUInteger length = [self length];
    if (length == 0) {
        return self;
    }
    static NSString * replacementCharacter = @"?";
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData *replacementCharacterData = [replacementCharacter dataUsingEncoding:enc];
    
    NSMutableData *resultData = [NSMutableData dataWithCapacity:self.length];
    
    const Byte *bytes = [self bytes];
    
    static const NSUInteger bufferMaxSize = 1024;
    Byte buffer[bufferMaxSize];
    NSUInteger bufferIndex = 0;
    
    NSUInteger byteIndex = 0;
    BOOL invalidByte = NO;
    
    while (byteIndex < length) {
        Byte byte = bytes[byteIndex];
        //检查第一位
        if (byte >= 0 && byte <= (Byte)0x7f) {
            //单字节文字
            CheckBuffer();
            buffer[bufferIndex++] = byte;
        } else if (byte >= (Byte)0x81 && byte <= (Byte)0xfe){
            //可能是双字节，可能是四字节
            if (byteIndex + 1 >= length) {
                //这是最后一个字节了，但是这个字节表明后面应该还有1或3个字节，那么这个字节一定是错误字节
                FlushBuffer();
                return resultData;
            }
            
            Byte byte2 = bytes[++byteIndex];
            if (byte2 >= (Byte)0x40 && byte <= (Byte)0xfe && byte != (Byte)0x7f) {
                //是双字节，并且可能合法
                unsigned char tuple[] = {byte, byte2};
                CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 2, kCFStringEncodingGB_18030_2000, false);
                if (cfstr) {
                    CFRelease(cfstr);
                    CheckBuffer();
                    buffer[bufferIndex++] = byte;
                    buffer[bufferIndex++] = byte2;
                } else {
                    //这个双字节字符不合法，但byte2可能是下一字符的第一字节
                    byteIndex -= 1;
                    invalidByte = YES;
                }
            } else if (byte2 >= (Byte)0x30 && byte2 <= (Byte)0x39) {
                //可能是四字节
                if (byteIndex + 2 >= length) {
                    FlushBuffer();
                    return resultData;
                }
                
                Byte byte3 = bytes[++byteIndex];
                
                if (byte3 >= (Byte)0x81 && byte3 <= (Byte)0xfe) {
                    // 第三位合法，判断第四位
                    
                    Byte byte4 = bytes[++byteIndex];
                    
                    if (byte4 >= (Byte)0x30 && byte4 <= (Byte)0x39) {
                        //第四位可能合法
                        unsigned char tuple[] = {byte, byte2, byte3, byte4};
                        CFStringRef cfstr = CFStringCreateWithBytes(kCFAllocatorDefault, tuple, 4, kCFStringEncodingGB_18030_2000, false);
                        if (cfstr) {
                            CFRelease(cfstr);
                            CheckBuffer();
                            buffer[bufferIndex++] = byte;
                            buffer[bufferIndex++] = byte2;
                            buffer[bufferIndex++] = byte3;
                            buffer[bufferIndex++] = byte4;
                        } else {
                            //这个四字节字符不合法，但是byte2可能是下一个合法字符的第一字节，回退3位
                            //并且将byte1,byte2用?替代
                            byteIndex -= 3;
                            invalidByte = YES;
                        }
                    } else {
                        //第四字节不合法
                        byteIndex -= 3;
                        invalidByte = YES;
                    }
                } else {
                    // 第三字节不合法
                    byteIndex -= 2;
                    invalidByte = YES;
                }
            } else {
                // 第二字节不是合法的第二位，但可能是下一个合法的第一位，所以回退一个byte
                invalidByte = YES;
                byteIndex -= 1;
            }
            
            if (invalidByte) {
                invalidByte = NO;
                FlushBuffer();
                [resultData appendData:replacementCharacterData];
            }
        }
        byteIndex++;
    }
    FlushBuffer();
    return resultData;
}

@end
