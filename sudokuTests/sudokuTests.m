//
//  sudokuTests.m
//  sudokuTests
//
//  Created by Jose Rojas on 12/21/14.
//  Copyright (c) 2014 Jose Rojas. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "Solution.h"
#import "SudokuGenerator.h"
#import "Position.h"

@interface sudokuTests : XCTestCase {
    SudokuGenerator * _generator;
}

@end

@implementation sudokuTests

- (BOOL) validateSudoku: (Solution*) solution {

    BOOL valid = true;

    for (NSUInteger i = 0; i < 81; i++) {
        Position * pos = [solution positionAtIndex:i];

        //test row has no duplicates, values are between 1-9
        NSMutableSet* set = [NSMutableSet set];
        valid &= pos.value.integerValue >= 1 && pos.value.integerValue <= 9;
        if (pos.value)
            [set addObject:pos.value];
        for (NSUInteger row = 0; row < 9; row++) {
            if (row != pos.y) {
                Position * posToTest = [solution getAtX:pos.x Y:row];
                valid &= ![set containsObject:posToTest.value] && posToTest.value.integerValue >= 1 && posToTest.value.integerValue <= 9;
                if (!valid)
                    valid = valid;

                if (posToTest.value)
                    [set addObject:posToTest.value];
            }
        }

        [set removeAllObjects];

        //test column has no duplicates, values are between 1-9
        if (pos.value)
            [set addObject:pos.value];
        valid &= pos.value.integerValue >= 1 && pos.value.integerValue <= 9;
        for (NSUInteger col = 0; col < 9; col++) {
            if (col != pos.x) {
                Position * posToTest = [solution getAtX:col Y:pos.y];
                valid &= ![set containsObject:posToTest.value] && posToTest.value.integerValue >= 1 && posToTest.value.integerValue <= 9;
                if (!valid)
                    valid = valid;
                if (posToTest.value)
                    [set addObject:posToTest.value];
            }
        }

        [set removeAllObjects];

        //test sub grid has no duplicates, values are between 1-9
        if (pos.value)
            [set addObject:pos.value];
        valid &= pos.value.integerValue >= 1 && pos.value.integerValue <= 9;
        //find closest subgrid origin x/y offset
        NSUInteger xOff = (pos.x / 3) * 3;
        NSUInteger yOff = (pos.y / 3) * 3;
        for (NSUInteger subgridY = 0; subgridY < 3; subgridY++) {
            for (NSUInteger subgridX = 0; subgridX < 3; subgridX++) {
                if (subgridX + xOff != pos.x ||
                    subgridY + yOff != pos.y) {
                    Position *posToTest = [solution getAtX:subgridX + xOff Y: subgridY + yOff];
                    valid &= ![set containsObject:posToTest.value] && posToTest.value.integerValue >= 1 && posToTest.value.integerValue <= 9;
                    if (!valid)
                        valid = valid;
                    if (posToTest.value)
                        [set addObject:posToTest.value];
                }
            }
        }
        
        valid &= pos.possibleValues.count == 0;

    }

    return valid;
}

- (BOOL) isPartialSolution: (Solution*) partialSolution ofSolution: (Solution *) solution {

    BOOL bIsPartial = true;

    for (NSUInteger i = 0; i < 81; i++) {
        Position *pos = [partialSolution positionAtIndex:i];
        Position *pos2 = [solution positionAtIndex:i];

        if (pos.value.integerValue != 0)
            bIsPartial &= pos.value && pos2.value && [pos.value isEqualToNumber:pos2.value];
    }

    return bIsPartial;
}

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.

    _generator = [SudokuGenerator new];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPositionIndexing {

    Solution * solution = [_generator generateSolution:nil];

    for (NSUInteger i = 0; i < 81; i++) {
        NSUInteger x = i % 9;
        NSUInteger y = i / 9;
        XCTAssertEqual([solution positionAtIndex:i], [solution getAtX:x Y:y], @"Position %lu does not equal cell at (%lu, %lu)", i, x, y);
    }

}

- (void)testInvalidSolutionFailsRulesOfSudoku {

    Solution * solution = [_generator generateSolution:nil];

    //duplicate value in row
    Position * pos1 = [solution getAtX:0 Y:0];
    Position * pos2 = [solution getAtX:5 Y:0];

    pos1.value = pos2.value;

    XCTAssert(![self validateSudoku:solution], @"Solution is a valid Sudoku.");

    solution = [_generator generateSolution:nil];

    //duplicate value in column
    pos1 = [solution getAtX:0 Y:0];
    pos2 = [solution getAtX:0 Y:5];

    pos1.value = pos2.value;

    XCTAssert(![self validateSudoku:solution], @"Solution is a valid Sudoku.");

    solution = [_generator generateSolution:nil];

    //duplicate value in subgrid
    pos1 = [solution getAtX:0 Y:0];
    pos2 = [solution getAtX:2 Y:2];

    pos1.value = pos2.value;

    XCTAssert(![self validateSudoku:solution], @"Solution is a valid Sudoku.");

    //use invalid number
    solution = [_generator generateSolution:nil];

    //duplicate value in subgrid
    pos1 = [solution getAtX:0 Y:0];

    pos1.value = @(10);

    XCTAssert(![self validateSudoku:solution], @"Solution is a valid Sudoku.");

}

- (void)testSudokuSolutionFollowRulesOfSudoku {

    //test that the solution generated follows the rules of Sudoku

    Solution * solution = [_generator generateSolution:nil];

    XCTAssert([self validateSudoku:solution], @"Solution is not a valid Sudoku.");

}

- (void)testSudokuPuzzleCanBeSolved {

    for (int i = 0; i < 1000; i++) {
        Puzzle* puzzle = [_generator generate:PuzzleDifficultyHard];

        Solution* partialSolution = puzzle.grid.copy;
        
        Solution * solution = [_generator generateSolution:puzzle.grid];

        //test solution is comprised of a partial solution
        XCTAssert([self validateSudoku:solution], @"Solution is not a valid Sudoku");
        XCTAssert([self isPartialSolution:partialSolution ofSolution:solution], @"Solution does not contain the partial solution");

        if (![self validateSudoku:solution]) {
            [puzzle.solution printGrid];
            [partialSolution printGrid];
        }
    }
}

- (void)testDifficultSolution {
    
    NSArray* array = @[@0, @0, @0, @0, @0, @7, @4, @0, @0,
                       @0, @0, @9, @4, @0, @8, @0, @0, @0,
                       @0, @0, @7, @2, @0, @0, @0, @1, @3,
                       @8, @0, @0, @0, @3, @0, @0, @0, @0,
                       @0, @4, @0, @1, @0, @0, @0, @5, @8,
                       @0, @1, @0, @0, @0, @0, @0, @0, @0,
                       @0, @0, @4, @9, @2, @0, @0, @0, @6,
                       @0, @2, @0, @0, @4, @0, @0, @0, @0,
                       @0, @0, @0, @8, @0, @0, @5, @4, @0];
    
    Solution* partialSolution = [[Solution alloc] initSolutionWithArray:array];
    
    [partialSolution printGrid];
    
    Solution * solution = [_generator generateSolution:partialSolution];

    [solution printGrid];
    
    XCTAssert([self validateSudoku:solution], @"Solution is not a valid Sudoku");
    XCTAssert([self isPartialSolution:partialSolution ofSolution:solution], @"Solution does not contain the partial solution");
}

@end
