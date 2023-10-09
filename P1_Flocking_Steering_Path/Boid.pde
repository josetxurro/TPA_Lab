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

  Boid(float x, float y) {
    acceleration = new PVector(0,0);
    velocity = new PVector(random(-1,1),random(-1,1));
    location = new PVector(x,y);
    r = 3.0;
    maxspeed = 3;
    maxforce = 0.05;
  }

  void run(ArrayList<Boid> boids) {
    flock(boids);
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

  // We accumulate a new acceleration each time based on three rules
  void flock(ArrayList<Boid> boids) {
    // 1. Separate
    // 2. Cohesion
    // 3. Align
    // 4. Seek
    // 5. Arrive
    // 6. Flee
    // 7. Wanders
    // 8. Borders
    // 9. Follow the path
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
    if (steering[3]) {
      PVector see = seek(new PVector(mouseX, mouseY));
      see.mult(_wsee);
      applyForce(see);
    }
    if (steering[4]) {
      PVector arr = arrive(new PVector(mouseX, mouseY));
      arr.mult(_warr);
      applyForce(arr);
    }
    if (steering[5]) {
      PVector fle = flee(new PVector(mouseX, mouseY));
      fle.mult(_wfle);
      applyForce(fle);
    }
    if (steering[6]) {
      PVector wan = wander();
      wan.mult(_wwan);
      applyForce(wan);
    }
    if (steering[8] && path.points.size() >= 3) {
      PVector pat = follow(path);
      pat.mult(_wpat);
      applyForce(pat);
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
  
  PVector follow(Path p) {
    // Predict location 25 (arbitrary choice) frames ahead
    PVector predict = velocity.copy();
    predict.normalize();
    predict.mult(25);
    PVector predictLoc = PVector.add(location, predict);

    // Now we must find the normal to the path from the predicted location
    // We look at the normal for each line segment and pick out the closest one
    PVector normal = null;
    PVector target = null;
    float worldRecord = 1000000;  // Start with a very high worldRecord distance that can easily be beaten

    // Loop through all points of the path
    for (int i = 0; i < p.points.size(); i++) {

      // Look at a line segment
      PVector a = p.points.get(i);
      PVector b = p.points.get((i+1)%p.points.size()); // Note Path has to wraparound

      // Get the normal point to that line
      PVector normalPoint = getNormalPoint(predictLoc, a, b);

      // Check if normal is on line segment
      PVector dir = PVector.sub(b, a);
      // If it's not within the line segment, consider the normal to just be the end of the line segment (point b)
      //if (da + db > line.mag()+1) {
      if (normalPoint.x < min(a.x,b.x) || normalPoint.x > max(a.x,b.x) || normalPoint.y < min(a.y,b.y) || normalPoint.y > max(a.y,b.y)) {
        normalPoint = b.copy();
        // If we're at the end we really want the next line segment for looking ahead
        a = p.points.get((i+1)%p.points.size());
        b = p.points.get((i+2)%p.points.size());  // Path wraps around
        dir = PVector.sub(b, a);
      }

      // How far away are we from the path?
      float d = PVector.dist(predictLoc, normalPoint);
      // Did we beat the worldRecord and find the closest line segment?
      if (d < worldRecord) {
        worldRecord = d;
        normal = normalPoint;
        
        // Look at the direction of the line segment so we can seek a little bit ahead of the normal
        dir.normalize();
        // This is an oversimplification
        // Should be based on distance to path & velocity
        dir.mult(25);
        target = normal.copy();
        target.add(dir);
        
      }
    }

    // Only if the distance is greater than the path's radius do we bother to steer
    if (worldRecord > _radius) {
      return seek(target);
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  PVector getNormalPoint(PVector p, PVector a, PVector b) {
    // Vector from a to p
    PVector ap = PVector.sub(p, a);
    // Vector from a to b
    PVector ab = PVector.sub(b, a);
    ab.normalize(); // Normalize the line
    // Project vector "diff" onto line by using the dot product
    ab.mult(ap.dot(ab));
    PVector normalPoint = PVector.add(a, ab);
    return normalPoint;
  }
  
  PVector wander() {
    float wanderR = 25;         // Radius for our "wander circle"
    float wanderD = 80;         // Distance for our "wander circle"
    float change = 0.3;
    wandertheta += random(-change,change);     // Randomly change wander theta

    // Now we have to calculate the new location to steer towards on the wander circle
    PVector circleloc = velocity.get();    // Start with velocity
    circleloc.normalize();            // Normalize to get heading
    circleloc.mult(wanderD);          // Multiply by distance
    circleloc.add(location);               // Make it relative to boid's location
    
    float h = velocity.heading2D();        // We need to know the heading to offset wandertheta

    PVector circleOffSet = new PVector(wanderR*cos(wandertheta+h),wanderR*sin(wandertheta+h));
    PVector target = PVector.add(circleloc,circleOffSet);
    return seek(target);
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
  
  PVector arrive(PVector target) {
    PVector desired = PVector.sub(target,location);

    float d = desired.mag();
    desired.normalize();
    if (d < 100) {
      float m = map(d,0,100,0,maxspeed);
      desired.mult(m);
    } else {
      desired.mult(maxspeed);
    }

    PVector steer = PVector.sub(desired,velocity);
    steer.limit(maxforce);
    
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
    fill(175);
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
    float d = 80;

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
      desired.mult(maxspeed);
      PVector steer = PVector.sub(desired, velocity);
      steer.limit(maxforce*3);
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
