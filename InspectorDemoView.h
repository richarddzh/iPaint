//
//  InspectorDemoView.h
//  iPaint
//
//  Created by 董 政 on 11-9-19.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import <Cocoa/Cocoa.h>

typedef enum {
	NullTool = 0,
	DrawLine,
	DrawRect,
	DrawOval,
	DrawBezier,
	PenTool = 5,
	BrushTool,
	EraserTool,
	BucketTool,
	TextTool,
	SelToolRect = 10,
	SelToolAny,
} ToolType;

typedef enum {
	LSSolid = 0,
	LSDotted = 1,
	LSDashed = 2,
	LSDotDashed = 3,
	LSLongDashed = 4
} LineStyle;

@interface InspectorDemoView : NSView {
	NSColor * outLineColor;
	NSColor * fillColor;
	NSColor * canvasColor;
	NSBezierPath * path;
	BOOL shouldFill;
	BOOL shouldOutline;
	BOOL shouldAntiAlias;
	LineStyle lineStyle;
	int dashPatternLength;
	NSCompositingOperation compositing;
	int opacity;
	NSImage * brush;
	int brushSize;
	int brushStyle;
}

@property (nonatomic,retain) NSColor * outLineColor;
@property (nonatomic,retain) NSColor * fillColor;
@property (nonatomic,retain) NSColor * canvasColor;
@property (nonatomic,readwrite) float lineWidth;
@property (nonatomic,readwrite) BOOL shouldFill;
@property (nonatomic,readwrite) BOOL shouldOutline;
@property (nonatomic,readwrite) BOOL shouldAntiAlias;
@property (nonatomic,readwrite) LineStyle lineStyle;
@property (nonatomic,readwrite) NSCompositingOperation compositing;
@property (nonatomic,readwrite) int opacity;
@property (nonatomic,readwrite) int brushSize;

- (void)rebuildPath;
- (IBAction)changeOutLineColor:(id)sender;
- (IBAction)changeFillColor:(id)sender;
- (IBAction)changeCanvasColor:(id)sender;
- (IBAction)changeLineStyle:(id)sender;
- (IBAction)changeCompositing:(id)sender;
- (IBAction)changeBrushStyle:(id)sender;

- (void)paintFigure:(NSBezierPath *)fig 
			onImage:(NSImage *)image
	  withTransform:(NSAffineTransform *)trans;

- (void)paintBrushOnImage:(NSImage *)image atPoint:(NSPoint)point;
- (void)recreateBrush;
- (void)recreateBrushAsEraser;
- (void)recreateBrushWithColor:(NSColor *)color;


@end
