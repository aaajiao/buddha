//
//  BuddhaMachineViewController.h
//  BuddhaMachine
//
//  Created by John Berry on 8/26/08.
//  Copyright Agile Partners LLC 2008. All rights reserved.
//

#import "ThemeView.h"
#import "BuddhaPlayer.h"
#import "SleepTimerListener.h"
#import "SleepTimer.h"

@interface BuddhaMachineViewController : UIViewController <UIAccelerometerDelegate,SleepTimerListener>{
    UInt8           _currentVersionIdx;
    
    CGPoint         startTouchPosition;
    NSArray*        allThemeNames;
    NSArray         *_themeNames;
    UInt8           _currentThemeIdx;
    NSArray         *_themeNames_v2;
    UInt8           _currentThemeIdx_v2;
    NSArray         *_themeNames_v3;
    UInt8           _currentThemeIdx_v3;

    NSString        *_currentSoundTheme;
    UInt8           _currentSoundIdx;
    BuddhaPlayer    *_player;
    
    UIAccelerationValue _lastAccelerometerReading;
	bool paused;
	
	SleepTimer* sleepTimer;
}

- (UInt8) getVersionSelection;
- (id) getCurrentTheme;
- (id) getNextTheme: (UInt8) themeIdx;
- (void) decrementThemeIdx;
- (void) incrementThemeIdx;

- (void) previousTheme: (float) transitionSpeed;
- (void) nextTheme: (float) transitionSpeed;
-(void)setVolume:(float) volume;
- (void) previousTrack: (id) sender;
- (void) nextTrack: (id) sender;
- (void) startTrack;

- (void) transitionFromThemeIdx: (UInt8) oldThemeIdx toThemeName: (NSString *) newThemeName duration: (float) duration;
- (void) transitionToThemeName: (NSString *) newThemeName duration: (float) duration;

- (void) toggleExposedMachine;

-(void) pause;
-(void) resume;

- (void) audioSessionInterrupted;
- (void) audioSessionResumed;

-(SleepTimer *)getSleepTimer;

@end

