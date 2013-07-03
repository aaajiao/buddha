//
//  BuddhaPlayer.m
//  BuddhaMachine
//
//  Created by Vadim Gritsenko on 8/27/08.
//  Copyright 2008 __MyCompanyName__. All rights reserved.
//

#import "BuddhaPlayer.h"
// === TODO ===
// Memory Checks
//  - audio queue leaks?


@interface BuddhaPlayer (PrivateMethods)
- (bool) allocAudioFile;
- (void) disposeAudioFile;
- (bool) allocAudioQueue;
- (void) disposeAudioQueue;
- (void) startAudioQueue;
- (void) stopAudioQueue;
- (void) fill: (AudioQueueBuffer *) buffer;
@end
static void AudioQueueBufferCallback(void                  *inUserData,
                                     AudioQueueRef          inAQ,
                                     AudioQueueBufferRef    inCompleteAQBuffer);


void CalculateBytesForTime(AudioStreamBasicDescription inDesc, UInt32 inMaxPacketSize, Float64 inSeconds, UInt32 *outBufferSize, UInt32 *outNumPackets) {
    UInt32 bufferSize;
	if (inDesc.mFramesPerPacket) {
		Float64 numPacketsForTime = inDesc.mSampleRate / inDesc.mFramesPerPacket * inSeconds;
		bufferSize = numPacketsForTime * inMaxPacketSize;
	} else {
		// variable bit rate: use default buffer size
		bufferSize = kMaxBufferSize > inMaxPacketSize ? kMaxBufferSize : inMaxPacketSize;
	}

    // Check limits
	if (bufferSize > kMaxBufferSize && bufferSize > inMaxPacketSize) {
		bufferSize = kMaxBufferSize;
	} else if (bufferSize < kMinBufferSize) {
        bufferSize = kMinBufferSize;
	}

    *outBufferSize = bufferSize;
	*outNumPackets = bufferSize / inMaxPacketSize;
}


@implementation BuddhaPlayer


#pragma mark -
#pragma mark === Startup / Shutdown ===
#pragma mark -


- (id) initWithSoundTheme: (NSString *) theme idx: (UInt32) idx volume: (AudioQueueParameterValue) volume {
    if (self = [super init]) {
        _name = [[NSString stringWithFormat: @"%@%02d", theme, idx] retain];
        _volume = volume;

        if ([self allocAudioFile] && [self allocAudioQueue]) {
            [self setVolume: volume];
            [self startAudioQueue];
        } else {
            [self release];
            self = nil;
        }
    }

    return self;
}

- (void) dealloc {
    [self disposeAudioQueue];
    [self disposeAudioFile];
    [_name release];
    [super dealloc];
}


#pragma mark -
#pragma mark === Controls ===
#pragma mark -


- (void) setVolume: (AudioQueueParameterValue) volume {
    OSStatus err;

    if (volume < 0.0) volume = 0.0;
    else if (volume > 1.0) volume = 1.0;
    err = AudioQueueSetParameter(_queue, kAudioQueueParam_Volume, volume);
    if (err) {
        NSLog(@"ERROR AudioQueueSetParameter Volume %d", err);
    }
}

- (void) stop {
    [self stopAudioQueue];
}

- (void) interrupt {
    [self stopAudioQueue];
    [self disposeAudioQueue];
}

- (void) resume {
	if(_playing)return;
    if ([self allocAudioQueue]) {
        [self setVolume: _volume];
        [self startAudioQueue];
    }
}


#pragma mark -
#pragma mark === Implementation ===
#pragma mark -


- (bool) allocAudioFile {
    OSStatus err;
    #ifndef NDEBUG
    NSLog(@"BuddhaPlayer %@: allocAudioFile", _name);
    #endif

    NSString *path = [[NSBundle mainBundle] pathForResource: _name ofType: @"caf"];
    if (path == nil) {
        NSLog(@"ERROR Missing %@", _name);
        return false;
    }

    NSURL *url = [NSURL fileURLWithPath: path isDirectory: NO];
    err = AudioFileOpenURL((CFURLRef) url, kAudioFileReadPermission, 0 /*inFileTypeHint*/, &_audioFile);
    if (err) {
        NSLog(@"ERROR AudioFileOpenURL %d: %@", err, path);
        return false;
    }

    _currentPacket = 0;
    return true;
}

- (void) disposeAudioFile {
    #ifndef NDEBUG
    NSLog(@"BuddhaPlayer %@: disposeAudioFile", _name);
    #endif

    AudioFileClose(_audioFile);
    _audioFile = NULL;
}

