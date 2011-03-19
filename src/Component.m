//  Spider
//  Component.m
//
//  Created by Daryl Dudey on 16/05/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSComponent

#pragma mark Alloc
- (id)init
{
	self = [super init];
	m_Inputs = [NSMutableArray new];
	m_Outputs = [NSMutableArray new];
	[m_Inputs retain];
	[m_Outputs retain];
	return self;
}

- (void) dealloc
{
	[m_Outputs release];
	[m_Inputs release];
	[m_Name release];
	[super dealloc];
}

#pragma mark Archiving
- (id) initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		// Component type
		int group = [coder decodeInt64ForKey:@"intGroup"]; 
		int index = [coder decodeInt64ForKey:@"intIndex"];
		m_ComponentType = [[NSApp delegate] componentTypeByGroup:group andIndex:index];

		// Connections
		m_Inputs = [coder decodeObjectForKey:@"m_Inputs"];
		m_Outputs = [coder decodeObjectForKey:@"m_Outputs"];
		[m_Inputs retain];
		[m_Outputs retain];
		
		// Setup inputs
		NSEnumerator *enumeratorInputNew = [m_Inputs objectEnumerator];
		PSComponentConnection *inputNew = nil;
		NSEnumerator *enumeratorInput = [[m_ComponentType arrayInputs] objectEnumerator];
		PSComponentConnection *input = nil;
		while (inputNew = [enumeratorInputNew nextObject])
		{
			input = [enumeratorInput nextObject];
			[inputNew setConnectionX:[input floatConnectionX]
					  andConnectionY:[input floatConnectionY]
							andTextX:[input floatTextX]
							andTextY:[input floatTextY]];
			[inputNew setAllowedTypes:[input intAllowedTypes]];
			[inputNew setMultipleInput:[input intMultipleInput]];
			[inputNew setConnectionType:[input intConnectionType]];
			[inputNew setOwner:self];
		}		
		
		// Setup outputs
		NSEnumerator *enumeratorOutputNew = [m_Outputs objectEnumerator];
		PSComponentConnection *outputNew = nil;
		NSEnumerator *enumeratorOutput = [[m_ComponentType arrayOutputs] objectEnumerator];
		PSComponentConnection *output = nil;
		while (outputNew = [enumeratorOutputNew nextObject])
		{
			output = [enumeratorOutput nextObject];
			[outputNew setConnectionX:[output floatConnectionX]
					   andConnectionY:[output floatConnectionY]
							 andTextX:[output floatTextX]
							 andTextY:[output floatTextY]];
			[outputNew setOutputType:[output intOutputType]];
			[outputNew setConnectionType:[output intConnectionType]];
			[outputNew setOwner:self];
		}
	
		// Variables
		[self setID:[coder decodeInt64ForKey:@"m_ID"]];
		[self setName:[coder decodeObjectForKey:@"m_Name"] simple:YES];
		[self setWidth:[coder decodeInt64ForKey:@"m_Width"]];
		[self setX:[coder decodeInt64ForKey:@"m_X"] 
			  andY:[coder decodeInt64ForKey:@"m_Y"]];
		[self setComplete:YES];

		// Values
		if ([m_ComponentType intGroup] == cComponentGroup_Literal)
		{
			switch ([m_ComponentType intIndex])
			{
				case cComponentLiteral_Boolean:
					[self setValueBoolean:[coder decodeBoolForKey:@"m_ValueBoolean"] simple:NO];
					break;
				case cComponentLiteral_Byte:
					[self setValueByte:[coder decodeInt64ForKey:@"m_ValueByte"] simple:NO];
					break;
				case cComponentLiteral_DateTime:
					[self setValueDateTime:[coder decodeObjectForKey:@"m_ValueDateTime"] simple:NO];
					break;
				case cComponentLiteral_Integer:
					[self setValueInteger:[coder decodeInt64ForKey:@"m_ValueInteger"] simple:NO];
					break;
				case cComponentLiteral_Real:
					[self setValueReal:[coder decodeDoubleForKey:@"m_ValueReal"] simple:NO];
					break;
				case cComponentLiteral_String:
					[self setValueString:[coder decodeObjectForKey:@"m_ValueString"] simple:NO];
					break;
			}
		}
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	// Component type
	[coder encodeInt64:[m_ComponentType intGroup]		forKey:@"intGroup"];
	[coder encodeInt64:[m_ComponentType intIndex]		forKey:@"intIndex"];
	
	// Connections
	[coder encodeObject:m_Inputs						forKey:@"m_Inputs"];
	[coder encodeObject:m_Outputs						forKey:@"m_Outputs"];
	
	// Variables
	[coder encodeInt64:m_ID								forKey:@"m_ID"];
	[coder encodeObject:m_Name							forKey:@"m_Name"];
	[coder encodeInt64:m_X								forKey:@"m_X"];
	[coder encodeInt64:m_Y								forKey:@"m_Y"];
	[coder encodeInt64:m_Width							forKey:@"m_Width"];
	[coder encodeInt64:m_Height							forKey:@"m_Height"];

	// Values
	if ([m_ComponentType intGroup] == cComponentGroup_Literal)
	{
		switch ([m_ComponentType intIndex])
		{
			case cComponentLiteral_Boolean:
				[coder encodeBool:m_ValueBoolean			forKey:@"m_ValueBoolean"];
				break;
			case cComponentLiteral_Byte:
				[coder encodeInt64:m_ValueByte				forKey:@"m_ValueByte"];
				break;
			case cComponentLiteral_DateTime:
				[coder encodeObject:m_ValueDateTime			forKey:@"m_ValueDateTime"];
				break;
			case cComponentLiteral_Integer:
				[coder encodeInt64:m_ValueInteger			forKey:@"m_ValueInteger"];
				break;
			case cComponentLiteral_Real:
				[coder encodeDouble:m_ValueReal				forKey:@"m_ValueReal"];
				break;
			case cComponentLiteral_String:
				[coder encodeObject:m_ValueString			forKey:@"m_ValueString"];
				break;
		}
	}
}

