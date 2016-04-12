//
//  ViewController.m
//  MyKit_AudioIO_Basic
//
//  Created by 本田忠嗣 on 2016/02/06.
//  Copyright © 2016年 TadatsuguHonda. All rights reserved.
//

#import "ViewController.h"

#import "MyKit_AudioIO.h"
#import "MyKit_AudioBuffer.h"

@interface ViewController ()
{
    MyKit_AudioBuffer*	_audioBuf;
    MyKit_AudioIO*		_audioIO;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    _audioBuf = [[MyKit_AudioBuffer alloc] initWithBufferSize:30*44100*(sizeof)float];
//	_audioIO = [[MyKit_AudioIO alloc] initWithBuffer:_audioBuf ];
	_audioIO = [[MyKit_AudioIO alloc] init];
	_audioIO.delegateAudioBuffer = _audioBuf;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushRec:(id)sender {
    [_audioIO stop];
    [_audioBuf rewindPush];
    
    [_audioIO rec];
}

- (IBAction)pushPlay:(id)sender {
    [_audioIO stop];
    [_audioBuf rewindPop];
    
    [_audioIO play];
}

- (IBAction)pushStop:(id)sender {
    [_audioIO stop];
}

@end
