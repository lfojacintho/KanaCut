//
//  HelloWorldLayer.mm
//  KanaCut
//
//  Created by Luis Jacintho on 11/18/13.
//  Copyright Publius Tecnologia 2013. All rights reserved.
//

#import "AppDelegate.h"
#import "HelloWorldLayer.h"
#import "RayCastCallback.h"

#import "PolygonSprite.h"
#import "HiraganaA.h"


enum {
	kTagParentNode = 1,
};


#pragma mark - HelloWorldLayer

@interface HelloWorldLayer()
{
    CGPoint _startPoint;
    CGPoint _endPoint;
    
    RayCastCallback *_raycastCallback;
}

@property (nonatomic, strong) CCArray *cache;

-(void) initPhysics;
-(void) addNewSpriteAtPosition:(CGPoint)p;
-(void) createMenu;
@end

@implementation HelloWorldLayer

+ (CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id) init
{
    self = [super init];
    
	if (self)
    {
		
		// enable events
		self.touchEnabled = YES;
		self.accelerometerEnabled = YES;
		CGSize s = [CCDirector sharedDirector].winSize;
		
		// init physics
		[self initPhysics];
        [self initSprites];
        
        _raycastCallback = new RayCastCallback ();
		
		[self scheduleUpdate];
	}
    
	return self;
}

- (void) dealloc
{
	delete world;
	world = NULL;
	
	delete m_debugDraw;
	m_debugDraw = NULL;
	
	[super dealloc];
}	

- (void) createMenu
{
	// Default font size will be 22 points.
	[CCMenuItemFont setFontSize:22];
	
	// Reset Button
	CCMenuItemLabel *reset = [CCMenuItemFont itemWithString:@"Reset" block:^(id sender){
		[[CCDirector sharedDirector] replaceScene: [HelloWorldLayer scene]];
	}];

	// to avoid a retain-cycle with the menuitem and blocks
	__block id copy_self = self;

	// Achievement Menu Item using blocks
	CCMenuItem *itemAchievement = [CCMenuItemFont itemWithString:@"Achievements" block:^(id sender) {
		
		
		GKAchievementViewController *achivementViewController = [[GKAchievementViewController alloc] init];
		achivementViewController.achievementDelegate = copy_self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:achivementViewController animated:YES];
		
		[achivementViewController release];
	}];
	
	// Leaderboard Menu Item using blocks
	CCMenuItem *itemLeaderboard = [CCMenuItemFont itemWithString:@"Leaderboard" block:^(id sender) {
		
		
		GKLeaderboardViewController *leaderboardViewController = [[GKLeaderboardViewController alloc] init];
		leaderboardViewController.leaderboardDelegate = copy_self;
		
		AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
		
		[[app navController] presentModalViewController:leaderboardViewController animated:YES];
		
		[leaderboardViewController release];
	}];
	
	CCMenu *menu = [CCMenu menuWithItems:itemAchievement, itemLeaderboard, reset, nil];
	
	[menu alignItemsVertically];
	
	CGSize size = [[CCDirector sharedDirector] winSize];
	[menu setPosition:ccp( size.width/2, size.height/2)];
	
	
	[self addChild: menu z:-1];	
}

-(void) initPhysics
{
	
	CGSize s = [[CCDirector sharedDirector] winSize];
	
	b2Vec2 gravity;
	gravity.Set(0.0f, -10.0f);
	world = new b2World(gravity);
	
	
	// Do we want to let bodies sleep?
	world->SetAllowSleeping(true);
	
	world->SetContinuousPhysics(true);
	
	m_debugDraw = new GLESDebugDraw( PTM_RATIO );
	world->SetDebugDraw(m_debugDraw);
	
	uint32 flags = 0;
	flags += b2Draw::e_shapeBit;
	//		flags += b2Draw::e_jointBit;
	//		flags += b2Draw::e_aabbBit;
	//		flags += b2Draw::e_pairBit;
	//		flags += b2Draw::e_centerOfMassBit;
	m_debugDraw->SetFlags(flags);		
	
	
	// Define the ground body.
	b2BodyDef groundBodyDef;
	groundBodyDef.position.Set(0, 0); // bottom-left corner
	
	// Call the body factory which allocates memory for the ground body
	// from a pool and creates the ground box shape (also from a pool).
	// The body is also added to the world.
	b2Body* groundBody = world->CreateBody(&groundBodyDef);
	
	// Define the ground box shape.
	b2EdgeShape groundBox;		
	
	// bottom
	
	groundBox.Set(b2Vec2(0,0), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// top
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO));
	groundBody->CreateFixture(&groundBox,0);
	
	// left
	groundBox.Set(b2Vec2(0,s.height/PTM_RATIO), b2Vec2(0,0));
	groundBody->CreateFixture(&groundBox,0);
	
	// right
	groundBox.Set(b2Vec2(s.width/PTM_RATIO,s.height/PTM_RATIO), b2Vec2(s.width/PTM_RATIO,0));
	groundBody->CreateFixture(&groundBox,0);
}

