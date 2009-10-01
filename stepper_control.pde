
long function_duration = 0;
axis axis_array[3];

void bzero(uint8_t *ptr, uint8_t len) {
  for (uint8_t i=0; i<len; i++) ptr[i] = 0;
}

void init_steppers(){
  //turn them off to start.
  disable_steppers();

  // setup data
  xaxis = &xaxis_data;
  yaxis = &yaxis_data;
  zaxis = &zaxis_data;

  axis_array[0] = xaxis;
  axis_array[1] = yaxis;
  axis_array[2] = zaxis;

  bzero((uint8_t*)&xaxis_data, sizeof(struct axis_t)); 
  bzero((uint8_t*)&yaxis_data, sizeof(struct axis_t)); 
  bzero((uint8_t*)&zaxis_data, sizeof(struct axis_t)); 

  //figure our stuff.
  calculate_deltas();
}

/*
 a->delta_units = a->target_units - a->current_units;
    a->delta_steps = to_steps(_units[i], abs(a->delta_units)); //XXX make x_units a vector
    */
    
// compute the ratio of motion for each axis based on longest movement
void set_stepRatio() {
int j;
  float maxstep = max(xaxis->delta_steps,max(yaxis->delta_steps,zaxis->delta_steps));
  for (int i=0;i<3;i++) {
    //axis_array[i]->steps_per_masterstep = axis_array[i]->delta_steps / maxstep;
    //axis_array[i]->incStep = 0;
    axis_array[i]->steps_per_masterstep = abs(_units[i]/maxstep * (axis_array[i]->target_units - axis_array[i]->current_units));
    axis_array[i]->incStep = 0;
    
j = axis_array[i]->delta_steps;
Serial.print(j,DEC);
j = maxstep;
Serial.print("/");
Serial.print(j,DEC);
j = axis_array[i]->steps_per_masterstep*100;
Serial.print("*100=");
Serial.println(j,DEC);

  }
}

// should this axis move on this round - also do housekeeping
bool query_pulse(axis a) {
  if (a->delta_steps == 0) return false;
  a->incStep += a->steps_per_masterstep;
  if (a->incStep >= 0.95) {
    a->incStep--;
    a->delta_steps--;
    return true;
  }  
  else return false;
}

void do_steps(uint8_t vector){
  if (vector & _BV(0)) digitalWrite(STEP_X, HIGH);
  if (vector & _BV(1)) digitalWrite(STEP_Y, HIGH);
  if (vector & _BV(2)) digitalWrite(STEP_Z, HIGH);
  delayMicroseconds(5);
  if (vector & _BV(0)) digitalWrite(STEP_X, LOW);
  if (vector & _BV(1)) digitalWrite(STEP_Y, LOW);
  if (vector & _BV(2)) digitalWrite(STEP_Z, LOW);
}


void dda_move(long micro_delay) {
  unsigned long starttime;
  uint8_t action_vector;

  div_t pause = div(micro_delay-function_duration, 1000);

  // Move axis as appropriate
  set_stepRatio(); //compute data for use by query_pulse()
  do {
    starttime = micros();

    action_vector = 0;
    for (int i=0; i<3; i++) {
      if (query_pulse(axis_array[i])) {
        action_vector |= _BV(i);
      }
    }
    if (action_vector) do_steps(action_vector);

    //delay
    function_duration = micros() - starttime; //to be subtracted out of delay for subsequent calls of dda_move()
    if (pause.quot) delay(pause.quot);			
    if (pause.rem)  delayMicroseconds(pause.rem);
  } 
  while (xaxis->delta_steps || yaxis->delta_steps || zaxis->delta_steps);

  // deal with potential rounding issue (XXX: not sure if there is an exact way to do this)
  action_vector = 0;
  if (xaxis->incStep > 0.5) action_vector = _BV(0);
  if (yaxis->incStep > 0.5) action_vector |= _BV(1);
  if (zaxis->incStep > 0.5) action_vector |= _BV(2);
  if (action_vector) do_steps(action_vector);
  if (pause.quot)    delay(pause.quot);			
  if (pause.rem)     delayMicroseconds(pause.rem);

  //we are at the target
  xaxis->current_units = xaxis->target_units;
  yaxis->current_units = yaxis->target_units;
  zaxis->current_units = zaxis->target_units;

  calculate_deltas();
}

void set_target(FloatPoint *fp){
  xaxis->target_units = fp->x;
  yaxis->target_units = fp->y;
  zaxis->target_units = fp->z;
  calculate_deltas();
}

void set_position(FloatPoint *fp){
  xaxis->current_units = fp->x;
  yaxis->current_units = fp->y;
  zaxis->current_units = fp->z;
  calculate_deltas();
}


long to_steps(float steps_per_unit, float units){
  return steps_per_unit * units;
}


void calculate_deltas() {
  //figure our deltas. 
  axis a;
  int i;
  for (i=0; i<3; i++) {
    a = axis_array[i];
    a->delta_units = a->target_units - a->current_units;
    a->delta_steps = to_steps(_units[i], abs(a->delta_units)); //XXX make x_units a vector
    a->direction = (a->delta_units < 0) ? BACKWARD : FORWARD;

    switch(i) {
    case 0: 
      digitalWrite(DIR_X, (a->direction==FORWARD) ? HIGH : LOW); 
      break;
    case 1: 
      digitalWrite(DIR_Y, (a->direction==FORWARD) ? HIGH : LOW); 
      break;
    case 2: 
      digitalWrite(DIR_Z, (a->direction==FORWARD) ? HIGH : LOW); 
      break;
    }
  }
}


long calculate_feedrate_delay(float feedrate){
  //how long is our line length?
  float distance    = sqrt(xaxis->delta_units*xaxis->delta_units + yaxis->delta_units*yaxis->delta_units + zaxis->delta_units*zaxis->delta_units);
  long master_steps = max(abs(xaxis->delta_steps), max(abs(yaxis->delta_steps), abs(zaxis->delta_steps)));

  //calculate delay between steps in microseconds.  this is sort of tricky, but not too bad.
  //the formula has been condensed to save space.  here it is in english:
  // distance / feedrate * 60000000.0 = move duration in microseconds
  // move duration / master_steps = time between steps for master axis.

  return ((distance * 60000000.0) / feedrate) / master_steps;	
}


long getMaxSpeed(){
  return (zaxis->delta_steps) ? calculate_feedrate_delay(FAST_Z_FEEDRATE) : calculate_feedrate_delay(FAST_XY_FEEDRATE);
}


