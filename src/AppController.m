//  Spider
//  AppController.m
//
//  Created by Daryl Dudey on 02/06/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSAppController

#pragma mark Alloc
+ (void) initialize
{
	// Create a dictionary for defaults
	NSMutableDictionary *defaultValues = [NSMutableDictionary dictionary];
	
	// Set defaults
	[defaultValues setObject:[NSNumber numberWithInt:25]
					  forKey:PSUD_GridSize];
	[defaultValues setObject:[NSNumber numberWithBool:NO]
					  forKey:PSUD_GridSnap];
	[defaultValues setObject:[NSNumber numberWithBool:NO]
					  forKey:PSUD_ComponentScrollOnSelect];
	[defaultValues setObject:[NSNumber numberWithInt:cPreferencesComponentDropLeft]
					  forKey:PSUD_ComponentDropAlign];
	[defaultValues setObject:[NSNumber numberWithBool:YES]
					  forKey:PSUD_ShowAnimations];
	[defaultValues setObject:[NSNumber numberWithBool:YES]
					  forKey:PSUD_ShowAnimationsFlow];
	[defaultValues setObject:[NSNumber numberWithInt:cPreferencesCopyConnectionsAlways]
					  forKey:PSUD_ConnectionsCopy];

	// Register defaults
	[[NSUserDefaults standardUserDefaults] registerDefaults:defaultValues];
}

- (id) init
{
	self = [super init];
	
	// Init various app wide stuff
	m_ComponentTypesArray = [NSMutableArray new];
	m_ComponentsCopy = [NSMutableArray new];
	m_ConnectionsCopy = [NSMutableArray new];
	[m_ComponentTypesArray retain];
	[m_ComponentsCopy retain];
	[m_ConnectionsCopy retain];
	[self setupStyles];
	
	// Setup in-built component library
	[self setupComponentsLiteral];
	[self setupComponentsProgramFlow];
	[self setupComponentsConditional];
	
	return self;
}

- (void) awakeFromNib
{
	// Setup palette
	[panelPalette setFloatingPanel:YES];
	[panelPalette setBecomesKeyOnlyIfNeeded:YES];
	[self setupPaletteLiteral];
	[self setupPaletteProgramFlow];
	[self setupPaletteConditional];
}

- (void) dealloc
{
	// Defaults
	[m_ControllerPreference release];

	// Styles
	[m_LeftParaStyle release];
	[m_RightParaStyle release];
	[m_CentreParaStyle release];
	[m_SelectionBoxColour release];
	[m_ComponentBorderColour release];
	[m_ConnectionColourFlow release];
	[m_ConnectionColourBoolean release];
	[m_ConnectionColourByte release];
	[m_ConnectionColourDateTime release];
	[m_ConnectionColourInteger release];
	[m_ConnectionColourReal release];
	[m_ConnectionColourString release];
	[m_ComponentShadow release];
	[m_ComponentShadowReversed release];
	[m_HeaderFont release];
	[m_ConnectionFont release];
	[m_InputAttributes release];
	[m_OutputAttributes release];
	[m_HeaderAttributes release];
	[m_FormatInAttributes release];
	[m_FormatOutAttributes release];
	[m_FormatSoleAttributes release];

	// Data
	[m_ComponentTypesArray release];
	[m_ComponentTypesArray release];
	[m_ComponentsCopy release];
	[m_ConnectionsCopy release];
	
	[super dealloc];
}

#pragma mark Overrides
- (BOOL) applicationShouldOpenUntitledFile:(NSApplication *)sender
{
	return NO;
}

- (BOOL) validateMenuItem:(id <NSMenuItem>)menuItem
{
	// Edit menu item?
	if ([[[menuItem menu] title] compare:@"Edit"] == NSOrderedSame)
	{
		return [self validateMenuItemEdit:menuItem];
	}
	return YES;
}

