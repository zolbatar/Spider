//  Spider
//  ComponentTemplate.m
//
//  Created by Daryl Dudey on 24/05/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSComponentType

#pragma mark Alloc
- (id)init
{
	self = [super init];
	m_Inputs = [NSMutableArray new];
	m_Outputs = [NSMutableArray new];
	m_ConnectionMaster = nil;
	return self;
}

- (void)dealloc
{
	[m_BackgroundColourSelected release];
	[m_BackgroundColour release];
	[m_Outputs release];
	[m_Inputs release];
	[m_Name release];
	[super dealloc];
}

#pragma mark Accessors
- (NSString *) stringName
{
	return m_Name;
}

- (void) setName:(NSString *)name;
{
	if (m_Name != name)
	{
		[m_Name release];
		m_Name = [name copy];
	}
}

- (NSString *) stringShortName
{
	return m_ShortName;
}

- (void) setShortName:(NSString *)shortName
{
	if (m_ShortName != shortName)
	{
		[m_ShortName release];
		m_ShortName = [shortName copy];
	}}

- (int) intGroup
{
	return m_Group;
}

- (int) intIndex
{
	return m_Index;
}

- (void) setGroup:(int)group
		 andIndex:(int)index;
{
	m_Group = group;
	m_Index = index;
}

- (void)setColourR:(float)r
			  andG:(float)g 
			  andB:(float)b
{
	// Background colour
	m_BackgroundColour = [NSColor colorWithDeviceRed:r									  
											   green:g
												blue:b
											   alpha:0.5];
	[m_BackgroundColour retain];
	m_BackgroundColourSelected = [NSColor colorWithDeviceRed:r									  
													   green:g
														blue:b
													   alpha:1.0];
	[m_BackgroundColourSelected retain];
}	

- (void) setConnections:(int)connections 
{
	m_Connections = connections;
	m_NoInputs = 0;
	m_NoOutputs = 0;
}

- (int) intConnections
{
	return m_Connections;
}

- (int) intNoInputs
{
	return m_NoInputs;
}

- (int) intNoOutputs
{
	return m_NoOutputs;
}

- (NSMutableArray *) arrayInputs
{
	return m_Inputs;
}

- (NSMutableArray *) arrayOutputs
{
	return m_Outputs;
}

- (int) intStyle
{
	return m_Style;
}

- (void) setStyle:(int)style
{
	m_Style = style;
}

- (PSComponentConnection *) connectionMaster
{
	return m_ConnectionMaster;
}

