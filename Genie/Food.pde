float FOOD_REAL_VALUE_FACTOR = 0.3;

class Food {
  PVector pos;
  float value;
  
  Food() {
    pos = new PVector( random(WORLD_WIDTH), random(WORLD_HEIGHT) );
    value = random(1);
  }
  
  Food( PVector _pos, float _value ) {
    pos = new PVector( _pos.x, _pos.y );
    value = _value;
  }
  
  void draw() {
    fill(0,200,200);
    noStroke();
    ellipse(pos.x,pos.y,value*20,value*20);
  }
  
  float getRealValue() {
    return value * FOOD_REAL_VALUE_FACTOR;
  }
}
