//
//  InspectorDemoView.m
//  iPaint
//
//  Created by 董 政 on 11-9-19.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import "InspectorDemoView.h"

CGFloat dashPattern[] = {
	0,0,0,0,0,
	2,1,1,0,0,
	2,3,1,0,0,
	4,3,1,1,1,
	2,6,2,0,0,
};

NSString * brushNames[] = {
	@"brushrect",
	@"brushoval",
	@"brushgauss",
	@"brushbar1",
	@"brushbar2",
};

@implementation InspectorDemoView

@synthesize outLineColor;
@synthesize fillColor;
@synthesize canvasColor;
@synthesize lineStyle;
@synthesize compositing;
@synthesize brushSize;

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
		[self setCanvasColor:[NSColor whiteColor]];
		[self setFillColor:[NSColor	blueColor]];
		[self setOutLineColor:[NSColor blackColor]];
		[self setOpacity:100];
		[self setCompositing:NSCompositeSourceOver];
		[self setShouldAntiAlias:YES];
		[self setLineWidth:1.0];
		[self setLineStyle:LSSolid];
		[self setShouldFill:YES];
		[self setShouldOutline:YES];
		[self setBrushSize:1];
		path = [[NSBezierPath bezierPath]retain];
		brush = nil;
		brushStyle = 0;
		[self rebuildPath];
    }
    return self;
}

- (void)dealloc {
	[path release];
	[self setOutLineColor:nil];
	[self setFillColor:nil];
	[self setCanvasColor:nil];
	[super dealloc];
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	NSGraphicsContext * gc = [NSGraphicsContext currentContext];
	[gc saveGraphicsState];
	NSRect fullRect;
	fullRect.origin = NSZeroPoint;
	fullRect.size = self.frame.size;
	[canvasColor setFill];
	NSRectFill(fullRect);
	[self paintFigure:path
			  onImage:nil
		withTransform:nil];
	[gc restoreGraphicsState];
}

- (void)viewDidEndLiveResize {
	[self rebuildPath];
	[self setNeedsDisplay:YES];
	[super viewDidEndLiveResize];
}

- (void)rebuildPath {
	NSSize size = self.frame.size;
	NSRect rect;
	rect.origin.x = size.width * 0.35;
	rect.origin.y = size.height * 0.15;
	rect.size.width = size.width * 0.5;
	rect.size.height = size.height * 0.5;
	[path removeAllPoints];
	[path appendBezierPathWithRect:rect];
	rect.origin.x = size.width * 0.15;
	rect.origin.y = size.height * 0.35;
	[path appendBezierPathWithOvalInRect:rect];
}

- (IBAction)changeOutLineColor:(id)sender {
	NSColorWell * well = (NSColorWell *)sender;
	[self setOutLineColor:[[well color]colorWithAlphaComponent:opacity/100.0]];
	[self setNeedsDisplay:YES];
	NSLog(@"Color: R%f G%f B%f A%f",
		  [outLineColor redComponent],
		  [outLineColor greenComponent],
		  [outLineColor blueComponent],
		  [outLineColor alphaComponent]);
}

- (IBAction)changeFillColor:(id)sender {
	NSColorWell * well = (NSColorWell *)sender;
	[self setFillColor:[[well color]colorWithAlphaComponent:opacity/100.0]];
	[self setNeedsDisplay:YES];
}

- (IBAction)changeCanvasColor:(id)sender {
	NSColorWell * well = (NSColorWell *)sender;
	[self setCanvasColor:[well color]];
	[self setNeedsDisplay:YES];
}

- (float)lineWidth {
	return [path lineWidth];
}

