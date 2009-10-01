#ifndef _INIT_
#define _INIT_


#define MAX_COMMANDS 8 //max arguments on one line
#define COMMAND_SIZE 64 //max length of input command

struct command_t {
	uint8_t type; //i.e. G or M
	double  value; //string value associated
	//struct command_t *next;
};
typedef struct command_t *command;

struct FloatPoint {
  float x;
  float y;
  float z;
};
FloatPoint zeros = {0.0,0.0,0.0};

struct axis_t {
  float current_units;
  float target_units;
  float delta_units;
  float delta_steps;
  uint16_t timePerStep;
  uint16_t oldTimeIntoSlice;
  bool stepped;
  int8_t direction; //FORWARD or BACKWARD
};
typedef struct axis_t *axis;

#define FORWARD 1
#define BACKWARD -1

//misc util functions
#define SBI(port,pin) port |= _BV(pin);
#define CBI(port,pin) port &= ~_BV(pin);
#define error(x) Serial.println(x)
#define debug(x) Serial.println(x)
#define debug2(x,y) Serial.print(x);Serial.println(y)
#define debug3(x,y,z) Serial.print(x);Serial.println(y,z)
#define disable_steppers() digitalWrite(ENABLE, LOW)
#define enable_steppers()  digitalWrite(ENABLE, HIGH);delay(500);



// define the parameters of our machine.
#define X_STEPS_PER_INCH 416.772354
#define X_STEPS_PER_MM   16.4083604
#define X_MOTOR_STEPS    400

#define Y_STEPS_PER_INCH 416.772354
#define Y_STEPS_PER_MM   16.4083604
#define Y_MOTOR_STEPS    400

#define Z_STEPS_PER_INCH 416.772354
#define Z_STEPS_PER_MM   16.4083604
#define Z_MOTOR_STEPS    400

//our maximum feedrates
#define FAST_XY_FEEDRATE 1000.0
#define FAST_Z_FEEDRATE  50.0

// Units in curve section
#define CURVE_SECTION_INCHES 0.019685
#define CURVE_SECTION_MM 0.5



/****************************************************************************************
* digital i/o pin assignment

****************************************************************************************/
//my config
#define ENABLE 7 //low enabled
#define MS1  6
#define MS2 5
#define MS3 2
#define RST 3 
#define SLP 3
#define STEP_X 12
#define STEP_Y 8
#define STEP_Z 13
#define DIR_X 11
#define DIR_Y 9
#define DIR_Z 10
//state machine
#define full 1
#define half 2
#define quarter 3
#define eighth 4
#define sixteenth 5

//cartesian bot pins
#define X_STEP_PIN STEP_X
#define X_DIR_PIN DIR_X
#define Y_STEP_PIN STEP_Y
#define Y_DIR_PIN DIR_Y
#define Z_STEP_PIN STEP_Z
#define Z_DIR_PIN DIR_Z



#endif
