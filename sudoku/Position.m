//
// Created by Jose Rojas on 2/1/15.
// Copyright (c) 2015 Jose Rojas. All rights reserved.
//

/*
 *  Position is a helper class that wrap NSSet to track the possible values that each Sudoku cell in a Solution can
 *  possibly be without violating the rules of Sudoku. The starting values in each Position are the numbers 1-9.
 *
 *  The Solution class manages the rules of Sudoku and which values are available in each position using the add: and
 *  remove: methods.
 *
 *  The Position possible values can be shuffled for the purpose of randomly choosing a possible value from the start
 *  of the possibleValues array for use in the Solution.
 */

#import "Position.h"

static NSComparator comparator = ^NSComparisonResult(Position *pos1, Position *pos2) {
    if (pos1.possibleValues.count < pos2.possibleValues.count)
        return NSOrderedAscending;
    else if (pos1.possibleValues.count == pos2.possibleValues.count) {
        return NSOrderedSame;
    } else
        return NSOrderedDescending;
};

@implementation Position

+ (NSComparator)comparator {
    return comparator;
}

- (instancetype) initWithX: (NSUInteger) x Y: (NSUInteger) y {

    self.value = @(0);
    self.x = x;
    self.y = y;
    self.possibleValues = [self shuffleSet:[[NSMutableArray alloc] initWithArray:
        @[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9)]]
    ];

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Position * newPos = [Position new];

    newPos.value = self.value;
    newPos.x = self.x;
    newPos.y = self.y;
    newPos.possibleValues = [[[NSMutableArray alloc] initWithArray:self.possibleValues] mutableCopy];

    return newPos;
}

- (NSMutableArray*) shuffleSet: (NSMutableArray*) arr {

    //Shuffle by swapping random elements within the set
    NSUInteger i = arr.count;
    while (i > 1) {
        uint32_t randInd1 = arc4random_uniform((uint32_t)arr.count);
        uint32_t randInd2 = arc4random_uniform((uint32_t)arr.count);

        if (randInd1 != randInd2) {
            id val = arr[randInd1];
            arr[randInd1] = arr[randInd2];
            arr[randInd2] = val;
            i--;
        }
    }

    return arr;
}

- (void) remove: (id) value {
    [self.possibleValues removeObject:value];
}

- (void) add: (id) value {
    if (![self.possibleValues containsObject:value])
        [self.possibleValues addObject:value];
}

- (NSString *)printableValue {
    return self.value.integerValue == 0 ? @"-" : [self.value stringValue];
}

@end
