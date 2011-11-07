//
//  MyDocument.m
//  iPaint
//
//  Created by 董 政 on 11-9-15.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import "MyDocument.h"

@implementation MyDocument

@synthesize myImage;
@synthesize pixelsSize;

- (id)init
{
    self = [super init];
    if (self) {
        // Add your subclass-specific initialization here.
        // If an error occurs here, send a [self release] message and return nil.
		pixelsSize.width = 640;
		pixelsSize.height = 480;
		/*[NSBundle loadNibNamed:@"NewFileView" owner:self];
		NSAlert * alert = [[NSAlert alloc] init];
		[alert setMessageText:@"Create Image"];
		[alert setAccessoryView:newFileView];
		[alert runModal];
		[alert release];*/
		MyBitmapImage * image = [[MyBitmapImage alloc]initWithSize:pixelsSize];
		NSRect rect = NSZeroRect;
		rect.size = pixelsSize;
		[image lockFocus];
		[[NSColor whiteColor]set];
		NSRectFill(rect);
		[image unlockFocus];
		[self setMyImage:image];
		[image release];
    }
    return self;
}

- (void)dealloc {
	[self setMyImage:nil];
	[super dealloc];
}

- (NSString *)windowNibName
{
    // Override returning the nib file name of the document
    // If you need to use a subclass of NSWindowController or if your document supports multiple NSWindowControllers, you should remove this method and override -makeWindowControllers instead.
    return @"MyDocument";
}

- (void)windowControllerDidLoadNib:(NSWindowController *) aController
{
    [super windowControllerDidLoadNib:aController];
    // Add any code here that needs to be executed once the windowController has loaded the document's window.
}

- (NSData *)dataOfType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to write your document to data of the specified type. If the given outError != NULL, ensure that you set *outError when returning nil.
	NSBitmapImageFileType type = NSPNGFileType;
	if ([typeName isEqualToString:@"Windows Bitmap Image"]) {
		type = NSBMPFileType;
	} else if ([typeName isEqualToString:@"JPEG Image"]) {
		type = NSJPEGFileType;
	} else if ([typeName isEqualToString:@"GIF Image"]) {
		type = NSGIFFileType;
	} else if ([typeName isEqualToString:@"TIFF Image"]) {
		type = NSTIFFFileType;
	}
    NSData * imageData = [myImage TIFFRepresentation];
	NSBitmapImageRep *imageRep = [[NSBitmapImageRep alloc]initWithData:imageData];
    NSDictionary *imageProps = [NSDictionary dictionary];
    imageData = [imageRep representationUsingType:type properties:imageProps];
	[imageRep release];
    // You can also choose to override -fileWrapperOfType:error:, -writeToURL:ofType:error:, or -writeToURL:ofType:forSaveOperation:originalContentsURL:error: instead.

    // For applications targeted for Panther or earlier systems, you should use the deprecated API -dataRepresentationOfType:. In this case you can also choose to override -fileWrapperRepresentationOfType: or -writeToFile:ofType: instead.

    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
	return imageData;
}

- (BOOL)readFromData:(NSData *)data ofType:(NSString *)typeName error:(NSError **)outError
{
    // Insert code here to read your document from the given data of the specified type.  If the given outError != NULL, ensure that you set *outError when returning NO.
	NSBitmapImageRep * imgRep = [NSBitmapImageRep imageRepWithData:data];
	pixelsSize.width = [imgRep pixelsWide];
	pixelsSize.height = [imgRep pixelsHigh];
	MyBitmapImage * image = [[MyBitmapImage alloc]initWithSize:pixelsSize];
	[image lockFocus];
	NSRect rect;
	rect.origin = NSZeroPoint;
	rect.size = pixelsSize;
	NSImage * repImage = [[NSImage alloc]initWithData:data];
	[repImage drawInRect:rect fromRect:NSZeroRect operation:NSCompositeCopy fraction:1.0];
	[repImage release];
	[image unlockFocus];
	[self setMyImage:image];
	[image release];
    // You can also choose to override -readFromFileWrapper:ofType:error: or -readFromURL:ofType:error: instead. 
    
    // For applications targeted for Panther or earlier systems, you should use the deprecated API -loadDataRepresentation:ofType. In this case you can also choose to override -readFromFile:ofType: or -loadFileWrapperRepresentation:ofType: instead.
    
    if ( outError != NULL ) {
		*outError = [NSError errorWithDomain:NSOSStatusErrorDomain code:unimpErr userInfo:NULL];
	}
    return YES;
}

- (void)resizeTo:(NSSize)newSize {
	pixelsSize = newSize;
	MyBitmapImage * newImage = [[MyBitmapImage alloc]initWithSize:newSize];
	[newImage lockFocus];
	[myImage drawInRect:NSMakeRect(0, 0, newSize.width, newSize.height)
			   fromRect:NSZeroRect
			  operation:NSCompositeCopy
			   fraction:1.0];
	[self setMyImage:newImage];
	[newImage unlockFocus];
	[newImage release];
}

- (void)cropWithPath:(NSBezierPath *)path {
	NSRect bounds = [path bounds];
	pixelsSize = bounds.size;
	NSAffineTransform * trans = [[NSAffineTransform transform]retain];
	[trans translateXBy:-bounds.origin.x yBy:-bounds.origin.y];
	[path transformUsingAffineTransform:trans];
	[trans release];
	MyBitmapImage * newImage = [[MyBitmapImage alloc]initWithSize:pixelsSize];
	[newImage lockFocus];
	NSRect rect = NSMakeRect(0, 0, pixelsSize.width, pixelsSize.height);
	[[NSColor whiteColor]set];
	NSRectFill(rect);
	[path addClip];
	[myImage drawInRect:rect
			   fromRect:bounds
			  operation:NSCompositeCopy
			   fraction:1.0];
	[newImage unlockFocus];
	[self setMyImage:newImage];
	[newImage release];
}

@end
