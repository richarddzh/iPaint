//
//  MyBitmapImage.m
//  iPaint
//
//  Created by 董 政 on 11-9-23.
//  Copyright 2011 复旦大学. All rights reserved.
//

#import "MyBitmapImage.h"


@implementation MyBitmapImage

#pragma mark -
#pragma mark NSObject

- (id)initWithSize:(NSSize)size {
	self = [super initWithSize:size];
	if (self != nil) {
	}
	return self;
}

- (void)dealloc {
	[super dealloc];
}

#pragma mark -
#pragma mark Additional functions

typedef struct {
	uint32 * bitmapData;
	int width;
	int height;
	uint32 toSpread;
	uint32 within;
} spreadColor_data;

void spreadColorAtPoint(spreadColor_data * pData, int x, int y) {
	if (x < 0 || y < 0 || x >= pData->width || y >= pData->height) return;
	uint32 color = pData->bitmapData[x + y * pData->width];
	if (color == pData->toSpread) return;
	if (color != pData->within) return;
	pData->bitmapData[x + y * pData->width] = pData->toSpread;
	spreadColorAtPoint(pData, x+1, y);
	spreadColorAtPoint(pData, x-1, y);
	spreadColorAtPoint(pData, x, y+1);
	spreadColorAtPoint(pData, x, y-1);
}

- (void)spreadColor:(NSColor *)color atPoint:(NSPoint)point {
	
	NSLog(@"REP:");
	for (NSImageRep * rep in [self representations]) {
		NSLog(@" - %@", [rep description]);
	}
	/*
	int x = point.x;
	int y = point.y;
	spreadColor_data data;
	spreadColor_data * pData = &data;
	pData->bitmapData = (uint32 *) [rep bitmapData];
	pData->width = self.size.width;
	pData->height = self.size.height;
	uint8 toSpread[4];
	toSpread[0] = [color alphaComponent] * 255;
	toSpread[1] = [color redComponent] * 255;
	toSpread[2] = [color greenComponent] * 255;
	toSpread[3] = [color blueComponent] * 255;
	pData->toSpread = *(uint32*)toSpread;
	pData->within = pData->bitmapData[y * pData->width + x];
	spreadColorAtPoint(pData, x, y);
	*/
	
}


@end
