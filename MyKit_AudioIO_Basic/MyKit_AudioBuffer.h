//
//  MyKit_AudioBuffer.h
//  MyKit_AudioBuffer
//
//  Created by 本田忠嗣 on 2016/01/10.
//  Copyright (c) 2016年 Orifice. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "MyKit_AudioIO.h"

// リニア―型バッファ
@interface MyKit_AudioBuffer : NSObject <MyKit_AudioIODelegate>
- (id)initWithBufferSize:(int)bufferSize;
- (void)rewindPush;
- (void)rewindPop;
- (void*)getBufferAddr;
- (int)peekDataSize;
// delegate method.
- (int)push:(void*)buf :(int)size
- (int)pop:(void*)buf :(int)size :(double)waitTime
@end

// リング型バッファ
@interface MyKit_AudioRingBuffer : NSObject <MyKit_AudioIODelegate>
- (id)initWithSize:(int)bufferSize;
- (void)reset;
// delegate method.
- (int)push:(void*)buf :(int)size
- (int)pop:(void*)buf :(int)size :(double)waitTime
@end


