//  Spider
//  LayoutTableController.m
//
//  Created by Daryl Dudey on 18/07/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import "Headers.h"

@implementation PSLayoutTableController

- (int) numberOfRowsInTableView:(NSTableView *)aTableView 
{
	// If no controller yet created, bail.
	if (controllerProject == nil)
	{
		return 0;
	}

	// Get array of layouts
	NSMutableArray *layouts = [[controllerProject project] arrayLayouts];

	// If rows are zero, disable delete
	if ([layouts count] == 0)
		[[controllerProject buttonDeleteLayout] setEnabled:NO];
	
	// Return array count
	return [layouts count];
}

- (id)				tableView:(NSTableView *)aTableView 
	objectValueForTableColumn:(NSTableColumn *)aTableColumn 
						  row:(int)rowIndex
{
	// Get array of layouts
	NSMutableArray *layouts = [[controllerProject project] arrayLayouts];

	// Jump to entry requested
	PSLayout *layout = [layouts objectAtIndex:rowIndex];
	
	// What do we want?
	NSString *identifier = [aTableColumn identifier];
	if ([identifier compare:@"Name"] == NSOrderedSame)
	{
		return [layout stringName];
	}
	else if ([identifier compare:@"Size"] == NSOrderedSame)
	{
		return [NSString stringWithFormat:@"%d/%d/0", [[layout arrayComponents] count], 
													  [[layout arrayConnections] count]];
	}
	return @"Error";
}

- (void) tableView:(NSTableView *)aTableView 
	setObjectValue:(id)anObject 
	forTableColumn:(NSTableColumn *)aTableColumn 
			   row:(int)rowIndex
{
	// Get array of layouts
	NSMutableArray *layouts = [[controllerProject project] arrayLayouts];
	
	// Jump to entry requested
	PSLayout *layout = [layouts objectAtIndex:rowIndex];
	
	// Allow renaming of layouts
	NSString *identifier = [aTableColumn identifier];
	if ([identifier compare:@"Name"] == NSOrderedSame)
	{
		if ([[layout stringName] compare:@"Main"] != NSOrderedSame)
		{
			[layout setName:anObject];
		}
		else
		{
			// Can't rename main
			NSBeginAlertSheet(@"Rename Layout", 
							  @"OK", 
							  nil, 
							  nil, 
							  [controllerProject window], 
							  self, 
							  nil,
							  NULL,
							  NULL,
							  @"Note: The 'Main' layout can't be renamed.",
							  nil);
		}
		[controllerProject refreshLayoutTable];
	}
}

@end
