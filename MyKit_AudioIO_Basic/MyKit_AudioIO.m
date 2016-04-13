//
//  MyKit_AudioIO.m
//  MyKit_AudioIO
//
//  Created by 本田忠嗣 on 2016/01/10.
//  Copyright (c) 2016年 Orifice. All rights reserved.
//

#import "MyKit_AudioIO.h"


// config.
static const int kNumberBuffers = 3;		// 3以上を推奨だが、3で十分
static const int kSamplesPerBuf = 1024;
static const int kSamplingRate  = 44100;


@interface MyKit_AudioIO()
{
    BOOL isPlaying;
    BOOL isRecording;
    AudioQueueRef _aQueIn;
    AudioQueueRef _aQueOut;
    AudioQueueBufferRef _buffersIn[kNumberBuffers];
    AudioQueueBufferRef _buffersOut[kNumberBuffers];
}
@end

@implementation MyKit_AudioIO


static void callbackOut(
                        void                 *inUserData,
                        AudioQueueRef        inAQ,
                        AudioQueueBufferRef  inBuffer)
{
    MyKit_AudioIO    *ref = (__bridge MyKit_AudioIO *)inUserData;
    id<MyKit_AudioIOBuffer> audioBuf = ref.audioIODelegate;

    //    NSLog(@"CB Out");
    inBuffer->mAudioDataByteSize = [audioBuf pop:inBuffer->mAudioData :kSamplesPerBuf * sizeof(Float32): 0.0];
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
    id<MyKit_AudioIOBuffer> audioBuf = ref.audioIODelegate;

	//    NSLog(@"CB In:%ld", inBuffer->mAudioDataByteSize);
	[audioBuf push:inBuffer->mAudioData :inBuffer->mAudioDataByteSize];
	AudioQueueEnqueueBuffer(inAQ, inBuffer, 0, NULL);
}

-(id)init
{
    self = [super init];
    if (!self) {
		return self;
	}

    isPlaying = NO;
    isRecording = NO;
    
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
    
    // IOバッファーをアロケート
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

-(int)rec
{
    if (isRecording) {
        return;
    }

	// Audio Buffer が有効か？
	if (![self.audioIODelegate respondsToSelector:@selector(push::)]) {
		return -1;
	}

    isRecording = YES;
    
    for (int idx = 0; idx < kNumberBuffers; idx++) {
        AudioQueueEnqueueBuffer(_aQueIn, _buffersIn[idx], 0, NULL);
    }

    AudioQueueStart(_aQueIn, NULL);
	return 0;
}

-(int)play
{
    if (isPlaying) {
        [self stop];
    }
	// Audio Buffer が有効か？
	if (![self.audioIODelegate respondsToSelector:@selector(pop:::)]) {
		return -1;
	}

    isPlaying = YES;
    
    for (int idx = 0; idx < kNumberBuffers; idx++) {
        [_audioBuf pop:_buffersOut[idx]->mAudioData
                      :kSamplesPerBuf * sizeof(Float32) : 0.0];
        _buffersOut[idx]->mAudioDataByteSize = kSamplesPerBuf  * sizeof(Float32);
        AudioQueueEnqueueBuffer(_aQueOut, _buffersOut[idx], 0, NULL);
    }
    
    AudioQueueStart(_aQueOut, NULL);
	return 0;
}

-(void)stop
{
    [self stopRec];
    [self stopPlay];
}

-(void)stopRec
{
    AudioQueueStop(_aQueIn, YES);
    isRecording = NO;
}

-(void)stopPlay
{
    AudioQueueStop(_aQueOut, YES);
    AudioQueueFlush(_aQueOut);
    isPlaying = NO;
}

@end
