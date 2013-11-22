//
//  HiraganaU.m
//  KanaCut
//
//  Created by Luis Jacintho on 11/22/13.
//  Copyright (c) 2013 Publius Tecnologia. All rights reserved.
//

#import "HiraganaU.h"

@implementation HiraganaU

- (instancetype) initWithWorld: (b2World *) world
{
    int32 count = 7;
    NSString *imageName = @"hiragana-u.png";
    b2Vec2 vertices[] = {
        b2Vec2(16.f / PTM_RATIO, 61.f / PTM_RATIO),
        b2Vec2(9.f / PTM_RATIO, 38.f / PTM_RATIO),
        b2Vec2(20.f / PTM_RATIO, 6.f / PTM_RATIO),
        b2Vec2(37.f / PTM_RATIO, 7.f / PTM_RATIO),
        b2Vec2(52.f / PTM_RATIO, 20.f / PTM_RATIO),
        b2Vec2(52.f / PTM_RATIO, 36.f / PTM_RATIO),
        b2Vec2(45.f / PTM_RATIO, 58.f / PTM_RATIO)
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
        self.type = kPolygonTypeHiraganaU;
    }
    
    return self;
}

@end
