//
//  TYAudioPlayer.h
//  audioRecord
//
//  Created by Jake Hu on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYAudioPlayer : NSObject

@property (nonatomic, strong) AVAudioPlayer * audioPlayer;

// 播放指定路径下音频（wav）
- (void)playAudioWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon;

- (void)pauseCurrentPlaying;

- (void)resumeCurrentPlaying;

// 停止当前播放音频
- (void)stopCurrentPlaying;

@end

NS_ASSUME_NONNULL_END
