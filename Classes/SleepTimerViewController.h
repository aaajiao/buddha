//
//  SleepTimerViewController.h
//  BuddhaMachine
//
//  Created by josh ott on 8/15/10.
//  Copyright 2010 Interval Studios Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SleepTimerListener.h"
#import "SleepTimer.h"

@interface SleepTimerViewController : UIViewController <SleepTimerListener> {
	IBOutlet UILabel* timelabel;
	IBOutlet UILabel* playInBackgroundLabel;
	IBOutlet UISwitch* playInBackgroundSwitch;
	IBOutlet UILabel* titleLabel;
	IBOutlet UISlider* timeSlider;
	
	SleepTimer* sleepTimer;
	int timeSeconds;
}
-(void)setTextColor:(UIColor*)color;
//-(void)killTimer;
-(void)setTime;
-(IBAction)sliderReleased:(id)sender;
-(IBAction)sliderValueChanged:(id)sender;
-(IBAction)playInBackgroundChanged:(id)sender;
-(void)setPlayInBackground:(BOOL)playInBG;

//-(IBAction)timerSwitchUpdated:(id)sender;

-(void)setTimeLabelText:(int)whatTime;
//-(void)countDown:(NSTimer*)theTimer;
- (id)initWithTimer:(SleepTimer*)sleepTimerRef andNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil; 
@end
