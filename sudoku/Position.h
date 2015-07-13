//
// Created by Jose Rojas on 2/1/15.
// Copyright (c) 2015 Jose Rojas. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface Position : NSObject<NSCopying>

/* Compares two Position classes by the size of their possibleValues arrays. The one which smaller is the more constrained
*  position.
*  */
+ (NSComparator) comparator;

/* Initialize the cell */
- (instancetype) initWithX: (NSUInteger) x Y: (NSUInteger) y;

/* Shuffle the possible values */
- (NSMutableArray*) shuffleSet: (NSMutableArray*) arr;

/* Add or remove a value for the set of possible values */
- (void) remove: (id) value;
- (void) add: (id) value;

/* The value of the Sudoku cell. 0 represents an unfilled cell, while 1-9 represents a filled cell. */
@property NSNumber * value;

/* A string representation of the cell value. 0 is converted into '-' for display purposes. */
@property (readonly) NSString* printableValue;

/* The x and y position in the grid of this cell */
@property NSUInteger x, y;

@property bool temporary;

/* The possible values that this cell can have. When self.value is not 0, then the count of possible values should be 0. */
@property NSMutableArray* possibleValues;

@end
