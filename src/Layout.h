//  Spider
//  Layout.h
//
//  Created by Daryl Dudey on 18/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSLayout : NSObject <NSCoding>
{
	// Owner
	PSProject *m_Project;
	PSLayoutWindowController *m_ControllerLayout;
	
	// Undo manager
	NSUndoManager *m_UndoManager;
	int m_UndoCount;
	
	// ID's
	long m_ComponentID;
	long m_ConnectionID;
	
	// Data
	NSString *m_Name;
	float m_Scale;
	NSRect m_SizeAndPosition;
	BOOL m_Ready;
	NSMutableArray *m_Components;
	NSMutableArray *m_ComponentsSelected;
	NSMutableArray *m_Connections;
	NSMutableArray *m_ConnectionsSelected;
	NSMutableArray *m_ComponentsArrayDeleted;
}

#pragma mark Accessors
- (void) setProject:(PSProject *)project;
- (NSString *) stringName;
- (void) setName:(NSString *)name;
- (NSMutableArray *) arrayComponents;
- (NSMutableArray *) arrayComponentsDeleted;
- (NSMutableArray *) arrayComponentsSelected;
- (void) setSelectedComponent:(PSComponent *)componentSelected;
- (void) addSelectedComponent:(PSComponent *)componentSelected;
- (long) nextComponentID;
- (long) nextConnectionID;
- (PSLayoutWindowController *) controllerLayout;
- (NSMutableArray *) arrayConnections;
- (NSMutableArray *) arrayConnectionsSelected;
- (void) setSelectedConnection:(PSConnection *)connectionSelected;
- (void) addSelectedConnection:(PSConnection *)connectionSelected;
- (NSUndoManager *) undoManager;
- (PSProject *) project;
- (float) floatScale;
- (void) setScale:(float)scale;
- (int) undoCount;
- (void) setSizeAndPosition:(NSRect)sizeAndPosition;
- (BOOL) isReady;

#pragma mark Handlers for Defaults Change
- (void) handleGridSizeChanged:(NSNotification *)notification;
- (void) handleGridSnapChanged:(NSNotification *)notification;
- (void) handleArrowheadsDrawnChanged:(NSNotification *)notification;

#pragma mark Components Management
- (void) addComponent:(PSComponentType *)componentType
					x:(int)x
					y:(int)y 
				width:(int)width;
- (void) addDeletedComponent:(PSComponent *)component;
- (void) removeComponent:(PSComponent *)component;
- (void) moveComponent:(PSComponent *)component
					 x:(int)x 
					 y:(int)y;
- (PSConnection *) makeConnection:(PSComponentConnection *)source destination:(PSComponentConnection *)destination; 
- (void) removeConnection:(PSComponentConnection *)source destination:(PSComponentConnection *)destination; 

#pragma mark Methods
- (void) showLayout;
- (void) refreshView;
- (void) clearSelectedComponents;
- (void) clearSelectedConnections;
- (void) selectAllComponents;
- (void) postLoadSetup;
- (void) makingUndo;
- (void) doingUndo;
- (void) checkUndo;
- (void) clearUndoCount;

@end
