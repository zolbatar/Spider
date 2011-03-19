//  Spider
//  View.h
//
//  Created by Daryl Dudey on 15/05/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSView : NSView
{
	id delegate;
	NSPoint m_CentrePoint;
	
	// Click events
	int m_State;
	NSPoint m_DownPoint, m_CurrentPoint;
	int m_MoveXLeft, m_MoveYLeft;
	PSComponentConnection *m_Connection;
	PSConnection *m_ConnectionLine;
	
	// Scrolling
	NSScrollView *m_ViewMainScroll;
	NSPoint m_GrabOrigin, m_ScrollOrigin;
	NSTimer *m_ScrollTimer;
	NSTimer *m_RedrawTimer;
	
	// Redraw timer
	float m_RedrawPhase;
	float m_RedrawPhaseReversed;
}

#pragma mark Handlers for Defaults Change
- (void) handleShowAnimationsChanged:(NSNotification *)notification;

#pragma mark Accessors
- (void) setViewMainScroll:(NSScrollView *)viewMainScroll;
- (void) setCentrePoint:(NSPoint)centrePoint;
- (NSScrollView *) viewMainScroll;
- (float) floatRedrawPhase;
- (float) floatRedrawPhaseReversed;

#pragma mark Methods
- (void) centreView;
- (void) verticallyCentreView;
- (void) scrollTo:(NSPoint)topLeft;

@end

@interface NSObject (PSViewDelegateMethods)
- (BOOL) clickLeft:(NSPoint)point;
- (void) dragLeftWithX:(int)deltaX andY:(int)deltaY;
@end

