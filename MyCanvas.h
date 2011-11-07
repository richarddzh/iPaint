//
//  MyCanvas.h
//  iPaint
//
//  Created by 董 政 on 11-9-15.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "MyDocument.h"
#import "InspectorDemoView.h"

@interface MyCanvas : NSView {
	MyDocument * document;
	NSBezierPath * figure;
	NSPoint controlPoints[5];
	InspectorDemoView * info;
	float zoom;
	NSAffineTransform * zoomTransformInversed;
	ToolType currentTool;
	IBOutlet NSScrollView * scrollView;
	NSImage * tempLayer;
	int bezierPhase;
	NSBezierPath * clip;
	NSBezierPath * clipDest;	
	BOOL holdingClip; // mouse is holding the clip to move it
	NSImage * pasteboard;
	BOOL isCutting;
	NSTextView * textView;
}

@property (nonatomic,retain) IBOutlet MyDocument * document;
@property (nonatomic,retain) IBOutlet InspectorDemoView * info;
@property (nonatomic,readwrite) ToolType currentTool;

//image size label
@property (nonatomic,readwrite,copy) NSString * sizeLabel;

//zooming
@property (nonatomic,readwrite,copy) NSString * zoomLabel;
@property (nonatomic,readwrite,assign) float zoomSlider;
@property (nonatomic,readwrite) BOOL canZoomOut;
@property (nonatomic,readwrite) BOOL canZoomIn;
//actions
- (IBAction) zoomButtonClicked:(id)sender;

//methods
- (void)repaintImage;
- (void)updateTransform;
- (void)recreateTempLayer;
- (void)doCut;
- (void)doCopy;
- (void)doPaste;
- (void)cancelPaste;
- (void)doResize:(NSSize)newSize;
- (void)setTextView:(NSTextView *)tv;
- (void)hideTextView;
- (void)paintTextView;
- (void)doCrop;
@end

