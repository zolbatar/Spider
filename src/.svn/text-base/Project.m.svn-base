//  Spider
//  Project.m
//
//  Created by Daryl Dudey on 17/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSProject

#pragma mark Alloc
- (id)init
{
	self = [super init];

	// Setup
	m_Name = @"";
	m_Layouts = [NSMutableArray new];
	[m_Layouts retain];
	m_LayoutsDeleted = [NSMutableArray new];
	[m_LayoutsDeleted retain];

	// Setup undo manager
	m_UndoManager = [NSUndoManager new];
	[m_UndoManager retain];
	m_UndoCount = 0;

    return self;
}

- (void)dealloc
{
	[m_Name release];
	[m_Layouts release];
	[m_LayoutsDeleted release];
	[m_UndoManager release];
	[super dealloc];
}

#pragma mark Archiving
- (id) initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		m_Name = [coder decodeObjectForKey:@"m_Name"];
		[m_Name retain];
		m_Layouts = [coder decodeObjectForKey:@"m_Layouts"];
		[m_Layouts retain];
		m_LayoutsDeleted = [NSMutableArray new];
		[m_LayoutsDeleted retain];
		
		// Setup undo manager
		m_UndoManager = [NSUndoManager new];
		[m_UndoManager retain];
		m_UndoCount = 0;
		
		// Set project pointer in layouts
		NSEnumerator *enumeratorLayout = [m_Layouts objectEnumerator];
		PSLayout *layout = nil;
		while (layout = [enumeratorLayout nextObject])
		{
			[layout setProject:self];
		}
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:m_Name					forKey:@"m_Name"];
	[coder encodeObject:m_Layouts				forKey:@"m_Layouts"];
}

#pragma mark Accessors
- (void) setController:(PSProjectWindowController *)controllerProject
{
	m_ControllerProject = controllerProject;
}

- (NSString *) stringName
{
	return m_Name;
}

- (void) setName:(NSString *)name
{
	if (m_Name != name)
	{
		[m_Name release];
		m_Name = [name copy];
	}
}

- (NSMutableArray *) arrayLayouts
{
	return m_Layouts;
}

- (NSMutableArray *) arrayLayoutsDeleted
{
	return m_LayoutsDeleted;
}

- (void) setIsLoaded:(BOOL)isLoaded
{
	m_IsLoaded = isLoaded;
}

- (BOOL) isLoaded
{
	return m_IsLoaded;
}

- (NSUndoManager *) undoManager
{
	return m_UndoManager;
}

- (PSProjectWindowController *) controllerProject
{
	return m_ControllerProject;
}

#pragma mark Project Management
- (PSLayout *) addLayoutToProject:(NSString *)name
{
	// Create new layout
	PSLayout *layout = [PSLayout new];
	[layout setName:name];
	[layout setProject:self];
	[m_Layouts addObject:layout];
	return layout;
}

- (void) removeLayoutFromProject:(PSLayout *)layout
{
	[m_LayoutsDeleted addObject:layout];
	[m_Layouts removeObject:layout];
}

- (void) addDeletedLayoutToProject:(PSLayout *)layout
{
	[m_Layouts addObject:layout];
	[m_LayoutsDeleted removeObject:layout];
	[layout checkUndo];
}

#pragma mark Methods
- (void) makingUndo
{
	m_UndoCount++;
	[self checkUndo];
}

- (void) doingUndo
{
	m_UndoCount--;
	[self checkUndo];
}

- (int) checkUndo
{
	// Add all layouts first
	int undoCount = 0;
	NSEnumerator *enumerator = [m_Layouts objectEnumerator];
	PSLayout *layout = nil;
	while (layout = [enumerator nextObject])
	{
		undoCount += abs([layout undoCount]);
	}
		
	if (m_ControllerProject != nil)
	{
		undoCount += m_UndoCount;
	}

	// Set edited
//	NSLog(@"Undocount %d", undoCount);
	if (undoCount == 0)
		[m_ControllerProject setDocumentEdited:NO];
	else
		[m_ControllerProject setDocumentEdited:YES];
	
	return undoCount;
}

- (void) clearUndoCount
{
	m_UndoCount = 0;
}

@end
