//
//  MyKit_AudioBuffer.h
//  MyKit_AudioBuffer
//
//  Created by 本田忠嗣 on 2016/01/10.
//  Copyright (c) 2016年 Orifice. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyKit_AudioIO.h"

@interface MyKit_AudioBuffer : NSObject <MyProtcol_AudioBuffer>
- (id)initWithBufferSize:(int32_t)bufferSize;
- (void)rewindPush;
- (void)rewindPop;
- (void*)getBufferAddr;
- (int32_t)peekDataSize;
@end

@interface MyKit_AudioRingBuffer : NSObject <MyProtcol_AudioBuffer>
- (id)initWithSize:(int32_t)bufferSize;
- (void)reset;
@end


