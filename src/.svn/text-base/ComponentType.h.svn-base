//  Spider
//  ComponentTemplate.h
//
//  Created by Daryl Dudey on 24/05/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

#pragma mark Components (Literal)
enum {
	cComponentLiteral_Boolean,
	cComponentLiteral_Byte,
	cComponentLiteral_DateTime,
	cComponentLiteral_Integer,
	cComponentLiteral_Real,
	cComponentLiteral_String
};
#define cComponentLiteralRed			1.0
#define cComponentLiteralGreen			1.0
#define cComponentLiteralBlue			0.0
#define cComponentLiteralArrayRed		0.0
#define cComponentLiteralArrayGreen		1.0
#define cComponentLiteralArrayBlue		1.0

#pragma mark Components (Program Flow)
enum {
	cComponentProgramFlow_Start,
	cComponentProgramFlow_Stop,
	cComponentProgramFlow_Pause
};
#define cComponentProgramFlowStartRed	0.0
#define cComponentProgramFlowStartGreen	1.0
#define cComponentProgramFlowStartBlue	0.0
#define cComponentProgramFlowStopRed	1.0
#define cComponentProgramFlowStopGreen	0.0
#define cComponentProgramFlowStopBlue	0.0
#define cComponentProgramFlowPauseRed	1.0
#define cComponentProgramFlowPauseGreen	0.5
#define cComponentProgramFlowPauseBlue	0.0

#pragma mark Components (Conditional)
enum {
	cComponentConditional_Compare
};
#define cComponentConditionalCompareRed		0.0
#define cComponentConditionalCompareGreen	0.0
#define cComponentConditionalCompareBlue	1.0

#pragma mark Components (Normal)
#define cComponentNormalRed				0.0
#define cComponentNormalGreen			1.0
#define cComponentNormalBlue			1.0

@interface PSComponentType : NSObject 
{
	// Group and name
	NSString *m_Name;
	NSString *m_ShortName;
	int m_Group, m_Index;
	
	// Appearance
	int m_Style;
	NSColor *m_BackgroundColour, *m_BackgroundColourSelected;
	
	// Connections
	int m_Connections, m_NoInputs, m_NoOutputs;
	NSMutableArray *m_Inputs;
	NSMutableArray *m_Outputs;
	PSComponentConnection *m_ConnectionMaster;
}

#pragma mark Accessors
- (NSString *) stringName;
- (void) setName:(NSString *)name;
- (NSString *) stringShortName;
- (void) setShortName:(NSString *)shortName;
- (int) intGroup;
- (int) intIndex;
- (void) setGroup:(int)group 
		 andIndex:(int)index;
- (void) setColourR:(float)r
			   andG:(float)g 
			   andB:(float)b;
- (void) setConnections:(int)connections;
- (int) intConnections;
- (int) intNoInputs;
- (int) intNoOutputs;
- (NSMutableArray *) arrayInputs;
- (NSMutableArray *) arrayOutputs;
- (int) intStyle;
- (void) setStyle:(int)style;
- (PSComponentConnection *) connectionMaster;

#pragma mark Methods
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
- (void) drawComponentConnection:(float)snappedX 
						snappedY:(float)snappedY 
					  connection:(PSComponentConnection *)connection 
						isOutput:(BOOL)isOutput 
						   index:(int)index 
						   width:(int)width
						   image:(NSImage *)image
						selected:(BOOL)selected;
- (void) drawComponentArc:(NSPoint)centre startAngle:(float)startAngle endAngle:(float)endAngle color:(NSColor *)color;
- (int) calculateHeight;
- (int) calculateWidth;
- (PSComponentConnection *) addInput:(NSString *)name allowedTypes:(int)allowedTypes;
- (PSComponentConnection *) addAutoTypeInput:(NSString *)name 
								allowedTypes:(int)allowedTypes 
								  countTypes:(int)countTypes
							   autoTypeIndex:(int)autoTypeIndex;
- (PSComponentConnection *) addOutput:(NSString *)name outputType:(int)outputType;
- (NSPoint) convertPolarToXY:(float)radius angle:(float)angle;

@end
