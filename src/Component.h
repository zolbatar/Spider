//  Spider
//  Component.h
//
//  Created by Daryl Dudey on 16/05/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSComponent : NSObject <NSCoding, NSCopying>
{
	// Owner
	PSLayout *m_Layout;

	BOOL m_Complete;
	long m_ID;
	PSComponentType *m_ComponentType;
	NSString *m_Name;
	int m_X, m_Y, m_Width, m_Height, m_OrigX, m_OrigY;
	
	// Connections
	NSMutableArray *m_Inputs;
	NSMutableArray *m_Outputs;
	
	// Value
	BOOL m_ValueBoolean;
	unsigned char m_ValueByte;
	NSDate *m_ValueDateTime;
	int m_ValueInteger;
	double m_ValueReal;
	NSString *m_ValueString;
}

#pragma mark Accessors
- (long) id;
- (void) setID:(long)id;
- (NSString *) stringName;
- (void) setName:(NSString *)name simple:(BOOL)simple;
- (int) intX;
- (int) intY;
- (int) intOrigX;
- (int) intOrigY;
- (void) setX:(int)x andY:(int)y;
- (int) intWidth;
- (int) intHeight;
- (void) setWidth:(int)width;
- (PSComponentType *) componentType;
- (void) setComponentTypeRaw:(PSComponentType *)componentType;
- (void) setComponentType:(PSComponentType *)componentType setID:(BOOL)setID;
- (NSMutableArray *) arrayInputs;
- (NSMutableArray *) arrayOutputs;
- (void) setLayout:(PSLayout *)layout;
- (BOOL) isComplete;
- (void) setComplete:(BOOL)complete;

#pragma mark Values
- (BOOL) boolValue;
- (void) setValueBoolean:(BOOL)boolValue simple:(BOOL)simple;
- (unsigned char) byteValue;
- (void) setValueByte:(unsigned char)byteValue simple:(BOOL)simple;
- (NSDate *) datetimeValue;
- (void) setValueDateTime:(NSDate *)datetimeValue simple:(BOOL)simple;
- (int) intValue;
- (void) setValueInteger:(int)intValue simple:(BOOL)simple;
- (double) realValue;
- (void) setValueReal:(double)doubleValue simple:(BOOL)simple;
- (NSString *) stringValue;
- (void) setValueString:(NSString *)stringValue simple:(BOOL)simple;

#pragma mark Methods
- (void) drawComponent:(NSView *)view selected:(BOOL)selected;
- (void) savePosition;
- (void) setConnectionPositions;

@end
