//
//  MyKit_AudioBuffer.h
//  MyKit_AudioBuffer
//
//  Created by 本田忠嗣 on 2016/01/10.
//  Copyright (c) 2016年 Orifice. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyKit_AudioIO.h"

@interface MyKit_AudioBuffer : NSObject <MyKit_AudioIOBuffer>
- (id)initWithBufferSize:(int)bufferSize;
- (void)rewindPush;
- (void)rewindPop;
- (void*)getBufferAddr;
- (int)peekDataSize;
- (int)push:(void*)buf :(int)size
- (int)pop:(void*)buf :(int)size :(double)waitTime
@end

@interface MyKit_AudioRingBuffer : NSObject <MyKit_AudioIOBuffer>
- (id)initWithSize:(int)bufferSize;
- (void)reset;
- (int)push:(void*)buf :(int)size
- (int)pop:(void*)buf :(int)size :(double)waitTime
@end