- (void) initSprites
{
    _cache = [[CCArray alloc] initWithCapacity: 53];
    
    PolygonSprite *sprite = [[HiraganaA alloc] initWithWorld: world];
    [self addChild: sprite z: 1];
    [sprite activateCollisions];
    [_cache addObject: sprite];
}

- (void) checkAndSliceObjects
{
    double curTime = CACurrentMediaTime ();
    
    for (b2Body *b = world->GetBodyList (); b; b = b->GetNext ())
    {
        if (b->GetUserData () != NULL)
        {
            PolygonSprite *sprite = (PolygonSprite *) b->GetUserData ();
            
            if (sprite.sliceEntered && curTime > sprite.sliceEntryTime)
            {
                sprite.sliceEntered = NO;
            }
            else if (sprite.sliceEntered && sprite.sliceExited)
            {
                [self splitPolygonSprite: sprite];
            }
        }
    }
}

- (void) clearSlices
{
    for (b2Body *b = world->GetBodyList (); b; b = b->GetNext ())
    {
        if (b->GetUserData () != NULL)
        {
            PolygonSprite *sprite = (PolygonSprite *) b->GetUserData ();
            sprite.sliceEntered = NO;
            sprite.sliceExited = NO;
        }
    }
}

- (void) splitPolygonSprite: (PolygonSprite *) sprite
{
    PolygonSprite *newSprite1, *newSprite2;
    
    b2Fixture *originalFixture = sprite.body->GetFixtureList();
    b2PolygonShape *originalPolygon = (b2PolygonShape *) originalFixture->GetShape ();
    int vertexCount = originalPolygon->GetVertexCount ();
    
    float determinant;
    int i;
    
    b2Vec2 *sprite1Vertices = (b2Vec2 *) calloc (24, sizeof (b2Vec2));
    b2Vec2 *sprite2Vertices = (b2Vec2 *) calloc (24, sizeof (b2Vec2));
    b2Vec2 *sprite1VerticesSorted, *sprite2VerticesSorted;
    
    int sprite1VertexCount = 0;
    int sprite2VertexCount = 0;
    
    sprite1Vertices[sprite1VertexCount++] = sprite.entryPoint;
    sprite1Vertices[sprite1VertexCount++] = sprite.exitPoint;
    sprite2Vertices[sprite2VertexCount++] = sprite.entryPoint;
    sprite2Vertices[sprite2VertexCount++] = sprite.exitPoint;
    
    for (i = 0; i < vertexCount; ++i)
    {
        b2Vec2 point = originalPolygon->GetVertex (i);
        
        b2Vec2 diffFromEntryPoint = point - sprite.entryPoint;
        b2Vec2 diffFromExitPoint = point - sprite.exitPoint;
        
        if ((diffFromEntryPoint.x == 0 && diffFromEntryPoint.y == 0) || (diffFromExitPoint.x == 0 && diffFromExitPoint.y == 0))
        {
            
        }
        else
        {
            determinant = calculate_determinant_2x3 (sprite.entryPoint.x, sprite.entryPoint.y,
                                                     sprite.exitPoint.x, sprite.exitPoint.y,
                                                     point.x, point.y);
            
            if (determinant > 0)
            {
                sprite1Vertices[sprite1VertexCount++] = point;
            }
            else
            {
                sprite2Vertices[sprite2VertexCount++] = point;
            }
        }
    }
    
    sprite1VerticesSorted = [self arrangeVertices: sprite1Vertices count: sprite1VertexCount];
    sprite2VerticesSorted = [self arrangeVertices: sprite2Vertices count: sprite2VertexCount];
    
    BOOL sprite1VerticesAreAcceptable = [self areVerticesAcceptable: sprite1VerticesSorted count: sprite1VertexCount];
    BOOL sprite2VerticesAreAcceptable = [self areVerticesAcceptable: sprite2VerticesSorted count: sprite2VertexCount];
    
    if (sprite1VerticesAreAcceptable && sprite2VerticesAreAcceptable)
    {
        b2Body *body1 = [self createBodyWithPosition: sprite.body->GetPosition ()
                                            rotation: sprite.body->GetAngle ()
                                            vertices: sprite1VerticesSorted
                                         vertexCount: sprite1VertexCount
                                             density: originalFixture->GetDensity ()
                                            friction: originalFixture->GetFriction ()
                                         restitution: originalFixture->GetRestitution ()];
        newSprite1 = [PolygonSprite spriteWithTexture: sprite.texture body: body1 original: NO];
        [self addChild: newSprite1 z:1];
        
        b2Body *body2 = [self createBodyWithPosition: sprite.body->GetPosition ()
                                            rotation: sprite.body->GetAngle ()
                                            vertices: sprite2VerticesSorted
                                         vertexCount: sprite2VertexCount
                                             density: originalFixture->GetDensity ()
                                            friction: originalFixture->GetFriction ()
                                         restitution: originalFixture->GetRestitution()];
        newSprite2 = [PolygonSprite spriteWithTexture: sprite.texture body: body2 original: NO];
        [self addChild: newSprite2 z: 1];
        
        if (sprite.original)
        {
            [sprite deactivateCollisions];
            sprite.position = ccp (-256, -256);
            sprite.sliceEntered = NO;
            sprite.sliceExited = NO;
            sprite.entryPoint.SetZero ();
            sprite.exitPoint.SetZero ();
        }
        else
        {
            world->DestroyBody (sprite.body);
            [self removeChild: sprite cleanup: YES];
        }
    }
    else
    {
        sprite.sliceEntered = NO;
        sprite.sliceExited = NO;
    }
    
    free (sprite1VerticesSorted);
    free (sprite2VerticesSorted);
    free (sprite1Vertices);
    free (sprite2Vertices);
}

