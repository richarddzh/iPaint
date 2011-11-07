//
//  MyUIController.m
//  iPaint
//
//  Created by 董 政 on 11-9-18.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import "MyUIController.h"


@implementation MyUIController

@synthesize myCanvas;
@synthesize newWidth;
@synthesize newHeight;
@synthesize retainAspectRatio;

- (id)init {
	self = [super init];
	if (self != nil) {
		myCanvas.currentTool = NullTool;
		retainAspectRatio = YES;
	}
	return self;
}

- (void)dealloc {
	[self setMyCanvas:nil];
	[super dealloc];
}

- (IBAction)toolBoxClicked:(id)sender {
	int selectedSegIndex = [sender selectedSegment];
	myCanvas.currentTool = (ToolType) [[sender cell]tagForSegment:selectedSegIndex];
	if (myCanvas.currentTool == DrawLine || myCanvas.currentTool == PenTool || myCanvas.currentTool == DrawBezier) {
		[myCanvas.info setShouldFill:NO];
		[myCanvas.info setShouldOutline:YES];
	}
	[myCanvas cancelPaste];
	[myCanvas hideTextView];
}

- (IBAction)doCopy:(id)sender {
	[myCanvas doCopy];
}

- (IBAction)doCut:(id)sender {
	[myCanvas doCut];
}

- (IBAction)doPaste:(id)sender {
	[myCanvas doPaste];
}

- (IBAction)doResize:(id)sender {
	if (retainAspectRatio) {
		NSSize size = myCanvas.document.pixelsSize;
		newHeight = newWidth / size.width * size.height;
	}
	[myCanvas doResize:NSMakeSize(newWidth, newHeight)];
}

- (NSTextView *)textView {
	return textView;
}

- (void)setTextView:(NSTextView *)tv {
	if (tv != textView) {
		[tv retain];
		[textView release];
		textView = tv;
		if (tv != nil) {
			[myCanvas setTextView:tv];
		}
	}
}

- (void)doCrop:(id)sender {
	[myCanvas doCrop];
}

- (NSDrawer *)drawer {
	return drawer;
}

- (void)setDrawer:(NSDrawer *)d {
	drawer = d;
	[d open];
}

@end
