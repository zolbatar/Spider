//  Spider
//  Layout.m
//
//  Created by Daryl Dudey on 18/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSLayout

#pragma mark Alloc
- (id)init
{
	self = [super init];
	
	// Register for user default changes
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleGridSizeChanged:)
												 name:@"PSUD_GridSize_Changed"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleGridSnapChanged:)
												 name:@"PSUD_GridSnap_Changed"
											   object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(handleArrowheadsDrawnChanged:)
												 name:@"PSUD_ShowAnimations_Changed"
											   object:nil];
	
	// Setup
	m_Components = [NSMutableArray new];
	m_ComponentsSelected = [NSMutableArray new];
	m_Connections = [NSMutableArray new];
	m_ConnectionsSelected = [NSMutableArray new];
	m_ComponentsArrayDeleted = [NSMutableArray new];
	[m_Components retain];
	[m_ComponentsSelected retain];
	[m_Connections retain];
	[m_ConnectionsSelected retain];
	[m_ComponentsArrayDeleted retain];
	m_ComponentID = 1;
	m_ConnectionID = 1;
	m_Ready = NO;
	
	// Setup undo manager
	m_UndoManager = [NSUndoManager new];
	[m_UndoManager retain];
	m_UndoCount = 0;

    return self;
}

- (void)dealloc
{
	[m_Name release];
	[m_Components release];
	[m_ComponentsSelected release];
	[m_Connections release];
	[m_ConnectionsSelected release];
	[m_ComponentsArrayDeleted release];
	[m_UndoManager release];

	// Unregister user default changes
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[super dealloc];
}

#pragma mark Archiving
- (id) initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		// Load
		m_Name = [coder decodeObjectForKey:@"m_Name"];
		m_SizeAndPosition = [coder decodeRectForKey:@"m_SizeAndPosition"];
		m_ComponentID = [coder decodeInt64ForKey:@"m_ComponentID"];
		m_ConnectionID = [coder decodeInt64ForKey:@"m_ConnectionID"];
		m_Components = [coder decodeObjectForKey:@"m_Components"];
		m_Connections = [coder decodeObjectForKey:@"m_Connections"];
		m_ConnectionsSelected = [NSMutableArray new];
		m_ComponentsSelected = [NSMutableArray new];
		m_ComponentsArrayDeleted = [NSMutableArray new];
		[m_Name retain];
		[m_Components retain];
		[m_ComponentsSelected retain];
		[m_Connections retain];
		[m_ConnectionsSelected retain];
		[m_ComponentsArrayDeleted retain];
		m_Ready = NO;

		// Setup undo manager
		m_UndoManager = [NSUndoManager new];
		[m_UndoManager retain];
		m_UndoCount = 0;
		
		[self postLoadSetup];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeObject:m_Name					forKey:@"m_Name"];
	[coder encodeRect:m_SizeAndPosition			forKey:@"m_SizeAndPosition"];
	[coder encodeInt64:m_ComponentID			forKey:@"m_ComponentID"];
	[coder encodeInt64:m_ConnectionID			forKey:@"m_ConnectionID"];
	[coder encodeObject:m_Components			forKey:@"m_Components"];
	[coder encodeObject:m_Connections			forKey:@"m_Connections"];
}

