// Steering behaviours (TPA) Jose Luis Pascual Sánchez

Flock flock;
Path path;
PVector centro;
float radio;
boolean dibujando = false;


void setup() {
  size(1500,1000);
  flock = new Flock();
  path = new Path();
  centro = new PVector();
  // Add an initial set of boids into the system
  for (int i = 0; i < 300; i++) {
    Boid b = new Boid(width/2,height/2);
    flock.addBoid(b);
  }
  smooth();
}

void draw() {

  background(255);
  
  if (steering[8]) path.display();
  
  if (steering[5]) {
    noFill();
    ellipse(mouseX, mouseY, _fleer, _fleer);
  }
  
  if (dibujando) {
    PVector actual = new PVector(mouseX, mouseY);
    float d = PVector.dist(centro, actual);
    
    stroke(0);
    line(centro.x, centro.y, mouseX, mouseY);
    
    noFill();
    ellipse(centro.x, centro.y, d*2, d*2);
  }
  
  for (Obstacle b : obstacles)
    b.display();
    
  flock.run();
  
  // Instructions
  fill(0);
  displayInfo();
}

void keyPressed() {
  if (key == '1') steering[0] = !steering[0];
  if (key == '2') steering[1] = !steering[1];
  if (key == '3') steering[2] = !steering[2];
  if (key == '4') steering[3] = !steering[3];
  if (key == '5') steering[4] = !steering[4];
  if (key == '6') steering[5] = !steering[5];
  if (key == '7') steering[6] = !steering[6];
  if (key == '8') steering[7] = !steering[7];
  if (key == '9') {
    steering[8] = !steering[8];
    path.points.clear();
  }

   
  if ((key == 'q' || key == 'Q') && steering[0]) _wsep += 0.1;
  if ((key == 'a' || key == 'A') && steering[0] && _wsep > 0.000001) _wsep -= 0.1;
  
  if ((key == 'w' || key == 'W') && steering[1]) _wcoh += 0.1;
  if ((key == 's' || key == 'S') && steering[1] && _wcoh > 0.1) _wcoh -= 0.1;
  
  if ((key == 'e' || key == 'E') && steering[2]) _wali += 0.1;
  if ((key == 'd' || key == 'D') && steering[2] && _wali > 0.1) _wali -= 0.1;
  
  if ((key == 'r' || key == 'R') && steering[3]) _wsee += 0.1;
  if ((key == 'f' || key == 'F') && steering[3] && _wsee > 0.1) _wsee -= 0.1;
  
  if ((key == 't' || key == 'T') && steering[4]) _warr += 0.1;
  if ((key == 'g' || key == 'G') && steering[4] && _warr > 0.1) _warr -= 0.1;
  
  if ((key == 'y' || key == 'Y') && steering[5]) _wfle += 0.1;
  if ((key == 'h' || key == 'H') && steering[5] && _wfle > 0.1) _wfle -= 0.1;
  
  if ((key == 'u' || key == 'U') && steering[6]) _wwan += 0.1;
  if ((key == 'j' || key == 'J') && steering[6] && _wwan > 0.1) _wwan -= 0.1;
  
  if ((key == 'o' || key == 'O') && steering[8]) _wpat += 0.1;
  if ((key == 'l' || key == 'L') && steering[8] && _wpat > 0.1) _wwan -= 0.1;
  
  if (keyCode == UP) _radius += 5.0;
  if (keyCode == DOWN && _radius > 0.99) _radius -= 5.0;
  
  if (keyCode == RIGHT) _fleer += 5.0;
  if (keyCode == LEFT && _fleer > 50) _fleer -= 5.0;
  if (keyCode == TAB && steering[8]) path.points.clear();
  if (keyCode == BACKSPACE) obstacles.clear();
}

void mousePressed() { 
  if (mouseButton == LEFT) {
    centro.set(mouseX, mouseY);
    dibujando = true;
  }
  
  if (mouseButton == CENTER && steering[8]) {
    path.addPoint(mouseX, mouseY);
  }
}

void mouseReleased() {
  if (dibujando) {
    radio = PVector.dist(centro, new PVector(mouseX, mouseY));
    
    if (radio > 10) obstacles.add(new Obstacle(centro.x, centro.y, radio));
    dibujando = false;
  }
}

// 1. Separate
// 2. Cohesion
// 3. Align
// 4. Seek
// 5. Arrive
// 6. Flee
// 7. Wanders
// 8. Borders
// 9. Follow the path
// 10. Obstacle avoidance
void displayInfo() {
  pushMatrix();
   {
      fill(0);
      textSize(25);
      text("STEERING BEHAVIOURS (Técnicas de Animación Procedural)", width*0.015, height*0.035);
      textAlign(RIGHT);
      text("Jose Luis Pascual Sánchez", width - 20, height*0.035);
      
      textSize(15);
      textAlign(LEFT);
      if (steering[0]) fill(208, 0, 0);
      else fill(0);
      text("1. Separate - weight(+q, -a): " + _wsep, width*0.015, height*0.1);
      
      if (steering[1]) fill(208, 0, 0);
      else fill(0);
      text("2. Cohesion - weight(+w, -s): " + _wcoh, width*0.015, height*0.125);
      
      if (steering[2]) fill(208, 0, 0);
      else fill(0);
      text("3. Align - weight(+e, -d): " + _wali, width*0.015, height*0.15);
      
      if (steering[3]) fill(208, 0, 0);
      else fill(0);
      text("4. Seek - weight(+r, -f): " + _wsee, width*0.015, height*0.175);
      
      if (steering[4]) fill(208, 0, 0);
      else fill(0);
      text("5. Arrive - weight(+t, -g): " + _warr, width*0.015, height*0.2);
      
      if (steering[5]) fill(208, 0, 0);
      else fill(0);
      text("6. Flee - weight(+y, -h): " + _wfle, width*0.015, height*0.225);
      text("     Flee radius (+rightArrow, -leftArrow): " + _fleer, width*0.015, height*0.25);
      
      if (steering[6]) fill(208, 0, 0);
      else fill(0);
      text("7. Wander - weight(+u, -j): " + _wwan, width*0.015, height*0.275);
      
      if (steering[7]) fill(208, 0, 0);
      else fill(0);
      text("8. Borders", width*0.015, height*0.3);
      
      if (steering[8]) fill(208, 0, 0);
      else fill(0);
      text("9. Follow the path - weight(+o, -l):" + _wpat, width*0.015, height*0.325);   
      text("     Number of points: " + path.points.size() , width*0.015, height*0.35);
      text("     Path radius (+upArrow, -downArrow): " + _radius , width*0.015, height*0.375);
      
      if (obstacles.size() > 0) fill(208, 0, 0);
      else fill(0);
      text("10. Obstacle avoidance - radius(left click)", width*0.015, height*0.4);
      text("       Number of obstacles:" + obstacles.size(), width*0.015, height*0.425);
   }
   popMatrix();
}

// Add a new boid into the System
void mouseDragged() {
  if (!dibujando && mouseButton == RIGHT) flock.addBoid(new Boid(mouseX,mouseY));
}
