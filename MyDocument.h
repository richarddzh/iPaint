//
//  MyDocument.h
//  iPaint
//
//  Created by 董 政 on 11-9-15.
//  Copyright 2011 复旦大学. All rights reserved.
//


#import <Cocoa/Cocoa.h>
#import "MyBitmapImage.h"

@interface MyDocument : NSDocument
{
	MyBitmapImage * myImage;
	NSSize pixelsSize;
}

@property (nonatomic,retain) MyBitmapImage * myImage;
@property (nonatomic,readwrite) NSSize pixelsSize;

- (void)resizeTo:(NSSize)newSize;
- (void)cropWithPath:(NSBezierPath *)path;

@end
