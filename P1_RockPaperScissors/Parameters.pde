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
final boolean [] steering = {true, true, true, false, false, false, false, true, false, false};

ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
float _wsep = 3.0;
float _wcoh = 1.0;
float _wali = 1.0;
float _wsee = 3.0;
float _warr = 1.0;
float _wfle = 3.0;
float _wwan = 1.0;
float _wpat = 1.0;

float _radius = 20;
float _fleer = 50;

// ROCK PAPER SCISSORS
enum boidType {
  ROCK,
  PAPER,
  SCISSORS
}

int [] numberType = {0, 0, 0};