int comparator (const void *a, const void *b)
{
    const b2Vec2 *va = (const b2Vec2 *) a;
    const b2Vec2 *vb = (const b2Vec2 *) b;
    
    if (va->x > vb->x)
    {
        return 1;
    }
    else if (va->x < vb->x)
    {
        return -1;
    }
    
    return 0;
}

- (b2Body *) createBodyWithPosition: (b2Vec2) position rotation: (float) rotation vertices: (b2Vec2 *) vertices vertexCount: (int32) count density: (float) density friction: (float) friction restitution: (float) restitution
{
    b2BodyDef bodyDef;
    bodyDef.type = b2_dynamicBody;
    bodyDef.position = position;
    bodyDef.angle = rotation;
    b2Body *body = world->CreateBody (&bodyDef);
    
    b2FixtureDef fixtureDef;
    fixtureDef.density = density;
    fixtureDef.friction = friction;
    fixtureDef.restitution = restitution;
    
    b2PolygonShape shape;
    shape.Set (vertices, count);
    fixtureDef.shape = &shape;
    body->CreateFixture (&fixtureDef);
    
    return body;
}

- (b2Vec2 *) arrangeVertices: (b2Vec2 *) vertices count: (int) count
{
    float determinant;
    int iCounterClockwise = 1;
    int iClockwise = count - 1;
    int i;
    
    b2Vec2 referencePointA, referencePointB;
    b2Vec2 *sortedVertices = (b2Vec2 *) calloc (count, sizeof (b2Vec2));
    
    qsort (vertices, count, sizeof (b2Vec2), comparator);
    
    sortedVertices[0] = vertices[0];
    referencePointA = vertices[0];
    referencePointB = vertices[count - 1];
    
    for (i = 1; i < count - 1; ++i)
    {
        determinant = calculate_determinant_2x3 (referencePointA.x, referencePointA.y,
                                                 referencePointB.x, referencePointB.y,
                                                 vertices[i].x, vertices[i].y);
        
        if (determinant < 0)
        {
            sortedVertices[iCounterClockwise++] = vertices[i];
        }
        else
        {
            sortedVertices[iClockwise--] = vertices[i];
        }
    }
    
    sortedVertices[iCounterClockwise] = vertices[count - 1];
    
    return sortedVertices;
}

