//
//  WXAVPlayer.m
//  ImitationWeChat
//
//  Created by xwmedia01 on 16/7/22.
//  Copyright © 2016年 wany. All rights reserved.
//

#import "WXAVPlayer.h"

@implementation WXAVPlayer


/**
 *  播放器视觉输出
 */
- (AVPlayerLayer *)mAVPlayerLayer
{
    if (!_mAVPlayerLayer) {
        _mAVPlayerLayer = [[AVPlayerLayer alloc] init];
        _mAVPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
        _mAVPlayerLayer.frame = self.bounds;

    }
    return _mAVPlayerLayer;
}

/**
 *  播放器
 */
- (AVPlayer *)mAVPlayer
{
    if (!_mAVPlayer) {
        _mAVPlayer = [[AVPlayer alloc] init];
    }
    return _mAVPlayer;
}


/**
 *  播放器控制层
 */

- (WXAVPlayerControl *)mAVPlayerControl
{
    if (!_mAVPlayerControl) {
        _mAVPlayerControl = [[WXAVPlayerControl alloc] initWithFrame:self.bounds];
    }
    return _mAVPlayerControl;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        NSError *error;
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategorySoloAmbient error:&error];
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&error];
        
        //播放器载体
        [self.layer addSublayer:self.mAVPlayerLayer];
        
        //添加自定义控制层
        [self addSubview:self.mAVPlayerControl];
    
    }
    return self;
}

- (void)setContentURL:(NSURL *)contentURL
{
    if (_contentURL != contentURL && contentURL)
    {
        
        //创建 asset 加载 url 对应资源,创建缓存关键字
        AVURLAsset *asset = [AVURLAsset URLAssetWithURL:_contentURL options:nil];
        
        NSArray *requestedKeys = @[@"playable"];
        
        //加载资源
        [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
         ^{
             dispatch_async( dispatch_get_main_queue(),
                            ^{
                                //修改avplayer
                                [self prepareToPlayAsset:asset withKeys:requestedKeys];
                            });
         }];

    }
}


/**
 *  加载播放视频
 *
 *  @param asset         播放的资源00
 *  @param requestedKeys 缓存的key
 */
- (void)prepareToPlayAsset:(AVURLAsset *)asset withKeys:(NSArray *)requestedKeys
{
    //检查音频资源是否加载成功
    for (NSString *thisKey in requestedKeys)
    {
        NSError *error = nil;
        AVKeyValueStatus keyStatus = [asset statusOfValueForKey:thisKey error:&error];
        if (keyStatus == AVKeyValueStatusFailed)
        {
            //加载失败做相应处理
            [self assetFailedToPrepareForPlayback:error];
            
            return;
        }
    }
    
    /*  音频资源加载成功
     *  使用AVAsset播放属性检测asset是否可以播放
     */
    if (!asset.playable) {
        
        //生成错误信息
        NSError *assetCannotBePlayedError = [NSError errorWithDomain:@"Item cannot be played" code:0 userInfo:nil];
        
        //加载失败做相应处理
        [self assetFailedToPrepareForPlayback:assetCannotBePlayedError];
        
        return;
        
    }
    
    //使用正确加载的asset资源创建 AVPlayerItem 实例
    self.mPlayerItem = [AVPlayerItem playerItemWithAsset:asset];
 
    //确保播放新的资源
    if (self.mAVPlayer.currentItem != self.mPlayerItem)
    {
        //替换新的播放资源
        [self.mAVPlayer replaceCurrentItemWithPlayerItem:self.mPlayerItem];
        [self.mAVPlayerLayer setPlayer:self.mAVPlayer];
    }
}


/**
 *  加载asset发生错误
 *
 *  @param error 错误信息
 */
-(void)assetFailedToPrepareForPlayback:(NSError *)error{
    NSLog(@"assetFailedToPrepareForPlayback=====>>%@", [error description]);
}


- (void)play
{
    if (self.mAVPlayer.currentItem) {
        [self.mAVPlayer play];
    }
}

- (void)pause
{
    if (self.mAVPlayer.currentItem) {
        [self.mAVPlayer pause];
    }
}

@end