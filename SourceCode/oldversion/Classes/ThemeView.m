//
//  ThemeView.m
//  BuddhaMachine
//
//  Created by John Berry on 8/26/08.
//  Copyright Agile Partners LLC 2008. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "ThemeView.h"
#import "BuddhaMachineViewController.h"

#import "UIDevice-hardware.h"

@implementation ThemeView

@synthesize exposed;


#pragma mark -
#pragma mark === Startup / Shutdown ===
#pragma mark -


+ (bool) volumeControlRequired {
    // FIXME Add condition for iPod Touch 2 - which has hardware volume control.
//    NSString *model = [UIDevice currentDevice].model;
//    return [model rangeOfString: @"iPhone"].location == NSNotFound;
	return [[UIDevice currentDevice] platformString] == IPOD_1G_NAMESTRING;
}

- (id) initWithFrame: (CGRect) frame controller: (BuddhaMachineViewController *) controller name: (NSString *) themeName version: (UInt8) currentVersion isExposed: (BOOL) isExposed {
	if (self = [super initWithFrame: frame]) {
        _controller = [controller retain];
        _name = [themeName retain];
        _version = currentVersion;
        exposed = isExposed;

        baseSkin = [[UIImageView alloc] initWithFrame: frame];
        baseSkin.userInteractionEnabled = YES;
        baseSkin.frame = frame;
        [self addSubview: baseSkin];
        
        nextButton = [[UIButton alloc] initWithFrame: CGRectMake(224, 390, 63, 63)];
        [nextButton addTarget: _controller action: @selector(nextTrack:) forControlEvents: UIControlEventTouchUpInside];
        [self addSubview: nextButton];
        
        logoButton = [[UIButton alloc] initWithFrame: CGRectMake(160 - (84 / 2), 344, 84, 43)];
        [logoButton addTarget: _controller action: @selector(showInfo:) forControlEvents: UIControlEventTouchUpInside];
        [self addSubview: logoButton];
        
        // Volume slider for iPod Touch
        if ([ThemeView volumeControlRequired]) {
            MPVolumeView *volumeView = [[MPVolumeView alloc] initWithFrame: CGRectMake(24, 406, 180, 0)];
            [volumeView sizeToFit];
            // Check if it has UISlider
            NSArray *subViews = [volumeView subviews];
            if ([subViews count] > 0 && [[subViews objectAtIndex: 0] isKindOfClass: [UISlider class]]) {
                // Dress up UISlider
                UISlider *volumeSlider = (UISlider *) [subViews objectAtIndex: 0];
                UIImage *thumbImage = [UIImage imageNamed: @"slider-thumb.png"];
                [volumeSlider setThumbImage: thumbImage forState: UIControlStateNormal];
                UIImage *sliderBG = [[UIImage imageNamed: @"slider-bg.png"] stretchableImageWithLeftCapWidth: 4.0 topCapHeight: 4.0];
                [volumeSlider setMinimumTrackImage: sliderBG forState: UIControlStateNormal];
                [volumeSlider setMaximumTrackImage: sliderBG forState: UIControlStateNormal];
            }

            [self addSubview: volumeView];
            [volumeView release];
        }

        if (exposed) {
            [self expose];
        } else {
            [self unexpose];
        }
	}

	return self;
}

- (void) dealloc {
    [baseSkin release];
    [nextButton release];
    [logoButton release];
    [_controller release];
	[super dealloc];
}


#pragma mark -
#pragma mark === Exposed ===
#pragma mark -


- (void) expose {
    NSString *openImageName = [NSString stringWithFormat: @"%@-open.jpg", _name];
    baseSkin.image = [UIImage imageNamed: openImageName];
    [nextButton setImage: nil forState: UIControlStateNormal];
    [logoButton setImage: nil forState: UIControlStateNormal];
}

- (void) unexpose {
    NSString *baseName = [NSString stringWithFormat: @"%@-face.jpg", _name];
    baseSkin.image = [UIImage imageNamed: baseName];
    
    NSString *nextImageName = [NSString stringWithFormat: @"%@-round-button.png", _name];
    UIImage *nextImage = [UIImage imageNamed: nextImageName];
    [nextButton setImage: nextImage forState: UIControlStateNormal];
    nextButton.adjustsImageWhenHighlighted = YES;
    
    NSString *logoImageName = @"fm3-logo-2.png";
    UIImage *logoImage = [UIImage imageNamed: logoImageName];
    [logoButton setImage: logoImage forState: UIControlStateNormal];
    logoButton.adjustsImageWhenHighlighted = YES;
}

- (void) toggleExposedMachine {
    if (exposed) {
        [self unexpose];
        exposed = NO;
    } else {
        [self expose];
        exposed = YES;
    }
}


@end
