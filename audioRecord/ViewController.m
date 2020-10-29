//
//  ViewController.m
//  audioRecord
//
//  Created by Jake Hu on 2020/10/29.
//

#import "ViewController.h"
#import <AVFoundation/AVFoundation.h>
#import "TYAudioRecorder.h"
#import "TYAudioPlayer.h"

@interface ViewController ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *data;

@property (nonatomic, strong) TYAudioRecorder *recorder;

@property (nonatomic, strong) TYAudioPlayer *player;

@property (nonatomic, strong) NSString *selectedSoundPath;
@property (weak, nonatomic) IBOutlet UIButton *playbtn;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.data = [NSMutableArray new];
    self.player = [TYAudioPlayer new];
    NSString *documentPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES).firstObject;
    self.recorder = [[TYAudioRecorder alloc] initWithDirectoryPath:documentPath];
    [self readExistFiles:documentPath];
}

- (void)readExistFiles:(NSString *)dirPath {
    NSArray *files = [[NSFileManager defaultManager] subpathsAtPath:dirPath];
    for (NSString *path in files) {
        BOOL isDir = NO;
        [[NSFileManager defaultManager] fileExistsAtPath:path isDirectory:&isDir];
        if (!isDir) {
            [self.data addObject:[dirPath stringByAppendingPathComponent:path]];
        }
    }
    [self.tableView reloadData];
}

- (IBAction)playAciton:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self play];
    } else {
        [self pause];
    }
}

- (void)play {
    if (self.player.audioPlayer) {
        [self.player resumeCurrentPlaying];
    }
    
    __weak typeof(self)weak_self = self;
    if (self.selectedSoundPath) {
        [self.player playAudioWithPath:self.selectedSoundPath completion:^(NSError * _Nonnull error) {
            weak_self.playbtn.selected = NO;
            if (!error) {
                NSLog(@"播放结束");
            } else {
                NSLog(@"%@", error.localizedDescription);
            }
        }];
    } else {
        NSLog(@"数据为空，请选择音频文件");
        weak_self.playbtn.selected = NO;
    }
}

- (void)pause {
    if (self.player.audioPlayer.isPlaying) {
        [self.player pauseCurrentPlaying];
    }
}

- (void)stopPalying {
    if (self.player.audioPlayer.isPlaying) {
        [self.player stopCurrentPlaying];
        self.playbtn.selected = NO;
    }
}

- (void)recordStart {
    [self.recorder startRecordingWithCompletion:^(NSError * _Nonnull error) {
        
    }];
}

- (void)recordEnd {
    
    if (!self.recorder.audioRecorder.isRecording) {
        return;
    }
    __weak typeof(self) weak_self = self;
    [self.recorder stopRecordingWithCompletion:^(NSString * _Nonnull recordPath) {
        [weak_self.data addObject:recordPath];
        [weak_self.tableView reloadData];
    }];
}


- (IBAction)recordTriggerAction:(UIButton *)sender {
    sender.selected = !sender.isSelected;
    if (sender.isSelected) {
        [self recordStart];
    } else {
        [self recordEnd];
    }
}

#pragma mark - tableView Delegate

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"];
        cell.textLabel.textColor = [UIColor darkTextColor];
    }
    cell.textLabel.text = [self.data[indexPath.row] pathComponents].lastObject;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedSoundPath = self.data[indexPath.row];
    [self stopPalying];
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *item = self.data[indexPath.row];
    
    UITableViewRowAction *share = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"分享" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [self shareAction:item];
        [tableView setEditing:NO animated:YES];
    }];
    share.backgroundColor = [UIColor systemYellowColor];

    return @[share];
}

- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - share

- (void)shareAction:(NSString *)filePath {
    UIActivityViewController *activityController = [[UIActivityViewController alloc] initWithActivityItems:@[[NSURL fileURLWithPath:filePath]] applicationActivities:nil];
    [self presentViewController:activityController animated:YES completion:nil];
}

@end
