//  Spider
//  Connection.h
//
//  Created by Daryl Dudey on 20/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSConnection : NSObject  <NSCoding, NSCopying> 
{
	// Source
	long m_SourceID;
	PSComponentConnection *m_Source;

	// Destination
	long m_DestinationID;
	PSComponentConnection *m_Destination;
}

#pragma mark Accessors
- (long) longSourceID;
- (PSComponentConnection *)connectionSource;
- (void) setSource:(PSComponentConnection *)connectionSource;
- (void) setSourceID:(long)id;
- (long) longDestinationID;
- (PSComponentConnection *)connectionDestination;
- (void) setDestination:(PSComponentConnection *)connectionDestination;
- (void) setDestinationID:(long)id;

@end
