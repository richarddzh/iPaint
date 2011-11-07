//
//  MyBitmapImage.h
//  iPaint
//
//  Created by 董 政 on 11-9-23.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface MyBitmapImage : NSImage {

}

- (id) initWithSize:(NSSize)size;
- (void) spreadColor:(NSColor *)color atPoint:(NSPoint)point;

@end
