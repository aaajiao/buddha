//
//  InfoView.m
//  BuddhaMachine
//
//  Created by John Berry on 8/27/08.
//  Copyright Agile Partners LLC 2008. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "InfoView.h"
#import "BuddhaMachineViewController.h"

#define XTRA_LARGE_FONT 17.0
#define LARGE_FONT      12.0
#define SMALL_FONT      11.0
#define LARGE_SPACING   28.0
#define SMALL_SPACING   22.0
#define DIVIDER_SPACING 20.0

@interface InfoView (hidden)
- (void) renderTitle: (NSString *) titleText;
- (void) renderToggle: (NSArray *) options;
- (void) renderLabel: (NSString *) labelText;
- (void) renderLink: (SEL) link withLabel: (NSString *) labelText;
- (void) renderDivider;
@end


@implementation InfoView

#pragma mark -
#pragma mark === Startup / Shutdown ===
#pragma mark -


- (id) initWithFrame: (CGRect) frame controller: (BuddhaMachineViewController *) controller name: (NSString *) themeName {
	if (self = [super initWithFrame: frame]) {
        _controller = [controller retain];

        NSString *baseName = [NSString stringWithFormat: @"%@-back.jpg", themeName];
        UIImageView *baseSkin = [[UIImageView alloc] initWithImage: [UIImage imageNamed: baseName]];
        [baseSkin setUserInteractionEnabled: YES];
        baseSkin.frame = frame;
        [self addSubview: baseSkin];
        [baseSkin release];

        UIButton *returnButton = [[UIButton alloc] initWithFrame: CGRectMake(0, 342, 320, 130)];
        [returnButton addTarget: _controller action: @selector(clearInfo:) forControlEvents: UIControlEventTouchDown];
        // FIXME There is no image to highlight.
        // returnButton.adjustsImageWhenHighlighted = YES;
        [self addSubview: returnButton];
        [returnButton release];


        currentFramePosition = CGRectMake(0, 18, frame.size.width, 30);
        textColor = [UIColor whiteColor];
        if (themeName == @"white") {
            textColor = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 1.0];
        }


        [self renderTitle: @"Buddha Machine"];
        [self renderToggle: [NSArray arrayWithObjects: @"1", @"2",@"3", nil]];

        [self renderDivider];

        // Music and Design
        [self renderLabel: @"MUSIC AND DESIGN"];
        [self renderLabel: @"Christiaan Virant and Zhang Jian"];
        [self renderLink: @selector(launchFM3URL:) withLabel: @"www.fm3buddhamachine.com"];
        [self renderLink: @selector(launchChineseURL:) withLabel: @"www.fm3.com.cn"];

        [self renderDivider];

        // Application Development
        [self renderLabel: @"APPLICATION DEVELOPMENT"];
        
//		UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(0, currentFramePosition, 40, 10)];
		UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
		button.frame = CGRectMake(227, currentFramePosition.origin.y+5, 80, 20);
		//button.buttonType = UIButtonTypeCustom;
		[button addTarget: self action: @selector(launchIntervalURL:) forControlEvents: UIControlEventTouchDown];
		[self addSubview: button];
		//[button release];
		
		[self renderLabel: @"Agile Partners, FM3, Jason Forrest, Joshue Ott"];
       // [self renderLink: @selector(launchAgileURL:) withLabel: @"www.agilepartners.com"];
		[self renderDivider];
		// Application Development
		//[self renderLabel: @"SLEEP TIMER"];
		sleepTimer = [[SleepTimerViewController alloc]initWithTimer:[_controller getSleepTimer] andNibName:@"SleepTimerViewController" bundle:[NSBundle mainBundle]];
		[self addSubview:sleepTimer.view];
		sleepTimer.view.frame = CGRectMake(currentFramePosition.origin.x, 
										   currentFramePosition.origin.y, 
										   currentFramePosition.size.width, 
										   sleepTimer.view.frame.size.height);
		[sleepTimer setTextColor:textColor];
		
		
	}

	return self;
}

