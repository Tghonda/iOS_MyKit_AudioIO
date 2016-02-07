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
    MyKit_AudioBuffer   *audio_buf;
    MyKit_AudioIO       *audio_io;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    audio_buf = [[MyKit_AudioBuffer alloc] initWithBufferSize:30*44100*4];
    audio_io = [[MyKit_AudioIO alloc] initWithBuffer:audio_buf ];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)pushRec:(id)sender {
    [audio_io stop];
    [audio_buf rewindPush];
    
    [audio_io rec];
}

- (IBAction)pushPlay:(id)sender {
    [audio_io stop];
    [audio_buf rewindPop];
    
    [audio_io play];
}

- (IBAction)pushStop:(id)sender {
    [audio_io stop];
}

@end