- (IBAction) copy:(id)sender
{
	// Do we want connections too?
	BOOL copyConnections;
	switch ([self userdefault_CopyConnections])
	{
		case cPreferencesCopyConnectionsAlways:
			copyConnections = YES;
			break;
		case cPreferencesCopyConnectionsNever:
			copyConnections = NO;
			break;
		case cPreferencesCopyConnectionsAsk:
			if (NSRunAlertPanel(@"Do you want any connections between selected components copied too?", 
								@"If you choose yes, when you paste the components any connections that existed between them will be pasted too.",
								@"Yes",
								@"No",
								nil) == NSAlertDefaultReturn)
			{
				copyConnections = YES;
			}
			else
			{
				copyConnections = NO;
			}
			break;
	}
	
	// Clear any previously copied components and connections	
	[m_ComponentsCopy removeAllObjects];
	[m_ConnectionsCopy removeAllObjects];
	
	// Get layout
	PSLayout *layout = [[[NSDocumentController sharedDocumentController] currentDocument] currentLayout];
	
	// Place to store all the ID's were adding
	NSMutableDictionary *dictionaryID = [NSMutableDictionary new];
	
	// Now add all selected components
	int x1 = cCanvasDefaultWidth, x2 = 0, y1 = cCanvasDefaultHeight, y2 = 0;
	NSEnumerator *enumeratorComponenents = [[layout arrayComponentsSelected] objectEnumerator];
	PSComponent *component = nil;
	while (component = [enumeratorComponenents nextObject])
	{
		[dictionaryID setObject:component forKey:[NSNumber numberWithLong:[component id]]];
		PSComponent *componentCopy = [component copy];
		[m_ComponentsCopy addObject:componentCopy];
		
		// Check dimensions
		if ([component intX] < x1)
			x1 = [component intX];
		if (([component intX] + [component intWidth]) > x2)
			x2 = [component intX] + [component intWidth];
		if ([component intY] < y1)
			y1 = [component intY];
		if (([component intY] + [component intHeight]) > y2)
			y2 = [component intY] + [component intHeight];
	}
	m_CenterX = ((x2 - x1) / 2) + x1;
	m_CenterY = ((y2 - y1) / 2) + y1;
	
	// And add connections
	if (copyConnections)
	{
		NSEnumerator *enumeratorConnections = [[layout arrayConnections] objectEnumerator];
		PSConnection *connection = nil;
		while (connection = [enumeratorConnections nextObject])
		{
			// Do we want it?
			if ( ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionSource] componentOwner] id]]] != nil) &&
				 ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionDestination] componentOwner] id]]] != nil))
			{
				// Save connection
				PSConnection *connectionCopy = [connection copy];
				[m_ConnectionsCopy addObject:connectionCopy];
			}
		}
	}
	
	// Release
	[dictionaryID release];
}

- (IBAction) cut:(id)sender
{
	BOOL copyConnections;
	switch ([self userdefault_CopyConnections])
	{
		case cPreferencesCopyConnectionsAlways:
			copyConnections = YES;
			break;
		case cPreferencesCopyConnectionsNever:
			copyConnections = NO;
			break;
		case cPreferencesCopyConnectionsAsk:
			if (NSRunAlertPanel(@"Do you want any connections between selected components copied too?", 
								@"If you choose yes, when you paste the components any connections that existed between them will be pasted too.",
								@"Yes",
								@"No",
								nil) == NSAlertDefaultReturn)
			{
				copyConnections = YES;
			}
			else
			{
				copyConnections = NO;
			}
			break;
	}
	
	// Clear any previously copied components and connections	
	[m_ComponentsCopy removeAllObjects];
	[m_ConnectionsCopy removeAllObjects];
	
	// Get layout
	PSLayout *layout = [[[NSDocumentController sharedDocumentController] currentDocument] currentLayout];
	
	// Place to store all the ID's were adding
	NSMutableDictionary *dictionaryID = [NSMutableDictionary new];
	
	// Now add all selected components
	int x1 = cCanvasDefaultWidth, x2 = 0, y1 = cCanvasDefaultHeight, y2 = 0;
	NSEnumerator *enumeratorComponents = [[layout arrayComponentsSelected] objectEnumerator];
	PSComponent *component = nil;
	while (component = [enumeratorComponents nextObject])
	{
		[dictionaryID setObject:component forKey:[NSNumber numberWithLong:[component id]]];
		PSComponent *componentCopy = [component copy];
		[m_ComponentsCopy addObject:componentCopy];
		
		// Check dimensions
		if ([component intX] < x1)
			x1 = [component intX];
		if (([component intX] + [component intWidth]) > x2)
			x2 = [component intX] + [component intWidth];
		if ([component intY] < y1)
			y1 = [component intY];
		if (([component intY] + [component intHeight]) > y2)
			y2 = [component intY] + [component intHeight];
	}
	m_CenterX = ((x2 - x1) / 2) + x1;
	m_CenterY = ((y2 - y1) / 2) + y1;
	
	// And add connections
	NSEnumerator *enumeratorConnections;
	PSConnection *connection;
	if (copyConnections)
	{
		enumeratorConnections = [[layout arrayConnections] objectEnumerator];
		connection = nil;
		while (connection = [enumeratorConnections nextObject])
		{
			// Do we want it?
			if ( ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionSource] componentOwner] id]]] != nil) &&
				 ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionDestination] componentOwner] id]]] != nil))
			{
				// Save connection
				PSConnection *connectionCopy = [connection copy];
				[m_ConnectionsCopy addObject:connectionCopy];
			}
		}
	}
	
	// Now cut components
	enumeratorComponents = [[layout arrayComponentsSelected] objectEnumerator];
	while (component = [enumeratorComponents nextObject])
	{
		// Add inverse to undo stack
		NSUndoManager *undo = [layout undoManager];
		[[undo prepareWithInvocationTarget:layout] addDeletedComponent:component];
		[undo setActionName:@"Cut"];
		[layout makingUndo];
		
		// If selected, unselect
		if ([[layout arrayComponentsSelected] containsObject:component])
		{
			[[layout arrayComponentsSelected] removeObject:component];
		}
		
		// Remove
		[[layout arrayComponentsDeleted] addObject:component];
		[[layout arrayComponents] removeObject:component];
	}
	
	// And cut connections
	enumeratorConnections = [[layout arrayConnections] objectEnumerator];
	while (connection = [enumeratorConnections nextObject])
	{
		// Do we want it?
		if ( ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionSource] componentOwner] id]]] != nil) ||
			 ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionDestination] componentOwner] id]]] != nil))
		{
			// Add inverse to undo stack
			NSUndoManager *undo = [layout undoManager];
			[[undo prepareWithInvocationTarget:layout] makeConnection:[connection connectionSource] 
														  destination:[connection connectionDestination]];
			[undo setActionName:@"Cut"];
			[layout makingUndo];

			// Remove connection
			[layout removeConnection:[connection connectionSource]
						 destination:[connection connectionDestination]];
		}
	}
	
	// Release
	[dictionaryID release];

	// Refresh
	[layout refreshView];
}

