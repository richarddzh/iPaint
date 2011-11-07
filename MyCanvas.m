//
//  MyCanvas.m
//  iPaint
//
//  Created by 董 政 on 11-9-15.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import "MyCanvas.h"
#import "MyDocument.h"

#define max(a,b) ((a)>(b)?(a):(b))
#define min(a,b) ((a)<(b)?(a):(b))
#define sign(a) ((a)>=0?((a)>0?1:0):(-1))

@implementation MyCanvas

#pragma mark -
#pragma mark Initialization and dealloc

CGFloat pattern[] = {2.0,2.0,3.0,3.0};

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
		zoom = 1.0;
		zoomTransformInversed = [[NSAffineTransform transform]retain];
		figure = [[NSBezierPath bezierPath]retain];
		tempLayer = [[NSImage alloc]initWithSize:NSZeroSize];
		bezierPhase = 0;
		clip = [[NSBezierPath bezierPath]retain];
		[clip setLineDash:pattern count:4 phase:0];
		clipDest = nil;
		holdingClip = NO;
		pasteboard = nil;
		isCutting = NO;
    }
    return self;
}

- (void)dealloc {
	[pasteboard release];
	[clipDest release];
	[clip release];
	[figure release];
	[tempLayer release];
	[zoomTransformInversed release];
	[self setZoomLabel:nil];
	[self setDocument:nil];
	[self setInfo:nil];
	[super dealloc];
}

#pragma mark -
#pragma mark Repainting

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
	NSGraphicsContext * gc = [NSGraphicsContext currentContext];
	[gc saveGraphicsState];
	NSImage * img = self.document.myImage;
	NSRect destRect = [scrollView documentVisibleRect];
	NSRect srcRect;
	srcRect.origin = [zoomTransformInversed transformPoint:destRect.origin];
	srcRect.size = [zoomTransformInversed transformSize:destRect.size];
	[img drawInRect:destRect
		   fromRect:srcRect
		  operation:NSCompositeCopy
		   fraction:1.0];
	[tempLayer drawInRect:destRect
				 fromRect:srcRect
				operation:NSCompositeSourceOver
				 fraction:1.0];
	if (currentTool == SelToolAny || currentTool == SelToolRect) {
		//outline the selection
		NSBezierPath * clip2 = clipDest!=nil ? [clipDest copy] : [clip copy];
		NSBezierPath * srcClip = [clip copy];
		NSAffineTransform * trans = [[NSAffineTransform transform]retain];
		[trans scaleBy:zoom];
		[clip2 transformUsingAffineTransform:trans];
		[srcClip transformUsingAffineTransform:trans];
		[[NSColor blackColor]set];
		[clip2 setLineWidth:3.0];
		[clip2 stroke];
		[[NSColor whiteColor]set];
		[clip2 setLineWidth:1.0];
		[clip2 stroke];
		[trans release];
		if (isCutting) {
			[self.info.canvasColor setFill];
			[srcClip fill];
		}
		[srcClip release];
		if (clipDest != nil) {
			destRect = [clip2 bounds];
			[clip2 addClip];
			[pasteboard drawInRect:destRect
						  fromRect:NSZeroRect
						 operation:self.info.compositing
						  fraction:self.info.opacity/100.0];
		}
		[clip2 release];
	}
	if (currentTool == TextTool) {
		NSRect rect = [textView frame];
		[[NSColor blackColor]set];
		NSFrameRectWithWidth(rect, 3.0);
		[[NSColor whiteColor]set];
		NSFrameRectWithWidth(rect, 1.0);
	}
	[gc restoreGraphicsState];
}

- (void)repaintImage {
	NSRect frame = [self frame];
	frame.size = self.document.pixelsSize;
	frame.size.width *= zoom;
	frame.size.height *= zoom;
	[self setFrame:frame];
	[self updateTransform];
	[self setNeedsDisplay:YES];
}

#pragma mark -
#pragma mark Properties

@synthesize info;
@synthesize currentTool;

- (MyDocument *)document {
	return document;
}

