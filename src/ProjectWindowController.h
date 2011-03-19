//  Spider
//  PSProjectWindowController.h
//
//  Created by Daryl Dudey on 18/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSProjectWindowController : NSWindowController 
{
	// Owner 
	PSProject *m_Project;

	// States
	BOOL m_IsRenaming;
	
#pragma mark Outlets
	// Project name
	IBOutlet NSTextField *textfieldProjectName;

	// Layouts
	IBOutlet NSWindow *windowSetLayoutName;
	IBOutlet NSTextField *textfieldSetLayoutName;
	IBOutlet NSTableView *tableviewLayouts;
	IBOutlet NSButton *buttonAddLayout;
	IBOutlet NSButton *buttonDeleteLayout;
	IBOutlet NSButton *buttonRenameLayout;
}

#pragma mark Actions
// Project name
- (IBAction) textfieldProjectName:(NSTextField *)sender;

// Layouts
- (void) layoutTableViewAction:(id)sender;
- (void) layoutTableViewDoubleAction:(id)sender;
- (IBAction) buttonGetLayoutNameOK:(NSButton *)sender;
- (IBAction) buttonGetLayoutNameCancel:(NSButton *)sender;
- (IBAction) buttonAddLayout:(NSButton *)sender;
- (IBAction) buttonDeleteLayout:(NSButton *)sender;
- (IBAction) buttonRenameLayout:(NSButton *)sender;

#pragma mark Accessors
- (void) setProject:(PSProject *)project;
- (PSProject *) project;
- (NSButton *) buttonDeleteLayout;
- (NSUndoManager *) undoManager;

#pragma mark Methods
- (void) postInit;
- (void) postReload;
- (void) refreshLayoutTable;
- (void) addLayout:(NSString *)name;
- (void) addDeletedLayout:(PSLayout *)layout;
- (void) removeLayout:(PSLayout *)layout;
- (void) changeProjectName:(NSString *)name;

@end
