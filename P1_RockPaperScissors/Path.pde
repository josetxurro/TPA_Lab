class Path {

  // A Path is an arraylist of points (PVector objects)
  ArrayList<PVector> points;

  Path() {
    // Arbitrary radius of 20
    points = new ArrayList<PVector>();
  }

  // Add a point to the path
  void addPoint(float x, float y) {
    PVector point = new PVector(x, y);
    points.add(point);
  }

  // Draw the path
  void display() {
    strokeJoin(ROUND);
    
    // Draw thick line for radius
    stroke(175);
    strokeWeight(_radius*2);
    noFill();
    beginShape();
    for (PVector v : points) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
    // Draw thin line for center of path
    stroke(0);
    strokeWeight(1);
    noFill();
    beginShape();
    for (PVector v : points) {
      vertex(v.x, v.y);
    }
    endShape(CLOSE);
  }
}
