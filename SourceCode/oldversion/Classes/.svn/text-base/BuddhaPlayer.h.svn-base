//
//  BuddhaPlayer.h
//  BuddhaMachine
//
//  Created by Vadim Gritsenko on 8/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#define kNumberBuffers 3
#define kMaxBufferSize 0x10000
#define kMinBufferSize 0x04000

@interface BuddhaPlayer : NSObject {
    NSString                       *_name;
    AudioQueueParameterValue        _volume;
    bool                            _playing;

	AudioFileID                     _audioFile;
	AudioQueueRef                   _queue;
	AudioQueueBufferRef             _buffers[kNumberBuffers];
	SInt64                          _currentPacket;
	UInt32                          _numPacketsToRead;
	AudioStreamPacketDescription   *_packetDescs;
}
-(bool) isPlaying;
- (id) initWithSoundTheme: (NSString *) theme idx: (UInt32) idx volume: (AudioQueueParameterValue) volume;
- (void) setVolume: (AudioQueueParameterValue) volume;

- (void) interrupt;
- (void) resume;

- (void) stop;

@end
