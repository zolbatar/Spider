//  Spider
//  ComponentConnection.h
//
//  Created by Daryl Dudey on 04/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

enum {
	cComponentConnection_Normal,
	cComponentConnection_AutoType,
	cComponentConnection_TypeSet
};

@interface PSComponentConnection : NSObject <NSCoding, NSCopying> 
{
	long m_ID;

	// Defaults (for PSComponentType)
	BOOL m_IsInput;
	NSString *m_Name;
	int m_Type, m_EffectiveType;
	int m_MultipleInput;
	int m_ConnectionType;
	int m_AutoTypeIndex;

	// Owning component
	PSComponent *m_Owner;
	
	// Relative connection positions
	float m_ConnectionX, m_ConnectionY;
	float m_TextX, m_TextY;

	// Absolute connection positions
	float m_AbsConnectionX, m_AbsConnectionY;
	float m_AbsTextX, m_AbsTextY;
}

#pragma mark Accessors
- (long) id;
- (void) setID:(long)id;
- (NSString *) stringName;
- (void) setName:(NSString *)name;
- (int) intAllowedTypes;
- (int) intRealAllowedTypes;
- (void) setAllowedTypes:(int)allowedTypes;
- (int) intOutputType;
- (void) setOutputType:(int) outputType;
- (float) floatConnectionX;
- (float) floatConnectionY;
- (float) floatTextX;
- (float) floatTextY;
- (void) setConnectionX:(float)connectionX 
		 andConnectionY:(float)connectionY
			   andTextX:(float)textX
			   andTextY:(float)textY;
- (void) setAbsoluteX:(float)x Y:(float)y;
- (float) floatAbsConnectionX;
- (float) floatAbsConnectionY;
- (PSComponent *) componentOwner;
- (void) setOwner:(PSComponent *)owner;
- (BOOL) isInput;
- (void) setMultipleInput:(int)multipleInput;
- (int) intMultipleInput;
- (void) setConnectionType:(int)connectionType;
- (int) intConnectionType;
- (void) setEffectiveTypeRaw:(int)effectiveType;
- (void) setEffectiveType:(int)effectiveType;
- (int) intEffectiveType;
- (void) setAutoTypeIndex:(int)autoTypeIndex;
- (int) intAutoTypeIndex;

@end