- (void)setDocument:(MyDocument *)doc {
	if (doc == document) return;
	[doc retain];
	[document release];
	document = doc;
	[self setSizeLabel:nil];
	if (document != nil) {
		[tempLayer setSize:self.document.pixelsSize];
		[self repaintImage];
	}
}

- (NSString *)sizeLabel {
	return [NSString stringWithFormat:@"%dx%d",
			(int)self.document.pixelsSize.width,
			(int)self.document.pixelsSize.height];
}

- (void)setSizeLabel:(NSString *)str {
}

#pragma mark -
#pragma mark Properties zooming

- (NSString *)zoomLabel {
	return [NSString stringWithFormat:@"%d%%", (int)(zoom * 100)];
}
- (void)setZoomLabel:(NSString *)str {
}

- (float)zoomSlider {
	return log(zoom)/log(16);
}
- (void)setZoomSlider:(float)slider {
	float oldZoom = zoom;
	zoom = pow(16, slider);
	if (oldZoom != zoom) {
		[self setZoomLabel:@""];
		[self setCanZoomIn:NO];
		[self setCanZoomOut:NO];
		[self repaintImage];
	}
}

- (BOOL)canZoomIn {
	return zoom < 16;
}
- (void)setCanZoomIn:(BOOL)b {
}

- (BOOL)canZoomOut {
	return zoom > 1.0/16;
}
- (void)setCanZoomOut:(BOOL)b {
}

- (IBAction)zoomButtonClicked:(id)sender {
	int index = [sender selectedSegment];
	float slider = self.zoomSlider;
	if (index == 0 && self.canZoomOut) {
		slider -= 0.125;
		if (slider < -1.0) slider = -1.0;
	} else if (index == 1) {
		slider = 0;
	} else if (index == 2) {
		slider += 0.125;
		if (slider > 1.0) slider = 1.0;
	}
	self.zoomSlider = slider;
}

#pragma mark -
#pragma mark NSView

- (BOOL)acceptsFirstResponder {
	return YES;
}

#pragma mark -
#pragma mark NSResponder

- (void)mouseDown:(NSEvent *)theEvent {
	if (currentTool == NullTool) return;
	NSPoint point = [zoomTransformInversed transformPoint:
					 [self convertPoint:[theEvent locationInWindow] fromView:nil]];
	switch (currentTool) {
		case DrawBezier:
			controlPoints[bezierPhase] = point;
			if (bezierPhase > 0) {
				[figure removeAllPoints];
				[figure moveToPoint:controlPoints[0]];
				[figure curveToPoint:controlPoints[1] 
					   controlPoint1:controlPoints[2] 
					   controlPoint2:controlPoints[3]];
				[self setNeedsDisplay:YES];
			}
			if (bezierPhase == 0) bezierPhase++;
			break;
		case PenTool:
			[figure moveToPoint:point];
			break;
		case BrushTool:
			[info recreateBrush];
			[info paintBrushOnImage:self.document.myImage atPoint:point];
			[self setNeedsDisplay:YES];
			break;
		case EraserTool:
			[info recreateBrushAsEraser];
			[info paintBrushOnImage:self.document.myImage atPoint:point];
			[self setNeedsDisplay:YES];
			break;
		case SelToolAny:
		case SelToolRect:
			if (clipDest == nil) {
				[clip removeAllPoints];
				if (currentTool == SelToolAny) {
					[clip moveToPoint:point];
				} else {
					controlPoints[0] = point;
				}
			} else if ([clipDest containsPoint:point]) {
				controlPoints[0] = point;
				holdingClip = YES;
			}
			break;
		case TextTool:
			[self paintTextView];
			controlPoints[0] = [self convertPoint:[theEvent locationInWindow] fromView:nil];
			break;
		default:
			controlPoints[0] = point;
			break;
	}
}