- (IBAction) paste:(id)sender
{
	// Get layout
	PSLayout *layout = [[[NSDocumentController sharedDocumentController] currentDocument] currentLayout];
	
	// Clear all selected
	[layout clearSelectedComponents];
	[layout clearSelectedConnections];
	
	// Set new ID's on connection and save mapping
	NSMutableDictionary *dictionaryConnections = [NSMutableDictionary dictionary];
	NSMutableDictionary *dictionaryConnectionID = [NSMutableDictionary dictionary];

	// Paste copied components
	NSEnumerator *enumeratorComponents = [m_ComponentsCopy objectEnumerator];
	PSComponent *component = nil;
	while (component = [enumeratorComponents nextObject])
	{
		// Copy component
		PSComponent *componentCopy = [component copy];
		
		// Undo
		NSUndoManager *undo = [layout undoManager];
		[[undo prepareWithInvocationTarget:layout] removeComponent:componentCopy];
		[undo setActionName:@"Paste"];
		[layout makingUndo];

		// Set new ID and save
		[componentCopy setID:[layout nextComponentID]];
		
		// Move by offset
		NSRect frame = [[[[layout controllerLayout] viewMain] superview] frame];
		NSRect visible = [[[layout controllerLayout] viewMain] visibleRect];
		int centerX = visible.origin.x + (frame.size.width / 2); 
		int centerY = visible.origin.y + (frame.size.height / 2); 
		int newX = [component intX] + centerX - m_CenterX;
		int newY = [component intY] + centerY - m_CenterY;
		[componentCopy setX:newX andY:newY];

		// Set ID on inputs
		NSEnumerator *enumeratorInput = [[componentCopy arrayInputs] objectEnumerator];
		PSComponentConnection *input = nil;
		long id;
		while (input = [enumeratorInput nextObject])
		{
			id = [input id];
			[input setOwner:componentCopy];
			[input setID:[layout nextConnectionID]];
			[dictionaryConnections setObject:[NSNumber numberWithLong:[input id]]
									  forKey:[NSNumber numberWithLong:id]];
			[dictionaryConnectionID setObject:input
									   forKey:[NSNumber numberWithLong:[input id]]];
		}		
		
		// Set ID on outputs
		NSEnumerator *enumeratorOutput = [[componentCopy arrayOutputs] objectEnumerator];
		PSComponentConnection *output = nil;
		while (output = [enumeratorOutput nextObject])
		{
			id = [output id];
			[output setOwner:componentCopy];
			[output setID:[layout nextConnectionID]];
			[dictionaryConnections setObject:[NSNumber numberWithLong:[output id]]
									  forKey:[NSNumber numberWithLong:id]];
			[dictionaryConnectionID setObject:output
									   forKey:[NSNumber numberWithLong:[output id]]];
		}

		// Now add to layout
		[[layout arrayComponents] addObject:componentCopy];
		[[layout arrayComponentsSelected] addObject:componentCopy];
	}
	
	// Paste copied connections
	NSEnumerator *enumeratorConnections = [m_ConnectionsCopy objectEnumerator];
	PSConnection *connection = nil;
	while (connection = [enumeratorConnections nextObject])
	{
		long sourceID = [connection longSourceID];
		long destinationID = [connection longDestinationID];
		long newSourceID = [[dictionaryConnections objectForKey:[NSNumber numberWithLong:sourceID]] longValue];
		long newDestinationID = [[dictionaryConnections objectForKey:[NSNumber numberWithLong:destinationID]] longValue];
		PSComponentConnection *source = [dictionaryConnectionID objectForKey:[NSNumber numberWithLong:newSourceID]];
		PSComponentConnection *destination = [dictionaryConnectionID objectForKey:[NSNumber numberWithLong:newDestinationID]];
		
//		NSLog(@"%d=%d %d=%d", sourceID, newSourceID, destinationID, newDestinationID);
		
		// Undo
		NSUndoManager *undo = [layout undoManager];
		[[undo prepareWithInvocationTarget:layout] removeConnection:source
														destination:destination];
		[undo setActionName:@"Paste"];
		[layout makingUndo];
		
		// Create new connection
		PSConnection *connection = [PSConnection new];
		[connection setSource:source];
		[connection setSourceID:newSourceID];
		[connection setDestination:destination];
		[connection setDestinationID:newDestinationID];
		
		// Add
		[[layout arrayConnections] addObject:connection];
	}
	[[layout controllerLayout] setSelectedConnectionsBasedOnSelectedComponents];

	// Refresh
	[[[layout project] controllerProject] refreshLayoutTable];
	[layout refreshView];
}

