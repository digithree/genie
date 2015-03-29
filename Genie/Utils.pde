
color getColour( float col ) {
  if( col < 0.25 ) {
    return color( 255 - ((col*4)*255), 128, ((col*4)*255) );
  } else if( col < 0.5 ) {
    return color( 0, 128 + (((col-0.25)*4)*128), 255 - (((col-0.25)*4)*255) );
  } else if( col < 0.75 ) {
    return color( ((col-0.5)*255), 128 + (((col-0.5)*4)*128), 0 );
  }
  // else
  return color( 255, 255 - (((col-0.75)*4)*255), 0 );
}


float SHAPE_MAX_POINTS = 20;

float SHAPE_MAX_SIZE = 50;
float SHAPE_MIN_SIZE = 5;

void drawShape( Genome g, float x, float y, PVector facing ) {
  int shapePoints = (int)(SHAPE_MAX_POINTS - (g.normal[GENOME_SHAPE] * (SHAPE_MAX_POINTS-3.f)));
  float realSize = g.getRealSize();
  boolean spikey;
  ArrayList<Integer> makeLonger = new ArrayList<Integer>();
  if( shapePoints % 2 == 0 ) {
    makeLonger.add( new Integer(shapePoints/2) );
  }
  if( shapePoints % 3 == 0 ) {
    makeLonger.add( new Integer(shapePoints/3) );
    makeLonger.add( new Integer((shapePoints/3)*2) );
  }
  if( shapePoints % 4 == 0 ) {
    makeLonger.add( new Integer(shapePoints/4) );
    makeLonger.add( new Integer((shapePoints/4)*3) );
  }
    
  if( shapePoints % 2 == 0 && shapePoints > 4 ) {
    spikey = true;
  } else {
    spikey = false;
  }
  float theta = TWO_PI/shapePoints;
  
  PVector curPoint = new PVector(facing.x,facing.y);
  strokeWeight(1);
  beginShape();
  for( int i = 0 ; i < shapePoints ; i++ ) {
    if( i == 0 ) { 
      vertex( (curPoint.x * (realSize*(1+g.normal[GENOME_VISION])))+x, (curPoint.y * (realSize*(1+g.normal[GENOME_VISION])))+y );
    } else if( spikey ) {
      boolean madeLonger = false;
      for( Integer j : makeLonger ) {
        if( j.intValue() == i ) {
          vertex( (curPoint.x * (realSize+0.5) * g.normal[GENOME_SPEED])+x, (curPoint.y * (realSize+0.5) * g.normal[GENOME_SPEED])+y );
          madeLonger = true;
          break;
        }
      }
      if( !madeLonger ) {
        if( i % 2 == 0 ) {
          vertex( (curPoint.x * realSize)+x, (curPoint.y * realSize)+y );
        } else {
          vertex( (curPoint.x * (realSize*0.6))+x, (curPoint.y * (realSize*0.6))+y );
        }
      }
    } else {
      boolean madeLonger = false;
      for( Integer j : makeLonger ) {
        if( j.intValue() == i ) {
          vertex( (curPoint.x * (realSize+0.5) * g.normal[GENOME_SPEED])+x, (curPoint.y * (realSize+0.5) * g.normal[GENOME_SPEED])+y );
          madeLonger = true;
          break;
        }
      }
      if( !madeLonger ) {
        vertex( (curPoint.x * realSize)+x, (curPoint.y * realSize)+y );
      }
    }
    curPoint.rotate(theta);
  }
  vertex( (curPoint.x * (realSize*(1+g.normal[GENOME_VISION])))+x, (curPoint.y * (realSize*(1+g.normal[GENOME_VISION])))+y );
  endShape();
}
