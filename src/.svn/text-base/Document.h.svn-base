//  Spider
//  Document.h
//
//  Created by Daryl Dudey on 14/05/2007.
//  Copyright Daryl Dudey 2007 . All rights reserved.

#import <Cocoa/Cocoa.h>
#import "Classes.h"

@interface PSDocument : NSDocument
{
	// Data
	BOOL m_IsLoaded;
	PSProject *m_Project;
	PSLayout *m_CurrentLayout;
	
	// Window Controllers
	PSProjectWindowController *m_ControllerProject;
}

#pragma mark Accessors
- (PSProject *) project;
- (PSProjectWindowController *) windowcontrollerProject;
- (BOOL) isLoaded;
- (PSLayout *) currentLayout;
- (void) setCurrentLayout:(PSLayout *)layout;

#pragma mark Methods
+ (void) reviewChangesAndQuitEnumeration:(BOOL)cont;
- (void) askToSave:(SEL)callback;
- (void) didSave:(PSDocument *)doc didSave:(BOOL)didSave contextInfo:(void  *)contextInfo;

@end