#pragma mark Copying
- (id) copyWithZone:(NSZone *)zone
{
	PSComponent *component = [PSComponent new];
	[component setComponentTypeRaw:m_ComponentType];
	[component setID:m_ID];
	[component setName:m_Name simple:YES];
	[component setX:m_X andY:m_Y];
	[component setWidth:m_Width];
	[component setComplete:m_Complete];
	
	// Set values
	[component setValueBoolean:m_ValueBoolean simple:YES];
	[component setValueByte:m_ValueByte simple:YES];
	[component setValueDateTime:m_ValueDateTime simple:YES];
	[component setValueInteger:m_ValueInteger simple:YES];
	[component setValueReal:m_ValueReal simple:YES];
	[component setValueString:m_ValueString simple:YES];
	
	// Copy inputs
	NSEnumerator *enumeratorInput = [m_Inputs objectEnumerator];
	PSComponentConnection *input = nil;
	while (input = [enumeratorInput nextObject])
	{
		PSComponentConnection *inputNew = [input copy];
		[[component arrayInputs] addObject:inputNew];
	}
	
	// Copy outputs
	NSEnumerator *enumeratorOutput = [m_Outputs objectEnumerator];
	PSComponentConnection *output = nil;
	while (output = [enumeratorOutput nextObject])
	{
		PSComponentConnection *outputNew = [output copy];
		[[component arrayOutputs] addObject:outputNew];
	}
	
	return component;
}

#pragma mark Accessors
- (long) id
{
	return m_ID;
}

- (void) setID:(long)id
{
	m_ID = id;
}

- (NSString *) stringName
{
	return m_Name;
}

