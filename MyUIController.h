//
//  MyUIController.h
//  iPaint
//
//  Created by 董 政 on 11-9-18.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyCanvas.h"

@interface MyUIController : NSObject {
	MyCanvas * myCanvas;
	int newWidth;
	int newHeight;
	BOOL retainAspectRatio;
	NSTextView * textView;
	NSDrawer * drawer;
}

@property (nonatomic,retain) IBOutlet MyCanvas * myCanvas;
@property (nonatomic,retain) IBOutlet NSTextView * textView;
@property (nonatomic,readwrite) int newWidth;
@property (nonatomic,readwrite) int newHeight;
@property (nonatomic,readwrite) BOOL retainAspectRatio;
@property (nonatomic,assign) IBOutlet NSDrawer * drawer;

- (IBAction)toolBoxClicked:(id)sender;
- (IBAction)doCopy:(id)sender;
- (IBAction)doCut:(id)sender;
- (IBAction)doPaste:(id)sender;
- (IBAction)doResize:(id)sender;
- (IBAction)doCrop:(id)sender;



@end
