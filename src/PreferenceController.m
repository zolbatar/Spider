//  Spider
//  PreferenceController.h
//
//  Created by Daryl Dudey on 12/06/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSPreferenceController

#pragma mark User Defaults
NSString *PSUD_GridSize = @"GridSize";
NSString *PSUD_GridSnap = @"GridSnap";
NSString *PSUD_ComponentScrollOnSelect = @"ComponentScrollOnSelect";
NSString *PSUD_ComponentDropAlign = @"ComponentDropAlign";
NSString *PSUD_ShowAnimations = @"ShowAnimations";
NSString *PSUD_ShowAnimationsFlow = @"ShowAnimationsFlow";
NSString *PSUD_ConnectionsCopy = @"ConnectionsCopy";

#pragma mark Alloc
- (id) init 
{
	self = [super initWithWindowNibName:@"Preferences"];
	return self;
}

- (void) windowDidLoad
{
	[self updateWindow];
}

#pragma mark Delegates
- (BOOL) windowShouldClose:(id)sender
{
	if ([self changeGridSize] == NO) 
		return NO; 
	if ([self changeGridSnap] == NO) 
		return NO; 
	if ([self changeComponentScrollOnSelect] == NO) 
		return NO; 
	if ([self changeComponentDropAlign] == NO)
		return NO;
	if ([self changeShowAnimations] == NO)
		return NO;
	if ([self changeShowAnimationsFlow] == NO)
		return NO;
	if ([self changeCopyConnections] == NO)
		return NO;
	return YES;
}

#pragma mark Methods
- (void) updateWindow
{
	[textfieldGridSize setStringValue:[NSString stringWithFormat:@"%d", [[NSApp delegate] userdefault_GridSize]]];
	[buttonGridSnap setState:[[NSApp delegate] userdefault_GridSnap]];
	[buttonComponentScrollOnSelect setState:[[NSApp delegate] userdefault_ComponentScrollOnSelect]];
	[buttonShowAnimations setState:[[NSApp delegate] userdefault_ShowAnimations]];
	[buttonShowAnimationsFlow setState:[[NSApp delegate] userdefault_ShowAnimationsFlow]];
	[matrixComponentDropAlign selectCellWithTag:[[NSApp delegate] userdefault_ComponentDropAlign]];
}

#pragma mark Actions
- (IBAction) actionGridSize:(NSTextField *)sender;
{
	[self changeGridSize];
}

- (IBAction) actionGridSnap:(NSButton *)sender
{
	[self changeGridSnap];
}

- (IBAction) actionComponentScrollOnSelect:(NSButton *)sender
{
	[self changeComponentScrollOnSelect];
}

- (IBAction) actionComponentDropAlign:(NSMatrix *)sender
{
	[self changeComponentDropAlign];
}

- (IBAction) actionShowAnimations:(NSButton *)sender
{
	[self changeShowAnimations];
	if ([buttonShowAnimations state] == NSOnState)
	{
		[buttonShowAnimationsFlow setEnabled:YES];
	}
	else
	{
		[buttonShowAnimationsFlow setEnabled:NO];
	}
}

- (IBAction) actionShowAnimationsFlow:(NSButton *)sender
{
	[self changeShowAnimationsFlow];
}

- (IBAction) actionCopyConnections:(NSMatrix *)sender
{
	[self changeCopyConnections];
}

#pragma mark Handle Changes
- (BOOL) changeGridSize
{
	int number = [[textfieldGridSize stringValue] intValue];
	if (number==0 || number==INT_MAX || number==INT_MIN)
	{
		[textfieldGridSize setStringValue:[NSString stringWithFormat:@"%d", [[NSApp delegate] userdefault_GridSize]]];
		NSRunAlertPanel(@"Invalid grid size",
						@"You specified an invalid grid size, not saved.",
						@"OK",
						nil,
						nil);
		return NO;
	}
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:number] 
											  forKey:PSUD_GridSize];
	
	// Send notification and close
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PSUD_GridSize_Changed" 
														object:self];
	return YES;
}

- (BOOL) changeGridSnap
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:([buttonGridSnap state]==NSOnState)] 
											  forKey:PSUD_GridSnap];
	
	// Send notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PSUD_GridSnap_Changed" 
														object:self];
	return YES;
}

- (BOOL) changeComponentScrollOnSelect
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:([buttonComponentScrollOnSelect state]==NSOnState)] 
											  forKey:PSUD_ComponentScrollOnSelect];
	return YES;
}

- (BOOL) changeComponentDropAlign
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[matrixComponentDropAlign selectedCell] tag]] 
											  forKey:PSUD_ComponentDropAlign];
	return YES;
}

- (BOOL) changeShowAnimations
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:([buttonShowAnimations state]==NSOnState)] 
											  forKey:PSUD_ShowAnimations];
	
	// Send notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PSUD_ShowAnimations_Changed" 
														object:self];
	return YES;
}

- (BOOL) changeShowAnimationsFlow
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithBool:([buttonShowAnimationsFlow state]==NSOnState)] 
											  forKey:PSUD_ShowAnimationsFlow];
	
	// Send notification
	[[NSNotificationCenter defaultCenter] postNotificationName:@"PSUD_ShowAnimationsFlow_Changed" 
														object:self];
	return YES;
}

- (BOOL) changeCopyConnections
{
	[[NSUserDefaults standardUserDefaults] setObject:[NSNumber numberWithInt:[[matrixCopyConnections selectedCell] tag]] 
											  forKey:PSUD_ConnectionsCopy];
	return YES;
}

@end