- (void) dealloc {
	[sleepTimer release];
    [_controller release];
	[super dealloc];
}


#pragma mark -
#pragma mark === UI Formatting ===
#pragma mark -


- (void) renderTitle: (NSString *) titleText {
    UILabel *label = [[UILabel alloc] initWithFrame: currentFramePosition];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName: @"Helvetica-Bold" size: XTRA_LARGE_FONT];
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.layer.opacity = 0.8;
    label.text = titleText;
    [self addSubview: label];
    [label release];

    currentFramePosition = CGRectOffset(currentFramePosition, 0, LARGE_SPACING);
}

- (void) renderLabel: (NSString *) labelText {
    UILabel *label = [[UILabel alloc] initWithFrame: currentFramePosition];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName: @"Helvetica-Bold" size: LARGE_FONT];
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.text = labelText;
    [self addSubview: label];
    [label release];

    currentFramePosition = CGRectOffset(currentFramePosition, 0, SMALL_SPACING);
}

- (void) renderToggle: (NSArray *) options {
    UISegmentedControl *segmentedControl = [[UISegmentedControl alloc] initWithItems:options];
    segmentedControl.frame = CGRectMake((self.frame.size.width / 2) - 70 , currentFramePosition.origin.y+5, 140, 30);

    segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    segmentedControl.tintColor = [UIColor colorWithRed: 0.5 green: 0.5 blue: 0.5 alpha: 1.0];
    segmentedControl.layer.opacity = 0.5;
    segmentedControl.selectedSegmentIndex = [_controller getVersionSelection];
    
    [segmentedControl addTarget: _controller action: @selector(changeVersionSelection:) forControlEvents: UIControlEventValueChanged];
    [self addSubview:segmentedControl];
    [segmentedControl release];

    currentFramePosition = CGRectOffset(currentFramePosition, 0, LARGE_SPACING);
}

- (void) renderLink: (SEL) link withLabel: (NSString *) labelText {
    UILabel *label = [[UILabel alloc] initWithFrame: currentFramePosition];
    label.textAlignment = UITextAlignmentCenter;
    label.font = [UIFont fontWithName: @"Helvetica-Bold" size: SMALL_FONT];
    label.textColor = textColor;
    label.backgroundColor = [UIColor clearColor];
    label.text = labelText;
    [self addSubview: label];
    [label release];

    UIButton *button = [[UIButton alloc] initWithFrame: currentFramePosition];
    [button addTarget: self action: link forControlEvents: UIControlEventTouchDown];
    [self addSubview: button];
    [button release];

    currentFramePosition = CGRectOffset(currentFramePosition, 0, SMALL_SPACING);
}

- (void) renderDivider {
    currentFramePosition = CGRectOffset(currentFramePosition, 0, DIVIDER_SPACING);
}


#pragma mark -
#pragma mark === UI Actions ===
#pragma mark -
- (IBAction) sliderMoved: (id) sender {
	if(![sender isKindOfClass:[UISlider class]]) return;
	UISlider *slider = (UISlider *) sender;
	NSLog(@"val=%f",slider.value*60);
}

- (IBAction) sliderReleased: (id) sender {
	NSLog(@"slider released");
}

- (IBAction) launchFM3URL: (id) sender {
    [self launchURL: @"http://www.fm3buddhamachine.com"];
}

- (IBAction) launchAgileURL: (id) sender {
    [self launchURL: @"http://www.agilepartners.com"];
}

- (IBAction) launchChineseURL: (id) sender {
    [self launchURL: @"http://www.fm3.com.cn"];
}

- (IBAction) launchIntervalURL: (id) sender {
    [self launchURL: @"http://www.intervalstudios.com"];
}


- (void) launchURL: (NSString *) url {
    [[UIApplication sharedApplication] openURL: [NSURL URLWithString: url]];
}

@end
