//
//  HelloWorldLayer.h
//  KanaCut
//
//  Created by Luis Jacintho on 11/18/13.
//  Copyright Publius Tecnologia 2013. All rights reserved.
//


#import <GameKit/GameKit.h>

// When you import this file, you import all the cocos2d classes
#import "cocos2d.h"
#import "Box2D.h"
#import "GLES-Render.h"

//Pixel to metres ratio. Box2D uses metres as the unit for measurement.
//This ratio defines how many pixels correspond to 1 Box2D "metre"
//Box2D is optimized for objects of 1x1 metre therefore it makes sense
//to define the ratio so that your most common object type is 1x1 metre.
#define PTM_RATIO 32

#define calculate_determinant_2x2(x1,y1,x2,y2)          x1*y2-y1*x2
#define calculate_determinant_2x3(x1,y1,x2,y2,x3,y3)    x1*y2+x2*y3+x3*y1-y1*x2-y2*x3-y3*x1

@class PolygonSprite;

// HelloWorldLayer
@interface HelloWorldLayer : CCLayer <GKAchievementViewControllerDelegate, GKLeaderboardViewControllerDelegate>
{
	b2World* world;					// strong ref
	GLESDebugDraw *m_debugDraw;		// strong ref
}

// returns a CCScene that contains the HelloWorldLayer as the only child
+(CCScene *) scene;

- (b2Vec2 *) arrangeVertices: (b2Vec2 *) vertices count: (int) count;
- (void) splitPolygonSprite: (PolygonSprite *) sprite;
- (BOOL) areVerticesAcceptable: (b2Vec2 *) vertices count: (int) count;
- (b2Body *) createBodyWithPosition: (b2Vec2) position rotation: (float) rotation vertices: (b2Vec2 *) vertices vertexCount: (int32) count density: (float) density friction: (float) friction restitution: (float) restitution;

@end
