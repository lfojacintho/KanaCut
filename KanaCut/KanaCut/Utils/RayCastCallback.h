//
//  RayCastCallback.h
//  KanaCut
//
//  Created by Luis Jacintho on 11/19/13.
//  Copyright (c) 2013 Publius Tecnologia. All rights reserved.
//

#ifndef KanaCut_RayCastCallback_h
#define KanaCut_RayCastCallback_h

#import "Box2D.h"
#import "PolygonSprite.h"

#define collinear(x1,y1,x2,y2,x3,y3) fabsf((y1-y2) * (x1-x3) - (y1-y3) * (x1-x2))

class RayCastCallback : public b2RayCastCallback
{
    public:
    RayCastCallback () {}

    float32 ReportFixture (b2Fixture *fixture, const b2Vec2 &point, const b2Vec2 &normal, float32 fraction)
    {
        PolygonSprite *ps = (PolygonSprite *) fixture->GetBody ()->GetUserData ();
        
        if (!ps.sliceEntered)
        {
            ps.sliceEntered = YES;
            ps.entryPoint = ps.body->GetLocalPoint (point);
            ps.sliceEntryTime = CACurrentMediaTime () + 1;
        }
        else if (!ps.sliceExited)
        {
            ps.exitPoint = ps.body->GetLocalPoint (point);
            
            b2Vec2 entrySide = ps.entryPoint - ps.centroid;
            b2Vec2 exitSide = ps.exitPoint - ps.centroid;
            
            if (entrySide.x * exitSide.x < 0 || entrySide.y * exitSide.y < 0)
            {
                ps.sliceExited = YES;
            }
            else
            {
                b2Fixture *fixture = ps.body->GetFixtureList ();
                b2PolygonShape *polygon = (b2PolygonShape *) fixture->GetShape ();
                int count = polygon->GetVertexCount ();
                
                BOOL onSameLine = NO;
                for (int i = 0; i < count; ++i)
                {
                    b2Vec2 pointA = polygon->GetVertex (i);
                    b2Vec2 pointB;
                    
                    if (i == count - 1)
                    {
                        pointB = polygon->GetVertex (0);
                    }
                    else
                    {
                        pointB = polygon->GetVertex (i + 1);
                    }
                    
                    float collinear = collinear (pointA.x, pointA.y, ps.entryPoint.x, ps.entryPoint.y, pointB.x, pointB.y);
                    
                    if (collinear <= 0.00001)
                    {
                        float collinear2 = collinear (pointA.x, pointA.y, ps.exitPoint.x, ps.exitPoint.y, pointB.x, pointB.y);
                        
                        if (collinear2 <= 0.00001)
                        {
                            onSameLine = YES;
                        }
                        
                        break;
                    }
                }
                
                if (onSameLine)
                {
                    ps.entryPoint = ps.exitPoint;
                    ps.sliceEntryTime = CACurrentMediaTime () + 1;
                    ps.sliceExited = NO;
                }
                else
                {
                    ps.sliceExited = YES;
                }
            }
        }
        
        return 1;
    }
};

#endif
