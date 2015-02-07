//
// Created by Jose Rojas on 2/7/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Solution;

typedef enum {
    PuzzleDifficultyEasy = 30,
    PuzzleDifficultyMedium = 45,
    PuzzleDifficultyHard = 56
} PuzzleDifficulty;

@interface Puzzle : NSObject

- (instancetype) initWithSolution: (Solution *) solution difficulty: (PuzzleDifficulty) difficulty;

@property Solution * solution;
@property Solution * grid;
@property PuzzleDifficulty difficulty;

@end