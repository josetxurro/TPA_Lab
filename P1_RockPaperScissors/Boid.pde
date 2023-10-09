// The Nature of Code
// Daniel Shiffman
// http://natureofcode.com

// Boid class
// Methods for Separation, Cohesion, Alignment added

class Boid {

  PVector location;
  PVector velocity;
  PVector acceleration;
  float r;
  float maxforce;    // Maximum steering force
  float maxspeed;    // Maximum speed
  float wandertheta = 0;
  int type;
  color colorType;

  Boid(float x, float y, boidType bt) {
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-1,1),random(-1,1));
    location = new PVector(x,y);
    r = 4.0;
    maxspeed = 3;
    maxforce = 0.05;
    
    switch(bt) {
      case ROCK:
        colorType = color(255, 0, 0);
        type = 0;
        break;
      case PAPER:
        colorType = color(0, 255, 0);
        type = 1;
        break;
      case SCISSORS:
        colorType = color(0, 0, 255);
        type = 2;
        break;
    }
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
    evaluate(boids);
    update();
    if (steering[7]) borders();
    else noBorders();
    obstacleAvoidance();
    render();
  }

  void applyForce(PVector force) {
    // We could add mass here if we want A = F / M
    acceleration.add(force);
  }
  
  void evaluate(ArrayList<Boid> boids) {
    for (Boid b : boids) {
      if (this.type != b.type && PVector.dist(location, b.location) < 200.0) pursueEvade(b);

      if (PVector.dist(location, b.location) < 10.0) rockPaperScissors(b);
      
    }
  }
  
  void pursueEvade(Boid b) {
    if (this.type == 0) {
      if (b.type == 1) {
        this.applyForce(evade(b));
      }
      else if (b.type == 2) {
        this.applyForce(pursue(b));
      }
    }
    else if (this.type == 1) {
      if (b.type == 0) {
        this.applyForce(pursue(b));
      }
      else if (b.type == 2) {
        this.applyForce(evade(b));
      }
    }
    else if (this.type == 2) {
      if (b.type == 0) {
        this.applyForce(evade(b));
      }
      else if (b.type == 1) {
        this.applyForce(pursue(b));
      }
    }
  }
  
  PVector pursue(Boid b) {
    PVector target = b.location.copy();
    PVector prediction = b.velocity.copy();
    prediction.mult(1.0);
    target.add(prediction);
    
    return this.seek(target);
  }
  
  PVector evade(Boid b) {
    PVector pursuit = this.pursue(b);
    pursuit.mult(-1);
    return pursuit;
  }
  
  
  void rockPaperScissors(Boid b) {    
    if (this.type == 0) {
      if (b.type == 1) {
        this.type = 1;
        numberType[0]--;
        numberType[1]++;
        this.colorType = color(0, 255, 0);
      }
      else if (b.type == 2) {
        b.type = 0;
        numberType[2]--;
        numberType[0]++;
        b.colorType = color(255, 0, 0);
      }
    }
    else if (this.type == 1) {
      if (b.type == 0) {
        b.type = 1;
        numberType[0]--;
        numberType[1]++;
        b.colorType = color(0, 255, 0);
      }                
      else if (b.type == 2) {
        this.type = 2;
        numberType[1]--;
        numberType[2]++;
        this.colorType = color(0, 0, 255);
      }
    }
    else if (this.type == 2) {
      if (b.type == 0) {
        this.type = 0;
        numberType[2]--;
        numberType[0]++;
        this.colorType = color(255, 0, 0);
      }
      else if (b.type == 1) {
        b.type = 2;
        numberType[1]--;
        numberType[2]++;
        b.colorType = color(0, 0, 255);
      }
    }
  }  

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    // 1. Separate
    // 2. Cohesion
    // 3. Align
    // 4. Seek
    // 6. Flee
    // 8. Borders
    if (steering[0]) {
      PVector sep = separate(boids);
      sep.mult(_wsep);
      applyForce(sep);
    }
    if (steering[1]) {
      PVector coh = cohesion(boids);
      coh.mult(_wcoh);
      applyForce(coh);
    }
    if (steering[2]) {
      PVector ali = align(boids);
      ali.mult(_wali);
      applyForce(ali);
    }
  }
  
  void obstacleAvoidance() {
    PVector ahead = velocity.copy().normalize().mult(10).add(location);
    for (Obstacle o : obstacles) {
      if (PVector.dist(ahead, o._s) < o._r + 20.0) {
        PVector avoidance = PVector.sub(ahead, o._s);
        avoidance.limit(maxforce);
        avoidance.mult(4.0);
        applyForce(avoidance);
      }
    }
  }

  // Method to update location
  void update() {
    // Update velocity
    velocity.add(acceleration);
    // Limit speed
    velocity.limit(maxspeed);
    location.add(velocity);
    // Reset accelertion to 0 each cycle
    acceleration.mult(0);
  }

  // A method that calculates and applies a steering force towards a target
  // STEER = DESIRED MINUS VELOCITY
  PVector seek(PVector target) {
    PVector desired = PVector.sub(target,location);  // A vector pointing from the location to the target
    // Normalize desired and scale to maximum speed
    desired.normalize();
    desired.mult(maxspeed);
    // Steering = Desired minus Velocity
    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);  // Limit to maximum steering force
    return steer;
  }
  
  PVector flee(PVector target) {
    if (PVector.dist(new PVector(mouseX, mouseY), location) < _fleer) {
      PVector desired = PVector.sub(location,target);  // A vector pointing from the location to the target
      // Normalize desired and scale to maximum speed
      desired.normalize();
      desired.mult(maxspeed);
      // Steering = Desired minus Velocity
      PVector steer = PVector.sub(desired,velocity);
      steer.limit(maxforce);  // Limit to maximum steering force
      return steer;
    }
    else 
      return new PVector();
  }
  
  void render() {
    // Draw a triangle rotated in the direction of velocity
    float theta = velocity.heading2D() + radians(90);
    fill(colorType);
    stroke(1);
    pushMatrix();
    translate(location.x,location.y);
    rotate(theta);
    beginShape(TRIANGLES);
    vertex(0, -r*2);
    vertex(-r, r*2);
    vertex(r, r*2);
    endShape();
    popMatrix();
  }

  // Wraparound
  void borders() {
    PVector desired = null;
    float d = 100;

    if (location.x < d) {
      desired = new PVector(maxspeed, velocity.y);
    } 
    else if (location.x > width -d) {
      desired = new PVector(-maxspeed, velocity.y);
    } 

    if (location.y < d) {
      desired = new PVector(velocity.x, maxspeed);
    } 
    else if (location.y > height-d) {
      desired = new PVector(velocity.x, -maxspeed);
    } 

    if (desired != null) {
      desired.normalize();
      desired.mult(maxspeed*5);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce);
      steer.mult(15);
      applyForce(steer);
    }
  }
  
  void noBorders() {
    if (location.x < -r) location.x = width+r;
    if (location.y < -r) location.y = height+r;
    if (location.x > width+r) location.x = -r;
    if (location.y > height+r) location.y = -r;
  }

  // Separation
  // Method checks for nearby boids and steers away
  PVector separate (ArrayList<Boid> boids) {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0,0,0);
    int count = 0;
    // For every boid in the system, check if it's too close
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      // If the distance is greater than 0 and less than an arbitrary amount (0 when you are yourself)
      if ((d > 0) && (d < desiredseparation)) {
        // Calculate vector pointing away from neighbor
        PVector diff = PVector.sub(location,other.location);
        diff.normalize();
        diff.div(d);        // Weight by distance
        steer.add(diff);
        count++;            // Keep track of how many
      }
    }
    // Average -- divide by how many
    if (count > 0) {
      steer.div((float)count);
    }

    // As long as the vector is greater than 0
    if (steer.mag() > 0) {
      // Implement Reynolds: Steering = Desired - Velocity
      steer.normalize();
      steer.mult(maxspeed);
      steer.sub(velocity);
      steer.limit(maxforce);
    }
    return steer;
  }

  // Alignment
  // For every nearby boid in the system, calculate the average velocity
  PVector align (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0,0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.velocity);
        count++;
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.normalize();
      sum.mult(maxspeed);
      PVector steer = PVector.sub(sum,velocity);
      steer.limit(maxforce);
      return steer;
    } else {
      return new PVector(0,0);
    }
  }

  // Cohesion
  // For the average location (i.e. center) of all nearby boids, calculate steering vector towards that location
  PVector cohesion (ArrayList<Boid> boids) {
    float neighbordist = 50;
    PVector sum = new PVector(0,0);   // Start with empty vector to accumulate all locations
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(location,other.location);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.location); // Add location
        count++;
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);  // Steer towards the location
    } else {
      return new PVector(0,0);
    }
  }
}
