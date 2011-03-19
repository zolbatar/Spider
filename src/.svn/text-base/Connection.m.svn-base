//  Spider
//  Connection.m
//
//  Created by Daryl Dudey on 20/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSConnection

#pragma mark Alloc
- (id)init
{
	self = [super init];
	return self;
}

- (void)dealloc
{
	[super dealloc];
}

#pragma mark Archiving
- (id) initWithCoder:(NSCoder *)coder
{
	if (self = [super init])
	{
		m_SourceID = [coder decodeInt64ForKey:@"m_SourceID"];
		m_DestinationID = [coder decodeInt64ForKey:@"m_DestinationID"];
	}
	return self;
}

- (void) encodeWithCoder:(NSCoder *)coder
{
	[coder encodeInt64:m_SourceID						forKey:@"m_SourceID"];
	[coder encodeInt64:m_DestinationID					forKey:@"m_DestinationID"];
}

#pragma mark Copying
- (id) copyWithZone:(NSZone *)zone
{
	PSConnection *connection = [PSConnection new];
	[connection setSourceID:m_SourceID]; 
	[connection setSource:m_Source];
	[connection setDestinationID:m_DestinationID]; 
	[connection setDestination:m_Destination];
	
	return connection;
}

#pragma mark Accessors
- (long) longSourceID
{
	return m_SourceID;
}

- (PSComponentConnection *)connectionSource
{
	return m_Source;
}

- (void) setSource:(PSComponentConnection *)connectionSource
{
	m_Source = connectionSource;
}

- (void) setSourceID:(long)id
{
	m_SourceID = id;
}

- (long) longDestinationID
{
	return m_DestinationID;
}

- (PSComponentConnection *)connectionDestination
{
	return m_Destination;
}

- (void) setDestination:(PSComponentConnection *)connectionDestination
{
	m_Destination = connectionDestination;
}

- (void) setDestinationID:(long)id
{
	m_DestinationID = id;
}

@end