- (void) setName:(NSString *)name simple:(BOOL)simple
{
	if (name != m_Name)
	{
		[m_Name release];
		m_Name = [name copy];
		if (simple) return;

		// Name and width (if to be set)
		int oldWidth = m_Width;
		switch ([m_ComponentType intStyle])
		{
			case cComponentStyle_Literal:
				[self setWidth:[name sizeWithAttributes:[[NSApp delegate] dictionaryFormatSoleAttributes]].width 
					+ (cBodyBorder * 2)];
				break;
			default:
				break;	
		}
				
		// Figure out positioning
		int dropAlign = [[NSApp delegate] userdefault_ComponentDropAlign];
		switch ([m_ComponentType intStyle])
		{
			case cComponentStyle_Literal:	

				// Set width
				if ([[NSApp delegate] userdefault_GridSnap])
				{
					int gridSpacing = [[NSApp delegate] userdefault_GridSize];
					m_Width = (m_Width + gridSpacing) / gridSpacing * gridSpacing;
				}
			
				switch (dropAlign)
				{
					case cPreferencesComponentDropCentre:
						[self setX:m_X - ((m_Width - oldWidth)/2) andY:m_Y];
						break;
					case cPreferencesComponentDropRight:
						[self setX:m_X - (m_Width - oldWidth) andY:m_Y];
						break;
					default:
						[self setConnectionPositions];
						break;
				}
				break;
		}
	}
}

- (int) intX
{
	return m_X;
}

- (int) intY
{
	return m_Y;
}

- (int) intOrigX
{
	return m_OrigX;
}

- (int) intOrigY
{
	return m_OrigY;
}

- (void) setX:(int)x andY:(int)y;
{
	// Work out padding
	int padding = cComponentSpacingLR;
	if ([[NSApp delegate] userdefault_GridSnap])
	{
		if (padding < [[NSApp delegate] userdefault_GridSize])
			padding = [[NSApp delegate] userdefault_GridSize];
	}

	// Position and size
	int snappedX = x;
	int snappedY = y;
	if ([[NSApp delegate] userdefault_GridSnap])
	{	
		int gridSpacing = [[NSApp delegate] userdefault_GridSize];
		snappedX = (snappedX + gridSpacing/2) / gridSpacing * gridSpacing;
		snappedY = (snappedY + gridSpacing/2) / gridSpacing * gridSpacing;
	}
	
	int maxX = cCanvasDefaultWidth - m_Width - padding;	
	if (snappedX < padding)
		snappedX = padding;
	if (snappedX > maxX)
		snappedX = maxX;
	m_X = snappedX;

	int maxY = cCanvasDefaultHeight - m_Width - padding;	
	if (snappedY < padding)
		snappedY = padding;
	if (snappedY > maxY)
		snappedY = maxY;
	m_Y = snappedY;
	
	// Set connections
	[self setConnectionPositions];
}

- (int) intWidth
{
	return m_Width;
}

- (void) setWidth:(int)width
{
	m_Width = width;
	m_Height = [m_ComponentType calculateHeight];
}

- (int) intHeight
{
	return m_Height;
}

- (PSComponentType *) componentType
{
	return m_ComponentType;
}

- (void) setComponentTypeRaw:(PSComponentType *)componentType
{
	m_ComponentType = componentType;
}

- (void) setComponentType:(PSComponentType *)componentType setID:(BOOL)setID
{
	// Is setID ever NO?
	if (setID == NO)
		NSLog(@"SetID=NO!");
	
	m_ComponentType = componentType;

	// Name and width
	switch ([m_ComponentType intStyle])
	{
		case cComponentStyle_Literal:
			break;
		default:
			[self setName:[m_ComponentType stringName] simple:NO]; 
			[self setWidth:cDefaultWidth];
			break;
	}
	
	// Move inputs
	NSEnumerator *enumeratorInput = [[componentType arrayInputs] objectEnumerator];
	PSComponentConnection *input = nil;
	while (input = [enumeratorInput nextObject])
	{
		// New connection
		PSComponentConnection *inputNew = [input copy];

		// Add
		if (setID)
			[inputNew setID:[m_Layout nextConnectionID]];
		[inputNew setOwner:self];
		[m_Inputs addObject:inputNew];
	}
	
	// Move outputs
	NSEnumerator *enumeratorOutput = [[componentType arrayOutputs] objectEnumerator];
	PSComponentConnection *output = nil;
	while (output = [enumeratorOutput nextObject])
	{
		// New connection
		PSComponentConnection *outputNew = [output copy];
		
		// Add
		if (setID)
			[outputNew setID:[m_Layout nextConnectionID]];
		[outputNew setOwner:self];
		[m_Outputs addObject:outputNew];
	}
}

- (NSMutableArray *) arrayInputs
{
	return m_Inputs;
}

- (NSMutableArray *) arrayOutputs
{
	return m_Outputs;
}

