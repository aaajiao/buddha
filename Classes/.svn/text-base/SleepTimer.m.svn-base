//
//  SleepTimer.m
//  BuddhaMachine
//
//  Created by josh ott on 8/16/10.
//  Copyright 2010 Interval Studios Inc. All rights reserved.
//

#import "SleepTimer.h"


@implementation SleepTimer
-(id)init{
	if (self = [super init]) {
		listeners = [[NSMutableSet alloc] init];
		ttime = 0;
	}
	return self;
}
-(void)addSleepListener:(id<SleepTimerListener>)newListener{
	[listeners addObject:newListener];
}
-(void)removeListener:(id<SleepTimerListener>)listener{
	[listeners removeObject:listener];
}

//-(NSTimer*)getTimer{
//}
-(bool)isActive{
	if(countdownTimer!=nil){
		return YES;
	}else{
		return NO;
	}
}
-(int)getSecondsRemaining{
	return ttime;
}
-(void)setSecondsRemaining:(int)sec{
	ttime = sec;
}
-(void)activateTimer:(int)totalSeconds{
	[self killTimer];
	[self setSecondsRemaining:totalSeconds];
	countdownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 
													  target:self 
													selector:@selector(countDown:) 
													userInfo:nil 
													 repeats:YES];
}
-(void)killTimer{
	if(countdownTimer!=nil){
		[countdownTimer invalidate];
		countdownTimer = nil;
		//[countdownTimer release];
	}
}
-(void)countDown:(NSTimer*)theTimer{
	
    ttime -= 1;
	NSLog(@"countdown %i",ttime);
	
	for(id<SleepTimerListener> listener in listeners){
		[listener timerUpdated:ttime];
	}
	if(ttime<=0){
		[self killTimer];
	}	
}
- (void)dealloc {		
	[self killTimer];
	[listeners release];
    [super dealloc];
}

@end