- (BOOL) areVerticesAcceptable: (b2Vec2 *) vertices count: (int) count
{
    if (count < 3)
    {
        NSLog (@"Not Acceptable: count < 3");
        return NO;
    }
    
    if (count > b2_maxPolygonVertices)
    {
        NSLog (@"Not Acceptable: count > maxVertices");
        return NO;
    }
    
    int32 i;
    for (i = 0; i < count; ++i)
    {
        int32 i1 = i;
        int32 i2 = i + 1 < count ? i + 1 : 0;
        b2Vec2 edge = vertices[i2] - vertices[i1];
        
        if (edge.LengthSquared() <= b2_epsilon * b2_epsilon)
        {
            NSLog (@"Not Acceptable: edge.LengthSquared <= b2_epsilon * b2_epsilon");
            return NO;
        }
    }
    
    float32 area = 0.f;
    b2Vec2 pRef(0.f, 0.f);
    
    for (i = 0; i < count; ++i)
    {
        b2Vec2 p1 = pRef;
        b2Vec2 p2 = vertices[i];
        b2Vec2 p3 = i + 1 < count ? vertices[i+1] : vertices[0];
        
        b2Vec2 e1 = p2 - p1;
        b2Vec2 e2 = p3 - p1;
        
        float32  D = b2Cross (e1, e2);
        
        float32 triangleArea = 0.5f * D;
        area += triangleArea;
    }
    
    if (area <= 0.0001)
    {
        NSLog (@"Not Acceptable: area <= 0.0001");
        return NO;
    }
    
    float determinant;
    float referenceDeterminant;
    b2Vec2 v1 = vertices[0] - vertices[count - 1];
    b2Vec2 v2 = vertices[1] - vertices[0];
    referenceDeterminant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
    
    for (i = 1; i < count - 1; ++i)
    {
        v1 = v2;
        v2 = vertices[i + 1] - vertices[i];
        determinant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
        
        if (referenceDeterminant * determinant < 0.f)
        {
            NSLog (@"Not Acceptable: not convex");
            return NO;
        }
    }
    
    v1 = v2;
    v2 = vertices[0] - vertices[count - 1];
    determinant = calculate_determinant_2x2(v1.x, v1.y, v2.x, v2.y);
    
    if (referenceDeterminant * determinant < 0.f)
    {
        NSLog (@"Not Acceptable: not convex");
        return NO;
    }
    
    return YES;
}

-(void) draw
{
	//
	// IMPORTANT:
	// This is only for debug purposes
	// It is recommend to disable it
	//
	[super draw];
	
	ccGLEnableVertexAttribs( kCCVertexAttribFlag_Position );
	
	kmGLPushMatrix();
    
    // DEBUG
    //ccDrawLine (_startPoint, _endPoint);
	//world->DrawDebugData();
	
	kmGLPopMatrix();
}

-(void) update: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	world->Step(dt, velocityIterations, positionIterations);
    
    [self checkAndSliceObjects];
}

- (void) ccTouchesBegan: (NSSet *) touches withEvent: (UIEvent *) event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        _startPoint = location;
        _endPoint = location;
    }
}

- (void) ccTouchesMoved: (NSSet *) touches withEvent: (UIEvent *) event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInView: [touch view]];
        location = [[CCDirector sharedDirector] convertToGL: location];
        _endPoint = location;
    }
    
    if (ccpLengthSQ (ccpSub (_startPoint, _endPoint)) > 25)
    {
        world->RayCast (_raycastCallback,
                        b2Vec2 (_startPoint.x / PTM_RATIO, _startPoint.y / PTM_RATIO),
                        b2Vec2 (_endPoint.x / PTM_RATIO, _endPoint.y / PTM_RATIO));
        
        world->RayCast (_raycastCallback,
                        b2Vec2 (_endPoint.x / PTM_RATIO, _endPoint.y / PTM_RATIO),
                        b2Vec2 (_startPoint.x / PTM_RATIO, _startPoint.y / PTM_RATIO));
        
        _startPoint = _endPoint;
    }
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	//Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
	}
    
    [self clearSlices];
}

#pragma mark GameKit delegate

-(void) achievementViewControllerDidFinish:(GKAchievementViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

-(void) leaderboardViewControllerDidFinish:(GKLeaderboardViewController *)viewController
{
	AppController *app = (AppController*) [[UIApplication sharedApplication] delegate];
	[[app navController] dismissModalViewControllerAnimated:YES];
}

@end
