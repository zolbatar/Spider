//  Spider
//  LayoutTableController.h
//
//  Created by Daryl Dudey on 18/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSLayoutTableController : NSObject 
{
#pragma mark Outlets
	IBOutlet PSProjectWindowController *controllerProject;
}

- (int) numberOfRowsInTableView:(NSTableView *)aTableView;
- (id)			tableView:(NSTableView *)aTableView 
objectValueForTableColumn:(NSTableColumn *)aTableColumn 
					  row:(int)rowIndex;
- (void) tableView:(NSTableView *)aTableView 
	setObjectValue:(id)anObject 
	forTableColumn:(NSTableColumn *)aTableColumn 
			   row:(int)rowIndex;

@end
