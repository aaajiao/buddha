//
//  SleepTimer.h
//  BuddhaMachine
//
//  Created by josh ott on 8/16/10.
//  Copyright 2010 Interval Studios Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SleepTimerListener.h"

@interface SleepTimer : NSObject {
	NSTimer* countdownTimer;
	NSMutableSet *listeners;
	int ttime;
}
//-(NSTimer*)getTimer;
-(int)getSecondsRemaining;
-(void)setSecondsRemaining:(int)sec;

-(void)addSleepListener:(id<SleepTimerListener>)newListener;
-(void)removeListener:(id<SleepTimerListener>)listener;

-(void)countDown:(NSTimer*)theTimer;
-(void)killTimer;
-(bool) isActive;

-(void)activateTimer:(int)totalSeconds;

@end
