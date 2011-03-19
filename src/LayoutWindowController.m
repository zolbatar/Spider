//  Spider
//  PSLayoutWindowController.m
//
//  Created by Daryl Dudey on 14/05/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSLayoutWindowController

#pragma mark Alloc
- (id)init
{
    if (self = [super initWithWindowNibName:@"Layout"])
	{
		[self setShouldCloseDocument:NO];
		[self setShouldCascadeWindows:YES];
	}
	return self;
}

- (void)dealloc
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	[super dealloc];
}

#pragma mark Overrides
- (void) windowDidLoad
{
	// Set canvas size & centre
	[viewMain setFrameSize:NSMakeSize(cCanvasDefaultWidth, cCanvasDefaultHeight)];

	// Setup main view
	[viewMain setViewMainScroll:viewMainScroll];
}

- (NSString *) windowTitleForDocumentDisplayName:(NSString *)displayName
{	
	return [NSString stringWithFormat:@"%@", [m_Layout stringName]];
}

- (NSUndoManager *) windowWillReturnUndoManager:(NSWindow *)sender
{
	return [self undoManager];
}

- (void) windowDidBecomeMain:(NSNotification *)aNotification
{
	[[[NSDocumentController sharedDocumentController] currentDocument] setCurrentLayout:m_Layout];
}

- (void) windowWillClose:(NSNotification *)aNotification
{
	[[[NSDocumentController sharedDocumentController] currentDocument] setCurrentLayout:nil];
	[[[NSDocumentController sharedDocumentController] currentDocument] removeWindowController:self];
}

#pragma mark Keyboard Event Overrides
- (void) keyDown:(NSEvent *)theEvent 
{
	// Are we trying to switch component library?
	//unsigned int currentFlags = [theEvent modifierFlags];
	
	// Send off
    [self interpretKeyEvents:[NSArray arrayWithObject:theEvent]];
}

- (void) deleteForward:(id)sender
{	
	// If nothing selected quit
	if ([[m_Layout arrayComponentsSelected] count] == 0 && [[m_Layout arrayConnectionsSelected] count] == 0)
		return;
	
	// Place to store all the ID's were adding
	NSMutableDictionary *dictionaryID = [NSMutableDictionary new];

	NSUndoManager *undo = [self undoManager];
	NSEnumerator *enumerator =[[m_Layout arrayComponentsSelected] objectEnumerator];
	PSComponent *component = nil;
	while (component = [enumerator nextObject])
	{
		[dictionaryID setObject:component forKey:[NSNumber numberWithLong:[component id]]];

		// Set undo
		[[undo prepareWithInvocationTarget:m_Layout] addDeletedComponent:component];
		
		// Now remove
		[[m_Layout arrayComponentsDeleted] addObject:component];
		[[m_Layout arrayComponents] removeObject:component];

		// Set undo action name
		[undo setActionName:@"Delete Component(s)"];
		[m_Layout makingUndo];
	}
		
	// Do we have any matching connections?
	NSEnumerator *enumeratorConnections = [[m_Layout arrayConnections] objectEnumerator];
	PSConnection *connection = nil;
	while (connection = [enumeratorConnections nextObject])
	{
		if ( ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionSource] componentOwner] id]]] != nil) ||
			 ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionDestination] componentOwner] id]]] != nil) 
			 || [[m_Layout arrayConnectionsSelected] containsObject:connection])
		{
			// Delete this connection
			[m_Layout removeConnection:[connection connectionSource] destination:[connection connectionDestination]];
		}
	}

	[m_Layout clearSelectedComponents];
	[m_Layout clearSelectedConnections];
	[self refreshView];
}

- (void) moveLeft:(id)sender
{
	[self relativeMove:-1 y:0];
}

- (void) moveRight:(id)sender
{
	[self relativeMove:1 y:0];
}

- (void) moveUp:(id)sender
{
	[self relativeMove:0 y:-1];
}

- (void) moveDown:(id)sender
{
	[self relativeMove:0 y:1];
}

#pragma mark Toolbar
- (void) setupToolbar
{
	m_ToolbarMain = [[[NSToolbar alloc] initWithIdentifier: @"Toolbar"] autorelease];
    
    // Set up toolbar properties: Allow customization, give a default display mode, and remember state in user defaults 
    [m_ToolbarMain setAllowsUserCustomization: YES];
    [m_ToolbarMain setAutosavesConfiguration: NO];
    [m_ToolbarMain setDisplayMode: NSToolbarDisplayModeIconAndLabel];
	[m_ToolbarMain setSizeMode:NSToolbarSizeModeRegular];
    
    // We are the delegate
    [m_ToolbarMain setDelegate: self];
    
    // Attach the toolbar to the document window 
    [windowDocument setToolbar: m_ToolbarMain];
}

