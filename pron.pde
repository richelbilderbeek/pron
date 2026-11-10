int s = 3; //Scale
int maxx = 320;
int maxy = 200;
int screen_width  = maxx * s;
int screen_height = maxy * s;
int x1 = (maxx / 2) + 1;
int y1 = (maxy / 2);
int d1 = 1; //Direction: 0: up, 1: right, 2: down, 3: down
color c1 = color(255, 128, 128);
int x2 = (maxx / 2) - 1;
int y2 = (maxy / 2);
int d2 = 3; //Direction: 0: up, 1: right, 2: down, 3: down
color c2 = color(128, 128, 255);
int score1 = 0;
int score2 = 0;


void setup()
{
  size(960, 600); //Must be (s * maxx, s * maxy) 
  background(0);
  textSize(32);
}

void draw()
{
  switch (d1) {
    case 0: y1 = (y1 - 1 + maxy) % maxy; break; 
    case 1: x1 = (x1 + 1 + maxx) % maxx; break; 
    case 2: y1 = (y1 + 1 + maxy) % maxy; break; 
    case 3: x1 = (x1 - 1 + maxx) % maxx; break;
  }
  switch (d2) {
    case 0: y2 = (y2 - 1 + maxy) % maxy; break; 
    case 1: x2 = (x2 + 1 + maxx) % maxx; break; 
    case 2: y2 = (y2 + 1 + maxy) % maxy; break; 
    case 3: x2 = (x2 - 1 + maxx) % maxx; break;
  }

  //Check for collisions
  if (get(s * x1, s * y1) != color(0)) 
  { 
    remove_color(get(s * x1, s * y1));
    ++score2;
  }   
  if (get(s * x2, s * y2) != color(0)) 
  { 
    remove_color(get(s * x2, s * y2)); 
    ++score1;
  }

  //Draw players and scores on new spot
  stroke(0); fill(0);
  rect(1 * screen_width / 4, 4,64,32);
  rect(3 * screen_width / 4, 4,64,32);
  
  stroke(c1);
  fill(c1);
  text(score1, 1 * screen_width / 4, 32);
  rect(s * x1, s * y1, s-1, s-1);
  stroke(c2);
  fill(c2);
  text(score2, 3 * screen_width / 4, 32);
  rect(s * x2, s * y2, s-1, s-1);
}

void remove_color(color cr)
{
  fill(0); stroke(0);
  for (int y=0; y!=maxy; ++y)
  {
    for (int x=0; x!=maxx; ++x)
    {
      if (get(s * x, s * y) == cr) { 
        rect(s * x, s * y, s-1, s-1);
      }
    }
  }
}

void keyPressed() {
  if (key == 'a' || key == 'A') { 
    d1 = (d1 - 1 + 4) % 4;
  }
  if (key == 'd' || key == 'D') { 
    d1 = (d1 + 1 + 4) % 4;
  }
  if (key == CODED) {
    if (keyCode == LEFT ) { 
      d2 = (d2 - 1 + 4) % 4;
    }
    if (keyCode == RIGHT) { 
      d2 = (d2 + 1 + 4) % 4;
    }
  }
}