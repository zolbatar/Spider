//  Spider
//  ComponentConnection.m
//
//  Created by Daryl Dudey on 04/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSComponentConnection

#pragma mark Alloc
- (id)init
{
	self = [super init];
	m_ConnectionType = cComponentConnection_Normal;
	return self;
}

- (void)dealloc
{
	[m_Name release];
	[super dealloc];
}

#pragma mark Archiving
- (id) initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		[self setID:[coder decodeInt64ForKey:@"m_ID"]];
		[self setName:[coder decodeObjectForKey:@"m_Name"]];
		[self setEffectiveTypeRaw:[coder decodeInt64ForKey:@"m_EffectiveType"]];
		[self setConnectionType:[coder decodeInt64ForKey:@"m_ConnectionType"]];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt64:m_ID								forKey:@"m_ID"];
	[coder encodeObject:m_Name							forKey:@"m_Name"];
	[coder encodeInt64:m_EffectiveType					forKey:@"m_EffectiveType"];
	[coder encodeInt64:m_ConnectionType					forKey:@"m_ConnectionType"];
	
}

#pragma mark Copying
- (id) copyWithZone:(NSZone *)zone
{
	PSComponentConnection *connection = [PSComponentConnection new];
	[connection setName:m_Name];
	[connection setID:[[[[NSDocumentController sharedDocumentController] currentDocument] currentLayout] nextConnectionID]];
	[connection setConnectionX:m_ConnectionX
				andConnectionY:m_ConnectionY
					  andTextX:m_TextX
					  andTextY:m_TextY];
	[connection setConnectionType:m_ConnectionType];
	[connection setEffectiveTypeRaw:m_EffectiveType];
	
	if (m_IsInput)
	{
		[connection setAllowedTypes:m_Type];
		[connection setMultipleInput:m_MultipleInput];
	}
	else
	{
		[connection setOutputType:m_Type];
	}
	
	return connection;
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

- (void) setName:(NSString *)name
{
	if (m_Name != name)
	{
		[m_Name release];
		m_Name = [name copy];
	}
}

- (int) intAllowedTypes
{
	if (m_EffectiveType != nil)
		return m_EffectiveType;
	return m_Type;
}

- (int) intRealAllowedTypes
{
	return m_Type;
}

- (void) setAllowedTypes:(int) allowedTypes
{
	m_IsInput = YES;
	m_Type = allowedTypes;
}

- (int) intOutputType
{
	return m_Type;
}

- (void) setOutputType:(int) outputType
{
	m_IsInput = NO;
	m_Type = outputType;
}

- (float) floatConnectionX
{
	return m_ConnectionX;
}

- (float) floatConnectionY
{
	return m_ConnectionY;
}

- (float) floatTextX
{
	return m_TextX;
}

- (float) floatTextY
{
	return m_TextY;
}

- (void) setConnectionX:(float)connectionX 
		 andConnectionY:(float)connectionY
			   andTextX:(float)textX
			   andTextY:(float)textY
{
	m_ConnectionX = connectionX;
	m_ConnectionY = connectionY;
	m_TextX = textX;
	m_TextY = textY;
}

- (void) setAbsoluteX:(float)x Y:(float)y
{
	m_AbsConnectionX = x;
	m_AbsConnectionY = y;
	m_AbsTextX = x;
	m_AbsTextY = y;
}

- (float) floatAbsConnectionX
{
	return m_AbsConnectionX;
}

- (float) floatAbsConnectionY
{
	return m_AbsConnectionY;
}

- (PSComponent *) componentOwner
{
	return m_Owner;
}

- (void) setOwner:(PSComponent *)owner
{
	m_Owner = owner;
}

- (BOOL) isInput
{
	return m_IsInput;
}

- (void) setMultipleInput:(int)multipleInput
{
	m_MultipleInput = multipleInput;
}

- (int) intMultipleInput
{
	return m_MultipleInput;
}

- (void) setConnectionType:(int)connectionType
{
	m_ConnectionType = connectionType;
}

- (int) intConnectionType
{
	return m_ConnectionType;
}

- (void) setEffectiveTypeRaw:(int)effectiveType
{
	m_EffectiveType = effectiveType;
}

- (void) setEffectiveType:(int)effectiveType
{
	m_EffectiveType = effectiveType;
	
	// See if there any slave connections we need to enable
	
	// Inputs first
	NSEnumerator *enumeratorInput = [[m_Owner arrayInputs] objectEnumerator];
	PSComponentConnection *connection = nil;
	while (connection = [enumeratorInput nextObject])
	{
		if ( ([connection intConnectionType] == cComponentConnection_AutoType) 
			 || ([connection intConnectionType] == cComponentConnection_TypeSet) ) 
		{
			[connection setConnectionType:cComponentConnection_TypeSet];
			[connection setEffectiveTypeRaw:effectiveType];
		}
	}

	// Outputs next
	NSEnumerator *enumeratorOutput = [[m_Owner arrayOutputs] objectEnumerator];
	connection = nil;
	while (connection = [enumeratorOutput nextObject])
	{
		if ( ([connection intConnectionType] == cComponentConnection_AutoType) 
			 || ([connection intConnectionType] == cComponentConnection_TypeSet) ) 
		{
			[connection setConnectionType:cComponentConnection_TypeSet];
			[connection setEffectiveTypeRaw:effectiveType];
		}
	}
}

- (int) intEffectiveType
{
	return m_EffectiveType;
}

- (void) setAutoTypeIndex:(int)autoTypeIndex
{
	m_AutoTypeIndex = autoTypeIndex;
}

- (int) intAutoTypeIndex
{
	return m_AutoTypeIndex;
}

@end