- (void) setLayout:(PSLayout *)layout
{
	m_Layout = layout;
}

- (BOOL) isComplete
{
	return m_Complete;
}

- (void) setComplete:(BOOL)complete
{
	m_Complete = complete;
}

#pragma mark Literals
- (BOOL) boolValue
{
	return m_ValueBoolean;
}

- (void) setValueBoolean:(BOOL)boolValue simple:(BOOL)simple
{
	m_ValueBoolean = boolValue;
	if (simple) return;
	
	if (m_ValueBoolean)
	{
		[self setName:@"True" simple:NO];
	}
	else
	{
		[self setName:@"False" simple:NO];
	}
}

- (unsigned char) byteValue
{
	return m_ValueByte;
}

- (void) setValueByte:(unsigned char)byteValue simple:(BOOL)simple
{
	m_ValueByte = byteValue;
	if (simple) return;

	[self setName:[NSString stringWithFormat:@"%d", m_ValueByte] simple:NO];
}

- (NSDate *) datetimeValue
{
	return m_ValueDateTime;
}
	
- (void) setValueDateTime:(NSDate *)datetimeValue simple:(BOOL)simple
{
	if (m_ValueDateTime != datetimeValue)
	{
		[m_ValueDateTime release];
		m_ValueDateTime = [datetimeValue copy];
	}
	if (simple) return;

	// Format date for display
	NSDateFormatter *dateFormatter = [[[NSDateFormatter alloc] initWithDateFormat:@"%Y-%m-%d %H:%M:%S"
															 allowNaturalLanguage:NO] autorelease];	
	[self setName:[dateFormatter stringFromDate:m_ValueDateTime] simple:NO];
}

- (int) intValue
{
	return m_ValueInteger;
}

- (void) setValueInteger:(int)intValue simple:(BOOL)simple
{
	m_ValueInteger = intValue;
	if (simple) return;

	[self setName:[NSString stringWithFormat:@"%d", m_ValueInteger] simple:NO];
}

- (double) realValue
{
	return m_ValueReal;
}

- (void) setValueReal:(double)doubleValue simple:(BOOL)simple
{
	m_ValueReal = doubleValue;
	if (simple) return;

	// Set string value
	[self setName:[NSString stringWithFormat:@"%g", m_ValueReal] simple:NO];
}

- (NSString *) stringValue
{
	return m_ValueString;
}

- (void) setValueString:(NSString *)stringValue simple:(BOOL)simple
{
	if (m_ValueString != stringValue)
	{
		[m_ValueString release];
		m_ValueString = [stringValue copy];
	}
	if (simple) return;

	if ([m_ValueString length] == 0)
	{
		[self setName:@"<Empty>" simple:NO];
	}
	else
	{
		[self setName:[NSString stringWithFormat:@"%@",m_ValueString] simple:NO];
	}
}

#pragma mark Methods
- (void) drawComponent:(NSView *)view selected:(BOOL)selected
{
	// Do we need to calculate height?
	if (m_Height == 0)
		m_Height = [m_ComponentType calculateHeight];
			
	// Draw component
	[m_ComponentType drawComponent:view
							 image:nil
								 x:m_X
								 y:m_Y
							 width:m_Width
							height:m_Height
						  selected:selected
							  name:m_Name
				 ignoreGridSpacing:NO
							inputs:m_Inputs
						   outputs:m_Outputs];
}

- (void) savePosition
{
	m_OrigX = m_X;
	m_OrigY = m_Y;
}

- (void) setConnectionPositions
{
	// move inputs
	NSEnumerator *enumeratorInput = [m_Inputs objectEnumerator];
	PSComponentConnection *input = nil;
	while (input = [enumeratorInput nextObject])
	{
		[input setAbsoluteX:m_X + [input floatConnectionX]
						  Y:m_Y + [input floatConnectionY]];
	}		
	
	// Move outputs
	NSEnumerator *enumeratorOutput = [m_Outputs objectEnumerator];
	PSComponentConnection *output = nil;
	while (output = [enumeratorOutput nextObject])
	{
		[output setAbsoluteX:m_X + [output floatConnectionX] + m_Width
						   Y:m_Y + [output floatConnectionY]];
	}
}

@end