- (IBAction) delete:(id)sender
{
	NSLog(@"Delete");
}

- (IBAction) selectAll:(id)sender
{
	PSLayout *layout = [[[NSDocumentController sharedDocumentController] currentDocument] currentLayout];
	if (layout != nil)
	{
		[layout selectAllComponents];
		[layout refreshView];
	}
}

#pragma mark Graceful termination
- (NSApplicationTerminateReply) applicationShouldTerminate:(NSApplication *)sender
{
	// Loop through all documents, see if we have any unsaved.
	NSArray *windows = [sender windows];
    unsigned count = [windows count];
    unsigned needsSaving = 0;
	
	// Any unsaved?
	NSMutableArray *documentsHandled = [NSMutableArray new];
    while (count--) 
	{
        NSWindow *window = [windows objectAtIndex:count];
        PSDocument *document = [[NSDocumentController sharedDocumentController] documentForWindow:window];
		if (document != nil && ![documentsHandled containsObject:document])
		{
			[documentsHandled addObject:document];
			if ([[document project] checkUndo] > 0)
				needsSaving++;
		}
    }

	if (needsSaving > 0) 
	{
        int choice = NSAlertDefaultReturn; 
		if (needsSaving > 1) 
		{ 
			choice = NSRunAlertPanel([NSString stringWithFormat:@"You have %d documents with unsaved changes. Do you want to review these changes before quitting?", needsSaving],
									 @"If you don't review your documents, all changes will be lost.",
									 @"Review Changes...", 
									 @"Discard Changes", 
									 @"Cancel");
            if (choice == NSAlertOtherReturn) 
				return NSTerminateCancel;
        }
        if (choice == NSAlertDefaultReturn) 
		{ 
            [PSDocument reviewChangesAndQuitEnumeration:YES];
            return NSTerminateLater;
        }
    }
    return NSTerminateNow;
}

- (void) applicationWillTerminate:(NSNotification *)notification 
{
}

