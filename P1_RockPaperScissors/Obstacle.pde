class Obstacle {
  float _x;
  float _y;
  float _r;
  PVector _s;
  
  Obstacle(float x, float y, float r) {
    _x = x;
    _y = y;
    _r = r;
    _s = new PVector(_x, _y);
  }
  
  void display() {
    fill(200);
    stroke(0);
    ellipse(_x, _y, _r*2, _r*2);
  }
}
