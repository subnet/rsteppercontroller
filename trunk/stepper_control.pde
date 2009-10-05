


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

  xaxis->step_pin = STEP_X;
  yaxis->step_pin = STEP_Y;
  zaxis->step_pin = STEP_Z;
  
  //figure our stuff.
  calculate_deltas();
}




//a motion is composed of a number of steps that take place
//over a length of time.  a slice of time is the total time
//divided by the number of steps.  We step when the the 
//timeIntoSlice >= .5*timePerStep.  we don't take 
//extra steps by keeping track of when we step.  only
//when the timeIntoSlice becomes a smaller number 
void dda_move(float feedrate) {
  long starttime,time,duration;
  float distance;
  uint16_t timeIntoSlice;
  axis a;
  uint8_t i;

  // distance / feedrate * 60000000.0 = move duration in microseconds
  distance = sqrt(xaxis->delta_units*xaxis->delta_units + 
    yaxis->delta_units*yaxis->delta_units + 
    zaxis->delta_units*zaxis->delta_units);
  duration = ((distance * 60000000.0) / feedrate);	

  // setup axis
  for (i=0;i<3;i++) {
    a = axis_array[i];
    a->timePerStep = duration / axis_array[i]->delta_steps;
    a->stepped = false;
    a->oldTimeIntoSlice = 0;
  }
  starttime = micros();
  // start move
  while (xaxis->delta_steps || yaxis->delta_steps || zaxis->delta_steps) {
    time = micros() - starttime;
    for (i=0; i<3; i++) {
      a = axis_array[i];
      // find out how far into the time segment we are in microsecods 
      timeIntoSlice = (time%a->timePerStep);
      // clear the step when we ener a new timeslice
      if (timeIntoSlice < a->oldTimeIntoSlice) {
        a->stepped = false;
      }
      a->oldTimeIntoSlice = timeIntoSlice;

      //check if we need to step, and step (timeIntoSlice >= timePerStep/2)
      if (!a->stepped && (timeIntoSlice >= ((a->timePerStep)>>1))) {
        digitalWrite(a->step_pin, HIGH);
        digitalWrite(a->step_pin, LOW);
        a->stepped = true;
        a->delta_steps--;
      }
    }
  }


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

long getMaxFeedrate(){
  return (zaxis->delta_steps) ? FAST_Z_FEEDRATE : FAST_XY_FEEDRATE;
}