#pragma mark Init App Objects
- (void) setupStyles
{
	// Paragraph styles
	m_LeftParaStyle = [NSMutableParagraphStyle new];
	[m_LeftParaStyle setAlignment:NSLeftTextAlignment];
	m_CentreParaStyle = [NSMutableParagraphStyle new];
	[m_CentreParaStyle setAlignment:NSCenterTextAlignment];
	m_RightParaStyle = [NSMutableParagraphStyle new];
	[m_RightParaStyle setAlignment:NSRightTextAlignment];

	// Font styles
	m_HeaderFont = [NSFont boldSystemFontOfSize: 9.0];
	m_ConnectionFont = [NSFont systemFontOfSize: 9.0];
	
	// Input text
	m_InputAttributes = [NSMutableDictionary dictionary];
	[m_InputAttributes setObject:m_ConnectionFont forKey:NSFontAttributeName];
	[m_InputAttributes setObject:m_LeftParaStyle forKey:NSParagraphStyleAttributeName];
	[m_InputAttributes setObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0] 
						  forKey:NSForegroundColorAttributeName];
	[m_InputAttributes retain];
	
	// Output text
	m_OutputAttributes = [NSMutableDictionary dictionary];
	[m_OutputAttributes setObject:m_ConnectionFont forKey:NSFontAttributeName];
	[m_OutputAttributes setObject:m_RightParaStyle forKey:NSParagraphStyleAttributeName];
	[m_OutputAttributes setObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0] 
						   forKey:NSForegroundColorAttributeName];
	[m_OutputAttributes retain];
	
	// Header style
	m_HeaderAttributes = [NSMutableDictionary dictionary];
	[m_HeaderAttributes setObject:m_HeaderFont forKey:NSFontAttributeName];
	[m_HeaderAttributes setObject:m_CentreParaStyle forKey:NSParagraphStyleAttributeName];
	[m_HeaderAttributes setObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:1.0] 
						   forKey:NSForegroundColorAttributeName];
	[m_HeaderAttributes retain];
	
	// Format In style
	m_FormatInAttributes = [NSMutableDictionary dictionary];
	[m_FormatInAttributes setObject:m_ConnectionFont forKey:NSFontAttributeName];
	[m_FormatInAttributes setObject:m_LeftParaStyle forKey:NSParagraphStyleAttributeName];
	[m_FormatInAttributes setObject:[NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:1.0] 
							 forKey:NSForegroundColorAttributeName];
	[m_FormatInAttributes retain];

	// Format Out style
	m_FormatOutAttributes = [NSMutableDictionary dictionary];
	[m_FormatOutAttributes setObject:m_ConnectionFont forKey:NSFontAttributeName];
	[m_FormatOutAttributes setObject:m_LeftParaStyle forKey:NSParagraphStyleAttributeName];
	[m_FormatOutAttributes setObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:1.0] 
							  forKey:NSForegroundColorAttributeName];
	[m_FormatOutAttributes retain];
	
	// Format Sole style
	m_FormatSoleAttributes = [NSMutableDictionary dictionary];
	[m_FormatSoleAttributes setObject:m_ConnectionFont forKey:NSFontAttributeName];
	[m_FormatSoleAttributes setObject:m_CentreParaStyle forKey:NSParagraphStyleAttributeName];
	[m_FormatSoleAttributes setObject:[NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:1.0] 
							   forKey:NSForegroundColorAttributeName];
	[m_FormatSoleAttributes retain];

	// Set shadows
	m_ComponentShadow = [NSShadow new];
	[m_ComponentShadow setShadowOffset:NSMakeSize(cShadowOffset, -cShadowOffset)];
	[m_ComponentShadow setShadowBlurRadius:3.0];
	[m_ComponentShadow setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
	[m_ComponentShadow retain];
	m_ComponentShadowReversed = [NSShadow new];
	[m_ComponentShadowReversed setShadowOffset:NSMakeSize(cShadowOffset, cShadowOffset)];
	[m_ComponentShadowReversed setShadowBlurRadius:3.0];
	[m_ComponentShadowReversed setShadowColor:[[NSColor blackColor] colorWithAlphaComponent:0.3]];
	[m_ComponentShadowReversed retain];
	
	// Connection colours (Flow)
	m_ConnectionColourFlow = [NSColor colorWithDeviceRed:0.5 green:0.5 blue:0.5 alpha:cSelectedAlpha];
	[m_ConnectionColourFlow retain];

	// Connection colours (Boolean)
	m_ConnectionColourBoolean = [NSColor colorWithDeviceRed:0.0 green:1.0 blue:1.0 alpha:cSelectedAlpha];
	[m_ConnectionColourBoolean retain];
	
	// Connection colours (Byte)
	m_ConnectionColourByte = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:1.0 alpha:cSelectedAlpha];
	[m_ConnectionColourByte retain];

	// Connection colours (DateTime)
	m_ConnectionColourDateTime = [NSColor colorWithDeviceRed:1.0 green:0.0 blue:1.0 alpha:cSelectedAlpha];
	[m_ConnectionColourDateTime retain];

	// Connection colours (Integer)
	m_ConnectionColourInteger = [NSColor colorWithDeviceRed:1.0 green:1.0 blue:0.0 alpha:cSelectedAlpha];
	[m_ConnectionColourInteger retain];

	// Connection colours (Real)
	m_ConnectionColourReal = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:1.0 alpha:cSelectedAlpha];
	[m_ConnectionColourReal retain];

	// Connection colours (String)
	m_ConnectionColourString  = [NSColor colorWithDeviceRed:1.0 green:0.0 blue:0.0 alpha:cSelectedAlpha];
	[m_ConnectionColourString retain];

	// Border colour
	m_ComponentBorderColour = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:cSelectedAlpha];
	[m_ComponentBorderColour retain];
	
	// Selection box colour
	m_SelectionBoxColour = [NSColor colorWithDeviceRed:0.0 green:0.0 blue:0.0 alpha:0.3];
	[m_SelectionBoxColour retain];
}

