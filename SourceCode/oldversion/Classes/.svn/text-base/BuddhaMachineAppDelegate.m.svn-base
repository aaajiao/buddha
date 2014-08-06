//
//  BuddhaMachineAppDelegate.m
//  BuddhaMachine
//
//  Created by John Berry on 8/26/08.
//  Copyright Agile Partners LLC 2008. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import "BuddhaMachineAppDelegate.h"
#import "BuddhaMachineViewController.h"
#import <AVFoundation/AVFoundation.h>


@interface BuddhaMachineAppDelegate (PrivateMethods)
- (void) audioSessionInterrupted;
- (void) audioSessionResumed;
@end
static void BMAudioSessionInterruptionListener(void *data, UInt32  state);


@implementation BuddhaMachineAppDelegate


#pragma mark -
#pragma mark === Startup / Shutdown ===
#pragma mark -


- (void) applicationDidFinishLaunching: (UIApplication *) application {

    NSNumber* playInBackground = [[NSUserDefaults standardUserDefaults] objectForKey:@"playInBackground"];
    if(playInBackground == nil){
        playInBackground = [NSNumber numberWithBool:NO];
        [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:NO] forKey:@"playInBackground"];
    }
    
    
    NSString* category = [playInBackground boolValue]? AVAudioSessionCategoryPlayback : AVAudioSessionCategoryAmbient;
    
    NSError *error = nil;
    if(![[AVAudioSession sharedInstance] setCategory:category error:nil]){
        NSLog(@"ERROR: audio category %@", error);
    }

    _controller = [[BuddhaMachineViewController alloc] init];
    _appWindow = [[UIWindow alloc] initWithFrame: [[UIScreen mainScreen] bounds]];

    [self setupUserDefaults];

    [_appWindow addSubview: _controller.view];
    [_appWindow makeKeyAndVisible];
	
	[_controller becomeFirstResponder];
#ifdef __IPHONE_4_0    
	UIDevice* device = [UIDevice currentDevice];     
	if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {		
		[application beginReceivingRemoteControlEvents];
	}
#endif
}

- (void) setupUserDefaults {
    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithInt: 0],                        @"lastThemeIndex",
            [NSString stringWithString: @"NO"],                 @"lastExposedValue",
            nil
        ]
    ];
}

- (void) applicationWillTerminate: (UIApplication *) application {
	NSLog(@"terminate called");
	[_controller resignFirstResponder];
#ifdef __IPHONE_4_0    
	UIDevice* device = [UIDevice currentDevice];     
	if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {		
		[application endReceivingRemoteControlEvents];
	}
#endif
	
	
    [[NSUserDefaults standardUserDefaults] synchronize];
    [_appWindow release];
    [_controller release];
}
- (void)applicationWillResignActive:(UIApplication *)application {	
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	
}

-(BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	
	

}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	[_controller becomeFirstResponder];
	[application beginReceivingRemoteControlEvents];
	// resume playback if we've been superceded by ipod (or something else);
	[_controller resume];
	//[self audioSessionResumed];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}


#pragma mark -
#pragma mark === Audio Session Callbacks ===
#pragma mark -

static void BMAudioSessionInterruptionListener (void *data, UInt32  state) {
    BuddhaMachineAppDelegate *delegate = (BuddhaMachineAppDelegate *) data;
    switch (state) {
        case kAudioSessionBeginInterruption:
            [delegate audioSessionInterrupted];
            break;
        case kAudioSessionEndInterruption:
            [delegate audioSessionResumed];
            break;
    }
}

- (void) audioSessionInterrupted {
    [_controller audioSessionInterrupted];
}

- (void) audioSessionResumed {
    OSStatus err;

    err = AudioSessionSetActive(true);
    if (err) {
        NSLog(@"ERROR Tuner: AudioSessionSetActive %d", err);
    }

    [_controller audioSessionResumed];
}

@end
