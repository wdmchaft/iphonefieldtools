// Copyright 2009 Brad Sokol
// 
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// 
// http://www.apache.org/licenses/LICENSE-2.0
// 
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//
//  CameraViewController.m
//  FieldTools
//
//  Created by Brad on 2009/04/14.
//  Copyright 2009 Brad Sokol. All rights reserved.
//

#import "CameraViewController.h"

#import "Camera.h"
#import "CameraViewTableDataSource.h"
#import "CoC.h"

#import "Notifications.h"
#import "UserDefaults.h"

@interface CameraViewController ()

- (void)cancelWasSelected;
- (void)cocChanged:(NSNotification*)notification;
- (void)enableSaveButtonForCamera:(Camera*)camera;
- (void)enableSaveButtonForNameLength:(int)nameLength coc:(float)coc;
- (void)saveWasSelected;

@property(nonatomic, retain) Camera* camera;
@property(nonatomic, retain) Camera* cameraWorking;
@property(nonatomic, retain) UIBarButtonItem* saveButton;

@end

@implementation CameraViewController

@synthesize camera;
@synthesize cameraWorking;
@synthesize saveButton;
@synthesize tableViewDataSource;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
{
	return [self initWithNibName:nibNameOrNil
						  bundle:nibBundleOrNil
					   forCamera:nil];
}

// The designated initializer.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil forCamera:(Camera*)aCamera
{
	self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (nil == self) 
    {
		return nil;
    }
	
	[self setCamera:aCamera];
	
	[self setCameraWorking:[[[Camera alloc] 
								initWithDescription:[[self camera] description]
								coc:[[self camera] coc]
								identifier:[[self camera] identifier]] autorelease]];
	
	UIBarButtonItem* cancelButton = 
		[[[UIBarButtonItem alloc] 
		  initWithBarButtonSystemItem:UIBarButtonSystemItemCancel									 
							   target:self
							   action:@selector(cancelWasSelected)] autorelease];
	[self setSaveButton: 
		[[[UIBarButtonItem alloc] 
		 initWithBarButtonSystemItem:UIBarButtonSystemItemSave	 
							  target:self
							  action:@selector(saveWasSelected)] autorelease]];
	[[self saveButton] setEnabled:NO];
	
	[[self navigationItem] setLeftBarButtonItem:cancelButton];
	[[self navigationItem] setRightBarButtonItem:[self saveButton]];
	[self enableSaveButtonForCamera:[self camera]];
	
	[self setTitle:NSLocalizedString(@"CAMERA_VIEW_TITLE", "Camera view")];

	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(cocChanged:)
												 name:COC_CHANGED_NOTIFICATION
											   object:nil];
    
	return self;
}

- (void)cancelWasSelected
{
	[[self navigationController] popViewControllerAnimated:YES];
}

- (void)saveWasSelected
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SAVING_NOTIFICATION
														object:self];
	
	[[self camera] setDescription:[[self cameraWorking] description]];
	[[self camera] setCoc:[[self cameraWorking] coc]];
	
	[[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:CAMERA_WAS_EDITED_NOTIFICATION
																						 object:[self camera]]];
	
	[[self navigationController] popViewControllerAnimated:YES];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	[[self view] setBackgroundColor:[UIColor viewFlipsideBackgroundColor]];

	[self setTableViewDataSource: [[self tableView] dataSource]];
	[[self tableViewDataSource] setCamera:[self cameraWorking]];
	[[self tableViewDataSource] setController:self];
}

- (void)didReceiveMemoryWarning 
{
    [super didReceiveMemoryWarning];
}

- (void)enableSaveButtonForCamera:(Camera*)aCamera
{
	[self enableSaveButtonForNameLength:[[aCamera description] length] coc:[[aCamera coc] value]];
}

- (void)enableSaveButtonForNameLength:(int)nameLength coc:(float)coc
{
	[[self saveButton] setEnabled:nameLength > 0 && coc > 0.0];
}

#pragma mark UITextFieldDelegate methods

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range 
													   replacementString:(NSString *)string
{
	// Enable the save button if text was entered
	int currentLength = [[textField text] length];
	int newLength = currentLength + [string length] - range.length;
	[self enableSaveButtonForNameLength:newLength coc:[[[self cameraWorking] coc] value]];

	return YES;
}
	 
- (void)textFieldDidEndEditing:(UITextField *)textField
{
	[[self cameraWorking] setDescription:[textField text]];
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView*)tableView didSelectRowAtIndexPath:(NSIndexPath*)indexPath
{
	[tableView deselectRowAtIndexPath:indexPath
							 animated:YES];
	
	[[NSNotificationCenter defaultCenter] 
	 postNotification:
	 [NSNotification notificationWithName:COC_SELECTED_FOR_EDIT_NOTIFICATION 
								   object:[self cameraWorking]]];
}

- (void)cocChanged:(NSNotification*)notification
{
	UITableView* tableView = (UITableView*) [self view];
	[tableView reloadData];
}

- (void)dealloc 
{
	[self setSaveButton:nil];
	[self setCamera:nil];
	[self setCameraWorking:nil];
	
    [super dealloc];
}

@end
