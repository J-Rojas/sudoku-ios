//
// Created by Jose Rojas on 2/1/15.
// Copyright (c) 2015 Jose Rojas. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Position;

typedef enum  {
    Invalid, //An invalid solution - this Solution would violate the rules of Sudoku
    Progress, //The converge function has made progress, but the Solution is not complete.
    Solved //The Solution is completely solved, all values are assigned and the Sudoku Solution is valid.
} SolutionState;

@interface Solution : NSObject<NSCopying>

- (instancetype) initSolution;
- (instancetype) initSolutionWithArray: (NSArray*) arrayOfValues;

- (BOOL) isValid;

/* Converge the Solution one step towards a complete, valid Solution, returning the state of the Solution */
- (SolutionState) converge;

- (void) reduce: (Position*) pos;

/* Prints the grid to the console, for debugging */
- (void) printGrid;

/* Update the candidate cell that is used as the next possible choice during the converge method. This is useful
 * when attempting to avoid an invalid solution state. */
- (BOOL) nextSolution;

/* Returns the Position cell at a given index. A position index linearly maps to 2D cell in a grid given:
* x (column) = index % 9
* y (row) = index / 9
*/
- (Position*) positionAtIndex: (NSUInteger) index;

/*
 * For a Position cell that is assigned a value, constrain all applicable cells in the same row, column, subgrid so
 * that their possible values to not violate the rules of Sudoku.
 */
- (void) removePosition: (Position *) pos;

/*
 * Get a Position cell using row and column, such that index = row * 9 + col
 */
- (Position *) getAtX: (NSUInteger) col Y: (NSUInteger) row;

@end