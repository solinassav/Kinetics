class Sistema {
  int KEY_LEFT = 0;
  int KEY_RIGHT = 1;
  int KEY_UP = 2;
  int KEY_DOWN = 3;
  public boolean[] keysPressed = new boolean[] {false, false, false, false};
  private float _x = 0, _y = 0; // _x e _y fanno riferimento alle coordinate del mouse.
  private float x, y, z;
  private float visPitch, visRoll, visYaw;
  public float visPitch_, visRoll_, visYaw_;
  private float deltaYaw, deltaPitch;
  private boolean zoomPos;
  private boolean zoomNeg;
  //Costruttore
  public Sistema(float x, float y, float z, float visYaw, float visPitch, float visRoll) {
    this.x = x ;
    this.y = y ;
    this.z = z;
    this.visPitch = visPitch;
    visPitch = map(visPitch, 0, 360., 0, 2*PI);
    this.visYaw = visYaw;
    visYaw = map(visYaw, 0, 360., 0, 2.*PI);
    this.visRoll = visRoll;
    visRoll = map(visRoll, 0, 360., 0, 2.*PI);
  }
  //Metodi
  private void setupSistema() {
    updateZoom();
    updateMovement();
    translate(x + width/2, y + height/2, z);
    stroke(255);
    rotateX(visPitch);
    rotateY(visRoll);
    rotateZ(visYaw);
  }
  public void disegnaPiani() {
    setupSistema();
    fill(255, 0, 0);
    rectMode(CENTER);
    rect(0, 0, 300, 300);
    rotateX(3.14*0.5);
    fill(0, 255, 0);
    rectMode(CENTER);
    rect(0, 0, 300, 300);
    rotateY(3.14*0.5);
    fill(0, 0, 255);
    rectMode(CENTER);
    rect(0, 0, 300, 300);
  }

  public void disegnaAssi() {
    setupSistema();
    stroke(255, 0, 0);
    line(0, -300, 0, 0, 300, 0);
    line(0, 0, -300, 0, 0, 300);
    line(300, 0, 0, -300, 0, 0);
  }

  public void disegnaGriglia() { 
    setupSistema();
    for (int i = -15; i<= 15; i++) {
      if (i == 0) {
        strokeWeight(3);
        stroke(#BC6A6A);
      } else if (i != 0) {
        strokeWeight(1);
        stroke(#E5DEDE);
      }
      line(20*i, -300, 0, 20*i, 300, 0);
      line(0, -300, 20*i, 0, 300, 20*i);
      line(20*i, 0, -300, 20*i, 0, 300);
      line(0, 20*i, -300, 0, 20*i, 300);
      line(300, 20*i, 0, -300, 20*i, 0);
      line(300, 0, 20*i, -300, 0, 20*i);
    }
  }
  public void mousePressed() {
    _x = mouseX;
    _y = mouseY;
  }
  private void riposizionaAssi() {
    rotateX(-visPitch);
    rotateY(-visRoll);
    rotateZ(-visYaw);
  }
  public void mouseDragged() {       
    riposizionaAssi();
    float delta_x = 0, delta_y = 0;  
    delta_x = mouseX - _x;
    delta_y = mouseY - _y;
    deltaYaw = map(delta_x, 0.0, width/2, 0.0, 3.14);
    deltaPitch = map(delta_y, 0.0, height/2, 0.0, 3.14); 

    visYaw += deltaYaw/100.0;  
    visYaw_=-visYaw;
    visPitch += deltaPitch/100.0;
    visPitch_= -visPitch;
    deltaYaw = 0;
    deltaPitch = 0;
  }
  public float getX() {
    return x;
  }
  public float getY() {
    return y;
  }
  public float getZ() {
    return z;
  }
  private void updateZoom() {

    if ( zoomPos) {
      z+=10;
    } else if (zoomNeg) {
      z-=10;
    }
  }
  public void keyPressed(char key, int keyCode) {
    if (key == CODED || key=='w' ||key=='s' ||key=='a'||key=='d') {
      if (keyCode == UP || key=='w' ) {
        keysPressed[KEY_UP] = true;
        keysPressed[KEY_DOWN] = false;
      } else if (keyCode == DOWN ||key=='s') {
        keysPressed[KEY_DOWN] = true;
        keysPressed[KEY_UP] = false;
      } else if (keyCode == LEFT ||key=='a') {
        keysPressed[KEY_LEFT] = true;
        keysPressed[KEY_RIGHT] = false;
      } else if (keyCode == RIGHT||key=='d') {
        keysPressed[KEY_RIGHT] = true;
        keysPressed[KEY_LEFT] = false;
      }
    }

    if (key=='v') {
      zoomPos=true;
    } else if (key=='c') {
      zoomNeg=true;
    }
  }
  void updateMovement() {
    int dirX = 0;
    int dirY = 0;

    float speed = 10.0f; 
    if (keysPressed[KEY_LEFT]) {
      dirX = -1;
    } 
    if (keysPressed[KEY_RIGHT]) {
      dirX = 1;
    }
    if (keysPressed[KEY_UP]) {
      dirY = -1;
    }
    if (keysPressed[KEY_DOWN]) {
      dirY = 1;
    }

    x += speed * dirX;
    y -= speed * dirY;
  }
  public void keyReleased(char key, int keyCode) {
    if (key == CODED || key=='w' ||key=='s' ||key=='a'||key=='d') {
      if (keyCode == UP|| key=='w' ) {
        keysPressed[KEY_UP] = false;
      } else if (keyCode == DOWN ||key=='s') {
        keysPressed[KEY_DOWN] = false;
      } else if (keyCode == LEFT ||key=='a') {
        keysPressed[KEY_LEFT] = false;
      } else if (keyCode == RIGHT||key=='d') {
        keysPressed[KEY_RIGHT] = false;
      }
    }

    if (key=='v') {
      zoomPos=false;
    } else if (key=='c') {
      zoomNeg=false;
    }
  }
}