#pragma mark Attributes & Styles Accessors
- (NSMutableParagraphStyle *) paragraphstyleLeft
{
	return m_LeftParaStyle;
}

- (NSMutableParagraphStyle *) paragraphstyleCentre
{
	return m_CentreParaStyle;
}

- (NSMutableParagraphStyle *) paragraphstyleRight
{
	return m_RightParaStyle;
}

- (NSShadow *) shadowComponent
{
	return m_ComponentShadow;
}

- (NSShadow *) shadowComponentReversed
{
	return m_ComponentShadowReversed;
}

- (NSMutableDictionary *) dictionaryInputAttributes
{
	return m_InputAttributes;
}

- (NSMutableDictionary *) dictionaryOutputAttributes
{
	return m_OutputAttributes;
}

- (NSMutableDictionary *) dictionaryHeaderAttributes
{
	return m_HeaderAttributes;
}

- (NSMutableDictionary *) dictionaryFormatInAttributes
{
	return m_FormatInAttributes;
}

- (NSMutableDictionary *) dictionaryFormatOutAttributes
{
	return m_FormatOutAttributes;
}

- (NSMutableDictionary *) dictionaryFormatSoleAttributes
{
	return m_FormatSoleAttributes;
}

- (NSColor *) colourComponentBorder
{
	return m_ComponentBorderColour;
}

- (NSColor *) colourSelectionBox
{
	return m_SelectionBoxColour;
}

- (NSColor *) colourConnectionFlow
{
	return m_ConnectionColourFlow;
}

- (NSColor *) colourConnectionBoolean
{
	return m_ConnectionColourBoolean;
}

- (NSColor *) colourConnectionByte
{
	return m_ConnectionColourByte;
}

- (NSColor *) colourConnectionDateTime
{
	return m_ConnectionColourDateTime;
}

- (NSColor *) colourConnectionInteger
{
	return m_ConnectionColourInteger;
}

- (NSColor *) colourConnectionReal
{
	return m_ConnectionColourReal;
}

- (NSColor *) colourConnectionString
{
	return m_ConnectionColourString;
}

#pragma mark Components
- (void) setupComponentsLiteral
{
	PSComponentType *componentType;
	
	// Boolean
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_Literal];
	[componentType setName:@"Literal - Boolean"];
	[componentType setGroup:cComponentGroup_Literal andIndex:cComponentLiteral_Boolean];
	[componentType setColourR:cComponentLiteralRed andG:cComponentLiteralGreen andB:cComponentLiteralBlue];
	[componentType setConnections:1];
	[componentType addOutput:@"Boolean" outputType:cAllowedBoolean];
	[self addComponentType:componentType];

	// Byte
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_Literal];
	[componentType setName:@"Literal - Byte"];
	[componentType setGroup:cComponentGroup_Literal andIndex:cComponentLiteral_Byte];
	[componentType setColourR:cComponentLiteralRed andG:cComponentLiteralGreen andB:cComponentLiteralBlue];
	[componentType setConnections:1];
	[componentType addOutput:@"Byte" outputType:cAllowedByte];
	[self addComponentType:componentType];
	
	// DateTime
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_Literal];
	[componentType setName:@"Literal - DateTime"];
	[componentType setGroup:cComponentGroup_Literal andIndex:cComponentLiteral_DateTime];
	[componentType setColourR:cComponentLiteralRed andG:cComponentLiteralGreen andB:cComponentLiteralBlue];
	[componentType setConnections:1];
	[componentType addOutput:@"DateTime" outputType:cAllowedDateTime];
	[self addComponentType:componentType];

	// Integer
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_Literal];
	[componentType setName:@"Literal - Integer"];
	[componentType setGroup:cComponentGroup_Literal andIndex:cComponentLiteral_Integer];
	[componentType setColourR:cComponentLiteralRed andG:cComponentLiteralGreen andB:cComponentLiteralBlue];
	[componentType setConnections:1];
	[componentType addOutput:@"Integer" outputType:cAllowedInteger];
	[self addComponentType:componentType];

	// Real
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_Literal];
	[componentType setName:@"Literal - Real"];
	[componentType setGroup:cComponentGroup_Literal andIndex:cComponentLiteral_Real];
	[componentType setColourR:cComponentLiteralRed andG:cComponentLiteralGreen andB:cComponentLiteralBlue];
	[componentType setConnections:1];
	[componentType addOutput:@"Real" outputType:cAllowedReal];
	[self addComponentType:componentType];
	
	// String
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_Literal];
	[componentType setName:@"Literal - String"];
	[componentType setGroup:cComponentGroup_Literal andIndex:cComponentLiteral_String];
	[componentType setColourR:cComponentLiteralRed andG:cComponentLiteralGreen andB:cComponentLiteralBlue];
	[componentType setConnections:1];
	[componentType addOutput:@"String" outputType:cAllowedString];
	[self addComponentType:componentType];
}