#pragma mark Accessors
- (void) setProject:(PSProject *)project
{
	m_Project = project;
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

- (NSMutableArray *) arrayComponents
{
	return m_Components;
}

- (NSMutableArray *) arrayComponentsDeleted
{
	return m_ComponentsArrayDeleted;
}

- (NSMutableArray *) arrayComponentsSelected
{
	return m_ComponentsSelected;
}

- (void) setSelectedComponent:(PSComponent *)componentSelected
{
	[self clearSelectedComponents];
	[m_ComponentsSelected addObject:componentSelected];
}

- (void) addSelectedComponent:(PSComponent *)componentSelected
{
	if (componentSelected != nil)
	{
		if (![m_ComponentsSelected containsObject:componentSelected])
			[m_ComponentsSelected addObject:componentSelected];
	}
}

- (long) nextComponentID
{
	return m_ComponentID++;
}

- (long) nextConnectionID
{
	return m_ConnectionID++;
}

- (PSLayoutWindowController *) controllerLayout
{
	return m_ControllerLayout;
}

- (NSMutableArray *) arrayConnections
{
	return m_Connections;
}

- (NSMutableArray *) arrayConnectionsSelected
{
	return m_ConnectionsSelected;
}

- (void) setSelectedConnection:(PSConnection *)connectionSelected
{
	[self clearSelectedConnections];
	[m_ConnectionsSelected addObject:connectionSelected];
}

- (void) addSelectedConnection:(PSConnection *)connectionSelected
{
	if (connectionSelected != nil)
	{
		if (![m_ConnectionsSelected containsObject:connectionSelected])
			[m_ConnectionsSelected addObject:connectionSelected];
	}
}

- (NSUndoManager *) undoManager
{
	return m_UndoManager;
}

- (PSProject *) project
{
	return m_Project;
}

- (float) floatScale
{
	return m_Scale;
}

- (void) setScale:(float)scale
{
	m_Scale = scale;
	return;
	
	// Min zoom?
	float minScale = cCanvasMinimumScale;
	if (m_Scale <= minScale)
		[[m_ControllerLayout toolbaritemZoomOut] setEnabled:NO];
	else
		[[m_ControllerLayout toolbaritemZoomOut] setEnabled:YES];
	
	// Max zoom?
	float maxScale = cCanvasMaximumScale;
	if (m_Scale >= maxScale)
		[[m_ControllerLayout toolbaritemZoomIn] setEnabled:NO];
	else
		[[m_ControllerLayout toolbaritemZoomIn] setEnabled:YES];
	
	// Do the zoom
	[[m_ControllerLayout viewMain] setZoomFactor:m_Scale];
	
	// If one or more component(s) selected, centre on it
	if ([[self arrayComponentsSelected] count] >= 1)
	{
		NSPoint centrePoint;
		if ([[self arrayComponentsSelected] count] == 1)
		{
			PSComponent *component = [[[self arrayComponentsSelected] objectEnumerator] nextObject];
			centrePoint = NSMakePoint([component intX] + ([component intWidth]/2),
									  [component intY] + ([component intHeight]/2));
		}
		else
		{
			NSEnumerator *enumerator = [[self arrayComponentsSelected] objectEnumerator];
			PSComponent *component = nil;
			int x = 0, y = 0;
			while (component = [enumerator nextObject])
			{
				x += [component intX] + ([component intWidth]/2);
				y += [component intY] + ([component intHeight]/2);
			}
			centrePoint = NSMakePoint(x / [[self arrayComponentsSelected] count],
									  y / [[self arrayComponentsSelected] count]);
		}
		[[m_ControllerLayout viewMain] setCentrePoint:centrePoint];
		[[m_ControllerLayout viewMain] centreView];
	}
	
	// Refresh
	[self refreshView];
}

- (int) undoCount
{
	return m_UndoCount;
}

- (void) setSizeAndPosition:(NSRect)sizeAndPosition
{
	m_SizeAndPosition = sizeAndPosition;
}

- (BOOL) isReady
{
	return m_Ready;
}

#pragma mark Handlers for Defaults Change
- (void) handleGridSizeChanged:(NSNotification *)notification
{
	[self refreshView];
}

- (void) handleGridSnapChanged:(NSNotification *)notification
{
	// FIXME: Go align all components
}

- (void) handleArrowheadsDrawnChanged:(NSNotification *)notification
{
	[self refreshView];
}

#pragma mark Components Management
- (void) addComponent:(PSComponentType *)componentType
					x:(int)x
					y:(int)y 
				width:(int)width;
{
	// Make components
	PSComponent *component = [PSComponent new];
	[component setComplete:NO];
	[component setID:[self nextComponentID]];
	[component setLayout:self];
	[component setComponentType:componentType setID:YES];
	[m_Components addObject:component];
	
	// Undo
	[[m_UndoManager prepareWithInvocationTarget:self] removeComponent:component];
	if (![m_UndoManager isUndoing])
	{
		[m_UndoManager setActionName:@"Insert Component"];
		[self makingUndo];
	}
	else 
	{
		[self doingUndo];
	}
		
	// Position and size
	[component setWidth:width];
	[component setX:x andY:y];
	
	// Post-add setup
	[m_ControllerLayout postAddComponent:component];
	
	// Set selected, update inspector and we're done!!
	[self setSelectedComponent:component];
	[[[self project] controllerProject] refreshLayoutTable];
	[self refreshView];
}

- (void) addDeletedComponent:(PSComponent *)component
{
	// Undo
	[[m_UndoManager prepareWithInvocationTarget:self] removeComponent:component];
	if (![m_UndoManager isUndoing])
	{
		[m_UndoManager setActionName:@"Insert Layout"];
		[self makingUndo];	
	}
	else 
	{
		[self doingUndo];
	}
	
	// Re-add & update inspector
	[m_Components addObject:component];
	[m_ComponentsArrayDeleted removeObject:component];
	[[[self project] controllerProject] refreshLayoutTable];
	[self refreshView];
}

- (void) removeComponent:(PSComponent *)component
{
	// Add inverse to undo stack
	[[m_UndoManager prepareWithInvocationTarget:self] addDeletedComponent:component];
	if (![m_UndoManager isUndoing])
	{
		[m_UndoManager setActionName:@"Delete Component"];
		[self makingUndo];
	}
	else 
	{
		[self doingUndo];
	}
	
	// If selected, unselect
	if ([m_ComponentsSelected containsObject:component])
	{
		[m_ComponentsSelected removeObject:component];
	}
	
	// Remove & update inspector
	[m_ComponentsArrayDeleted addObject:component];
	[m_Components removeObject:component];
	[[[self project] controllerProject] refreshLayoutTable];
	[self refreshView];
}

- (void) moveComponent:(PSComponent *)component 
					 x:(int)x 
					 y:(int)y
{
	// Add inverse to undo stack
	[[m_UndoManager prepareWithInvocationTarget:self] moveComponent:component
																  x:[component intX]
																  y:[component intY]];
	if (![m_UndoManager isUndoing])
	{
		[m_UndoManager setActionName:@"Move Component(s)"];
		[self makingUndo];
	}
	else 
	{
		[self doingUndo];
	}
	
	// Move and update
	[component setX:x andY:y];
	[self refreshView];
}

- (PSConnection *) makeConnection:(PSComponentConnection *)source destination:(PSComponentConnection *)destination
{
	// First check for any duplicates
	NSEnumerator *enumerator = [m_Connections objectEnumerator];
	PSConnection *connection = nil;
	while (connection = [enumerator nextObject])
	{
		if ( ([connection connectionSource] == source || [connection connectionDestination] == source) &&
			 ([connection connectionSource] == destination || [connection connectionDestination] == destination))	
		{
			// Duplicate
			return nil;
		}
	}
		
	// Add inverse to undo stack
	[[m_UndoManager prepareWithInvocationTarget:self] removeConnection:source 
														   destination:destination];
	if (![m_UndoManager isUndoing])
	{
		[m_UndoManager setActionName:@"Make connection"];
		[self makingUndo];
	}
	else 
	{
		[self doingUndo];
	}
	
	// Make new connection
	connection = [PSConnection new];
	[connection setSource:source];
	[connection setSourceID:[source id]];
	[connection setDestination:destination];
	[connection setDestinationID:[destination id]];
	[m_Connections addObject:connection];
	
	
	// Is source a master?
	if ([source intConnectionType] == cComponentConnection_AutoType)
		[source setEffectiveType:[destination intAllowedTypes]];
	else if ([destination intConnectionType] == cComponentConnection_AutoType)
		[destination setEffectiveType:[source intOutputType]];

	// Refresh
	[[[self project] controllerProject] refreshLayoutTable];
	[self refreshView];
	return connection;
}

- (void) removeConnection:(PSComponentConnection *)source destination:(PSComponentConnection *)destination
{
	// Add inverse to undo stack
	[[m_UndoManager prepareWithInvocationTarget:self] makeConnection:source 
														 destination:destination];
	if (![m_UndoManager isUndoing])
	{
		[m_UndoManager setActionName:@"Break connection"];
		[self makingUndo];
	}
	else 
	{
		[self doingUndo];
	}
	
	// Enumerate until match
	NSEnumerator *enumerator = [m_Connections objectEnumerator];
	PSConnection *connection = nil;
	while (connection = [enumerator nextObject])
	{
		if ( ([connection connectionSource] == source) &&
			 ([connection connectionDestination] == destination))
		{
			break;
		}
	}
	
	// Delete
	if (connection != nil)
	{
		// Remove
		[m_Connections removeObject:connection];
	}

	// Refresh
	[[[self project] controllerProject] refreshLayoutTable];
	[self refreshView];
}

#pragma mark Methods
- (void) showLayout
{
	// Create window controller
	if (m_ControllerLayout == nil)
	{
		m_ControllerLayout = [PSLayoutWindowController new];
		[m_ControllerLayout setLayout:self];
		[m_ControllerLayout setProject:m_Project];
		[[[NSDocumentController sharedDocumentController] currentDocument] setCurrentLayout:self];
		[[[NSDocumentController sharedDocumentController] currentDocument] addWindowController:m_ControllerLayout];
		[m_ControllerLayout showWindow:self];

		// Setup scale
		[self setScale:m_Scale];
		[[m_ControllerLayout viewMain] verticallyCentreView];
		m_Ready = YES;
		[self refreshView];
	}
	else
	{
		[[[NSDocumentController sharedDocumentController] currentDocument] setCurrentLayout:self];
		[[m_ControllerLayout window] makeKeyAndOrderFront:self];
	}
	[self checkUndo];
}

- (void) refreshView
{
	[m_ControllerLayout updateInspector];
	[m_ControllerLayout refreshView];
}

- (void) clearSelectedComponents
{
	[m_ComponentsSelected removeAllObjects];
}

- (void) clearSelectedConnections
{
	[m_ConnectionsSelected removeAllObjects];
}

- (void) selectAllComponents
{
	[self clearSelectedComponents];
	
	// Loop through all and add
	NSEnumerator *enumeratorComponents = [m_Components objectEnumerator];
	PSComponent *component;
	while (component = [enumeratorComponents nextObject])
	{
		[m_ComponentsSelected addObject:component];
	}
}

- (void) postLoadSetup
{	
	// First, build dictionary
	NSMutableDictionary *connections = [NSMutableDictionary dictionary];
	NSEnumerator *enumeratorComponents = [m_Components objectEnumerator];
	PSComponent *component;
	while (component = [enumeratorComponents nextObject])
	{
		// Setup inputs
		NSEnumerator *enumeratorInput = [[component arrayInputs] objectEnumerator];
		PSComponentConnection *input = nil;
		while (input = [enumeratorInput nextObject])
		{
			[connections setObject:input
							forKey:[NSNumber numberWithLong:[input id]]];
		}		
		
		// Setup outputs
		NSEnumerator *enumeratorOutput = [[component arrayOutputs] objectEnumerator];
		PSComponentConnection *output = nil;
		while (output = [enumeratorOutput nextObject])
		{
			[connections setObject:output
							forKey:[NSNumber numberWithLong:[output id]]];
		}
	}
	
	// Loop through connections
	NSEnumerator *enumerator = [m_Connections objectEnumerator];
	PSConnection *connection;
	while (connection = [enumerator nextObject])
	{
		// Source
		PSComponentConnection *source = [connections objectForKey:
			[NSNumber numberWithLong:[connection longSourceID]]];
		[connection setSource:source];
		
		// Destination
		PSComponentConnection *destination = [connections objectForKey:
			[NSNumber numberWithLong:[connection longDestinationID]]];
		[connection setDestination:destination];
	}
}

- (void) makingUndo
{
	m_UndoCount++;
	[self checkUndo];
	[m_Project checkUndo];
}

- (void) doingUndo
{
	m_UndoCount--;
	[self checkUndo];
	[m_Project checkUndo];
}

- (void) checkUndo
{
	if (m_ControllerLayout != nil)
	{
		if (m_UndoCount == 0)
			[m_ControllerLayout setDocumentEdited:NO];
		else
			[m_ControllerLayout setDocumentEdited:YES];
	}
}

- (void) clearUndoCount
{
	m_UndoCount = 0;
}

@end
