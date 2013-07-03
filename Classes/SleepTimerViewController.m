//
//  SleepTimerViewController.m
//  BuddhaMachine
//
//  Created by josh ott on 8/15/10.
//  Copyright 2010 Interval Studios Inc. All rights reserved.
//

#import "SleepTimerViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

//TODO background sound doesn't seem to be doing anything in simulator. Maybe categories work differently in sim, or maybe I messed up.

@implementation SleepTimerViewController

- (id)initWithTimer:(SleepTimer*)sleepTimerRef andNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil{
	if(self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]){
		sleepTimer = sleepTimerRef;
		[sleepTimer addSleepListener:self];
	}
	return self;
}
/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	// set the timer label to the sleeptimer ref current time:
	int ttime = [sleepTimer getSecondsRemaining];
	NSLog(@"ttime = %i   %i",ttime, (int)(timeSlider.value*60)*60);
	if(ttime==0){
		ttime = (int)(timeSlider.value*60)*60;	
	}
	// set the slider background color:
	UIImage *slidebg = [[UIImage imageNamed:@"bar-filled.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	UIImage *slidewhite = [[UIImage imageNamed:@"bar-blank.png"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
	UIImage *slidebut = [UIImage imageNamed:@"sliderthumb.png"];
	[timeSlider setMinimumTrackImage:slidebg forState:UIControlStateNormal];
	[timeSlider setMaximumTrackImage:slidewhite forState:UIControlStateNormal];					
	[timeSlider setThumbImage:slidebut forState:UIControlStateNormal];
    
    if([playInBackgroundSwitch respondsToSelector:@selector(onTintColor)]){
        playInBackgroundSwitch.onTintColor = [UIColor grayColor];
    }
        
    NSNumber* playInBackground = [[NSUserDefaults standardUserDefaults] objectForKey:@"playInBackground"];
    if(playInBackground == nil){
        playInBackground = [NSNumber numberWithBool:NO];
    }
	
    [playInBackgroundSwitch setOn:[playInBackground boolValue] ];
    
	// set the slider to the value:
	timeSlider.value = ((float)ttime)/(60*60);
	timeSeconds = ttime;
	//timeSlider.alpha = .8;
	[self setTimeLabelText:timeSeconds];
	//if([sleepTimer isActive]) [timeSwitch setOn:true] ;
}

-(void)setTime{
	timeSeconds = (int)(timeSlider.value*60)*60;	
	[self setTimeLabelText:timeSeconds];	
}
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/
-(void)setTextColor:(UIColor *)color{
	timelabel.textColor = color;
	titleLabel.textColor = color;
    playInBackgroundLabel.textColor = color;
}
-(IBAction)sliderReleased:(id)sender{
	NSLog(@"slider released");
	if(timeSeconds!=0){
		[sleepTimer activateTimer:timeSeconds];
        [playInBackgroundSwitch setOn:YES animated:YES ];
        [self setPlayInBackground:YES];
	}else{
        [playInBackgroundSwitch setOn:NO animated:YES ];
        [self setPlayInBackground:NO];
		[sleepTimer killTimer];
	}
}
-(IBAction)sliderValueChanged:(id)sender{
	if(![sender isKindOfClass:[UISlider class]]) return;
	UISlider *slider = (UISlider *) sender;
	NSLog(@"val=%f",(slider.value*60));	
	[self setTime];
	// update the timer:
	if(timeSeconds==0)[sleepTimer killTimer];
	[sleepTimer setSecondsRemaining:timeSeconds];
}


-(void)setPlayInBackground:(BOOL)playInBG{
    
    [[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:playInBG] forKey:@"playInBackground"];
    
    NSString* category = playInBG? AVAudioSessionCategoryPlayback : AVAudioSessionCategoryAmbient;
    
    NSError *error = nil;
    if(![[AVAudioSession sharedInstance] setCategory:category error:nil]){
        NSLog(@"ERROR: audio category %@", error);
    }
    
    
    if (![[AVAudioSession sharedInstance] setActive:YES error:&error]) {
        NSLog(@"ERROR: audio active %@", error);
    }
}

-(IBAction)playInBackgroundChanged:(id)sender{
    BOOL playInBG = playInBackgroundSwitch.on;
    
    [self setPlayInBackground:playInBG];
    
    
}

/*
-(IBAction)timerSwitchUpdated:(id)sender{
	if(![sender isKindOfClass:[UISwitch class]]) return;
	UISwitch *toggle = (UISwitch *) sender;
	[self setTime];

	if(toggle.on){
		[sleepTimer activateTimer:timeSeconds];
	}else{
		[sleepTimer killTimer];
	}
	
}*/

-(void)timerUpdated:(int)secondsRemaining{
	[self setTimeLabelText:secondsRemaining];
}
-(void)setTimeLabelText:(int)whatTime{
	if(whatTime>0){
		int seconds = whatTime % 60;
		int minutes = (whatTime - seconds) / 60;
	    timelabel.text = [NSString stringWithFormat:@"SLEEP TIMER %d:%.2d", minutes, seconds];
	}else{
		timelabel.text = @"SLEEP TIMER OFF";
	}

}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
	[sleepTimer removeListener:self];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
