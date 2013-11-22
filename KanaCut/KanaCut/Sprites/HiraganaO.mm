//
//  HiraganaO.m
//  KanaCut
//
//  Created by Luis Jacintho on 11/22/13.
//  Copyright (c) 2013 Publius Tecnologia. All rights reserved.
//

#import "HiraganaO.h"

@implementation HiraganaO

- (instancetype) initWithWorld: (b2World *) world
{
    int32 count = 8;
    NSString *imageName = @"hiragana-o.png";
    b2Vec2 vertices[] = {
        b2Vec2(61.f / PTM_RATIO, 38.f / PTM_RATIO),
        b2Vec2(48.f / PTM_RATIO, 50.f / PTM_RATIO),
        b2Vec2(23.f / PTM_RATIO, 59.f / PTM_RATIO),
        b2Vec2(6.f / PTM_RATIO, 49.f / PTM_RATIO),
        b2Vec2(6.f / PTM_RATIO, 13.f / PTM_RATIO),
        b2Vec2(11.f / PTM_RATIO, 6.f / PTM_RATIO),
        b2Vec2(44.f / PTM_RATIO, 5.f / PTM_RATIO),
        b2Vec2(54.f / PTM_RATIO, 13.f / PTM_RATIO)
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
        self.type = kPolygonTypeHiraganaO;
    }
    
    return self;
}

@end
