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
  uint8_t step_pin;
  uint8_t min_pin;
  uint8_t max_pin;
  float current_units;
  float target_units;
  float delta_units;
  uint32_t delta_steps;
  uint16_t timePerStep;
  uint32_t stepCount;
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
#define disable_steppers() digitalWrite(ENABLE, HIGH)
#define enable_steppers()  digitalWrite(ENABLE, LOW)



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
#define STEP_X 11
#define STEP_Y 9
#define STEP_Z 10
#define DIR_X 12
#define DIR_Y 8
#define DIR_Z 13

// specify min-max sense pins or 0 if not used
// specify if the pin is to to detect a switch closing when
// the signal is high using the syntax
// #define MIN_X 12 | ACTIVE_HIGH
// or to sense a low signal (preferred!!!)
// #define MIN_Y 13 | ACTIVE_LOW
// active low is prefered as it will cause the AVR to use it's internal pullups to 
// avoid bounce on the line.  If you want active_high, then you must add external pulldowns
// to avoid false signals.
#define ACTIVE_HIGH _BV(7)
#define ACTIVE_LOW  _BV(6)
#define MIN_X 0
#define MAX_X 0
#define MIN_Y 0
#define MAX_Y 0
#define MIN_Z 0
#define MAX_Z 0

//state machine
#define full 1
#define half 2
#define quarter 3
#define eighth 4
#define sixteenth 5




#endif