- (bool) allocAudioQueue {
    OSStatus err;
    #ifndef NDEBUG
    NSLog(@"BuddhaPlayer %@: allocAudioQueue", _name);
    #endif

	AudioStreamBasicDescription dataFormat;
    // Data Format          AAC
    // mSampleRate          44100
    // mFormatID            0x61616320  'aac '
    // mFormatFlags         0
    // mBytesPerPacket      0
    // mFramesPerPacket     1024
    // mBytesPerFrame       0
    // mChannelsPerFrame    2
    // mBitsPerChannel      0

    UInt32 size = sizeof(dataFormat);
    err = AudioFileGetProperty(_audioFile, kAudioFilePropertyDataFormat, &size, &dataFormat);
    if (err) {
        NSLog(@"ERROR AudioFileGetProperty %d", err);
        return false;
    }

    err = AudioQueueNewOutput(&dataFormat, AudioQueueBufferCallback, self, nil, kCFRunLoopCommonModes, 0, &_queue);
    if (err) {
        NSLog(@"ERROR AudioQueueNewOutput %d", err);
        return false;
    }

    UInt32 bufferByteSize;
    {
        // Get maximum packet size for this audio file
        UInt32 maxPacketSize = 0;
        size = sizeof(maxPacketSize);
        AudioFileGetProperty(_audioFile, kAudioFilePropertyPacketSizeUpperBound, &size, &maxPacketSize);

        // Derive buffer size and packets count
        CalculateBytesForTime(dataFormat, maxPacketSize, 0.3 /*seconds*/, &bufferByteSize, &_numPacketsToRead);

        // Allocate packet descriptors for VBR audio
        bool isFormatVBR = dataFormat.mBytesPerPacket == 0 || dataFormat.mFramesPerPacket == 0;
        if (isFormatVBR) {
            _packetDescs = malloc(sizeof(AudioStreamPacketDescription) * _numPacketsToRead);
        } else {
            _packetDescs = NULL; 
        }

        #ifndef NDEBUG
        NSLog(@"BuddhaPlayer %@: Buffer %d bytes, %d packets", _name, bufferByteSize, _numPacketsToRead);
        #endif
    }

    // Set cookie, if there is one
    size = sizeof(UInt32);
    err = AudioFileGetPropertyInfo(_audioFile, kAudioFilePropertyMagicCookieData, &size, NULL);
    if (!err && size) {
        void *cookie = malloc(size);
        err = AudioFileGetProperty(_audioFile, kAudioFilePropertyMagicCookieData, &size, cookie);
        err = AudioQueueSetProperty(_queue, kAudioQueueProperty_MagicCookie, cookie, size);
        free(cookie);
    }

    // Set channel layout, if there is one
    err = AudioFileGetPropertyInfo(_audioFile, kAudioFilePropertyChannelLayout, &size, NULL);
    if (!err && size) {
        AudioChannelLayout *acl = (AudioChannelLayout *) malloc(size);
        err = AudioFileGetProperty(_audioFile, kAudioFilePropertyChannelLayout, &size, acl);
        err = AudioQueueSetProperty(_queue, kAudioQueueProperty_ChannelLayout, acl, size);
        free(acl);
    }

    // Allocate queue buffers
    for (int i = 0; i < kNumberBuffers; ++i) {
        err = AudioQueueAllocateBuffer(_queue, bufferByteSize, &_buffers[i]);
        if (err) {
            NSLog(@"ERROR AudioQueueAllocateBuffer %d", err);
            return false;
        }
    }

    // All done
    return true;
}
-(bool) isPlaying{
	return _playing;
}
- (void) disposeAudioQueue {
    #ifndef NDEBUG
    NSLog(@"BuddhaPlayer %@: disposeAudioQueue", _name);
    #endif

    bool immediate = !_playing;
    _playing = false;

    // -1843611850      0x921cb736      ????????
    // -1604975124
    AudioQueueDispose(_queue, immediate);
    //if (err) {
    //    NSLog(@"ERROR AudioQueueDispose %d", err);
    //}
    _queue = NULL;
    free(_packetDescs);
    _packetDescs = NULL;
}
- (void) startAudioQueue {
    OSStatus err;
    #ifndef NDEBUG
    NSLog(@"BuddhaPlayer %@: startAudioQueue", _name);
    #endif
	if(_playing)return;
    // Prime queue buffers
    _playing = true;
    for (int i = 0; i < kNumberBuffers; ++i) {
        AudioQueueBufferCallback(self, _queue, _buffers[i]);
    }	

    // Start the queue
    err = AudioQueueStart(_queue, NULL);
    if (err) {
        NSLog(@"ERROR AudioQueueStart %d", err);
		_playing = false;
    }
}

- (void) stopAudioQueue {
    OSStatus err;
    #ifndef NDEBUG
    NSLog(@"BuddhaPlayer %@: stopAudioQueue", _name);
    #endif
	if(!_playing) return;
    _playing = false;
    AudioQueueStop(_queue, true);
    if (err) {
        NSLog(@"ERROR AudioQueueStop %d", err);
    }
}


#pragma mark -
#pragma mark === Audio Queue Callback ===
#pragma mark -


static void AudioQueueBufferCallback(void                  *inUserData,
                                     AudioQueueRef          inAQ,
                                     AudioQueueBufferRef    inCompleteAQBuffer) {
	BuddhaPlayer *bp = (BuddhaPlayer *) inUserData;
    [bp fill: inCompleteAQBuffer];
}

- (void) fill: (AudioQueueBuffer *) buffer {
    if (_playing) {
        OSStatus err;
        UInt32 numBytes;
        UInt32 numPackets = _numPacketsToRead;

        while (true) {
            err = AudioFileReadPackets(_audioFile, false, &numBytes, _packetDescs, _currentPacket, &numPackets, buffer->mAudioData);
            if (err) {
                // 2003334207   0x7768743F  wht?    kAudioFileUnspecifiedError
                NSLog(@"ERROR %d in callback", err);
                break;
            }

            // Zero packets read with no error: EOF condition. Restart.
            if (numPackets == 0) {
                numPackets = _numPacketsToRead;
                _currentPacket = 0;
                continue;
            }

            // Schedule buffer, completely full or just partially full (if at the end of file)
            _currentPacket += numPackets;
            buffer->mAudioDataByteSize = numBytes;
            AudioQueueEnqueueBuffer(_queue, buffer, _packetDescs ? numPackets : 0, _packetDescs);
            break;
        }
    }
}

@end