#pragma mark Methods
//cComponentShape_Data
- (void) drawComponent:(NSView *)view 
				 image:(NSImage *)image
					 x:(int)x 
					 y:(int)y
				 width:(int)width
				height:(int)height
			  selected:(BOOL)selected
				  name:(NSString *)name
	 ignoreGridSpacing:(BOOL)ignoreGridSpacing
				inputs:(NSMutableArray *)inputs
			   outputs:(NSMutableArray *)outputs;
{
	// Get grid, then snap position to grid
	int gridSpacing = 0, tempSnappedX = x, tempSnappedY = y;
	if (ignoreGridSpacing == NO)
	{
		if ([[NSApp delegate] userdefault_GridSnap])
		{
			gridSpacing = [[NSApp delegate] userdefault_GridSize];
			
			tempSnappedX = (tempSnappedX + gridSpacing/2) / gridSpacing * gridSpacing;
			tempSnappedY = (tempSnappedY + gridSpacing/2) / gridSpacing * gridSpacing;
		}
	}	
	float snappedX = tempSnappedX, snappedY = tempSnappedY;

	// Save graphics context
	if (view != nil) 
	{
		[view lockFocus];
		[[[NSApp delegate] shadowComponent] set];
	}
	if (image != nil) 
	{
		[image lockFocus];
		if (m_Style != cComponentStyle_Literal)
		{
			[image setFlipped:YES];
			[[[NSApp delegate] shadowComponentReversed] set];
		}
		else 
		{
			[[[NSApp delegate] shadowComponent] set];
		}
	}

	// Draw outline
	NSBezierPath *thePath = [NSBezierPath bezierPath];
	[thePath setLineWidth:cBorderWidth];
	if (selected)
	{
		PSLayout *layout = [[[NSDocumentController sharedDocumentController] currentDocument] currentLayout];
		float lineDash[2];
		lineDash[0] = 7.0; 
		lineDash[1] = 3.0;
		[thePath setLineDash:lineDash count:2 phase:[[[layout controllerLayout] viewMain] floatRedrawPhase]];			

		[[[NSApp delegate] colourComponentBorder] set];
		[m_BackgroundColourSelected setFill];
	}
	else
	{
		[[[NSApp delegate] getNonSelectedColour:[[NSApp delegate] colourComponentBorder]] set];
		[m_BackgroundColour setFill];
	}
	
	// What shape?
	switch (m_Style)
	{
		case cComponentStyle_Literal:
			[thePath moveToPoint:NSMakePoint(snappedX, snappedY + cSmallCornerRadius)];
			[thePath appendBezierPathWithArcFromPoint:NSMakePoint(snappedX, snappedY) 
											  toPoint:NSMakePoint(snappedX + cSmallCornerRadius, snappedY) 
											   radius:cSmallCornerRadius];
			[thePath lineToPoint:NSMakePoint(snappedX + width - cSmallCornerRadius, snappedY)];
			[thePath appendBezierPathWithArcFromPoint:NSMakePoint(snappedX + width, snappedY) 
											  toPoint:NSMakePoint(snappedX + width, snappedY + cSmallCornerRadius) 
											   radius:cSmallCornerRadius];
			[thePath lineToPoint:NSMakePoint(snappedX + width, snappedY + height - cSmallCornerRadius)];
			[thePath appendBezierPathWithArcFromPoint:NSMakePoint(snappedX + width, snappedY + height) 
											  toPoint:NSMakePoint(snappedX + width - cSmallCornerRadius, snappedY + height) 
											   radius:cSmallCornerRadius];
			[thePath lineToPoint:NSMakePoint(snappedX + cSmallCornerRadius, snappedY + height)];
			[thePath appendBezierPathWithArcFromPoint:NSMakePoint(snappedX, snappedY + height) 
											  toPoint:NSMakePoint(snappedX, snappedY + height - cSmallCornerRadius) 
											   radius:cSmallCornerRadius];
			[thePath closePath];
			[thePath fill];
			[thePath stroke];
			break;
		case cComponentStyle_ProgramFlow:
			[thePath appendBezierPathWithArcWithCenter:NSMakePoint(snappedX + cProgramFlowRadius, snappedY + cProgramFlowRadius)
												radius:cProgramFlowRadius
											startAngle:0
											  endAngle:360];
			[thePath fill];
			[thePath stroke];
			break;
		default:
			[thePath moveToPoint:NSMakePoint(snappedX, cTitleHeight + snappedY)];
			[thePath lineToPoint:NSMakePoint(snappedX, snappedY + cCornerRadius)];
			[thePath appendBezierPathWithArcFromPoint:NSMakePoint(snappedX, snappedY) 
											  toPoint:NSMakePoint(snappedX + cCornerRadius, snappedY) 
											   radius:cCornerRadius];
			[thePath lineToPoint:NSMakePoint(snappedX + width - (2 * cCornerRadius), snappedY)];
			[thePath appendBezierPathWithArcFromPoint:NSMakePoint(snappedX + width, snappedY) 
											  toPoint:NSMakePoint(snappedX + width, snappedY + cCornerRadius) 
											   radius:cCornerRadius];
			[thePath lineToPoint:NSMakePoint(snappedX + width, snappedY + height)];
			[thePath lineToPoint:NSMakePoint(snappedX, snappedY + height)];
			[thePath closePath];
			[thePath moveToPoint:NSMakePoint(snappedX, snappedY + cTitleHeight)];
			[thePath lineToPoint:NSMakePoint(snappedX + width, snappedY + cTitleHeight)];
			[thePath fill];
			[thePath stroke];
			break;
	}

	// Title
	if (image != nil && m_Style != cComponentStyle_Literal)
	{
		[NSGraphicsContext saveGraphicsState];
		NSAffineTransform *flipTransform = [NSAffineTransform transform];;
		switch (m_Style)
		{
			case cComponentStyle_ProgramFlow:
				[flipTransform translateXBy:0.0 yBy:19 + snappedY];
				break;
			default:
				[flipTransform translateXBy:0.0 yBy:23 + snappedY];
				break;
		}
		[flipTransform scaleXBy:1.0 yBy:-1.0];
		[flipTransform concat];
	}
	float yTitle;
	switch (m_Style)
	{	
		case cComponentStyle_Literal:
			[name drawInRect:NSMakeRect(snappedX + cBodyBorder,
										snappedY + cConnectionInitialSpace,
										width - (2 * cBodyBorder),
										cConnectionHeight)
			  withAttributes: [[NSApp delegate] dictionaryFormatSoleAttributes]];
			break;
		case cComponentStyle_ProgramFlow:
			if (image == nil)
				yTitle = snappedY + cProgramFlowRadius - 7;
			else
				yTitle = -snappedY - cProgramFlowRadius + 1;
			[name drawInRect:NSMakeRect(snappedX, 
										yTitle, 
										cProgramFlowRadius * 2 ,
										cProgramFlowRadius * 2)
			  withAttributes: [[NSApp delegate] dictionaryHeaderAttributes]];
			break;
		default:
			[name drawInRect:NSMakeRect(snappedX + cBodyBorder, 
										snappedY + cBodyBorder, 
										width - (2 * cBodyBorder),
										cTitleHeight - (2 * cBodyBorder))
			  withAttributes: [[NSApp delegate] dictionaryHeaderAttributes]];
			break;
	}
	if (image != nil && m_Style != cComponentStyle_Literal)
		[NSGraphicsContext restoreGraphicsState];

	// Draw inputs
	NSEnumerator *enumeratorInput = [inputs objectEnumerator];
	PSComponentConnection *input = nil;
	int i = 0;
	while (input = [enumeratorInput nextObject])
	{
		[self drawComponentConnection:snappedX snappedY:snappedY connection:input 
							 isOutput:NO index:i width:width image:image selected:selected];
		i++;
	}
	
	// Draw outputs
	NSEnumerator *enumeratorOutput = [outputs objectEnumerator];
	PSComponentConnection *output = nil;
	i = 0;
	while (output = [enumeratorOutput nextObject])
	{
		[self drawComponentConnection:snappedX+width snappedY:snappedY connection:output 
							 isOutput:YES index:i width:width image:image selected:selected];
		i++;
	}
	
	// Restore graphics context
	if (view != nil) [view unlockFocus];
	if (image != nil) [image unlockFocus];
}

