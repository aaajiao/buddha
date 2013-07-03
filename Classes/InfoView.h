//
//  InfoView.h
//  BuddhaMachine
//
//  Created by John Berry on 8/27/08.
//  Copyright Agile Partners LLC 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SleepTimerViewController.h"

@class BuddhaMachineViewController;

@interface InfoView : UIView {
@public
    BuddhaMachineViewController     *_controller;

@private
    CGRect                          currentFramePosition;
    UIColor                         *textColor;
	SleepTimerViewController		*sleepTimer;
}

- (void) launchURL: (NSString *) url;
- (id) initWithFrame: (CGRect) frame controller: (BuddhaMachineViewController *) controller name: (NSString *) themeName;

@end