// Toolbar item titles
static NSString *toolbarItemIdentifierShowRulers = @"Show Rulers";
static NSString *toolbarItemIdentifierZoomNormal = @"Zoom Normal";
static NSString *toolbarItemIdentifierZoomIn = @"Zoom In";
static NSString *toolbarItemIdentifierZoomOut = @"Zoom Out";
static NSString *toolbarItemIdentifierShowPalette = @"Show/Hide Palette";

- (NSToolbarItem *)toolbar:(NSToolbar *)toolbar
     itemForItemIdentifier:(NSString *)itemIdentifier
 willBeInsertedIntoToolbar:(BOOL)flag
{
	NSToolbarItem *toolbarItem = [[[NSToolbarItem alloc] initWithItemIdentifier: itemIdentifier] autorelease];
    if ([itemIdentifier isEqual: toolbarItemIdentifierShowRulers]) 
	{
		[toolbarItem setLabel:@"Rulers"];
		[toolbarItem setPaletteLabel:@"Rulers"];
		[toolbarItem setToolTip:@"Show/Hide Rulers"];
		[toolbarItem setImage:[NSImage imageNamed:@"Rulers.tiff"]];
		[toolbarItem setAction:@selector(toggleRulers:)];
		[toolbarItem setTarget:self];
	}
	else if ([itemIdentifier isEqual: toolbarItemIdentifierZoomNormal])
	{
		[toolbarItem setLabel:@"Normal"];
		[toolbarItem setPaletteLabel:@"Normal"];
		[toolbarItem setToolTip:@"Zoom back to 100%"];
		[toolbarItem setImage:[NSImage imageNamed:@"ZoomNormal.tiff"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(zoomNormal:)];
	}
	else if ([itemIdentifier isEqual: toolbarItemIdentifierZoomIn])
	{
		m_ToolbaritemZoomIn = toolbarItem;
		[toolbarItem setLabel:@"In"];
		[toolbarItem setPaletteLabel:@"In"];
		[toolbarItem setToolTip:@"Zoom In"];
		[toolbarItem setImage:[NSImage imageNamed:@"ZoomIn.tiff"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAutovalidates:NO];
		[toolbarItem setAction:@selector(zoomIn:)];
	}
	else if ([itemIdentifier isEqual: toolbarItemIdentifierZoomOut])
	{
		m_ToolbaritemZoomOut = toolbarItem;
		[toolbarItem setLabel:@"Out"];
		[toolbarItem setPaletteLabel:@"Out"];
		[toolbarItem setToolTip:@"Zoom Out"];
		[toolbarItem setImage:[NSImage imageNamed:@"ZoomOut.tiff"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAutovalidates:NO];
		[toolbarItem setAction:@selector(zoomOut:)];
	}
	else if ([itemIdentifier isEqual: toolbarItemIdentifierShowPalette])
	{
		[toolbarItem setLabel:@"Palette"];
		[toolbarItem setPaletteLabel:@"Palette"];
		[toolbarItem setToolTip:@"Show/Hide Palette"];
		[toolbarItem setImage:[NSImage imageNamed:@"Palette.tiff"]];
		[toolbarItem setTarget:self];
		[toolbarItem setAction:@selector(togglePalette:)];
	} else  {
		toolbarItem = nil;
    }
    return toolbarItem;
}

- (NSArray *) toolbarAllowedItemIdentifiers: (NSToolbar *) toolbar
{
    return [NSArray arrayWithObjects:
			toolbarItemIdentifierZoomIn,
			toolbarItemIdentifierZoomOut,
			toolbarItemIdentifierShowPalette,
			NSToolbarSeparatorItemIdentifier,
			NSToolbarFlexibleSpaceItemIdentifier,
			NSToolbarSpaceItemIdentifier,
			nil];
}

- (NSArray *) toolbarDefaultItemIdentifiers: (NSToolbar *) toolbar 
{
    return [NSArray arrayWithObjects: 
			toolbarItemIdentifierZoomOut,
			toolbarItemIdentifierZoomIn,
			NSToolbarFlexibleSpaceItemIdentifier,
			toolbarItemIdentifierShowPalette,
			nil];
}

- (void) togglePalette:(id)sender
{
	if ([[[NSApp delegate] panelPalette] isVisible])
		[[[NSApp delegate] panelPalette] setIsVisible:NO];
	else
		[[[NSApp delegate] panelPalette] setIsVisible:YES];
}

- (void) showPalette:(id)sender
{
	[[[NSApp delegate] panelPalette] setIsVisible:YES];
}

- (void) toggleRulers:(id)sender
{
	if ([viewMainScroll rulersVisible])
	{
		[viewMainScroll setRulersVisible:NO];
	}
	else {
		[viewMainScroll setRulersVisible:YES];
	}
}

- (void) zoomIn:(id)sender
{
	float scale = [m_Layout floatScale];
	if (scale < cCanvasMaximumScale)
	{
		// Add inverse to undo stack
		[[[m_Layout undoManager] prepareWithInvocationTarget:self] zoomOut:self];
		if (![[m_Layout undoManager] isUndoing])
		{
			[[m_Layout undoManager] setActionName:@"Zoom In"];
			[m_Layout makingUndo];
		}
		else 
		{
			[m_Layout doingUndo];
		}
		
		// Zoom
		[m_Layout setScale:scale * 2.0];
	}
}

- (void) zoomOut:(id)sender
{
	float scale = [m_Layout floatScale];
	if (scale > cCanvasMinimumScale)
	{
		// Add inverse to undo stack
		[[[m_Layout undoManager] prepareWithInvocationTarget:self] zoomIn:self];
		if (![[m_Layout undoManager] isUndoing])
		{
			[[m_Layout undoManager] setActionName:@"Zoom In"];
			[m_Layout makingUndo];
		}
		else 
		{
			[m_Layout doingUndo];
		}
		
		// Zoom
		[m_Layout setScale:scale / 2.0];
	}
}

#pragma mark Accessors
- (void) setProject:(PSProject *)project
{
	m_Project = project;
}

- (void) setLayout:(PSLayout *)layout
{
	m_Layout = layout;
//	[m_Layout setControllerLayout:self];
}

- (PSLayout *) layout
{
	return m_Layout;
}

- (PSLayout *) getLayout
{
	return m_Layout;
}

- (PSView *) viewMain
{
	return viewMain;
}

- (NSUndoManager *) undoManager
{
	return [m_Layout undoManager];
}

- (NSToolbar *) toolbar
{
	return m_ToolbarMain;
}

- (NSToolbarItem *) toolbaritemZoomIn
{
	return m_ToolbaritemZoomIn;
}

- (NSToolbarItem *) toolbaritemZoomOut
{
	return m_ToolbaritemZoomOut;
}

#pragma mark Methods
- (void) drawComponents:(PSView *)sender andPositionAndSize:(NSRect)positionAndSize
{
	int phase;
	for (phase = 0; phase < 2; phase++)
	{
		NSEnumerator *enumerator = [[m_Layout arrayComponents] objectEnumerator];
		PSComponent *component = nil;
		while (component = [enumerator nextObject])
		{
			if (  (phase == 0 && ![[m_Layout arrayComponentsSelected] containsObject:component]) ||
				  (phase == 1 && [[m_Layout arrayComponentsSelected] containsObject:component]))
			{
				// Can we see it? 
				BOOL visible = YES;
				if (([component intX] - cComponentSpacingLR) > (positionAndSize.origin.x + positionAndSize.size.width)) visible = NO;
				if (([component intX] + [component intWidth] + cComponentSpacingLR) < positionAndSize.origin.x) visible = NO;
				if ([component intY] > (positionAndSize.origin.y + positionAndSize.size.height)) visible = NO;
				if (([component intY] + [component intHeight]) < positionAndSize.origin.y) visible = NO;

				// If so, display
				if (visible && [component isComplete]) 
				{
					[component drawComponent:sender selected:[[m_Layout arrayComponentsSelected] containsObject:component]];
				}
			}
		}
	}
}

- (void) drawConnections:(PSView *)sender andPositionAndSize:(NSRect)positionAndSize
{
	int phase;
	for (phase = 0; phase < 2; phase++)
	{
		NSEnumerator *enumerator = [[m_Layout arrayConnections] objectEnumerator];
		PSConnection *connection;
		while (connection = [enumerator nextObject])
		{
			if (  (phase == 0 && ![[m_Layout arrayConnectionsSelected] containsObject:connection]) ||
				  (phase == 1 && [[m_Layout arrayConnectionsSelected] containsObject:connection]))
			{
				PSComponentConnection *output = [connection connectionSource];
				PSComponentConnection *input = [connection connectionDestination];

				// Draw line	
				NSBezierPath *connectionLine = [NSBezierPath bezierPath];
				[connectionLine setLineCapStyle:NSSquareLineCapStyle];

				// Line width, depends on whether we are selected or not.
				[connectionLine setLineWidth:cConnectionThickess];
				if ([[m_Layout arrayConnectionsSelected] containsObject:connection] && phase == 1)
				{
					float lineDash[2];
					lineDash[0] = 5.0; 
					lineDash[1] = 5.0;
					[connectionLine setLineDash:lineDash count:2 phase:[[[m_Layout controllerLayout] viewMain] floatRedrawPhase]];			
				}
		
				// Correct connection colour
				switch ([output intOutputType])
				{
					case cAllowedFlow:
						[[[NSApp delegate] colourConnectionFlow] set];
						[[[NSApp delegate] colourConnectionFlow] setFill];
						break;
					case cAllowedBoolean:
						[[[NSApp delegate] colourConnectionBoolean] set];
						[[[NSApp delegate] colourConnectionBoolean] setFill];
						break;
					case cAllowedByte:
						[[[NSApp delegate] colourConnectionByte] set];
						[[[NSApp delegate] colourConnectionByte] setFill];
						break;
					case cAllowedDateTime:
						[[[NSApp delegate] colourConnectionDateTime] set];
						[[[NSApp delegate] colourConnectionDateTime] setFill];
						break;
					case cAllowedInteger:
						[[[NSApp delegate] colourConnectionInteger] set];
						[[[NSApp delegate] colourConnectionInteger] setFill];
						break;
					case cAllowedReal:
						[[[NSApp delegate] colourConnectionReal] set];
						[[[NSApp delegate] colourConnectionReal] setFill];
						break;
					case cAllowedString:
						[[[NSApp delegate] colourConnectionString] set];
						[[[NSApp delegate] colourConnectionString] setFill];
						break;
				}
				
				// Now make the link
				[connectionLine moveToPoint:NSMakePoint([output floatAbsConnectionX] + cConnectionSize/2, 
														[output floatAbsConnectionY] + cConnectionSize/2)];
				[connectionLine lineToPoint:NSMakePoint([input floatAbsConnectionX] - cConnectionSize/2, 
														[input floatAbsConnectionY] + cConnectionSize/2)];
				[connectionLine stroke];
			
				// Do we want fancy animated arrows?
				if ( [[NSApp delegate] userdefault_ShowAnimations] && [[NSApp delegate] userdefault_ShowAnimationsFlow] )
				{
					[NSGraphicsContext saveGraphicsState];
					
					float width = ([input floatAbsConnectionX] - cConnectionSize/2) - ([output floatAbsConnectionX] + cConnectionSize/2);
					float height = ([input floatAbsConnectionY] + cConnectionSize/2) - ([output floatAbsConnectionY] + cConnectionSize/2);
					float length = sqrt ((width) * (width) +
										 (height) * (height));
					float angle = asin(abs(width) / length);
					
					// Loop through every x pixels and stick a arrow
					NSBezierPath *arrow = [NSBezierPath bezierPath];
					[[NSColor blackColor] set];
					[[NSColor whiteColor] setFill];
					[arrow setLineCapStyle:NSSquareLineCapStyle];
					[arrow setLineWidth:cConnectionThickess];
					float pos = ([[[m_Layout controllerLayout] viewMain] floatRedrawPhaseReversed] * cAnimationConnectionSpeed);
					while (pos > cAnimationCycle)
						pos -= cAnimationCycle;
					for (; pos < length; pos += cAnimationCycle )
					{
						NSAffineTransform* xform = [NSAffineTransform transform];
						
						// Quadrant?
						if (height > 0)
						{
							if (width > 0)
							{
								[xform translateXBy:([output floatAbsConnectionX] + cConnectionSize/2) + (pos * sin(angle)) 
												yBy:([output floatAbsConnectionY] + cConnectionSize/2) + (pos * cos(angle))];
								[xform rotateByRadians:-angle];
							}
							else
							{
								[xform translateXBy:([output floatAbsConnectionX] + cConnectionSize/2) - (pos * sin(angle)) 
												yBy:([output floatAbsConnectionY] + cConnectionSize/2) + (pos * cos(angle))];
								[xform rotateByRadians:angle];
							}
						}
						else
						{
							if (width > 0)
							{
								[xform translateXBy:([output floatAbsConnectionX] + cConnectionSize/2) + (pos * sin(angle)) 
												yBy:([output floatAbsConnectionY] + cConnectionSize/2) - (pos * cos(angle))];
								[xform rotateByRadians:(angle + pi)];
							}
							else
							{
								[xform translateXBy:([output floatAbsConnectionX] + cConnectionSize/2) - (pos * sin(angle)) 
												yBy:([output floatAbsConnectionY] + cConnectionSize/2) - (pos * cos(angle))];
								[xform rotateByRadians:-(angle + pi)];
							}
						}
						[xform concat];
						
						// Apply the changes
						[arrow moveToPoint:NSMakePoint(0, -cArrowSize)];
						[arrow lineToPoint:NSMakePoint(cArrowSize, -cArrowSize)];
						[arrow lineToPoint:NSMakePoint(0, cArrowSize)];
						[arrow lineToPoint:NSMakePoint(-cArrowSize, -cArrowSize)];
						[arrow lineToPoint:NSMakePoint(0, -cArrowSize)];
						[arrow stroke];
						[arrow fill];
			
						// Undo transform
						[xform invert];
						[xform concat];
					}
					[NSGraphicsContext restoreGraphicsState];
				}
			}
		}
	}
}

- (BOOL) matchComponent:(NSPoint)point shiftHeld:(BOOL)shiftHeld
{
	NSEnumerator *enumerator = [[m_Layout arrayComponents] objectEnumerator];
	PSComponent *component;
	while (component = [enumerator nextObject])
	{
		// Within limits of this component?
		if ( (point.x >= [component intX]) && (point.x <= ([component intX] + [component intWidth])) )
		{
			if ( (point.y >= [component intY]) && (point.y <= ([component intY] + [component intHeight])) )
			{
				// Selection behaviour
				if (!shiftHeld)
				{
					// Is the selected one one we already have selected?
					if ([[m_Layout arrayComponentsSelected] containsObject:component])
					{
						return YES;
					}
					else
					{
						[m_Layout clearSelectedConnections];
						[m_Layout clearSelectedComponents];
					}
				}
				else
				{
					if ([[m_Layout arrayComponentsSelected] count] > 1)
					{
						// Is the selected one one we already have selected?
						if ([[m_Layout arrayComponentsSelected] containsObject:component])
						{
							[[m_Layout arrayComponentsSelected] removeObject:component];
							
							// Any objects left?
							if ([[m_Layout arrayComponentsSelected] count] >= 1)
							{
								if ([[m_Layout arrayComponentsSelected] count] == 1)
									[m_Layout clearSelectedConnections];
								[self setSelectedConnectionsBasedOnSelectedComponents];
								[self refreshView];
								[self updateInspector];
								return YES;
								
							}
							else
							{
								[m_Layout clearSelectedConnections];
								[self refreshView];
								[self updateInspector];
								return NO;
							}
						}
					}
					else if ([[m_Layout arrayComponentsSelected] count] == 1)
					{
						if ([[m_Layout arrayComponentsSelected] containsObject:component])
						{
							[m_Layout clearSelectedComponents];
							[self refreshView];
							[self updateInspector];
							return NO;
						}
					}
				}
				
				// Centre view on it
				if ([[NSApp delegate] userdefault_ComponentScrollOnSelect])
				{
					NSPoint centrePoint = NSMakePoint([component intX] + ([component intWidth]/2),
													  [component intY] + ([component intHeight]/2));
					[viewMain setCentrePoint:centrePoint];
					[viewMain centreView];
				}

				// Add, setup connections
				[m_Layout addSelectedComponent:component];
				[self setSelectedConnectionsBasedOnSelectedComponents];
				
				// Update inspector
				[self refreshView];
				[self updateInspector];
				return YES;
			}
		}
	}
	// No match
	[m_Layout clearSelectedComponents];
	[self refreshView];
	[self updateInspector];
	return NO;
}

- (PSComponentConnection *) matchConnection:(NSPoint)point matchType:(int)matchType matchInput:(BOOL)matchInput matchOutput:(BOOL)matchOutput
{
	NSEnumerator *enumerator = [[m_Layout arrayComponents] objectEnumerator];
	PSComponent *component;
	while (component = [enumerator nextObject])
	{
		// Check inputs
		if (matchInput)
		{
			NSEnumerator *enumeratorInput = [[component arrayInputs] objectEnumerator];
			PSComponentConnection *input = nil;
			while (input = [enumeratorInput nextObject])
			{
				if ( (point.x >= ([input floatAbsConnectionX] - cConnectionSize)) &&
					 (point.x <= [input floatAbsConnectionX]) &&
					 (point.y >= [input floatAbsConnectionY]) &&
					 (point.y <= ([input floatAbsConnectionY] + cConnectionSize)))
				{
					switch ([input intConnectionType])
					{
						case cComponentConnection_Normal:
						case cComponentConnection_AutoType:
							if (matchType == 0)
								return input;
							if (([input intAllowedTypes] & matchType) > 0)
								return input;
							break;
						case cComponentConnection_TypeSet:
							if (matchType == 0 && ([input intEffectiveType] != nil))
								return input;
							if (([input intAllowedTypes] & matchType) > 0)
								return input;
							break;
					}
				}
			}
		}	

		if (matchOutput)
		{
			// Check outputs
			NSEnumerator *enumeratorOutput = [[component arrayOutputs] objectEnumerator];
			PSComponentConnection *output = nil;
			while (output = [enumeratorOutput nextObject])
			{
				if ( (point.x >= [output floatAbsConnectionX]) &&
					 (point.x <= ([output floatAbsConnectionX] + cConnectionSize)) &&
					 (point.y >= [output floatAbsConnectionY]) &&
					 (point.y <= ([output floatAbsConnectionY] + cConnectionSize)))
				{
					switch ([output intConnectionType])
					{
						case cComponentConnection_Normal:
						case cComponentConnection_AutoType:
							if (matchType == 0)
								return output;
							if (([output intOutputType] & matchType) > 0)
								return output;
							break;
						case cComponentConnection_TypeSet:
							if (matchType == 0 && [output intEffectiveType] != nil)
								return output;
							if (([output intOutputType] & matchType) > 0)
								return output;
							break;
					}
				}
			}
		}	
	}
	return nil;
}

- (PSConnection *) matchConnectionLine:(NSPoint)point
{
	// Clear any selections first
	[m_Layout clearSelectedConnections];
	
	NSEnumerator *enumerator = [[m_Layout arrayConnections] objectEnumerator];
	PSConnection *connection, *closestConnection = nil;
	float closestDistance = cMatchDistance;
	while (connection = [enumerator nextObject])
	{
		// Get end of line points
		NSPoint a = NSMakePoint([[connection connectionSource] floatAbsConnectionX], 
								[[connection connectionSource] floatAbsConnectionY]);
		NSPoint b = NSMakePoint([[connection connectionDestination] floatAbsConnectionX], 
								[[connection connectionDestination] floatAbsConnectionY]);
		
		// Calculate distance
		float distance = [self calculateDistancePointToLine:point lineStart:a lineEnd:b];
		
		// Are we closer?
		if ( (distance != -1.0) && (distance < closestDistance) )
		{
			closestDistance = distance;
			closestConnection = connection;
		}
	}
	
	// Do we have a connection?
	if (closestConnection != nil)
	{
		[m_Layout setSelectedConnection:closestConnection];
		return closestConnection;
	}
	else
	{
		[m_Layout clearSelectedConnections];
		return nil;
	}
} 

- (void) selectionBox:(NSRect)rect
{
	// Clear currently selected
	[m_Layout clearSelectedComponents];

	// Place to store all the ID's were adding
	NSMutableDictionary *dictionaryID = [NSMutableDictionary new];

	// Now find 'em!
	NSEnumerator *enumerator = [[m_Layout arrayComponents] objectEnumerator];
	PSComponent *component;
	while (component = [enumerator nextObject])
	{
		// Within limits of this component?
		if ( (([component intX] >= rect.origin.x) ||
			 (([component intX] + [component intWidth]) >= rect.origin.x)) &&
			 (([component intX] <= rect.origin.x + rect.size.width) || 
			 (([component intX] + [component intWidth]) <= rect.origin.x + rect.size.width)))
		{
			if ( (([component intY] >= rect.origin.y) || 
				 (([component intY] + [component intHeight]) >= rect.origin.y)) &&
				 (([component intY] <= rect.origin.y + rect.size.height) || 
				 (([component intY] + [component intHeight]) <= rect.origin.y + rect.size.height)))
			{
				// Make this component the currently selected one
				[m_Layout addSelectedComponent:component];
				[dictionaryID setObject:component forKey:[NSNumber numberWithLong:[component id]]];
			}
		}
	}

	// Set selected connections
	[self setSelectedConnectionsBasedOnSelectedComponents];

	[self refreshView];
	[self updateInspector];
}

- (void) dragLeftWithX:(int)deltaX andY:(int)deltaY
{
	PSComponent *component;
	NSEnumerator *enumeratorSelected = [[m_Layout arrayComponents] objectEnumerator];
	while (component = [enumeratorSelected nextObject])
	{
		if ([[m_Layout arrayComponentsSelected] containsObject:component])
		{
			[component setX:[component intX] + deltaX
					   andY:[component intY] + deltaY];
		}
	}
	[self updateInspector];
}

- (void) refreshView
{
	[viewMain setNeedsDisplay:YES];
}

- (void) updateInspector
{
	// Only show inspector if we have one selected object
	PSComponent *selectedComponent = nil;
	if ([[m_Layout arrayComponentsSelected] count] == 1)
	{
		selectedComponent = [[m_Layout arrayComponentsSelected] objectAtIndex:0];
	}

	if (selectedComponent == nil)
	{
		[textfieldTitleValueLabel setStringValue:@"Title:"];
		[textfieldTitleValue setStringValue:@""];
		[textfieldID setStringValue:@""];
		[textfieldType setStringValue:@""];
		[textfieldPosition setStringValue:@""];
		[textfieldSize setStringValue:@""];
	}
	else
	{
		switch ([[selectedComponent componentType] intStyle])
		{
			case cComponentStyle_Literal: 
				[textfieldTitleValueLabel setStringValue:@"Value:"];
				[textfieldTitleValue setStringValue:[selectedComponent stringName]];
				break;
			default:
				[textfieldTitleValueLabel setStringValue:@"Title:"];
				[textfieldTitleValue setStringValue:[selectedComponent stringName]];
				break;
		}
		[textfieldID setStringValue:[NSString stringWithFormat:@"%d", [selectedComponent id]]];
		[textfieldType setStringValue: [[selectedComponent componentType] stringName]]; 
		[textfieldPosition setStringValue:[NSString stringWithFormat:@"%d, %d", 
			[selectedComponent intX], [selectedComponent intY]]];
		[textfieldSize setStringValue:[NSString stringWithFormat:@"%d x %d", 
			[selectedComponent intWidth], [selectedComponent intHeight]]];
	}
}

- (void) relativeMove:(int)x y:(int)y
{
	// Grid spacing
	if ([[NSApp delegate] userdefault_GridSnap])
	{	
		x *= [[NSApp delegate] userdefault_GridSize];
		y *= [[NSApp delegate] userdefault_GridSize];
	}
	
	// Move right 
	NSUndoManager *undo = [self undoManager];
	NSEnumerator *enumerator =[[m_Layout arrayComponentsSelected] objectEnumerator];
	PSComponent *component = nil;
	while (component = [enumerator nextObject])
	{
		// Set undo
		[[undo prepareWithInvocationTarget:m_Layout] moveComponent:component
																 x:[component intX] 
																 y:[component intY]];
		
		// Now move
		[m_Layout moveComponent:component
							  x:[component intX] + x
							  y:[component intY] + y];

		// Set undo action name
		[undo setActionName:@"Move Component(s)"];
		[m_Layout makingUndo];
	}
}

- (void) postAddComponent:(PSComponent *)component
{
	int group = [[component componentType] intGroup];
	int index = [[component componentType] intIndex];
	switch (group)
	{
		case cComponentGroup_Literal:
			switch (index)
			{
				case cComponentLiteral_Boolean:
					[component setValueBoolean:NO simple:NO];
					break;
				case cComponentLiteral_Byte:
					[component setValueByte:0 simple:NO];
					break;
				case cComponentLiteral_DateTime:
					[m_ComponentValue setValueDateTime:[NSCalendarDate dateWithString:@"2000-01-01 00:00:00"] simple:NO];
					break;
				case cComponentLiteral_Integer:
					[component setValueInteger:0 simple:NO];
					break;
				case cComponentLiteral_Real:
					[component setValueReal:0.0 simple:NO];
					break;
				case cComponentLiteral_String:
					[component setValueString:@"" simple:NO];
					break;
			}
			[self setLiteralValue:component];
			return;
		default:
			if ([[component componentType] stringShortName] != nil)
			{
				[component setName:[[component componentType] stringShortName] simple:NO];
			}
	}
	
	// Refresh layout
	[component setComplete:YES];
	[self refreshView];
}

- (void) setLiteralValue:(PSComponent *)component
{
	m_ComponentValue = component;
	int index = [[component componentType] intIndex];
	switch (index)
	{
		case cComponentLiteral_Boolean:
			if ([component boolValue])
			{
				[buttoncellValueBooleanTrue setState:NSOffState];
				[buttoncellValueBooleanFalse setState:NSOnState];
			}
			else
			{
				[buttoncellValueBooleanTrue setState:NSOnState];
				[buttoncellValueBooleanFalse setState:NSOffState];
			}
			[NSApp beginSheet:windowValueBoolean
			   modalForWindow:[self window]
				modalDelegate:self
			   didEndSelector:@selector(getValueDidEnd:returnCode:contextInfo:)
				  contextInfo:NULL];
			break;
		case cComponentLiteral_Byte:
			[textfieldValueByte setStringValue:[NSString stringWithFormat:@"%d",[component byteValue]]];
			[NSApp beginSheet:windowValueByte
			   modalForWindow:[self window]
				modalDelegate:self
			   didEndSelector:@selector(getValueDidEnd:returnCode:contextInfo:)
				  contextInfo:NULL];
			break;
		case cComponentLiteral_DateTime:
			[datepickerDateTime setDateValue:[component datetimeValue]];
			[NSApp beginSheet:windowValueDateTime
			   modalForWindow:[self window]
				modalDelegate:self
			   didEndSelector:@selector(getValueDidEnd:returnCode:contextInfo:)
				  contextInfo:NULL];
			break;
		case cComponentLiteral_Integer:
			[textfieldValueInteger setStringValue:[NSString stringWithFormat:@"%d",[component intValue]]];
			[NSApp beginSheet:windowValueInteger
			   modalForWindow:[self window]
				modalDelegate:self
			   didEndSelector:@selector(getValueDidEnd:returnCode:contextInfo:)
				  contextInfo:NULL];
			break;
		case cComponentLiteral_Real:
			[textfieldValueReal setStringValue:[NSString stringWithFormat:@"%f",[component realValue]]];
			[NSApp beginSheet:windowValueReal
			   modalForWindow:[self window]
				modalDelegate:self
			   didEndSelector:@selector(getValueDidEnd:returnCode:contextInfo:)
				  contextInfo:NULL];
			break;
		case cComponentLiteral_String:
			[textfieldValueString setStringValue:[component stringValue]];
			[NSApp beginSheet:windowValueString
			   modalForWindow:[self window]
				modalDelegate:self
			   didEndSelector:@selector(getValueDidEnd:returnCode:contextInfo:)
				  contextInfo:NULL];
			break;
	}
}

- (IBAction) getValueDidEnd:(NSWindow *)sheet
				 returnCode:(int) returnCode
				contextInfo:(void *) contextInfo
{
	[sheet orderOut:self];
}

- (IBAction) actionValueDone:(NSTextField *)sender
{
	int group = [[m_ComponentValue componentType] intGroup];
	int index = [[m_ComponentValue componentType] intIndex];
	switch (group)
	{
		case cComponentGroup_Literal:
			switch (index)
			{
				case cComponentLiteral_Boolean:
					if ([buttoncellValueBooleanTrue state] == NSOnState)
						[m_ComponentValue setValueBoolean:YES simple:NO];
					else
						[m_ComponentValue setValueBoolean:NO simple:NO];
					[NSApp endSheet:windowValueBoolean];
					break;
				case cComponentLiteral_Byte:
					[m_ComponentValue setValueByte:[textfieldValueByte intValue] simple:NO];
					[NSApp endSheet:windowValueByte];
					break;
				case cComponentLiteral_DateTime:
					[m_ComponentValue setValueDateTime:[datepickerDateTime dateValue] simple:NO];
					[NSApp endSheet:windowValueDateTime];
					break;
				case cComponentLiteral_Integer:
					[m_ComponentValue setValueInteger:[textfieldValueInteger intValue] simple:NO];
					[NSApp endSheet:windowValueInteger];
					break;
				case cComponentLiteral_Real:
					[m_ComponentValue setValueReal:[textfieldValueReal doubleValue] simple:NO];
					[NSApp endSheet:windowValueReal];
					break;
				case cComponentLiteral_String:
					[m_ComponentValue setValueString:[textfieldValueString stringValue] simple:NO];
					[NSApp endSheet:windowValueString];
					break;
			}
			break;
	}
	
	// Refresh layout
	[m_ComponentValue setComplete:YES];
	m_ComponentValue = nil;
	[m_Layout refreshView];
}

- (float) calculateDistancePointToLine:(NSPoint)point lineStart:(NSPoint)lineStart lineEnd:(NSPoint)lineEnd
{
	float length = sqrt	((lineEnd.x - lineStart.x) * (lineEnd.x - lineStart.x) +
						 (lineEnd.y - lineStart.y) * (lineEnd.y - lineStart.y));
	float lengthToLine = abs((point.x - lineStart.x) * (lineEnd.y - lineStart.y) - 
							 (point.y - lineStart.y) * (lineEnd.x - lineStart.x)) / length;
	float distanceP1 = sqrt ((point.x - lineStart.x) * (point.x - lineStart.x) +
							 (point.y - lineStart.y) * (point.y - lineStart.y));
	float distanceP2 = sqrt ((point.x - lineEnd.x) * (point.x - lineEnd.x) +
							 (point.y - lineEnd.y) * (point.y - lineEnd.y));
	if ( (distanceP1 > length) || (distanceP2 > length))
		 return -1;
	return lengthToLine;
}

- (void) setSelectedConnectionsBasedOnSelectedComponents
{
	[m_Layout clearSelectedConnections];

	// Place to store all the ID's were adding
	NSMutableDictionary *dictionaryID = [NSMutableDictionary new];

	// Loop through
	NSEnumerator *enumerator = [[m_Layout arrayComponentsSelected] objectEnumerator];
	PSComponent *component;
	while (component = [enumerator nextObject])
	{
		[dictionaryID setObject:component forKey:[NSNumber numberWithLong:[component id]]];
	}
	
	// Do we have any connections to highlight?
	NSEnumerator *enumeratorConnections = [[m_Layout arrayConnections] objectEnumerator];
	PSConnection *connection = nil;
	while (connection = [enumeratorConnections nextObject])
	{
		// Do we want it?
		if ( ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionSource] componentOwner] id]]] != nil) &&
			 ([dictionaryID objectForKey:[NSNumber numberWithLong:[[[connection connectionDestination] componentOwner] id]]] != nil))
		{
			[m_Layout addSelectedConnection:connection];
		}
	}
}

@end
