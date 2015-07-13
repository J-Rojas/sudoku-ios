//
// Created by Jose Rojas on 12/21/14.
// Copyright (c) 2014 Jose Rojas. All rights reserved.
//

/*
 * The SudokuGenerator class is a helper class that generates Sudoku solutions and their associated puzzles.
 *
 * A PuzzleDifficulty can be supplied when generating a Puzzle to configure the number of missing squares.
 * The higher the difficulty, the more missing squares.
 *
 * See generateSolution: for more details on the Solution generation algorithm.
 *
 */

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

- (Solution *) generateSolution: (Solution*) initialState {
    Solution *solution = nil;

    int i = 0;
    while (i < 1) {

        //solve by starting with a completely unsolved Sudoku grid and converge the solution towards a partially
        // complete and valid Sudoku grid by choosing a possible grid value at each iteration until the Sudoku grid is
        // solved. Along the way the algorithm will encounter invalid states that represent 'dead ends' in the solution
        // space where no further progress can be made because not every randomly chosen path of values can lead to a
        // Sudoku solution. To optimize this search without starting over again with an entirely new Solution,
        // a stack of Solutions is saved (so up to 81 solution states can be stored, one per cell in the Sudoku).
        // When a dead end is encountered, the stack is popped one level and the next possible path within that
        // Solution state is then chosen (a different choice is made for the possible value of a next filled cell).
        // This ensures progress and convergence for any given path in the entire Sudoku solution space. In most cases,
        // it is unlikely to back track much or at all because the size of the Sudoku solution space is so large.
        //
        // A recursive solution was not used here for the purposes of being able to save the steps of the convergence
        // for further analysis. This is not applied yet in the code, however that is the motiviation of this solution
        // looking forward.

        int backTrackCount = 0;
        solution = initialState ? initialState.copy : [Solution new];
        
        [solution reduce:nil];
        
        SolutionState state, prevState;
        [_solutionStack addObject:[solution copy]];
        
        do {
            prevState = state;
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
                    solution = [_solutionStack lastObject];
                    if(![solution nextSolution]) {
                        [_solutionStack removeLastObject];                        
                        backTrackCount++;
                    } else {
                        solution = [solution copy];
                    }
                    break;
            }
            
            //[solution printGrid];
            
        } while (state != Solved && solution);

        i++;
        
        if (solution == nil)
            NSLog(@"Backtrack count %d", backTrackCount);
    }
    
    return solution;
}

- (Puzzle *)generatePuzzleWithSolution:(Solution *)solution difficulty: (PuzzleDifficulty) difficulty {
    return [[Puzzle alloc] initWithSolution:solution difficulty: difficulty];
}

- (Puzzle *)generate: (PuzzleDifficulty) difficulty {
    Solution * solution = [self generateSolution: nil];
    Puzzle * puzzle = [self generatePuzzleWithSolution:solution difficulty: difficulty];

    return puzzle;
}

@end