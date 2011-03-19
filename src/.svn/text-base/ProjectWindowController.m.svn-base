//  Spider
//  PSProjectWindowController.h
//
//  Created by Daryl Dudey on 18/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSProjectWindowController

#pragma mark Alloc
- (id)init
{
    if (self = [super initWithWindowNibName:@"Project"])
	{
		[self setShouldCloseDocument:YES];
	}
    return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark Overrides
- (void) windowDidLoad
{
	// Init or load?
	if ([m_Project isLoaded])
	{
		[self postReload];
	}
	else
	{
		[self postInit];
	}
	
	// Layout tableview
	[tableviewLayouts setAction:@selector(layoutTableViewAction:)];
	[tableviewLayouts setDoubleAction:@selector(layoutTableViewDoubleAction:)];
	[tableviewLayouts setTarget:self];
	
	// Enable add layout
	[buttonAddLayout setEnabled:YES];
}

- (NSString *) windowTitleForDocumentDisplayName:(NSString *)displayName
{	
	if ([[m_Project stringName] compare:@""] != NSOrderedSame)
	{
		return [NSString stringWithFormat:@"Project - %@", [m_Project stringName]];
	}
	return @"Project";
}

- (NSUndoManager *) windowWillReturnUndoManager:(NSWindow *)sender
{
	return [self undoManager];
}

- (BOOL) windowShouldClose:(id)sender
{
	if ([[self window] isDocumentEdited])
	{
		// Chuck up an alert sheet about saving.
		NSBeginAlertSheet(	@"Do you want to save changes to this project before closing?", 
							@"Save",
							@"Don't Save",
							@"Cancel",
							[self window], 
							self,
							@selector(didEndCloseSheet:returnCode:contextInfo:),
							NULL,
							sender,
							@"If you don't save, your changes will be lost.");
		return NO;
	}
	return YES;
}

- (void) didEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo
{
	switch (returnCode)
	{
		case NSAlertDefaultReturn:				// Save
			[[self undoManager] removeAllActions];
			[self close];
			break;
		case NSAlertAlternateReturn:			// Don't save
			while ([[self undoManager] canUndo])
			{
				[[self undoManager] undo];
			}
			[self close];
			break;
		case NSAlertOtherReturn:				// Cancel
			break;
	}
}

#pragma mark Actions
- (void) layoutTableViewAction:(id)sender
{
	if ([tableviewLayouts selectedRow] < 0)
		return;
	
	// Get layout
	NSMutableArray *layouts = [m_Project arrayLayouts];
	PSLayout *layout = [layouts objectAtIndex:[tableviewLayouts selectedRow]];

	if ([[layout stringName] compare:@"Main"] != NSOrderedSame)
	{
		[buttonDeleteLayout setEnabled:YES];
		[buttonRenameLayout setEnabled:YES];
	}
	else
	{
		[buttonDeleteLayout setEnabled:NO];
		[buttonRenameLayout setEnabled:NO];
	}
}

- (void) layoutTableViewDoubleAction:(id)sender
{
	if ([tableviewLayouts selectedRow] < 0)
		return;

	// Get layout
	NSMutableArray *layouts = [m_Project arrayLayouts];
	PSLayout *layout = [layouts objectAtIndex:[tableviewLayouts selectedRow]];

	// Show (if not already visible)
	[layout showLayout];
}

- (IBAction) buttonAddLayout:(NSButton *)sender
{
	m_IsRenaming = NO;
	[textfieldSetLayoutName setStringValue:@""];
	[NSApp beginSheet:windowSetLayoutName
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(getLayoutNameDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (IBAction) getLayoutNameDidEnd:(NSWindow *)sheet
					  returnCode:(int) returnCode
					 contextInfo:(void *) contextInfo
{
	[sheet orderOut:self];
}

- (IBAction) buttonGetLayoutNameOK:(NSButton *)sender
{
	[NSApp endSheet:windowSetLayoutName];
	if (m_IsRenaming)
	{
		// Get layout
		NSMutableArray *layouts = [m_Project arrayLayouts];
		PSLayout *layout = [layouts objectAtIndex:[tableviewLayouts selectedRow]];

		// Rename
		[layout setName:[textfieldSetLayoutName stringValue]];

		// Refresh table
		[self refreshLayoutTable];
		
		// Refresh title of opened layout
		if ([layout controllerLayout] != nil)
			[[layout controllerLayout] synchronizeWindowTitleWithDocumentName];
	}
	else
	{
		[self addLayout:[textfieldSetLayoutName stringValue]];
	}
}

- (IBAction) buttonGetLayoutNameCancel:(NSButton *)sender
{
	[NSApp endSheet:windowSetLayoutName];
}

- (IBAction) buttonDeleteLayout:(NSButton *)sender
{
	// Get layout
	NSMutableArray *layouts = [m_Project arrayLayouts];
	PSLayout *layout = [layouts objectAtIndex:[tableviewLayouts selectedRow]];

	// Delete
	[self removeLayout:layout];
}

- (IBAction) buttonRenameLayout:(NSButton *)sender
{
	// Get layout
	NSMutableArray *layouts = [m_Project arrayLayouts];
	PSLayout *layout = [layouts objectAtIndex:[tableviewLayouts selectedRow]];

	m_IsRenaming = YES;
	[textfieldSetLayoutName setStringValue:[layout stringName]];
	[NSApp beginSheet:windowSetLayoutName
	   modalForWindow:[self window]
		modalDelegate:self
	   didEndSelector:@selector(getLayoutNameDidEnd:returnCode:contextInfo:)
		  contextInfo:NULL];
}

- (IBAction) textfieldProjectName:(NSTextField *)sender
{
	// Different?
	if ([[m_Project stringName] compare:[textfieldProjectName stringValue]] != NSOrderedSame)
	{
		[self changeProjectName:[textfieldProjectName stringValue]];
	}
}

#pragma mark Accessors
- (void) setProject:(PSProject *)project
{
	m_Project = project;
}

- (PSProject *) project
{
	return m_Project;
}

- (NSButton *) buttonDeleteLayout
{
	return buttonDeleteLayout;
}

- (NSUndoManager *) undoManager
{
	return [m_Project undoManager];
}

#pragma mark Methods
- (void) postInit
{
}

- (void) postReload
{
	[textfieldProjectName setStringValue:[m_Project stringName]];
}

- (void) refreshLayoutTable
{
	[tableviewLayouts reloadData];
}

- (void) addLayout:(NSString *)name
{
	// Create layout
	PSLayout *layout = [m_Project addLayoutToProject:[textfieldSetLayoutName stringValue]];
	
	// Undo (except main)
	[[[m_Project undoManager] prepareWithInvocationTarget:self] removeLayout:layout];
	if (![[m_Project undoManager] isUndoing])
	{
		[[m_Project undoManager] setActionName:@"New Layout"];
		[m_Project makingUndo];	
	}
	else 
	{
		[m_Project doingUndo];
	}
	
	// Refresh table
	[self refreshLayoutTable];
	
	// And show
	[layout showLayout];
}

- (void) addDeletedLayout:(PSLayout *)layout
{
	// Undo
	[[[m_Project undoManager] prepareWithInvocationTarget:self] removeLayout:layout];
	if (![[m_Project undoManager] isUndoing])
	{
		[[m_Project undoManager] setActionName:@"Add Layout"];
		[m_Project makingUndo];	
	}
	else 
	{
		[m_Project doingUndo];
	}

	// Re-add deleted layout
	[m_Project addDeletedLayoutToProject:layout];

	// Refresh table
	[self refreshLayoutTable];
}

- (void) removeLayout:(PSLayout *)layout
{
	// If open, close.
	if ([layout controllerLayout] != nil)
	{
		if ([[[NSDocumentController sharedDocumentController] currentDocument] currentLayout] == layout)
			[[[NSDocumentController sharedDocumentController] currentDocument] setCurrentLayout:nil];
		[[layout controllerLayout] close];
	}
	
	// Undo
	[[[m_Project undoManager] prepareWithInvocationTarget:self] addDeletedLayout:layout];
	if (![[m_Project undoManager] isUndoing])
	{
		[[m_Project undoManager] setActionName:@"Delete Layout"];
		[m_Project makingUndo];	
	}
	else 
	{
		[m_Project doingUndo];
	}

	// Delete
	[m_Project removeLayoutFromProject:layout];
	
	// Refresh table
	[self refreshLayoutTable];
}

- (void) changeProjectName:(NSString *)name
{
	// Undo
	[[[m_Project undoManager] prepareWithInvocationTarget:self] changeProjectName:[m_Project stringName]];
	if (![[m_Project undoManager] isUndoing])
	{
		[[m_Project undoManager] setActionName:@"Rename Project"];
		[m_Project makingUndo];	
	}
	else 
	{
		[m_Project doingUndo];
	}
	
	// Store name
	[m_Project setName:name];
	[textfieldProjectName setStringValue:[m_Project stringName]];
	[self synchronizeWindowTitleWithDocumentName];
}

@end