- (void) drawComponentConnection:(float)snappedX 
						snappedY:(float)snappedY 
					  connection:(PSComponentConnection *)connection 
						isOutput:(BOOL)isOutput 
						   index:(int)index 
						   width:(int)width
						   image:(NSImage *)image
						selected:(BOOL)selected
{
	// Setup inverted (for drags)
	[[[NSApp delegate] colourComponentBorder] set];
	if (image != nil)
	{
		[NSGraphicsContext saveGraphicsState];
		NSAffineTransform *flipTransform = [NSAffineTransform transform];
		float posY = 23 + cTitleHeight + snappedY + [connection floatTextY] + (index * cConnectionHeight);
		[flipTransform translateXBy:0.0 yBy:posY];
		[flipTransform scaleXBy:1.0 yBy:-1.0];
		[flipTransform concat];
	}
	if (m_Style != cComponentStyle_Literal)
	{
		if (isOutput == NO)
		{
			[[connection stringName] drawInRect:NSMakeRect(snappedX + [connection floatTextX],
														   snappedY + [connection floatTextY],
														   width - (cBodyBorder * 2),
														   cConnectionHeight) 
								 withAttributes: [[NSApp delegate] dictionaryInputAttributes]];
		}
		else
		{
			[[connection stringName] drawInRect:NSMakeRect(snappedX + [connection floatTextX] - width,
														   snappedY + [connection floatTextY],
														   width - (cBodyBorder * 2),
														   cConnectionHeight) 
								 withAttributes: [[NSApp delegate] dictionaryOutputAttributes] ];
		}
	}
	if (image != nil)
		[NSGraphicsContext restoreGraphicsState];
	
	// Colour
	if (selected)
		[[[NSApp delegate] colourComponentBorder] set];
	else
		[[[NSApp delegate] getNonSelectedColour:[[NSApp delegate] colourComponentBorder]] set];
	
	// Draw connecter line
	NSBezierPath *linePath = [NSBezierPath bezierPath];
	[linePath setLineWidth:cBorderWidth];
	[linePath moveToPoint:NSMakePoint(snappedX, 
									  snappedY + [connection floatConnectionY] + cConnectionSize/2)];
	[linePath relativeLineToPoint:NSMakePoint([connection floatConnectionX], 0)];
	[linePath stroke];
	
	// Master?
	if ([connection intMultipleInput] > 1 && [connection intConnectionType] == cComponentConnection_AutoType)
	{
		float angle = 360 / [connection intMultipleInput];
		float currentAngle = 0;
		NSPoint centre = NSMakePoint(snappedX + [connection floatConnectionX] - cConnectionSize/2,
									 snappedY + [connection floatConnectionY] + cConnectionSize/2);
		
		// Byte
		if ( ([connection intRealAllowedTypes] & cAllowedByte) == cAllowedByte)
		{
			[self drawComponentArc:centre startAngle:currentAngle endAngle:currentAngle+angle 
							 color:[[NSApp delegate] colourConnectionByte]];
			currentAngle += angle;
		}
		
		// DateTime
		if ( ([connection intRealAllowedTypes] & cAllowedDateTime) == cAllowedDateTime)
		{
			[self drawComponentArc:centre startAngle:currentAngle endAngle:currentAngle+angle 
							 color:[[NSApp delegate] colourConnectionDateTime]];
			currentAngle += angle;
		}
		
		// Integer
		if ( ([connection intRealAllowedTypes] & cAllowedInteger) == cAllowedInteger)
		{
			[self drawComponentArc:centre startAngle:currentAngle endAngle:currentAngle+angle 
							 color:[[NSApp delegate] colourConnectionInteger]];
			currentAngle += angle;
		}
		
		// Real
		if ( ([connection intRealAllowedTypes] & cAllowedReal) == cAllowedReal)
		{
			[self drawComponentArc:centre startAngle:currentAngle endAngle:currentAngle+angle 
							 color:[[NSApp delegate] colourConnectionReal]];
			currentAngle += angle;
		}
		
		// String
		if ( ([connection intRealAllowedTypes] & cAllowedString) == cAllowedString)
		{
			[self drawComponentArc:centre startAngle:currentAngle endAngle:currentAngle+angle 
							 color:[[NSApp delegate] colourConnectionString]];
			currentAngle += angle;
		}
		
		// Oval 
		NSBezierPath *connectorshapePath = [NSBezierPath bezierPath];
		[connectorshapePath setLineWidth:cBorderWidth];
		
		// Draw border
		[connectorshapePath appendBezierPathWithOvalInRect:NSMakeRect(snappedX + [connection floatConnectionX],
																	  snappedY + [connection floatConnectionY],
																	  (isOutput == NO) ? -cConnectionSize : cConnectionSize,
																	  cConnectionSize)];
		[connectorshapePath stroke];
	}
	else
	{
		// Connecter 
		NSBezierPath *connectorshapePath = [NSBezierPath bezierPath];
		[connectorshapePath setLineWidth:cBorderWidth];
		[connectorshapePath setLineJoinStyle:NSRoundLineJoinStyle];
		
		// Choose colour
		switch ([connection intAllowedTypes])
		{
			case cAllowedFlow:
				[[[NSApp delegate] colourConnectionFlow] setFill];
				break;
			case cAllowedBoolean:
				[[[NSApp delegate] colourConnectionBoolean] setFill];
				break;
			case cAllowedByte:
				[[[NSApp delegate] colourConnectionByte] setFill];
				break;
			case cAllowedDateTime:
				[[[NSApp delegate] colourConnectionDateTime] setFill];
				break;
			case cAllowedInteger:
				[[[NSApp delegate] colourConnectionInteger] setFill];
				break;
			case cAllowedReal:
				[[[NSApp delegate] colourConnectionReal] setFill];
				break;
			case cAllowedString:
				[[[NSApp delegate] colourConnectionString] setFill];
				break;
		}
		
		// Draw connection point
		switch ([connection intConnectionType])
		{
			case cComponentConnection_Normal:
				[connectorshapePath moveToPoint:NSMakePoint(snappedX + [connection floatConnectionX], 
															snappedY + [connection floatConnectionY])];
				[connectorshapePath relativeLineToPoint:NSMakePoint((isOutput == NO) ? -cConnectionSize : cConnectionSize, 0)];
				[connectorshapePath relativeLineToPoint:NSMakePoint(0, cConnectionSize)];
				[connectorshapePath relativeLineToPoint:NSMakePoint((isOutput == NO) ? cConnectionSize : -cConnectionSize, 0)];
				[connectorshapePath closePath];
				break;
			case cComponentConnection_AutoType:
			case cComponentConnection_TypeSet:
				[connectorshapePath appendBezierPathWithOvalInRect:NSMakeRect(snappedX + [connection floatConnectionX],
																			  snappedY + [connection floatConnectionY],
																			  (isOutput == NO) ? -cConnectionSize : cConnectionSize,
																			  cConnectionSize)];
				break;
		}
		if ([connection intAllowedTypes] != nil)
			[connectorshapePath fill];
		[connectorshapePath stroke];
	}
}

