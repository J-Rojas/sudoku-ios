//
// Created by Jose Rojas on 12/21/14.
// Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SudokuGenerator.h"
#import "Solution.h"
#import "Puzzle.h"

@implementation SudokuGenerator {
    NSMutableArray * _solutionStack;
};

- (instancetype) init {
    _solutionStack = [NSMutableArray new];
    return self;
};

- (Solution *) generateSolution {
    Solution *solution = nil;

    int i = 0;
    while (i < 1) {

        int backTrackCount = 0;
        solution = [Solution new];
        SolutionState state = Invalid;
        [_solutionStack addObject:[solution copy]];

        do {
            state = [solution converge];
            switch (state) {
                case Solved:

                    NSLog(@"Puzzle solved!!! Backtrack count %d", backTrackCount);
                    //[solution printGrid];
                    [_solutionStack removeAllObjects];
                    break;
                case Progress:
                    [_solutionStack addObject:[solution copy]];
                    break;
                case Invalid:
                    backTrackCount++;
                    solution = [_solutionStack lastObject];
                    [_solutionStack removeLastObject];
                    [solution nextSolution];
                    break;
            }

        } while (state != Solved && _solutionStack.count > 0);

        i++;
    }

    return solution;
}

- (Puzzle *)generatePuzzleWithSolution:(Solution *)solution difficulty: (PuzzleDifficulty) difficulty {
    return [[Puzzle alloc] initWithSolution:solution difficulty: difficulty];
}

- (Puzzle *)generate: (PuzzleDifficulty) difficulty {
    Solution * solution = [self generateSolution];
    Puzzle * puzzle = [self generatePuzzleWithSolution:solution difficulty: difficulty];

    return puzzle;
}

@end