- (void) setupComponentsProgramFlow
{
	PSComponentType *componentType;

	// Start
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_ProgramFlow];
	[componentType setName:@"Program Flow - Start"];
	[componentType setShortName:@"Start"];
	[componentType setGroup:cComponentGroup_ProgramFlow andIndex:cComponentProgramFlow_Start];
	[componentType setColourR:cComponentProgramFlowStartRed andG:cComponentProgramFlowStartGreen andB:cComponentProgramFlowStartBlue];
	[componentType setConnections:1];
	[componentType addOutput:@"" outputType:cAllowedFlow];
	[self addComponentType:componentType];

	// Stop
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_ProgramFlow];
	[componentType setName:@"Program Flow - Stop"];
	[componentType setShortName:@"Stop"];
	[componentType setGroup:cComponentGroup_ProgramFlow andIndex:cComponentProgramFlow_Stop];
	[componentType setColourR:cComponentProgramFlowStopRed andG:cComponentProgramFlowStopGreen andB:cComponentProgramFlowStopBlue];
	[componentType setConnections:1];
	[componentType addInput:@"" allowedTypes:cAllowedFlow];
	[self addComponentType:componentType];

	// Pause 
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_ProgramFlow];
	[componentType setName:@"Program Flow - Break"];
	[componentType setShortName:@"Break"];
	[componentType setGroup:cComponentGroup_ProgramFlow andIndex:cComponentProgramFlow_Pause];
	[componentType setColourR:cComponentProgramFlowPauseRed andG:cComponentProgramFlowPauseGreen andB:cComponentProgramFlowPauseBlue];
	[componentType setConnections:1];
	[componentType addInput:@"" allowedTypes:cAllowedFlow];
	[componentType addOutput:@"" outputType:cAllowedFlow];
	[self addComponentType:componentType];
}

- (void) setupComponentsConditional
{
	PSComponentType *componentType;
	
	// Start
	componentType = [PSComponentType new];
	[componentType setStyle:cComponentStyle_Conditional];
	[componentType setName:@"Flow - Conditional Branch (Numeric)"];
	[componentType setShortName:@"Numeric Branch"];
	[componentType setGroup:cComponentGroup_Conditional andIndex:cComponentConditional_Compare];
	[componentType setColourR:cComponentConditionalCompareRed andG:cComponentConditionalCompareGreen andB:cComponentConditionalCompareBlue];
	[componentType setConnections:4];
	[componentType addInput:@"In" allowedTypes:cAllowedFlow];
	[componentType addAutoTypeInput:@"Op 1" allowedTypes:cAllowedByte|cAllowedInteger|cAllowedReal|cAllowedString countTypes:4 autoTypeIndex:1];
	[componentType addAutoTypeInput:@"Op 2" allowedTypes:cAllowedByte|cAllowedInteger|cAllowedReal|cAllowedString countTypes:4 autoTypeIndex:1];
	[componentType addOutput:@"=" outputType:cAllowedFlow];
	[componentType addOutput:@"!=" outputType:cAllowedFlow];
	[componentType addOutput:@"<" outputType:cAllowedFlow];
	[componentType addOutput:@">" outputType:cAllowedFlow];
	[self addComponentType:componentType];
}	

#pragma mark Palette
- (void) setupPaletteLiteral
{
	PSComponentType *componentType;
	
	// Boolean
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_Literal andIndex:cComponentLiteral_Boolean];
	[staticviewLiteralBoolean setComponentType:componentType];
	[staticviewLiteralBoolean setNeedsDisplay:YES];
	
	// Byte
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_Literal andIndex:cComponentLiteral_Byte];
	[staticviewLiteralByte setComponentType:componentType];
	[staticviewLiteralByte setNeedsDisplay:YES];
	
	// DateTime
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_Literal andIndex:cComponentLiteral_DateTime];
	[staticviewLiteralDateTime setComponentType:componentType];
	[staticviewLiteralDateTime setNeedsDisplay:YES];
	
	// Integer
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_Literal andIndex:cComponentLiteral_Integer];
	[staticviewLiteralInteger setComponentType:componentType];
	[staticviewLiteralInteger setNeedsDisplay:YES];
	
	// Real
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_Literal andIndex:cComponentLiteral_Real];
	[staticviewLiteralReal setComponentType:componentType];
	[staticviewLiteralReal setNeedsDisplay:YES];
	
	// String
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_Literal andIndex:cComponentLiteral_String];
	[staticviewLiteralString setComponentType:componentType];
	[staticviewLiteralString setNeedsDisplay:YES];
}

