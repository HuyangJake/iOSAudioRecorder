//
//  TYAudioPlayer.m
//  audioRecord
//
//  Created by Jake Hu on 2020/10/29.
//

#import "TYAudioPlayer.h"

@interface TYAudioPlayer()<AVAudioPlayerDelegate>

@property (nonatomic, copy) void(^playFinish)(NSError * error);

@property (nonatomic, assign) NSTimeInterval pausedTime;
@end

@implementation TYAudioPlayer

- (void)playAudioWithPath:(NSString *)aFilePath
                  completion:(void(^)(NSError *error))completon {
    NSFileManager * fm = [NSFileManager defaultManager];
    _playFinish = completon;
    NSError *error = nil;
    if (![fm fileExistsAtPath:aFilePath]) {
        error = [NSError errorWithDomain:@"file path not exist" code:0 userInfo:nil];
        if (_playFinish) {
            _playFinish(error);
        }

        return;
    }
    NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:aFilePath];
    
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    
    self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:wavUrl error:&error];
    if (error || !_audioPlayer) {
        error = [NSError errorWithDomain:NSLocalizedString(@"error.initPlayerFail", @"Failed to initialize AVAudioPlayer")
                                    code:0
                                userInfo:nil];
        if (_playFinish) {
            _playFinish(error);
        }
        _playFinish = nil;
        return;
    }
    _audioPlayer.delegate = self;
    [_audioPlayer prepareToPlay];
    [_audioPlayer play];
    
}

- (void)stopCurrentPlaying {
    _pausedTime = 0;
    if (_audioPlayer) {
        _audioPlayer.delegate = nil;
        [_audioPlayer stop];
        _audioPlayer = nil;
    }
    
    if (_playFinish) {
        _playFinish = nil;
    }
}

- (void)pauseCurrentPlaying {
    if (_audioPlayer) {
        [_audioPlayer pause];
        self.pausedTime = _audioPlayer.currentTime;
    }
}

- (void)resumeCurrentPlaying {
    if (_audioPlayer) {
        [_audioPlayer playAtTime:self.pausedTime];
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player
                       successfully:(BOOL)flag {
    _pausedTime = 0;
    if (_playFinish) {
        _playFinish(nil);
    }
    if (_audioPlayer) {
        _audioPlayer.delegate = nil;
        _audioPlayer = nil;
    }
    _playFinish = nil;
}

- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player
                                 error:(NSError *)error {
    if (_playFinish) {
        NSError *error = [NSError errorWithDomain:NSLocalizedString(@"error.palyFail", @"Play failure")
                                             code:0
                                         userInfo:nil];
        _playFinish(error);
    }
    if (_audioPlayer) {
        _audioPlayer.delegate = nil;
        _audioPlayer = nil;
    }
}


@end
