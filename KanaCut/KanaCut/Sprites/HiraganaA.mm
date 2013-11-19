//
//  HiraganaA.m
//  KanaCut
//
//  Created by Luis Jacintho on 11/19/13.
//  Copyright 2013 Publius Tecnologia. All rights reserved.
//

#import "HiraganaA.h"

@implementation HiraganaA

- (instancetype) initWithWorld: (b2World *) world
{
    int32 count = 8;
    NSString *imageName = @"hiragana-a.png";
    b2Vec2 vertices[] = {
        b2Vec2(57.f / PTM_RATIO, 53.f / PTM_RATIO),
        b2Vec2(27.f / PTM_RATIO, 61.f / PTM_RATIO),
        b2Vec2(8.f / PTM_RATIO, 52.f / PTM_RATIO),
        b2Vec2(7.f / PTM_RATIO, 17.f / PTM_RATIO),
        b2Vec2(12.f / PTM_RATIO, 10.f / PTM_RATIO),
        b2Vec2(42.f / PTM_RATIO, 5.f / PTM_RATIO),
        b2Vec2(55.f / PTM_RATIO, 10.f / PTM_RATIO),
        b2Vec2(59.f / PTM_RATIO, 21.f / PTM_RATIO),
    };
    CGSize screen = [[CCDirector sharedDirector] winSize];
    
    b2Body *body = [self createBodyForWorld: world
                                   position: b2Vec2 (screen.width / 2 / PTM_RATIO,
                                                     screen.height / 2 / PTM_RATIO)
                                   rotation: 0.f
                                   vertices: vertices
                                vertexCount: count
                                    density: 5.f
                                   friction: 0.2f
                                restitution: 0.2f];
    
    self = [super initWithFile: imageName body: body original: YES];
    
    if (self)
    {
        
    }
    
    return self;
}

@end
