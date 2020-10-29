//
//  TYAudioRecorder.m
//  audioRecord
//
//  Created by Jake Hu on 2020/10/29.
//

#import "TYAudioRecorder.h"

@interface TYAudioRecorder()<AVAudioRecorderDelegate>
@property (nonatomic, strong) AVAudioRecorder * audioRecorder;
@property (nonatomic, copy) NSDictionary * recordSettings;
@property (nonatomic, copy) void(^recordFinish)(NSString * recordPath);

@property (nonatomic, strong) NSString * directoryPath;
@end

@implementation TYAudioRecorder

- (instancetype)initWithDirectoryPath:(NSString *)dirPath {
    if (self = [super init]) {
        self.directoryPath = dirPath;
    }
    return self;
}

- (void)setDirectoryPath:(NSString *)directoryPath {
    _directoryPath = directoryPath;
    
}

- (AVAudioRecorder *)audioRecorder {
    return _audioRecorder;
}

- (void)startRecordingWithCompletion:(void(^)(NSError *error))completion {
    NSError *error = nil;
    NSDateFormatter *formater = [NSDateFormatter new];
    [formater setDateFormat:@"yyyy_MM_dd_hh_mm_ss"];
    NSString *fileName = [formater stringFromDate:[NSDate date]];
    NSString *wavFilePath = [[self.directoryPath stringByAppendingPathComponent:fileName]                             stringByAppendingPathExtension:@"wav"];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:wavFilePath]) {
        [[NSFileManager defaultManager] createFileAtPath:wavFilePath contents:nil attributes:nil];
    }
    
    NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavFilePath];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:wavUrl
                                            settings:self.recordSettings
                                               error:&error];
    _audioRecorder.meteringEnabled = YES;
    _audioRecorder.delegate = self;

    if (!_audioRecorder || error ) {
        _audioRecorder = nil;
        if (completion) {
            completion(error);
        }
        return;
    }
    BOOL success = [_audioRecorder record];
    if (success) {
        NSLog(@"录音成功");
    }

    if (completion) {
        completion(nil);
    }
}

- (void)startRecordingWithFilePath:(NSString *)path
                  completion:(void(^)(NSError *error))completion{
    NSError *error = nil;
    NSString *wavFilePath = [[path stringByDeletingPathExtension]
                             stringByAppendingPathExtension:@"wav"];
    NSURL *wavUrl = [[NSURL alloc] initFileURLWithPath:wavFilePath];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryRecord error:nil];
    
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:wavUrl
                                            settings:self.recordSettings
                                               error:&error];
    _audioRecorder.meteringEnabled = YES;
    _audioRecorder.delegate = self;

    if (!_audioRecorder || error ) {
        _audioRecorder = nil;
        if (completion) {
            completion(error);
        }
        return;
    }
    BOOL success = [_audioRecorder record];
    if (success) {
        NSLog(@"录音成功");
    }

    if (completion) {
        completion(nil);
    }
}

- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath))completion{
    self.recordFinish = completion;
    [self.audioRecorder stop];
}
// 取消录音
- (void)cancelCurrentRecording
{
    _audioRecorder.delegate = nil;
    if (_audioRecorder.recording) {
        [_audioRecorder stop];
    }
    _audioRecorder = nil;
    _recordFinish = nil;
}

#pragma mark - AVAudioRecorderDelegate
- (void)audioRecorderDidFinishRecording:(AVAudioRecorder *)recorder
                           successfully:(BOOL)flag
{
    NSString *recordPath = [[recorder url] path];
    if (self.recordFinish) {
        if (!flag) {
            recordPath = nil;
        }
        self.recordFinish(recordPath);
    }
    self.audioRecorder = nil;
    self.recordFinish = nil;
}

- (void)audioRecorderEncodeErrorDidOccur:(AVAudioRecorder *)recorder
                                   error:(NSError *)error{
    NSLog(@"%@",error);
}



- (BOOL)checkMicrophoneAvailability{
    __block BOOL ret = NO;
    AVAudioSession *session = [AVAudioSession sharedInstance];
    if ([session respondsToSelector:@selector(requestRecordPermission:)]) {
        [session performSelector:@selector(requestRecordPermission:) withObject:^(BOOL granted) {
            ret = granted;
        }];
    } else {
        ret = YES;
    }
    
    return ret;
}

#pragma mark - Accessor

- (NSDictionary *)recordSettings {
    if (!_recordSettings) {
        _recordSettings = @{AVSampleRateKey:[NSNumber numberWithFloat:44100.0],
                             AVFormatIDKey:[NSNumber numberWithInt: kAudioFormatLinearPCM],
                             AVLinearPCMBitDepthKey:[NSNumber numberWithInt:16],
                             AVNumberOfChannelsKey:[NSNumber numberWithInt:1],
                             };
    }
    return _recordSettings;
}

@end
