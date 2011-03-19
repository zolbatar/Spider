//  Spider
//  AppController.h
//
//  Created by Daryl Dudey on 02/06/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSAppController : NSObject
{
	NSMutableArray *m_ComponentTypesArray;

#pragma mark Copy & Paste
	NSMutableArray *m_ComponentsCopy;
	NSMutableArray *m_ConnectionsCopy;
	int m_CenterX, m_CenterY;
	
#pragma mark Controllers
	PSPreferenceController *m_ControllerPreference;
	
#pragma mark Attributes & Styles
	NSMutableParagraphStyle *m_LeftParaStyle;
	NSMutableParagraphStyle *m_CentreParaStyle;
	NSMutableParagraphStyle *m_RightParaStyle;
	NSFont *m_HeaderFont;
	NSFont *m_ConnectionFont;
	NSMutableDictionary *m_InputAttributes;
	NSMutableDictionary *m_OutputAttributes;
	NSMutableDictionary *m_HeaderAttributes;
	NSMutableDictionary *m_FormatInAttributes;
	NSMutableDictionary *m_FormatOutAttributes;
	NSMutableDictionary *m_FormatSoleAttributes;
	NSShadow *m_ComponentShadow;
	NSShadow *m_ComponentShadowReversed;
	NSColor *m_ComponentBorderColour;
	NSColor *m_SelectionBoxColour;

#pragma mark Connection Colours
	NSColor *m_ConnectionColourFlow;
	NSColor *m_ConnectionColourBoolean;
	NSColor *m_ConnectionColourByte;
	NSColor *m_ConnectionColourDateTime;
	NSColor *m_ConnectionColourInteger;
	NSColor *m_ConnectionColourReal;
	NSColor *m_ConnectionColourString;

#pragma mark Outlets
	IBOutlet NSPanel *panelPalette;
	
#pragma mark Literals
	IBOutlet PSStaticView *staticviewLiteralBoolean;
	IBOutlet PSStaticView *staticviewLiteralByte;
	IBOutlet PSStaticView *staticviewLiteralDateTime;
	IBOutlet PSStaticView *staticviewLiteralInteger;
	IBOutlet PSStaticView *staticviewLiteralReal;
	IBOutlet PSStaticView *staticviewLiteralString;
	
#pragma mark Program Flow
	IBOutlet PSStaticView *staticviewProgramFlowStart;
	IBOutlet PSStaticView *staticviewProgramFlowStop;
	IBOutlet PSStaticView *staticviewProgramFlowPause;

#pragma mark Conditional
	IBOutlet PSStaticView *staticviewConditionalCompare;
}

#pragma mark Init App Objects
- (void) setupStyles;

#pragma mark Attributes & Styles Accessors
- (NSShadow *) shadowComponent;
- (NSShadow *) shadowComponentReversed;
- (NSMutableDictionary *) dictionaryInputAttributes;
- (NSMutableDictionary *) dictionaryOutputAttributes;
- (NSMutableDictionary *) dictionaryHeaderAttributes;
- (NSMutableDictionary *) dictionaryFormatInAttributes;
- (NSMutableDictionary *) dictionaryFormatOutAttributes;
- (NSMutableDictionary *) dictionaryFormatSoleAttributes;
- (NSColor *) colourComponentBorder;
- (NSColor *) colourSelectionBox;
- (NSMutableParagraphStyle *) paragraphstyleLeft;
- (NSMutableParagraphStyle *) paragraphstyleCentre;
- (NSMutableParagraphStyle *) paragraphstyleRight;
- (NSColor *) colourConnectionFlow;
- (NSColor *) colourConnectionBoolean;
- (NSColor *) colourConnectionByte;
- (NSColor *) colourConnectionDateTime;
- (NSColor *) colourConnectionInteger;
- (NSColor *) colourConnectionReal;
- (NSColor *) colourConnectionString;

#pragma mark Components
- (void) setupComponentsLiteral;
- (void) setupComponentsProgramFlow;
- (void) setupComponentsConditional;

#pragma mark Palette
- (void) setupPaletteLiteral;
- (void) setupPaletteProgramFlow;
- (void) setupPaletteConditional;

#pragma mark Accessors
- (PSPreferenceController *) m_ControllerPreference;
- (void) addComponentType:(PSComponentType *)componentType;
- (NSPanel *) panelPalette;

#pragma mark User Defaults
- (int) userdefault_GridSize;
- (BOOL) userdefault_GridSnap;
- (BOOL) userdefault_ComponentScrollOnSelect;
- (int) userdefault_ComponentDropAlign;
- (BOOL) userdefault_ShowAnimations;
- (BOOL) userdefault_ShowAnimationsFlow;
- (int) userdefault_CopyConnections;

#pragma mark Actions
- (IBAction) actionMenuPreferences:(NSMenuItem *)sender;

#pragma mark Methods
- (PSComponentType *) componentTypeByGroup:(int)group andIndex:(int)index;
- (BOOL) validateMenuItemEdit:(id <NSMenuItem>)menuItem;
- (NSColor *) getNonSelectedColour:(NSColor *)color;

@end
