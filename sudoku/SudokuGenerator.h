//
// Created by Jose Rojas on 12/21/14.
// Copyright (c) 2014 Jose Rojas. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Puzzle.h"

@class Solution;
@class Puzzle;

@interface SudokuGenerator : NSObject

/* Generate a completed, solved solution based on an incomplete solution */
- (Solution*) generateSolution: (Solution*) initialState;

/* Generate a Puzzle with a completed Solution and a difficulty setting */
- (Puzzle *) generatePuzzleWithSolution:(Solution *)solution difficulty: (PuzzleDifficulty) difficulty;

/* Generate a Puzzle with a randomly generated Solution and a difficult setting */
- (Puzzle *) generate: (PuzzleDifficulty) difficulty;

@end