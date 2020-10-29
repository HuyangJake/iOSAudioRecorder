//
//  TYAudioRecorder.h
//  audioRecord
//
//  Created by Jake Hu on 2020/10/29.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TYAudioRecorder : NSObject

- (instancetype)initWithDirectoryPath:(NSString *)dirPath;

- (AVAudioRecorder *)audioRecorder;

/// 开始录音，无指定文件地址
- (void)startRecordingWithCompletion:(void(^)(NSError *error))completion;

/// 开始录音
- (void)startRecordingWithFilePath:(NSString *)aFilePath
                                completion:(void(^)(NSError *error))completion;
/// 停止录音
- (void)stopRecordingWithCompletion:(void(^)(NSString *recordPath))completion;

/// 取消录音
- (void)cancelCurrentRecording;

@end

NS_ASSUME_NONNULL_END
