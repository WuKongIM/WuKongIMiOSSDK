//
//  WuKongIMSDKTests.m
//  WuKongIMSDKTests
//
//  Created by tangtaoit on 11/23/2019.
//  Copyright (c) 2019 tangtaoit. All rights reserved.
//

// https://github.com/Specta/Specta

SpecBegin(InitialSpecs)

describe(@"these will fail", ^{

    it(@"can do maths", ^{
        NSLog(@"dddd");
        expect(2).to.equal(2);
    });

    it(@"can read", ^{
        expect(@"number").to.equal(@"number");
    });
    
    it(@"will wait for 10 seconds and fail", ^{
        waitUntil(^(DoneCallback done) {
           done();
        });
    });
});

describe(@"these will pass", ^{
    
    it(@"can do maths", ^{
        expect(1).beLessThan(23);
    });
    
    it(@"can read", ^{
        expect(@"team").toNot.contain(@"I");
    });
    
    it(@"will wait and succeed", ^{
        waitUntil(^(DoneCallback done) {
            done();
        });
    });
});

SpecEnd

