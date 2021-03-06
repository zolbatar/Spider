//  Spider
//  StaticView.m
//
//  Created by Daryl Dudey on 14/06/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSStaticView

NSString *ComponentPBoardType = @"ComponentPBoardType";

#pragma mark Alloc

- (id)initWithFrame:(NSRect)rect
{
	self = [super initWithFrame:rect];
	m_Name = nil;
	
	// Setup paste board
	[[NSPasteboard pasteboardWithName:NSDragPboard] 
		declareTypes:[NSArray arrayWithObject:ComponentPBoardType] 
			   owner:self];
	
	return self;
}

- (void) dealloc
{
	[m_ComponentType release];
	[super dealloc];
}

#pragma mark Overrides
- (BOOL) isFlipped
{
	return YES;
}

- (BOOL) needsPanelToBecomeKey
{
	return NO;
}

- (BOOL) acceptsFirstMouse:(NSEvent *)theEvent
{
	return YES;
}

- (unsigned int) draggingSourceOperationMaskForLocal:(BOOL)isLocal
{
	if (isLocal)
	{
		return NSDragOperationCopy;
	}
	else
	{
		return NSDragOperationNone;
	}
}

- (void) mouseDragged:(NSEvent *)event
{
	if ([[[NSDocumentController sharedDocumentController] currentDocument] currentLayout] == nil)
	{
		NSLog(@"Layout is nil.");
	}
	
	// Draw component
	NSImage *image = [[NSImage alloc] initWithSize:NSMakeSize([m_ComponentType calculateWidth] + cStaticViewSpacingH*2, 
															 [m_ComponentType calculateHeight] + cStaticViewSpacingV*2)];
	[m_ComponentType drawComponent:nil
							 image:image
								 x:cStaticViewSpacingH
								 y:cStaticViewSpacingV
							 width:[m_ComponentType calculateWidth]
							height:[m_ComponentType calculateHeight] 
						  selected:YES
							  name:m_Name
				 ignoreGridSpacing:YES
							inputs:[m_ComponentType arrayInputs]
						   outputs:[m_ComponentType arrayOutputs]];

	// Drag from centre
	NSPoint p = [self convertPoint:[event locationInWindow] 
						  fromView:nil];
	p.x -= (([m_ComponentType calculateWidth] / 2) + cStaticViewSpacingH);
	p.y += (([m_ComponentType calculateHeight] / 2) + cStaticViewSpacingV);
	
	// Start drag
	[self dragImage:image
				 at:p
			 offset:NSMakeSize(0,0)
			  event:event
		 pasteboard:[NSPasteboard pasteboardWithName:NSDragPboard]
			 source:self
		  slideBack:YES];
	[image release];
}

- (void) drawRect:(NSRect)rect 
{
	// No component type set don't draw
	if (m_ComponentType == nil)
		return;
			
	switch ([m_ComponentType intStyle])
	{
		case cComponentStyle_Literal:
			[m_ComponentType drawComponent:self
									 image:nil
										 x:cStaticViewSpacingH
										 y:cStaticViewSpacingV
									 width:cLiteralQuickbarWidthShort
									height:[m_ComponentType calculateHeight]
								  selected:NO
									  name:nil
						 ignoreGridSpacing:YES
									inputs:[m_ComponentType arrayInputs]
								   outputs:[m_ComponentType arrayOutputs]];
			break;
		default:
			[m_ComponentType drawComponent:self
									 image:nil
										 x:cStaticViewSpacingH
										 y:cStaticViewSpacingV
									 width:[m_ComponentType calculateWidth]
									height:[m_ComponentType calculateHeight]
								  selected:NO
									  name:m_Name
						 ignoreGridSpacing:YES
									inputs:[m_ComponentType arrayInputs]
								   outputs:[m_ComponentType arrayOutputs]];
			break;
	}
}

#pragma mark Accessors
- (PSComponentType *) componentType
{
	return m_ComponentType;
}

- (void) setComponentType:(PSComponentType *)componentType
{
	if (m_ComponentType != componentType)
	{
		[m_ComponentType release];
		m_ComponentType = [componentType retain];
	}
	NSEnumerator *enumeratorOutput;
	PSComponentConnection *output;
	switch ([m_ComponentType intStyle])
	{
		case cComponentStyle_Literal:
			enumeratorOutput = [[m_ComponentType arrayOutputs] objectEnumerator];
			output = [enumeratorOutput nextObject];
			m_Name = [output stringName];
			break;
		default:
			if ([componentType stringShortName] != nil) 
				[self setName:[componentType stringShortName]];
			else
				[self setName:[m_ComponentType stringName]];
			break;
	}
}

- (void) setName:(NSString *)name
{
	if (m_Name != name)
	{
		[m_Name release];
		m_Name = [name copy];
	}
}

@end
