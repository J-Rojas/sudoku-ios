//
// Created by Jose Rojas on 2/1/15.
// Copyright (c) 2015 ___FULLUSERNAME___. All rights reserved.
//

#import "Position.h"


@implementation Position

- (instancetype) initWithX: (int) x Y: (int) y {

    _value = @(0);
    _x = x;
    _y = y;
    _possibleValues = [self shuffleSet:[[NSMutableArray alloc] initWithArray:@[@(1), @(2), @(3), @(4), @(5), @(6), @(7), @(8), @(9)]]];

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    Position * newPos = [Position new];

    newPos.value = _value;
    newPos.x = _x;
    newPos.y = _y;
    newPos.possibleValues = [[[NSMutableArray alloc] initWithArray:_possibleValues] mutableCopy];

    return newPos;
}

- (NSMutableArray*) shuffleSet: (NSMutableArray*) arr {
    int i = arr.count;
    while (i-- > 0) {
        int randInd1 = arc4random_uniform(arr.count);
        int randInd2 = arc4random_uniform(arr.count);

        id val = arr[randInd1];
        arr[randInd1] = arr[randInd2];
        arr[randInd2] = val;
    }

    return arr;
}

- (void) remove: (id) value {
    [_possibleValues removeObject:value];
}

- (void) add: (id) value {
    [_possibleValues addObject:value];
}

- (NSString *)printableValue {
    return _value.integerValue == 0 ? @"-" : [_value stringValue];
}

@end
