// Steering behaviours (TPA) Jose Luis Pascual Sánchez
// Rock, paper, scissors!

Flock flock;
PVector centro;
float radio;
boolean dibujando = false;
boidType rock = boidType.ROCK;
boidType paper = boidType.PAPER;
boidType scissors = boidType.SCISSORS;
boidType add;

void setup() {
  size(1500,1000);
  flock = new Flock();
  centro = new PVector();
  add = rock;
  
  
  // Add an initial set of boids into the system
  /*
  for (int i = 0; i < 100; i++) {
    Boid b = new Boid(width/4,height/4, rock);
    flock.addBoid(b);
  }
  
  for (int i = 0; i < 100; i++) {
    Boid b = new Boid(width/2,height/2, paper);
    flock.addBoid(b);
  }
  
  for (int i = 0; i < 100; i++) {
    Boid b = new Boid(3*width/4, 3*height/4, scissors);
    flock.addBoid(b);
  }
  */
  
  for (int i = 0; i < 100; i++) {
    Boid b = new Boid(random(width),random(height), rock);
    flock.addBoid(b);
  }
  
  for (int i = 0; i < 100; i++) {
    Boid b = new Boid(random(width),random(height), paper);
    flock.addBoid(b);
  }
  
  for (int i = 0; i < 100; i++) {
    Boid b = new Boid(random(width),random(height), scissors);
    flock.addBoid(b);
  }
  
  smooth();
}

void restart() {
  setup();
}

void draw() {

  background(255);
  
  
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
  if (keyCode == BACKSPACE) obstacles.clear();
 
  // ROCK PAPER SCISSORS
  if ((key == 'z' || key == 'Z')) add = rock;
  if ((key == 'x' || key == 'X')) add = paper;
  if ((key == 'c' || key == 'C')) add = scissors;
  
  if (key == 'k')
    restart();
}

void mousePressed() { 
  if (mouseButton == LEFT) {
    centro.set(mouseX, mouseY);
    dibujando = true;
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
      text("ROCK, PAPER, SCISSORS!", width*0.015, height*0.065);
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
      
      if (steering[7]) fill(208, 0, 0);
      else fill(0);
      text("8. Borders", width*0.015, height*0.3);
      
      
      if (obstacles.size() > 0) fill(208, 0, 0);
      else fill(0);
      text("10. Obstacle avoidance - radius(left click)", width*0.015, height*0.4);
      text("       Number of obstacles:" + obstacles.size(), width*0.015, height*0.425);
      
      fill(255, 0, 0);
      if (add == rock) {
        text("* Rock (X): " + numberType[0], width*0.015, height-(height*0.035)-50);
      } else {
        text("Rock (X): " + numberType[0], width*0.015, height-(height*0.035)-50);
      }
      
      fill(0, 255, 0);
      if (add == paper) {
        text("* Paper (Z): " + numberType[1], width*0.015, height-(height*0.035)-25);
      } else {
        text("Paper (Z): " + numberType[1], width*0.015, height-(height*0.035)-25);
      }
      
      fill(0, 0, 255);
      if (add == scissors) {
        text("* Scissors (C): " + numberType[2], width*0.015, height-(height*0.035));
      } else {
        text("Scissors (C): " + numberType[2], width*0.015, height-(height*0.035));
      }
   }
   popMatrix();
}

// Add a new boid into the System
void mouseDragged() {
  if (!dibujando && mouseButton == RIGHT) flock.addBoid(new Boid(mouseX,mouseY, add));
}
