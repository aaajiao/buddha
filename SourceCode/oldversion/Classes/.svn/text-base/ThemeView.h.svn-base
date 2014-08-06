//
//  ThemeView.h
//  BuddhaMachine
//
//  Created by John Berry on 8/26/08.
//  Copyright Agile Partners LLC 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BuddhaMachineViewController;

@interface ThemeView : UIView {
    BuddhaMachineViewController     *_controller;
    NSString                        *_name;
    UInt8                           _version;
    BOOL                            exposed;
    
    UIImageView                     *baseSkin;
    UIButton                        *nextButton;
    UIButton                        *logoButton;
}

@property (readonly) BOOL exposed;

- (id) initWithFrame: (CGRect) frame controller: (BuddhaMachineViewController *) controller name: (NSString *) themeName version: (UInt8) currentVersion isExposed: (BOOL) isExposed;

- (void) expose;
- (void) unexpose;
- (void) toggleExposedMachine;

@end
