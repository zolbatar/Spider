//  Spider
//  PreferenceController.h
//
//  Created by Daryl Dudey on 12/06/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

extern NSString *PSUD_GridSize;
extern NSString *PSUD_GridSnap;
extern NSString *PSUD_ComponentScrollOnSelect;
extern NSString *PSUD_ComponentDropAlign;
extern NSString *PSUD_ShowAnimations;
extern NSString *PSUD_ShowAnimationsFlow;
extern NSString *PSUD_ConnectionsCopy;

@interface PSPreferenceController : NSWindowController 
{
	IBOutlet NSTextField *textfieldGridSize;
	IBOutlet NSButton *buttonGridSnap;
	IBOutlet NSButton *buttonComponentScrollOnSelect;
	IBOutlet NSMatrix *matrixComponentDropAlign;
	IBOutlet NSButton *buttonShowAnimations;
	IBOutlet NSButton *buttonShowAnimationsFlow;
	IBOutlet NSMatrix *matrixCopyConnections;
}

#pragma mark Methods
- (void) updateWindow;

#pragma mark Actions
- (IBAction) actionGridSize:(NSTextField *)sender;
- (IBAction) actionGridSnap:(NSButton *)sender;
- (IBAction) actionComponentScrollOnSelect:(NSButton *)sender;
- (IBAction) actionComponentDropAlign:(NSMatrix *)sender;
- (IBAction) actionShowAnimations:(NSButton *)sender;
- (IBAction) actionShowAnimationsFlow:(NSButton *)sender;
- (IBAction) actionCopyConnections:(NSMatrix *)sender;

#pragma mark Handle Changes
- (BOOL) changeGridSize;
- (BOOL) changeGridSnap;
- (BOOL) changeComponentScrollOnSelect;
- (BOOL) changeComponentDropAlign;
- (BOOL) changeShowAnimations;
- (BOOL) changeShowAnimationsFlow;
- (BOOL) changeCopyConnections;

@end
