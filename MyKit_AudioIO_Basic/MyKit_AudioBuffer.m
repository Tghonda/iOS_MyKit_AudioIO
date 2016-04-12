//
//  MyKit_AudioBuffer.m
//  MyKit_AudioBuffer
//
//  Created by 本田忠嗣 on 2016/01/10.
//  Copyright (c) 2016年 Orifice. All rights reserved.
//

#import "MyKit_AudioBuffer.h"

@interface MyKit_AudioBuffer()
{
    void*	_data;
    int		_totalSize;
    int		_popPosition;
    int		_pushPosition;
}

@property (nonatomic) int totalSize;
@property (nonatomic) int readPosition;
@property (nonatomic) int writePosition;

@end

@implementation MyKit_AudioBuffer

-(id)initWithBufferSize:(int)bufferSize
{
    if (bufferSize <= 0) {
        return nil;
    }
    
    self = [super init];
    if ( !self ) {
        return nil;
    }
    
    _data = malloc(bufferSize);
    if ( !_data ) {
        return nil;
    }
    
    _totalSize = bufferSize;
    _popPosition = 0;
    _pushPosition = 0;
    
    return self;
}

- (void)dealloc
{
    if (_data) {
        free(_data);
        _data = nil;
    }
    //	[super dealloc];		// ARC では super を呼び出してはいけない！（コンパイラーが自動生成する）
}

-(int)push:(void*)buf :(int)size
{
    int len = _totalSize - _pushPosition;
    if (size > len) {
        size = len;
    }

    memcpy(_data+_pushPosition, buf, size);
    _pushPosition += size;
    return size;
}

-(int)pop:(void*)buf :(int)size :(double)waitTime
{
    int len = _pushPosition - _popPosition;
    if (size > len) {
        size = len;
    }
    
    memcpy(buf, _data+_popPosition, size);
    _popPosition += size;
    return size;
}

-(void)rewindPush
{
    _pushPosition = 0;
}

-(void)rewindPop
{
    _popPosition = 0;
}

-(void*)getBufferAddr
{
    return _data;
}

-(int)peekDataSize
{
    return _pushPosition;
}

@end


/*******************************************************************
	Ring Buffer.
*/
@interface MyKit_AudioRingBuffer()
{
	void*	_buffer;
	int		_pushCount;
	int		_popCount;
	int		_bufferLength;

}

@end

@implementation MyKit_AudioRingBuffer
- (id)initWithSize:(int)bufferSize
{
	if ( !(self = [super init]) ) return nil;

	_buffer = malloc(bufferSize);
	if ( !_buffer )	return nil;

	memset(_buffer, 0, bufferSize);
	_pushCount = 0;
	_popCount = 0;
	_bufferLength = bufferSize;

	return self;
}

- (void)dealloc
{
    if (_buffer) {
        free(_buffer);
    }
}

- (void)reset
{
    _pushCount = 0;
    _popCount = 0;
}

- (int)push:(void*)buf :(int) size
{
    if ( _bufferLength < (_pushCount - _popCount) + size ){
        NSLog(@"Ring buffer Overflow !!!!");
		return -1;		// Over fllow!
    }
	int rsize = size;
	int tailLength = _bufferLength - (_pushCount % _bufferLength);
	if (size > tailLength) {
		memcpy(_buffer+(_pushCount % _bufferLength), buf, tailLength);
		size -= tailLength;
		buf  += tailLength;
		_pushCount += tailLength;
	}
	memcpy(_buffer+(_pushCount % _bufferLength), buf, size);
	_pushCount += size;

	return rsize;
}

- (int)pop:(void*)buf :(int)size :(double)waitTime
{
	// config.
	static double waitTics = 30.0/1000.0;

    while (size > (_pushCount - _popCount)) {
		[NSThread sleepForTimeInterval:waitTics];
		waitTime -= waitTics;
        if (waitTime < 0) {
            return -1;		// internal error!
        }
	}

	int rsize = size;
	int tailLength = _bufferLength - (_popCount % _bufferLength);
	if (size > tailLength) {
		memcpy(buf, _buffer+(_popCount % _bufferLength), tailLength);
		size -= tailLength;
		buf  += tailLength;
		_popCount += tailLength;
	}
	memcpy(buf, _buffer+(_popCount % _bufferLength), size);
	_popCount += size;

	return rsize;
}

@end

#if 0
/*******************************************************************
	Linear Buffer.
*/
@interface OFCLinearBuffer()
{
	void* _buffer;
	int _bufferLength;
}

@end

@implementation OFCLinearBuffer
- (id)initWithSize:(int)bufferSize
{
	if ( !(self = [super init]) ) return nil;

	_buffer = malloc(bufferSize);
	if ( !_buffer )	return nil;

	memset(_buffer, 0, bufferSize);
	_bufferLength = bufferSize;

	return self;
}

- (void)pushTail:(void*)buf :(int) size
{
	if (size > _bufferLength) {
		buf += size - _bufferLength;
		memcpy(_buffer, buf, _bufferLength);
		return;
	}
	memmove(_buffer, _buffer+size, _bufferLength - size);
	memcpy(_buffer + (_bufferLength - size), buf, size);
}

- (void)pushHead:(void*)buf :(int) size
{
	if (size > _bufferLength) {
		memcpy(_buffer, buf, _bufferLength);
		return;
	}
	memmove(_buffer+size, _buffer, _bufferLength - size);
	memcpy(_buffer, buf, size);
}

@end
#endif