- (void)setLineWidth:(float)f {
	if (f != [path lineWidth]) {
		[path setLineWidth:f];
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)shouldFill {
	return shouldFill;
}

- (void)setShouldFill:(BOOL)b {
	if (b != shouldFill) {
		shouldFill = b;
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)shouldOutline {
	return shouldOutline;
}

- (void)setShouldOutline:(BOOL)b {
	if (b != shouldOutline) {
		shouldOutline = b;
		[self setNeedsDisplay:YES];
	}
}

- (BOOL)shouldAntiAlias {
	return shouldAntiAlias;
}

- (void)setShouldAntiAlias:(BOOL)b {
	if (b != shouldAntiAlias) {
		shouldAntiAlias = b;
		[self setNeedsDisplay:YES];
	}
}

- (IBAction)changeLineStyle:(id)sender {
	LineStyle ls = (LineStyle)[[sender selectedItem]tag];
	if (ls != lineStyle) {
		lineStyle = ls;
		[self setNeedsDisplay:YES];
	}
}

- (int)opacity {
	return opacity;
}

- (void)setOpacity:(int)f {
	if (f != opacity) {
		opacity = f;
		NSColor * fc = [[fillColor colorWithAlphaComponent:f/100.0]retain];
		NSColor * oc = [[outLineColor colorWithAlphaComponent:f/100.0]retain];
		[self setFillColor:fc];
		[self setOutLineColor:oc];
		[fc release];
		[oc release];
		[self setNeedsDisplay:YES];
	}
}

- (IBAction)changeCompositing:(id)sender {
	NSCompositingOperation op = (NSCompositingOperation)[[sender selectedItem]tag];
	if (op != compositing) {
		compositing = op;
		[self setNeedsDisplay:YES];
	}
}

- (IBAction)changeBrushStyle:(id)sender {
	int selectedSegIndex = [sender selectedSegment];
	brushStyle = [[sender cell]tagForSegment:selectedSegIndex];
}

- (void)paintFigure:(NSBezierPath *)fig 
			onImage:(NSImage *)image
	  withTransform:(NSAffineTransform *)trans {
	if ([fig elementCount] > 0) {
		[fig setLineWidth:self.lineWidth];
		CGFloat pattern[4];
		for (int i = 0; i < 4; i++) 
			pattern[i] = dashPattern[lineStyle*5+i+1]*(self.lineWidth);
		[fig setLineDash:pattern count:(int)dashPattern[lineStyle*5] phase:0.0];
		if (trans != nil) {
			fig = [fig copy];
			[fig transformUsingAffineTransform:trans];
			NSSize size = NSZeroSize;
			size.width = self.lineWidth;
			size = [trans transformSize:size];
			[fig setLineWidth:size.width];
		}
		[image lockFocus];
		NSGraphicsContext * gc = [NSGraphicsContext currentContext];
		[gc saveGraphicsState];
		[gc setCompositingOperation:compositing];
		[gc setShouldAntialias:shouldAntiAlias];
		if (shouldFill) {
			[fillColor setFill];
			[fig fill];
		}
		if (shouldOutline) {
			[outLineColor setStroke];
			[fig stroke];
		}
		[gc restoreGraphicsState];
		[image unlockFocus];
		if (trans != nil) {
			[fig release];
		}
	}
}

- (void)recreateBrushWithColor:(NSColor *)color {
	if (brush != nil) [brush release];
	NSRect rect;
	rect.origin = NSZeroPoint;
	rect.size.width = rect.size.height = brushSize;
	NSString * brushFileName = [[NSBundle mainBundle]pathForResource:brushNames[brushStyle]
															  ofType:@"png"];
	NSImage * brushImage = [[NSImage alloc]initWithContentsOfFile:brushFileName];
	brush = [[NSImage alloc]initWithSize:rect.size];
	[brush lockFocus];
	[color set];
	NSRectFill(rect);
	[brushImage drawInRect:rect 
				  fromRect:NSZeroRect 
				 operation:NSCompositeDestinationIn
				  fraction:1.0];
	[brushImage release];
	[brush unlockFocus];
}

- (void)recreateBrush {
	[self recreateBrushWithColor:fillColor];
}

- (void)recreateBrushAsEraser {
	[self recreateBrushWithColor:canvasColor];
}

- (void)paintBrushOnImage:(NSImage *)image atPoint:(NSPoint)point {
	NSRect rect;
	rect.origin.x = point.x - brushSize / 2;
	rect.origin.y = point.y - brushSize / 2;
	rect.size.width = brushSize;
	rect.size.height = brushSize;
	[image lockFocus];
	[brush drawInRect:rect fromRect:NSZeroRect operation:NSCompositeSourceOver fraction:1.0];
	[image unlockFocus];
}


@end