- (void) setupPaletteProgramFlow
{
	PSComponentType *componentType;
	
	// Flow Start
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_ProgramFlow andIndex:cComponentProgramFlow_Start];
	[staticviewProgramFlowStart setComponentType:componentType];
	[staticviewProgramFlowStart setNeedsDisplay:YES];
	
	// Flow Stop
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_ProgramFlow andIndex:cComponentProgramFlow_Stop];
	[staticviewProgramFlowStop setComponentType:componentType];
	[staticviewProgramFlowStop setNeedsDisplay:YES];

	// Flow Pause
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_ProgramFlow andIndex:cComponentProgramFlow_Pause];
	[staticviewProgramFlowPause setComponentType:componentType];
	[staticviewProgramFlowPause setNeedsDisplay:YES];
}	

- (void) setupPaletteConditional
{
	PSComponentType *componentType;
	
	// Flow Start
	componentType = [[NSApp delegate] componentTypeByGroup:cComponentGroup_Conditional andIndex:cComponentConditional_Compare];
	[staticviewConditionalCompare setComponentType:componentType];
	[staticviewConditionalCompare setNeedsDisplay:YES];}

#pragma mark Accessors
- (PSPreferenceController *) m_ControllerPreference
{
	return m_ControllerPreference;
}

- (void) addComponentType:(PSComponentType *)componentType
{
	[m_ComponentTypesArray addObject:componentType];
}

- (NSPanel *) panelPalette
{
	return panelPalette;
}

#pragma mark Actions
- (IBAction) actionMenuPreferences:(NSMenuItem *)sender
{
	// Do we already have a preference controller?
	if (!m_ControllerPreference)
	{
		m_ControllerPreference = [PSPreferenceController new];
	}
	[m_ControllerPreference showWindow:self];
	[m_ControllerPreference updateWindow];
}

#pragma mark User Defaults
- (int) userdefault_GridSize
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:PSUD_GridSize];
}

- (BOOL) userdefault_GridSnap
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:PSUD_GridSnap];
}

- (BOOL) userdefault_ComponentScrollOnSelect
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:PSUD_ComponentScrollOnSelect];
}

- (int) userdefault_ComponentDropAlign
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:PSUD_ComponentDropAlign];
}

- (BOOL) userdefault_ShowAnimations
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:PSUD_ShowAnimations];
}

- (BOOL) userdefault_ShowAnimationsFlow
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults boolForKey:PSUD_ShowAnimationsFlow];
}

- (int) userdefault_CopyConnections
{
	NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
	return [defaults integerForKey:PSUD_ConnectionsCopy];
}

#pragma mark Methods
- (PSComponentType *) componentTypeByGroup:(int)group andIndex:(int)index
{
	NSEnumerator *enumeratorInput = [m_ComponentTypesArray objectEnumerator];
	PSComponentType *componentType = nil;
	while (componentType = [enumeratorInput nextObject])
	{
		if ( ([componentType intGroup] == group) && ([componentType intIndex] == index))
			return componentType;
	}
	return nil;
}

- (BOOL) validateMenuItemEdit:(id <NSMenuItem>)menuItem
{
	// Is there a layout window active?
	NSWindow *mainWindow = [NSApp mainWindow];
	if ([[[mainWindow delegate] windowNibName] compare:@"Project"] == NSOrderedSame)
	{
		return NO;
	}
	else if ([[[mainWindow delegate] windowNibName] compare:@"Layout"] == NSOrderedSame)
	{
		PSLayout *layout = [[[NSDocumentController sharedDocumentController] currentDocument] currentLayout];
		if (layout != nil)
		{
			if ([[menuItem title] compare:@"Select All"] == NSOrderedSame)
			{
				if ([[layout arrayComponents] count] <= 1) 
					return NO;
				else
					return YES;
			}
			else if ([[menuItem title] compare:@"Paste"] == NSOrderedSame)
			{
				if ([m_ComponentsCopy count] > 0)
					return YES;
				else
					return NO;
			}
			else
			{
				if ([[layout arrayComponentsSelected] count] > 0)
					return YES;
				else
					return NO;
			}
		}
	}
	return NO;
}

- (NSColor *) getNonSelectedColour:(NSColor *)color
{
	return 	[NSColor colorWithDeviceRed:[color redComponent] 
								  green:[color greenComponent]
								   blue:[color blueComponent]
								  alpha:cUnSelectedAlpha]; 
}

@end