- (void)mouseDragged:(NSEvent *)theEvent {
	if (currentTool == NullTool) return;
	[self recreateTempLayer];
	NSPoint point = [zoomTransformInversed transformPoint:
					 [self convertPoint:[theEvent locationInWindow] fromView:nil]];
	switch (currentTool) {
		case DrawBezier:
			controlPoints[bezierPhase] = point;
			if (bezierPhase == 1) {
				controlPoints[2] = controlPoints[0];
				controlPoints[3] = controlPoints[1];
			}
			[figure removeAllPoints];
			[figure moveToPoint:controlPoints[0]];
			[figure curveToPoint:controlPoints[1] 
				   controlPoint1:controlPoints[2] 
				   controlPoint2:controlPoints[3]];
			break;
		case BrushTool:
		case EraserTool:
			[info paintBrushOnImage:self.document.myImage atPoint:point];
			[self setNeedsDisplay:YES];
			return;
			break;
		case DrawLine:
			[figure removeAllPoints];
			[figure moveToPoint:controlPoints[0]];
			[figure lineToPoint:point];
			break;
		case DrawRect:
		case DrawOval:
			[figure removeAllPoints];
			NSRect rect;
			rect.origin = controlPoints[0];
			rect.size.width = point.x - controlPoints[0].x;
			rect.size.height = point.y - controlPoints[0].y;
			if ([theEvent modifierFlags] & NSShiftKeyMask) {
				float size = max(fabs(rect.size.width), fabs(rect.size.height));
				rect.size.width = size * sign(rect.size.width);
				rect.size.height = size * sign(rect.size.height);
			}
			if (currentTool == DrawRect) {
				[figure appendBezierPathWithRect:rect];
			} else {
				[figure appendBezierPathWithOvalInRect:rect];
			}
			break;
		case PenTool:
			[figure lineToPoint:point];
			break;
		case SelToolAny:
		case SelToolRect:
			if (clipDest == nil) {
				if (currentTool == SelToolAny) {
					[clip lineToPoint:point];
				} else {
					[clip removeAllPoints];
					NSRect rect;
					rect.origin = controlPoints[0];
					rect.size.width = point.x - controlPoints[0].x;
					rect.size.height = point.y - controlPoints[0].y;
					if ([theEvent modifierFlags] & NSShiftKeyMask) {
						float size = max(fabs(rect.size.width), fabs(rect.size.height));
						rect.size.width = size * sign(rect.size.width);
						rect.size.height = size * sign(rect.size.height);
					}
					[clip appendBezierPathWithRect:rect];
				}
			} else if (holdingClip) {
				controlPoints[1] = point;
				NSAffineTransform * trans = [[NSAffineTransform transform]retain];
				[trans translateXBy:controlPoints[1].x-controlPoints[0].x 
								yBy:controlPoints[1].y-controlPoints[0].y];
				[clipDest transformUsingAffineTransform:trans];
				[trans release];
				controlPoints[0] = point;
			}
			[self setNeedsDisplay:YES];
			return;
		case TextTool:
			{
				NSPoint point = [self convertPoint:[theEvent locationInWindow] fromView:nil];
				NSRect rect;
				rect.origin.x = min(controlPoints[0].x, point.x);
				rect.origin.y = min(controlPoints[0].y, point.y);
				rect.size.width = fabs(controlPoints[0].x - point.x);
				rect.size.height = fabs(controlPoints[0].y - point.y);
				[textView setFrame:rect];
				[self setNeedsDisplay:YES];
			}
			return;
		default:
			return;
			break;
	}
	[self.info paintFigure:figure onImage:tempLayer withTransform:nil];
	[self setNeedsDisplay:YES];
}

- (void)mouseUp:(NSEvent *)theEvent {
	if (currentTool == NullTool) return;
	switch (currentTool) {
		case DrawBezier:
			bezierPhase++;
			if (bezierPhase < 4) break;
		case DrawLine:
		case DrawRect:
		case DrawOval:
		case PenTool:
			bezierPhase = 0;
			[self.info paintFigure:figure onImage:self.document.myImage withTransform:nil];
			[self setNeedsDisplay:YES];
			[figure removeAllPoints];
			[self recreateTempLayer];
			break;
		case SelToolAny:
			holdingClip = NO;
			if (clipDest != nil) {
			} else {
				[clip closePath];
			}
			[self setNeedsDisplay:YES];
			break;
		default:
			break;
	}
}

