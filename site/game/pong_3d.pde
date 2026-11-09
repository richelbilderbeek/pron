import processing.serial.*;

import ddf.minim.*;
AudioPlayer player;
Minim minim;//audio context

//import processing.sound.*;
//SoundFile file;

// Arena is 500 x 500 x 500
// Center of the arena is (0, 0, 0)
final float speed_z = 0.0;
//final float speed_z = 0.001;

final float player1_r = 50;
final float player2_r = 50;
final float bal_r = 50.0;
final float minx = -500.0;
final float maxx =  500.0;
final float miny = -250.0;
final float maxy =  250.0;

final float bal_x = 0.0;
final float bal_y = 0.0;
final float bal_dx = 5.0;
final float bal_dy = 0.1;
final float player1_x = minx + (1.0 * player1_r);
final float player1_y = 0.0;
final float player1_dy = 0.0;
final float player2_x = maxx - (1.0 * player2_r);
final float player2_y = 0.0;
final float player2_dy = 0.0;
final float text_size = 128;
float hoek_z = 0.0;
int score1 = 0;
int score2 = 0;

Ball player_1 = new Ball(
  new PVector(player1_x, player1_y), 
  new PVector(0.0, 0.0), 
  player1_r);

Ball player_2 = new Ball(
  new PVector(player2_x, player2_y), 
  new PVector(0.0, 0.0), 
  player2_r);

Ball bal = new Ball(
  new PVector(bal_x, bal_y), 
  new PVector(bal_dx, bal_dy), 
  bal_r);

Serial serial_port;



/// standalone means without Arduino
final boolean standalone = true;

void setup()
{
  fullScreen(P3D);
  textSize(text_size);
  if (!standalone)
  {
    serial_port = new Serial(this, Serial.list()[0], 9600);
  }

  minim = new Minim(this);
  player = minim.loadFile("EddiesTwister.mp3");
  player.play();
}

void draw()
{
  if (!standalone)
  {
    while (serial_port.available() > 0) 
    {
      final int spacer_value = serial_port.read();
      if (spacer_value != 0) continue; 
      if (serial_port.available() == 0) break;
      player_1.set_y(map(serial_port.read(), 1, 255, miny, maxy));
      if (serial_port.available() == 0) break;
      player_2.set_y(map(serial_port.read(), 1, 255, miny, maxy));
    }
  }
  background(0);
  noStroke();
  directionalLight(255, 0, 0, -cos(hoek_z * 5.0), -sin(hoek_z * 5.0), 0);
  directionalLight(0, 255, 0, 0, -cos(hoek_z * 7.0), -sin(hoek_z * 7.0));
  directionalLight(0, 0, 255, -sin(hoek_z * 3.0), 0, -cos(hoek_z * 3.0));

  translate(width / 2, height / 2);
  rotateX(hoek_z * 0.2);
  rotateY(hoek_z * 0.3);
  rotateZ(hoek_z);

  player_1.move();
  player_2.move();
  bal.move();

  bal.check_collision(player_1);
  bal.check_collision(player_2);

  player_1.display();
  player_2.display();
  bal.display();

  draw_surrounding();

  fill(255, 128, 128);
  text(score1, -text_size, text_size / 2);

  fill(128, 128, 255);
  text(score2,  text_size, text_size / 2);

  hoek_z += speed_z;
}

void draw_surrounding()
{
  //Draw surrounding
  for (float i = 0; i < 100.0; i += 1.0)
  {
    final float block_x = minx + ((i / 100.0) * (maxx - minx));
    final float block_y = miny ;
    translate(block_x, block_y);
    box(10);
    translate(-block_x, -block_y);
  }
  for (float i = 0; i < 100.0; i += 1.0)
  {
    final float block_x = minx + ((i / 100.0) * (maxx - minx));
    final float block_y = maxy;
    translate(block_x, block_y);
    box(10);
    translate(-block_x, -block_y);
  }
  for (float i = 0; i < 100.0; i += 1.0)
  {
    final float block_x = minx;
    final float block_y = miny + ((i / 100.0) * (maxy - miny));
    translate(block_x, block_y);
    box(10);
    translate(-block_x, -block_y);
  }
  for (float i = 0; i < 100.0; i += 1.0)
  {
    final float block_x = maxx;
    final float block_y = miny + ((i / 100.0) * (maxy - miny));
    translate(block_x, block_y);
    box(10);
    translate(-block_x, -block_y);
  }
}

float get_distance(float dx, float dy)
{
  return sqrt((dx * dx) + (dy * dy));
}

void keyPressed() {

  if (key == CODED) 
  {
    if (keyCode == UP) 
    {
      player_2.change_dy(-1);
    } 
    if (keyCode == DOWN) 
    {
      player_2.change_dy(1);
    }
  }
  if (key == 'w') 
  {
    player_1.change_dy(-1);
  }
  if (key == 's') 
  {
    player_1.change_dy( 1);
  }
}


// Use Ball from https://processing.org/examples/circlecollision.html
class Ball 
{
  PVector m_position;
  PVector m_velocity;
  float m_radius;

  Ball(PVector position, PVector velocity, float radius) 
  {
    m_position = position;
    m_velocity = velocity;
    m_radius = radius;
  }

  final float get_radius() { 
    return m_radius;
  }

