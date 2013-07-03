//
//  BuddhaMachineAppDelegate.m
//  BuddhaMachine
//
//  Created by John Berry on 8/26/08.
//  Copyright Agile Partners LLC 2008. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "BuddhaMachineViewController.h"
#import "InfoView.h"


#define kHorizSwipeMin              100
#define kVertSwipeMax               100
#define kTransitionDurationFast     0.1
#define kTransitionDurationSlow     0.5

@implementation BuddhaMachineViewController


#pragma mark -
#pragma mark === Startup / Shutdown ===
#pragma mark -


- (id) init {
    if (self = [super init]) {
        _currentVersionIdx = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastVersionIndex"];
        if (!_currentVersionIdx) _currentVersionIdx = 3;
        

//
//        _themeNames = [[NSArray alloc] initWithObjects: @"pink", @"blue", @"orange", @"white", @"red", @"green", @"black", @"lime", @"grey", @"teal", @"brown", @"purple", nil];
//        _currentThemeIdx = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastThemeIndex"];
//        
//        _themeNames_v2 = [[NSArray alloc] initWithObjects: @"lime", @"purple", @"pink", @"blue", @"orange", @"white", @"red", @"green", @"black", @"lime", @"grey", @"teal", @"brown", nil];
//        _currentThemeIdx_v2 = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastThemeIndex_v2"];
//
//        _themeNames_v3 = [[NSArray alloc] initWithObjects: @"grey", @"pink", @"blue", @"orange", @"white", @"red", @"green", @"black", @"teal", @"brown", @"purple", nil];
//        _currentThemeIdx_v3 = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastThemeIndex_v2"];

        
        allThemeNames = [[NSArray arrayWithObjects:@"pink", @"blue", @"orange", @"white", @"red", @"green", @"black", @"lime", @"grey", @"teal", @"brown",  @"purple", @"black", nil] retain];

        _themeNames = allThemeNames;
        _currentThemeIdx = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastThemeIndex"];
        
        _themeNames_v2 = allThemeNames;
        _currentThemeIdx_v2 = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastThemeIndex_v2"];

        _themeNames_v3 = allThemeNames;
        _currentThemeIdx_v3 = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastThemeIndex_v2"];

        _currentSoundTheme = [[NSString stringWithFormat:@"v%i_hi", _currentVersionIdx] retain];
        _currentSoundIdx = [[NSUserDefaults standardUserDefaults] integerForKey: @"lastSoundIndex"];
        if (!_currentSoundIdx) _currentSoundIdx = 1;
		
		sleepTimer = [[SleepTimer alloc] init];
		[sleepTimer addSleepListener:self];
    }

    return self;
}
-(BOOL)canBecomeFirstResponder {
    return YES;
}
- (void)remoteControlReceivedWithEvent:(UIEvent*)event {
    if (event.type == UIEventTypeRemoteControl) {
        switch(event.subtype) {
            case UIEventSubtypeRemoteControlPlay:
				NSLog(@"play");
				[self resume];
                break;
            case UIEventSubtypeRemoteControlPause:
				NSLog(@"pause");
				[self pause];
                break;
            case UIEventSubtypeRemoteControlStop:
				NSLog(@"stop");
				[self pause];
                break;
			case UIEventSubtypeRemoteControlTogglePlayPause:
				NSLog(@"play pause toggle");
				if([_player isPlaying]){
					[self pause];
				}else{
					[self resume];
				}
                break;
			case UIEventSubtypeRemoteControlNextTrack:
				NSLog(@"next trqack");
				[self nextTrack:self];
                break;
			case UIEventSubtypeRemoteControlPreviousTrack:
				NSLog(@"prev track");
				[self previousTrack:self];
				break;
            default:
                return;
		}
    }
}
- (void) loadView {
    CGRect frame = [[UIScreen mainScreen] bounds];
    UIView *contentView = [[UIView alloc] initWithFrame: frame];
    
    BOOL isExposed = [[[NSUserDefaults standardUserDefaults] valueForKey: @"lastExposedValue"] boolValue];

    ThemeView *curTheme = [[ThemeView alloc] initWithFrame: frame controller: self name: [self getCurrentTheme] version: _currentVersionIdx isExposed: isExposed];
    [contentView addSubview: curTheme];
    [curTheme release];

    self.view = contentView;
    [contentView release];
    
    [[UIAccelerometer sharedAccelerometer] setUpdateInterval: 1.0 / 20.0];
    [[UIAccelerometer sharedAccelerometer] setDelegate: self];
}
-(SleepTimer *)getSleepTimer{
	return sleepTimer;
}
- (void) dealloc {
    [allThemeNames release];
    [_currentSoundTheme release];
    [_player release];
    [super dealloc];
}


#pragma mark -
#pragma mark === System Callbacks ===
#pragma mark -


- (void) viewWillAppear: (BOOL) animated {
    _player = [[BuddhaPlayer alloc] initWithSoundTheme: _currentSoundTheme idx: _currentSoundIdx volume: 1.0];
    [super viewWillAppear: animated];
}

