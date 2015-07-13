//
// Created by Jose Rojas on 2/7/15.
// Copyright (c) 2015 Jose Rojas. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Solution;

//Each value represents the minimum number of cells to unassign from the complete solution. The harder the difficulty,
// the more cells to unassign.
typedef enum {
    PuzzleDifficultyEasy = 30,
    PuzzleDifficultyMedium = 45,
    PuzzleDifficultyHard = 56
} PuzzleDifficulty;

@interface Puzzle : NSObject

/* initialize a partial solution based on a complete solution and a PuzzleDifficulty setting */
- (instancetype) initWithSolution: (Solution *) solution difficulty: (PuzzleDifficulty) difficulty;

/* The complete solution */
@property Solution * solution;

/* The partially complete solution */
@property Solution * grid;

/* The Puzzle difficulty setting used to generate the partial solution. */
@property (readonly) PuzzleDifficulty difficulty;

@end