  void set_velocity_to_zero()
  {
    m_velocity.x = 0.0; 
    m_velocity.y = 0.0;
  }
  void set_y(float y) 
  {
    m_position.y = y;
  }
  void change_dy(float change)
  {
    m_velocity.y += change;
  }
  void move() 
  {
    m_position.add(m_velocity);

    if (m_position.x > maxx - m_radius) 
    {
      m_velocity.x = -abs(m_velocity.x);
      ++score1;
    } 
    else if (m_position.x < minx + m_radius) 
    {
      m_velocity.x = abs(m_velocity.x);
      ++score2;
    } 
    else if (m_position.y > maxy - m_radius) 
    {
      m_velocity.y = -abs(m_velocity.y);
    } 
    else if (m_position.y < miny + m_radius) 
    {
      m_velocity.y = abs(m_velocity.y);
    }
  }

  void check_collision(final Ball other) 
  {

    // Get distances between the balls components
    final PVector distanceVect = PVector.sub(other.m_position, m_position);

    // Calculate magnitude of the vector separating the balls
    final float distanceVectMag = distanceVect.mag();

    // Minimum distance before they are touching
    final float minDistance = m_radius + other.get_radius();

    //No collission
    if (distanceVectMag > minDistance) return;

    final float distanceCorrection = (minDistance-distanceVectMag)/2.0;
    final PVector d = distanceVect.copy();
    final PVector correctionVector = d.normalize().mult(distanceCorrection);
    
    //RJCB: I don't think I need this
    //other.m_position.add(correctionVector);
    m_position.sub(correctionVector);

    // get angle of distanceVect
    final float theta  = distanceVect.heading();
    // precalculate trig values
    final float sine = sin(theta);
    final float cosine = cos(theta);

    /* bTemp will hold rotated ball positions. You 
     just need to worry about bTemp[1] position*/
    PVector[] bTemp = {
      new PVector(), new PVector()
    };

    /* this ball's position is relative to the other
     so you can use the vector between them (bVect) as the 
     reference point in the rotation expressions.
     bTemp[0].position.x and bTemp[0].position.y will initialize
     automatically to 0.0, which is what you want
     since b[1] will rotate around b[0] */
    bTemp[1].x  = cosine * distanceVect.x + sine * distanceVect.y;
    bTemp[1].y  = cosine * distanceVect.y - sine * distanceVect.x;

    // rotate Temporary velocities
    PVector[] vTemp = {
      new PVector(), new PVector()
    };

    vTemp[0].x  = cosine * m_velocity.x + sine * m_velocity.y;
    vTemp[0].y  = cosine * m_velocity.y - sine * m_velocity.x;
    
    //Instead of using the player's velocity, use the opposite velocity of the ball 
    //vTemp[1].x  = cosine * other.m_velocity.x + sine * other.m_velocity.y;
    //vTemp[1].y  = cosine * other.m_velocity.y - sine * other.m_velocity.x;
    vTemp[1].x  = cosine * -m_velocity.x + sine * -m_velocity.y;
    vTemp[1].y  = cosine * -m_velocity.y - sine * -m_velocity.x;

    /* Now that velocities are rotated, you can use 1D
     conservation of momentum equations to calculate 
     the final velocity along the x-axis. */
    PVector[] vFinal = {  
      new PVector(), new PVector()
    };

    // RJCB: No idea what these m's are for
    //final float m = m_radius;
    //final float other_m = other.get_radius();
    //final float m = m_radius * 0.1;
    //final float other_m = other.get_radius() * 0.1;

    // final rotated velocity for b[0]

    vFinal[0].x = ((m_radius - other.get_radius()) * vTemp[0].x + 2 * other.get_radius() * vTemp[1].x) / (m_radius + other.get_radius());
    vFinal[0].y = vTemp[0].y;

    // final rotated velocity for b[0]
    vFinal[1].x = ((other.get_radius() - m_radius) * vTemp[1].x + 2 * m_radius * vTemp[0].x) / (m_radius + other.get_radius());
    vFinal[1].y = vTemp[1].y;

    // hack to avoid clumping
    bTemp[0].x += vFinal[0].x;
    bTemp[1].x += vFinal[1].x;

    /* Rotate ball positions and velocities back
     Reverse signs in trig expressions to rotate 
     in the opposite direction */
    // rotate balls
    PVector[] bFinal = { 
      new PVector(), new PVector()
    };

    bFinal[0].x = cosine * bTemp[0].x - sine * bTemp[0].y;
    bFinal[0].y = cosine * bTemp[0].y + sine * bTemp[0].x;
    bFinal[1].x = cosine * bTemp[1].x - sine * bTemp[1].y;
    bFinal[1].y = cosine * bTemp[1].y + sine * bTemp[1].x;

    //Nope, other players do not move
    // update balls to screen position
    //other.m_position.x = m_position.x + bFinal[1].x;
    //other.m_position.y = m_position.y + bFinal[1].y;

    m_position.add(bFinal[0]);

    // update velocities
    m_velocity.x = cosine * vFinal[0].x - sine * vFinal[0].y;
    m_velocity.y = cosine * vFinal[0].y + sine * vFinal[0].x;
    
    //Nope, other players do not move
    //other.m_velocity.x = cosine * vFinal[1].x - sine * vFinal[1].y;
    //other.m_velocity.y = cosine * vFinal[1].y + sine * vFinal[1].x;

  }

  void display() 
  {
    translate(m_position.x, m_position.y);
    sphere(m_radius);
    translate(-m_position.x, -m_position.y);
  }
}