- (void) viewWillDisappear: (BOOL) animated {
    // release player, it will finish playback async
    [_player release];
    _player = nil;
    [super viewWillDisappear: animated];
}

- (BOOL) shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	return interfaceOrientation == UIInterfaceOrientationPortrait;
}

- (void) didReceiveMemoryWarning {
	[super didReceiveMemoryWarning];
}
-(void) pause{
	paused = true;
	[self audioSessionInterrupted];
}
-(void) resume{
	paused = false;
	[self audioSessionResumed];
}

- (void) audioSessionInterrupted {
    [_player interrupt];
}

- (void) audioSessionResumed {
	if(!paused)[_player resume];
}


#pragma mark -
#pragma mark === UI Actions ===
#pragma mark -


- (UInt8) getVersionSelection {
    return (_currentVersionIdx - 1);
}


- (id) getCurrentTheme {
//    if (_currentVersionIdx == 2) {
//        return [_themeNames_v2 objectAtIndex: _currentThemeIdx_v2];
//    }
    return [_themeNames objectAtIndex: _currentThemeIdx];
}


- (id) getNextTheme: (UInt8) themeIdx {
//    if (_currentVersionIdx == 2) {
//        return [_themeNames_v2 objectAtIndex: themeIdx];
//    }
    return [_themeNames objectAtIndex: themeIdx];
}


- (void) decrementThemeIdx {
    // modulus operator doesn't work the way I expected on negatives...
    // hmm, I guess these are unsigned ints, so... not really negative, just rolled over... oops
//    if (_currentVersionIdx == 2) {
//        _currentThemeIdx_v2 = ([_themeNames_v2 count] + _currentThemeIdx_v2 - 1) % ([_themeNames_v2 count]);
//        [[NSUserDefaults standardUserDefaults] setInteger: _currentThemeIdx_v2 forKey: @"lastThemeIndex_v2"];
//    } else {
        _currentThemeIdx = ([_themeNames count] + _currentThemeIdx - 1) % ([_themeNames count]);
        [[NSUserDefaults standardUserDefaults] setInteger: _currentThemeIdx forKey: @"lastThemeIndex"];
//    }
}


- (void) incrementThemeIdx {
//    if (_currentVersionIdx == 2) {
//        _currentThemeIdx_v2 = (_currentThemeIdx_v2 + 1) % ([_themeNames_v2 count]);
//        [[NSUserDefaults standardUserDefaults] setInteger: _currentThemeIdx_v2 forKey: @"lastThemeIndex_v2"];
//    } else {
        _currentThemeIdx = (_currentThemeIdx + 1) % ([_themeNames count]);
        [[NSUserDefaults standardUserDefaults] setInteger: _currentThemeIdx forKey: @"lastThemeIndex"];
//    }
}


- (void) changeVersionSelection: (id) sender {
    _currentVersionIdx = [sender selectedSegmentIndex] + 1;
    [[NSUserDefaults standardUserDefaults] setInteger: _currentVersionIdx forKey: @"lastVersionIndex"];

    [self transitionToThemeName: [self getCurrentTheme] duration: kTransitionDurationSlow];
    [self startTrack];
}

- (void) previousTrack: (id) sender{
	_currentSoundIdx--;
	[self startTrack];
}
- (IBAction) nextTrack: (id) sender {
    _currentSoundIdx++;
    [self startTrack];
}


- (void) startTrack {
    // immediately stop previous track

    [_player stop];
    [_player release];
    _player = nil;

    _currentSoundTheme = [NSString stringWithFormat:@"v%i_hi", _currentVersionIdx];
	
    while (true) {
        [[NSUserDefaults standardUserDefaults] setInteger: _currentSoundIdx forKey: @"lastSoundIndex"];
        _player = [[BuddhaPlayer alloc] initWithSoundTheme: _currentSoundTheme idx: _currentSoundIdx volume: 1.0];
        if (_player) break;
        _currentSoundIdx = 1;
    }
}

- (void) nextTheme: (float) transitionSpeed {
    if ([[self.view subviews] count] > 1) {
        return;
    }

    [self incrementThemeIdx];
    [self transitionFromThemeIdx: 0 toThemeName: [self getCurrentTheme] duration: transitionSpeed];
}

- (void) previousTheme: (float) transitionSpeed {
    [self decrementThemeIdx];
    [self transitionFromThemeIdx: 0 toThemeName: [self getCurrentTheme] duration: transitionSpeed];
}

- (void) transitionFromThemeIdx: (UInt8) oldThemeIdx toThemeName: (NSString *) newThemeName duration: (float) duration {
    CGRect frame = [[UIScreen mainScreen] bounds];
    ThemeView *oldTheme = (ThemeView *) [[self.view subviews] objectAtIndex: 0];
    ThemeView *newTheme = [[ThemeView alloc] initWithFrame: frame controller: self name: newThemeName version: _currentVersionIdx isExposed: oldTheme.exposed];
    

    [oldTheme removeFromSuperview];
    [self.view addSubview: newTheme];
    [newTheme release];

	// Set up the animation
	CATransition *animation = [CATransition animation];
    animation.type = kCATransitionFade;
	animation.duration = duration;
	animation.timingFunction = [CAMediaTimingFunction functionWithName: kCAMediaTimingFunctionEaseInEaseOut];
	animation.delegate = self;
	[[self.view layer] addAnimation: animation forKey: @"transitionViewAnimation"];
}