- (void) drawComponentArc:(NSPoint)centre startAngle:(float)startAngle endAngle:(float)endAngle color:(NSColor *)color
{
//	PSLayout *layout = [[[NSDocumentController sharedDocumentController] currentDocument] currentLayout];
	NSBezierPath *arc = [NSBezierPath bezierPath];
	[arc setLineWidth:0];
	[color setFill];
	[arc moveToPoint:centre];
	[arc appendBezierPathWithArcWithCenter:centre
									radius:cConnectionSize/2
//									startAngle:startAngle + ([[[layout controllerLayout] viewMain] floatRedrawPhase] * 12)
//									endAngle:endAngle + ([[[layout controllerLayout] viewMain] floatRedrawPhase] * 12)];
									startAngle:startAngle
									endAngle:endAngle];
	[arc lineToPoint:centre];
	[arc fill];
}

- (int) calculateHeight
{
	int height = 0;
	switch (m_Style)
	{
		case cComponentStyle_Literal:
			height = cTitleHeight;
			break;
		case cComponentStyle_ProgramFlow:
			height = cProgramFlowRadius * 2;
			break;
		default:
			height = cTitleHeight + cConnectionInitialSpace + (m_Connections * cConnectionHeight);
			break;
	}
	return height;
}

- (int) calculateWidth
{
	PSComponentConnection *output = nil;
	int width;
	switch (m_Style)
	{
		case cComponentStyle_Literal:
			output = [[m_Outputs objectEnumerator] nextObject];
			width = [[output stringName] sizeWithAttributes:[[NSApp delegate] dictionaryOutputAttributes]].width;
			width += (cBodyBorder * 2) + 1;
			break;
		case cComponentStyle_ProgramFlow:
			width = cProgramFlowRadius * 2;
			break;
		case cComponentStyle_Conditional:
			width = cConditionalWidth;
			break;
		default:
			width = cDefaultWidth;
			break;	
	}
	return width;
}

