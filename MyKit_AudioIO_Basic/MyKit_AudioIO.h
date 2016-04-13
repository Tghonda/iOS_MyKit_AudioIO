//
//  MyKit_AudioIO.h
//  MyKit_AudioIO
//
//  Created by 本田忠嗣 on 2016/01/10.
//  Copyright (c) 2016年 Orifice. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

// バッファプロトコル
@protocol MyKit_AudioIODelegate
@optional
-(int32_t)push:(void*)data :(int32_t)size;
-(int32_t)pop:(void*)data :(int32_t)size :(double)waitTime;
@end

// AudioIO クラス
// 設計方針：このクラスはAudioの入出力に限定し、余分な処理は実装しない
//　出力データが不足している場合の０フィルなどは AudioBuffer に任せる
//　出力データリクエストの Delegate も同様
/* 使用時のサンプルコード
		：
	audio_buf = [[MyKit_AudioBuffer alloc] initWithBufferSize:30*44100*(sizeof)float];
	audio_io = [[MyKit_AudioIO alloc] init];
	audio_io.audioIODelegate = audio_buf;
		：
*/　
@interface MyKit_AudioIO : NSObject

@property (nonatomic, weak) id<MyKit_AudioIODelegate> audioIODelegate;

-(int)rec;
-(int)play;
-(void)stop;
-(void)stopRec;
-(void)stopPlay;
@end
