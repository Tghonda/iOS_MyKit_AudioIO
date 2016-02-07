//
//  MyKit_AudioIO.m
//  MyKit_AudioIO
//
//  Created by 本田忠嗣 on 2016/01/10.
//  Copyright (c) 2016年 Orifice. All rights reserved.
//

#import "MyKit_AudioIO.h"


// config.
#define kNumberBuffers	3
#define kSamplesPerBuf	1024
#define kSamplingRate   44100


@interface MyKit_AudioIO()
{
    BOOL isPlaying;
    BOOL isRecording;
    AudioQueueRef _aQueIn;
    AudioQueueRef _aQueOut;
    AudioQueueBufferRef _buffersIn[kNumberBuffers];
    AudioQueueBufferRef _buffersOut[kNumberBuffers];
}

@property (nonatomic, weak) id<MyProtcol_AudioBuffer> audioBuf;

@end

@implementation MyKit_AudioIO


static void callbackOut(
                        void                 *inUserData,
                        AudioQueueRef        inAQ,
                        AudioQueueBufferRef  inBuffer)
{
    MyKit_AudioIO    *ref = (__bridge MyKit_AudioIO *)inUserData;
    
    //    NSLog(@"CB Out");
    inBuffer->mAudioDataByteSize = [ref->_audioBuf pop:inBuffer->mAudioData :kSamplesPerBuf * sizeof(Float32): 0.0];
    inBuffer->mPacketDescriptionCount = inBuffer->mAudioDataByteSize/sizeof(Float32);
    AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}


static void callbackIn(
                       void                                *inUserData,
                       AudioQueueRef                       inAQ,
                       AudioQueueBufferRef                 inBuffer,
                       const AudioTimeStamp                *inStartTime,
                       UInt32                              inNumberPacketDescriptions,
                       const AudioStreamPacketDescription  *inPacketDescs)
{
	MyKit_AudioIO    *ref = (__bridge MyKit_AudioIO *)inUserData;
    
	//    NSLog(@"CB In:%ld", inBuffer->mAudioDataByteSize);
	[ref->_audioBuf push:inBuffer->mAudioData :inBuffer->mAudioDataByteSize];
	AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

-(id)initWithBuffer:(id <MyProtcol_AudioBuffer>)buffer
{
    self = [super init];
    if (self == nil)	return nil;

    isPlaying = false;
    isRecording = false;
    _audioBuf = buffer;
    
    // オーディオフォーマット
    AudioStreamBasicDescription audioFormat;
    audioFormat.mSampleRate         = kSamplingRate;
    audioFormat.mFormatID           = kAudioFormatLinearPCM;
    audioFormat.mFormatFlags        = kAudioFormatFlagIsFloat;
    audioFormat.mFramesPerPacket    = 1;
    audioFormat.mChannelsPerFrame   = 1;
    audioFormat.mBitsPerChannel     = 8 * sizeof(Float32);
    audioFormat.mBytesPerPacket     = sizeof(Float32);
    audioFormat.mBytesPerFrame      = sizeof(Float32);
    audioFormat.mReserved           = 0;
    
    // AudioQueue 作成
    AudioQueueNewInput(&audioFormat, &callbackIn, (void *)CFBridgingRetain(self), NULL, NULL, 0, &_aQueIn);
    AudioQueueNewOutput(&audioFormat, &callbackOut, (void *)CFBridgingRetain(self), NULL, NULL, 0, &_aQueOut);
    
    // バッファーをアロケート
    UInt32  bufSize = kSamplesPerBuf * sizeof(Float32);
    for (int idx = 0; idx < kNumberBuffers; idx++) {
        AudioQueueAllocateBuffer(_aQueIn, bufSize, &_buffersIn[idx]);
    }
    
    for (int idx = 0; idx < kNumberBuffers; idx++) {
        AudioQueueAllocateBuffer(_aQueOut, bufSize, &_buffersOut[idx]);
    }
    
    return self;
}

-(void)dealloc
{
    AudioQueueDispose(_aQueIn, YES);
    AudioQueueDispose(_aQueOut, YES);
}

-(void)rec
{
    if (isRecording)
        return;
    
    isRecording = true;
    
    for (int idx = 0; idx < kNumberBuffers; idx++) {
        AudioQueueEnqueueBuffer(_aQueIn, _buffersIn[idx], 0, NULL);
    }
    AudioQueueStart(_aQueIn, NULL);
}

-(void)play
{
    if (isPlaying) {
        [self stop];
    }
    isPlaying = true;
    
    for (int idx = 0; idx < kNumberBuffers; idx++) {
        [_audioBuf pop:_buffersOut[idx]->mAudioData
                      :kSamplesPerBuf * sizeof(Float32) : 0.0];
        _buffersOut[idx]->mAudioDataByteSize = kSamplesPerBuf  * sizeof(Float32);
        AudioQueueEnqueueBuffer(_aQueOut, _buffersOut[idx], 0, NULL);
    }
    
    AudioQueueStart(_aQueOut, NULL);
}

-(void)stop
{
    [self stopRec];
    [self stopPlay];
}

-(void)stopRec
{
    AudioQueueStop(_aQueIn, YES);
    isRecording = false;
}

-(void)stopPlay
{
    AudioQueueStop(_aQueOut, YES);
    AudioQueueFlush(_aQueOut);
    isPlaying = false;
}

@end