- (PSComponentConnection *) addInput:(NSString *)name allowedTypes:(int)allowedTypes
{
	PSComponentConnection *input = [PSComponentConnection new];
	[input setName:name];
	[input setAllowedTypes:allowedTypes];
	
	// Connection point offset
	int offset = 0, connectionOffset = 0;
	switch (m_Style)
	{
		case cComponentStyle_Literal:
			offset = cConnectionInitialSpace;
			connectionOffset = 2;
			break;
		case cComponentStyle_ProgramFlow:
			offset = cProgramFlowRadius;
			connectionOffset = -4;
			break;
		default:
			offset = cTitleHeight + cConnectionInitialSpace;
			connectionOffset = 3;
			break;
			
	}
	
	// Set position of input connection and label
	[input setConnectionX:-cConnectionStalkSize
		   andConnectionY:offset + (cConnectionHeight * m_NoInputs) + connectionOffset
				 andTextX:cBodyBorder
				 andTextY:offset + (cConnectionHeight * m_NoInputs)];
	
	// And add
	[m_Inputs addObject:input];
	m_NoInputs++;

	return input;
}

- (PSComponentConnection *) addAutoTypeInput:(NSString *)name 
								allowedTypes:(int)allowedTypes 
								  countTypes:(int)countTypes
							   autoTypeIndex:(int)autoTypeIndex
{
	PSComponentConnection *input = [self addInput:name allowedTypes:allowedTypes];
	[input setMultipleInput:countTypes];
	m_ConnectionMaster = input;
	[input setConnectionType:cComponentConnection_AutoType];
	[input setAutoTypeIndex:autoTypeIndex];
	
	return input;
}

- (PSComponentConnection *) addOutput:(NSString *)name outputType:(int)outputType
{
	PSComponentConnection *output = [PSComponentConnection new];
	[output setName:name];
	[output setOutputType:outputType];
	
	// Connection point offset
	int offset = 0, connectionOffset = 0;
	switch (m_Style)
	{
		case cComponentStyle_Literal:
			offset = cConnectionInitialSpace;
			connectionOffset = 2;
			break;
		case cComponentStyle_ProgramFlow:
			offset = cProgramFlowRadius;
			connectionOffset = -4;
			break;
		default:
			offset = cTitleHeight + cConnectionInitialSpace;
			connectionOffset = 3;
			break;
	}
	
	// Set position of input connection and label
	[output setConnectionX:cConnectionStalkSize
			andConnectionY:offset + (cConnectionHeight * m_NoOutputs) + connectionOffset
				  andTextX:cBodyBorder
				  andTextY:offset + (cConnectionHeight * m_NoOutputs)];
	
	// And add
	[m_Outputs addObject:output];
	m_NoOutputs++;
	
	return output;
}

- (NSPoint) convertPolarToXY:(float)radius angle:(float)angle
{
	NSPoint point = NSMakePoint(radius * cos(pi / 180.0 * angle), 
								radius * sin(pi / 180.0 * angle));
	return point;
}

@end
