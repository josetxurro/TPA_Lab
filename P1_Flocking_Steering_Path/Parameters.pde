// 1. Separate
// 2. Cohesion
// 3. Align3
// 4. Seek
// 5. Arrive
// 6. Flee
// 7. Wanders
// 8. Borders
// 9. Follow the path
// 10. Obstacle avoidance
final boolean [] steering = {false, false, false, false, false, false, false, false, false, false};

ArrayList<Obstacle> obstacles = new ArrayList<Obstacle>();
float _wsep = 3.0;
float _wcoh = 1.0;
float _wali = 1.0;
float _wsee = 1.0;
float _warr = 1.0;
float _wfle = 1.0;
float _wwan = 1.0;
float _wpat = 1.0;

float _radius = 20;
float _fleer = 50;
