//  Spider
//  Document.m
//
//  Created by Daryl Dudey on 14/05/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"
#import <objc/objc-runtime.h>

@implementation PSDocument

#pragma mark Alloc
- (id) init
{
	self = [super init];

	// Make project
	m_IsLoaded = NO;
	m_Project = [PSProject new];
	[m_Project retain];
 
	return self;
}

- (void) dealloc
{
	// Document data
	[m_Project release];
	
	[super dealloc];
}

#pragma mark Overrides
- (void) makeWindowControllers
{
	// Main Window Controller
	m_ControllerProject = [PSProjectWindowController new];
	[self addWindowController:m_ControllerProject];
	[m_ControllerProject setProject:m_Project];
	[m_Project setController:m_ControllerProject];
	[m_ControllerProject release];

	// Init?
	if (!m_IsLoaded)
	{
		[m_Project addLayoutToProject:@"Main"];
	}
	
	[m_Project setIsLoaded:m_IsLoaded];
}

- (NSData *) dataRepresentationOfType:(NSString *)aType
{
	// Clear all layout and project undo counts
	NSEnumerator *enumerator = [[m_Project arrayLayouts] objectEnumerator];
	PSLayout *layout = nil;
	while (layout = [enumerator nextObject])
	{
		[layout clearUndoCount];
		[layout checkUndo];
	}
	[m_Project clearUndoCount];
	[m_Project checkUndo];

	return [NSKeyedArchiver archivedDataWithRootObject:m_Project];
}

- (BOOL) loadDataRepresentation:(NSData *)data ofType:(NSString *)aType
{
	PSProject *newProject = [NSKeyedUnarchiver unarchiveObjectWithData:data];
	if (newProject == nil)
	{
		NSLog(@"Error loading");
		return NO;
	}
	else
	{
		m_IsLoaded = YES;
		[m_Project release];
		m_Project = newProject;
		[m_Project retain];
		[m_ControllerProject setProject:m_Project];
		[m_Project setController:m_ControllerProject];
		return YES;
	}
}

- (IBAction) revertDocumentToSaved:(id)sender
{
	NSLog(@"Revert");
}

- (IBAction) printDocument:(id)sender
{
	NSLog(@"Print");
}

#pragma mark Accessors
- (PSProject *) project
{
	return m_Project;
}

- (PSProjectWindowController *) windowcontrollerProject
{
	return m_ControllerProject;
}

- (BOOL) isLoaded
{
	return m_IsLoaded;
}

- (PSLayout *) currentLayout
{
	return m_CurrentLayout;
}

- (void) setCurrentLayout:(PSLayout *)layout
{
	m_CurrentLayout = layout;
}

#pragma mark Methods
+ (void) reviewChangesAndQuitEnumeration:(BOOL)cont
{
	if (cont)
	{
		NSArray *windows = [NSApp windows];
		unsigned count = [windows count];
		NSMutableArray *documentsHandled = [NSMutableArray new];
		while (count--) 
		{
			NSWindow *window = [windows objectAtIndex:count];
			PSDocument *document = [[NSDocumentController sharedDocumentController] documentForWindow:window];
			if (document != nil  && ![documentsHandled containsObject:document]) 
			{
				[documentsHandled addObject:document];
				if ([[document project] checkUndo] > 0) 
				{
					[document askToSave:@selector(reviewChangesAndQuitEnumeration:)];
					return;
				}
            }
        }
    }
    [NSApp replyToApplicationShouldTerminate:cont];
}

- (void) askToSave:(SEL)callback 
{
	[[[m_Project controllerProject] window] makeKeyAndOrderFront:nil];
    NSBeginAlertSheet(@"Do you want to save changes to this document before closing?",
					  @"Save",
					  @"Don't Save",
					  @"Cancel",
					  [[m_Project controllerProject] window], 
					  self,
					  @selector(willEndCloseSheet:returnCode:contextInfo:),
					  @selector(didEndCloseSheet:returnCode:contextInfo:),
					  (void *)callback,
					  @"If you don't save, your changes will be lost.");
}

- (void) willEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
    if (returnCode == NSAlertAlternateReturn) 
	{
		[self close];
        if (contextInfo) 
			((void (*)(id, SEL, BOOL))objc_msgSend)([self class], (SEL)contextInfo, YES);        
    }
}

- (void) didEndCloseSheet:(NSWindow *)sheet returnCode:(int)returnCode contextInfo:(void *)contextInfo 
{
    if (returnCode == NSAlertDefaultReturn)
	{  
		[self saveDocumentWithDelegate:self
					   didSaveSelector:@selector(didSave:didSave:contextInfo:)
						   contextInfo:contextInfo];
    } 
	else if (returnCode == NSAlertOtherReturn) 
	{  
		if (contextInfo)
			((void (*)(id, SEL, BOOL))objc_msgSend)([self class], (SEL)contextInfo, NO);          
    }
}

- (void) didSave:(PSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo
{
	if (contextInfo)
		((void (*)(id, SEL, BOOL))objc_msgSend)([self class], (SEL)contextInfo, YES);          
}

@end
