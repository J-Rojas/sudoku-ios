//
// Created by Jose Rojas on 12/21/14.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Puzzle.h"

@class Solution;
@class Puzzle;

@interface SudokuGenerator : NSObject

- (Solution*) generateSolution: (Solution*) initialState;
- (Puzzle*) generatePuzzleWithSolution: (Solution *) solution;

- (Puzzle *) generate: (PuzzleDifficulty) difficulty;

@end