#pragma mark -
#pragma mark Methods

- (void)updateTransform {
	[zoomTransformInversed release];
	zoomTransformInversed = [[NSAffineTransform transform]retain];
	NSImage * image = self.document.myImage;
	[zoomTransformInversed scaleBy:image.size.width/self.frame.size.width];
}

- (void)recreateTempLayer {
	NSRect rect = [scrollView documentVisibleRect];
	rect.size = [zoomTransformInversed transformSize:rect.size];
	rect.origin = [zoomTransformInversed transformPoint:rect.origin];
	[tempLayer lockFocus];
	[[NSColor clearColor]setFill];
	NSRectFill(rect);
	[tempLayer unlockFocus];
}

- (void)doCut {
	[self doCopy];
	isCutting = YES;
}

- (void)doCopy {
	[clipDest release];
	clipDest = [clip copy];
	[pasteboard release];
	NSRect srcRect = [clip bounds];
	pasteboard = [[NSImage alloc]initWithSize:srcRect.size];
	[pasteboard lockFocus];
	[self.document.myImage drawAtPoint:NSZeroPoint
							  fromRect:srcRect
							 operation:NSCompositeCopy
							  fraction:1.0];
	[pasteboard unlockFocus];
}

- (void)doPaste {
	[self.document.myImage lockFocus];
	if (isCutting) {
		[self.info.canvasColor setFill];
		[clip fill];
	}
	[clipDest addClip];
	NSRect destRect = [clipDest bounds];
	[pasteboard drawInRect:destRect
				  fromRect:NSZeroRect
				 operation:self.info.compositing
				  fraction:self.info.opacity/100.0];
	[self.document.myImage unlockFocus];
	[pasteboard release];
	pasteboard = nil;
	[clipDest release];
	clipDest = nil;
	isCutting = NO;
	[self setNeedsDisplay:YES];
}

- (void)cancelPaste {
	[pasteboard release];
	pasteboard = nil;
	[clipDest release];
	clipDest = nil;
	[clip removeAllPoints];
	[self setNeedsDisplay:YES];
	isCutting = NO;
}

- (void)doResize:(NSSize)newSize {
	[document resizeTo:newSize];
	[self setSizeLabel:nil];
	[tempLayer setSize:self.document.pixelsSize];
	[self repaintImage];
}

- (void)doCrop {
	if (currentTool != SelToolAny && currentTool != SelToolRect) return;
	if (clip == nil || [clip elementCount] <= 0) return;
	[document cropWithPath:clip];
	[self setSizeLabel:nil];
	[tempLayer setSize:self.document.pixelsSize];
	[self repaintImage];
}

- (void)setTextView:(NSTextView *)tv {
	textView = tv;
	if (tv != nil) {
		[self hideTextView];
		[tv setDrawsBackground:NO];
	}
}

- (void)hideTextView{
	[textView setFrame:NSZeroRect];
	[textView setString:@""];
}

- (void)paintTextView {
	NSRect rect = [textView frame];
	if (rect.size.width <= 0 || rect.size.height <= 0 || [[textView string]length] <= 0)
		return;
	NSAttributedString * string = [textView attributedString];
	rect.size = [string size];
	NSImage * strimg = [[NSImage alloc]initWithSize:rect.size];
	[strimg lockFocus];
	[string drawAtPoint:NSZeroPoint];
	[strimg unlockFocus];
	rect.size = [zoomTransformInversed transformSize:rect.size];
	rect.origin = [zoomTransformInversed transformPoint:rect.origin];
	[document.myImage lockFocus];
	[strimg drawInRect:rect
			  fromRect:NSZeroRect
			 operation:NSCompositeSourceOver
			  fraction:[info opacity]/100.0];
	[document.myImage unlockFocus];
	[strimg release];
	[self hideTextView];
}

@end
