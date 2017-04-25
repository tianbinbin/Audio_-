//
//  ViewController.m
//  Audio_tool
//
//  Created by 田彬彬 on 2017/4/25.
//  Copyright © 2017年 田彬彬. All rights reserved.
//

#import "ViewController.h"

// 这个库使c的接口 偏向于底层 主要用于在线流媒体的播放
#import <AudioToolbox/AudioToolbox.h>
// 主要是提供了音频和回放的底层api  同时也是负责管理音视频硬件
#import <AVFoundation/AVFoundation.h>

@interface ViewController ()<AVAudioRecorderDelegate>
{
    // 用来录音
    AVAudioRecorder * recorder;
    
    // 设置定时监测 用来监听当前音量的大小 控制话筒图片
    NSTimer * timer;
    
    NSURL * urlPlay;
}


@property (nonatomic, strong) UIButton * btn;               // 用来控制录音功能
@property (nonatomic, strong) UIButton * playbtn;           // 用来播放已经录制好的音频文件
@property (nonatomic, strong) UIImageView * imageV;         // 控制音量的图片
@property (nonatomic, strong) AVAudioPlayer * avplayre;     // 播放器


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // 第一步 进行录音设置
    [self audio];
    
    self.imageV = [[UIImageView alloc]initWithFrame:CGRectMake((self.view.frame.size.width-200)/2, 100, 100, 100)];
    self.imageV.image = [UIImage imageNamed:@"editpicture_localchartlet9.png"];
    [self.view addSubview:self.imageV];
    
    
    self.btn = [UIButton buttonWithType:UIButtonTypeCustom];
    self.btn.frame  = CGRectMake(self.imageV.frame.origin.x, 250, 50, 40);
    [self.btn setTitle:@"start" forState:UIControlStateNormal];
    self.btn.backgroundColor = [UIColor grayColor];
    // 当按钮被按下的时候
    [self.btn addTarget:self action:@selector(btnDown:) forControlEvents:UIControlEventTouchDown];
    
    //手指抬起的时候结束
    [self.btn addTarget:self action:@selector(btnup:) forControlEvents:UIControlEventTouchUpInside];
    
    // 当触摸拖动离开 控制范围时
    [self.btn addTarget:self action:@selector(btndragup:) forControlEvents:UIControlEventTouchDragExit];
    
    [self.view addSubview:self.btn];
}



-(void)audio
{
    // 先配置recoder
    NSMutableDictionary * recoderSeting = [NSMutableDictionary dictionary];
    
    // 设置录音格式
    [recoderSeting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    
    // 设置录音采样率
    [recoderSeting setValue:[NSNumber numberWithInt:44100] forKey:AVSampleRateKey];
    
    // 录音通道
    [recoderSeting setValue:[NSNumber numberWithInt:1] forKey:AVNumberOfChannelsKey];
    
    // 线性采样数 8 16 24 32
    [recoderSeting setValue:[NSNumber numberWithInt:16] forKey:AVLinearPCMBitDepthKey];
    
    // 录音质量
    [recoderSeting setValue:[NSNumber numberWithInt:AVAudioQualityHigh] forKey:AVEncoderAudioQualityKey];
    
    NSString * strurl = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    NSURL * url = [NSURL fileURLWithPath:[NSString stringWithFormat:@"%@/recod.aac",strurl]];
    
    urlPlay = url;
    
    NSError * error;
    
    recorder = [[AVAudioRecorder alloc]initWithURL:url settings:recoderSeting error:&error];
    
    // 开启音量检测
    recorder.meteringEnabled = YES;
    recorder.delegate = self;
}

-(void)btnDown:(UIButton *)btn
{
    [btn setTitle:@"stop" forState:UIControlStateNormal];
    
    // 创建录音文件进行录音
    if([recorder prepareToRecord])
    {
        // 开始
        [recorder record];
    }
    
    // 设置定时监测
    timer = [NSTimer scheduledTimerWithTimeInterval:0 target:self selector:@selector(detectionVoice) userInfo:nil repeats:YES];
}


-(void)btnup:(UIButton *)btn
{
    [btn setTitle:@"start" forState:UIControlStateNormal];
    
    double ctime = recorder.currentTime;
    
    if(ctime>2)
    {
        NSLog(@"播放记录文件");
        
        NSLog(@"%@",urlPlay);
    }
    else
    {
        NSLog(@"删除记录文件");
        // 删除记录文件
        [recorder deleteRecording];
    }
    
    [recorder stop];
    [timer invalidate];
}

-(void)btndragup:(UIButton *)btn
{
    [btn setTitle:@"start" forState:UIControlStateNormal];
    
    //删除录制文件
    [recorder deleteRecording];
    [recorder stop];
    [timer invalidate];
    
    NSLog(@"取消发送");
    
}

/**
 * detectionVoice
 */
-(void)detectionVoice
{
    
    // 刷新当前音量数据
    [recorder updateMeters];
    
    double lowPassResult = pow(10, (0.05*[recorder peakPowerForChannel:0]));
    
    
    NSLog(@"刷新当前音量数据%lf",lowPassResult);
    // 取值范围现在是 0～1
    if(lowPassResult>0&&lowPassResult<0.06)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet0.png"]];
    }
    else if(lowPassResult<=0.13&&lowPassResult>0.06)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet1.png"]];
    }
    else if(lowPassResult<=0.20&&lowPassResult>0.13)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet2.png"]];
    }
    else if(lowPassResult<=0.27&&lowPassResult>0.20)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet3.png"]];
    }
    else if(lowPassResult<=0.34&&lowPassResult>0.27)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet4.png"]];
    }
    else if(lowPassResult<=0.41&&lowPassResult>0.34)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet5.png"]];
    }
    else if(lowPassResult<=0.48&&lowPassResult>0.41)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet6.png"]];
    }
    else if(lowPassResult<=0.55&&lowPassResult>0.48)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet7.png"]];
    }
    else if(lowPassResult<=0.62&&lowPassResult>0.55)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet8.png"]];
    }
    else if(lowPassResult<=1&&lowPassResult>0.62)
    {
        [self.imageV setImage:[UIImage imageNamed:@"editpicture_localchartlet9.png"]];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
}



@end
