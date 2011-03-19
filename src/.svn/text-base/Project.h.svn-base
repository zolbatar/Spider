//  Spider
//  Project.h
//
//  Created by Daryl Dudey on 17/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSProject : NSObject <NSCoding> 
{
	// State
	BOOL m_IsLoaded;
	
	// Window controller
	PSProjectWindowController *m_ControllerProject;
	
	// Undo manager
	NSUndoManager *m_UndoManager;
	int m_UndoCount;
	
	// Data
	NSString *m_Name;
	NSMutableArray *m_Layouts;
	NSMutableArray *m_LayoutsDeleted;
}

#pragma mark Accessors
- (void) setController:(PSProjectWindowController *)controllerProject;
- (NSString *) stringName;
- (void) setName:(NSString *)name;
- (NSMutableArray *) arrayLayouts;
- (NSMutableArray *) arrayLayoutsDeleted;
- (void) setIsLoaded:(BOOL)isLoaded;
- (BOOL) isLoaded;
- (NSUndoManager *) undoManager;
- (PSProjectWindowController *) controllerProject;

#pragma mark Project Management
- (PSLayout *) addLayoutToProject:(NSString *)name;
- (void) addDeletedLayoutToProject:(PSLayout *)layout;
- (void) removeLayoutFromProject:(PSLayout *)layout;

#pragma mark Methods
- (void) makingUndo;
- (void) doingUndo;
- (int) checkUndo;
- (void) clearUndoCount;

@end