- (void) transitionToThemeName: (NSString *) newThemeName duration: (float) duration {
    CGRect frame = [[UIScreen mainScreen] bounds];
    ThemeView *oldTheme = (ThemeView *) [[self.view subviews] objectAtIndex: 0];
    InfoView *oldInfo = (InfoView *) [[self.view subviews] objectAtIndex: 1];
    ThemeView *newTheme = [[ThemeView alloc] initWithFrame: frame controller: self name: newThemeName version: _currentVersionIdx isExposed: oldTheme.exposed];
    InfoView *newInfo = [[InfoView alloc] initWithFrame: frame controller: self name: newThemeName];
    

    [oldTheme removeFromSuperview];
    [oldInfo removeFromSuperview];
    [self.view addSubview: newTheme];
    [self.view addSubview: newInfo];
    [newTheme release];
    [newInfo release];
}
-(void)setVolume:(float) volume{
	[_player setVolume:volume];
}

- (IBAction) showInfo: (id) sender {
    CGRect frame = [[UIScreen mainScreen] bounds];
    InfoView *iView = [[InfoView alloc] initWithFrame: frame controller: self name: [self getCurrentTheme]];
    
    [UIView beginAnimations: nil context: NULL];
        [UIView setAnimationDuration: 0.5];
        [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromRight forView: self.view cache: YES];
        [self.view addSubview: iView];
    [UIView commitAnimations];
    [iView release];
}

- (IBAction) clearInfo: (id) sender {
    if ([[self.view subviews] count] < 2) {
        return;
    }
    InfoView *iView = (InfoView *) [[self.view subviews] objectAtIndex: 1];
    
    [UIView beginAnimations: nil context: NULL];
        [UIView setAnimationDuration: 0.5];
        [UIView setAnimationTransition: UIViewAnimationTransitionFlipFromLeft forView: self.view cache: YES];
        [iView removeFromSuperview];
    [UIView commitAnimations];
}

- (void) toggleExposedMachine {
    if ([[self.view subviews] count] > 1) {
        return;
    }
    
    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
    ThemeView *curTheme = (ThemeView *) [[self.view subviews] objectAtIndex: 0];
    [curTheme toggleExposedMachine];
    
    NSString *boolString = curTheme.exposed ? @"YES" : @"NO";
    [[NSUserDefaults standardUserDefaults] setValue: boolString forKey: @"lastExposedValue"];
}


#pragma mark -
#pragma mark === Touches ===
#pragma mark -


- (void) touchesBegan: (NSSet *) touches withEvent: (UIEvent *) event {
    UITouch *touch = [touches anyObject];
    startTouchPosition = [touch locationInView: self.view];
}

- (void) touchesMoved: (NSSet *) touches withEvent: (UIEvent *) event {
    UITouch *touch = touches.anyObject;
    CGPoint currentTouchPosition = [touch locationInView: self.view];

    // If the swipe tracks correctly.
    if (fabsf(startTouchPosition.x - currentTouchPosition.x) >= kHorizSwipeMin &&
        fabsf(startTouchPosition.y - currentTouchPosition.y) <= kVertSwipeMax) {
        
        if ([[self.view subviews] count] > 1) {
            return;
        }
        
        // It appears to be a swipe.
        if (startTouchPosition.x < currentTouchPosition.x)
            [self previousTheme: kTransitionDurationSlow];
        else
            [self nextTheme: kTransitionDurationSlow];
    }
}


- (void) animationDidStart: (CAAnimation *) animation {
    // FIXME: need to set _transitioning here. Needs delegate stuff
}



#pragma mark -
#pragma mark === UIAccelerometerDelegate ===
#pragma mark -


- (void) accelerometer: (UIAccelerometer *) accelerometer didAccelerate: (UIAcceleration *) acceleration {
    UIAccelerationValue v = acceleration.x * acceleration.x + acceleration.y * acceleration.y + acceleration.z * acceleration.z;
    if (_lastAccelerometerReading < 8.0 && v > 8.0) {
        //[self toggleExposedMachine];
        [self nextTheme: kTransitionDurationFast];
    }
    _lastAccelerometerReading = v;
}
#pragma mark -
#pragma mark === SleepTimerListener ===
#pragma mark -

-(void)timerUpdated:(int)secondsRemaining{
	if(secondsRemaining<60){
		// fade out the last minute;
		NSLog(@" fade at %f",(float)secondsRemaining/60);
		[_player setVolume:(float)secondsRemaining/60];
	}	
    if(secondsRemaining <= 0)
    {		
		exit(0);
    }
}

@end
