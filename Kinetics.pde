import java.net.*;
import java.io.*;
import java.net.InetAddress;
import java.net.Socket;
import websockets.*;
WebsocketClient wsc, wsc2, wsc3;
public InertialSensor mpu6050, mpu6050_2, mpu6050_3;
String dataStr, dataStr2, dataStr3;
float sensibilita;
float[] pA = new float[3];
float[] pB = new float[3];
float[] pC = new float[3];
Socket mouseSocket;
//Sistema sistema = new Sistema(0, 0, -100, 0, 0, 0);
float[] versore = new float[3];
float[] versore2 = new float[3];
float[] versore3 = new float[3];
float l1=100, l2=200, l3=300;
void settings() {
  size(displayWidth-100, displayHeight-100, P3D);
}
void setup() {
  sensibilita = 2;
  //mpu6050 = new InertialSensor(0, 0, 0, sensibilita, "Template");
  //mpu6050_2 = new InertialSensor(0, 0, 0, sensibilita, "Template");
  mpu6050_3 = new InertialSensor(0, 0, 0, sensibilita, "Template");
  //wsc = new WebsocketClient(this, "ws://192.168.1.200:81//");
  //wsc2 = new WebsocketClient(this, "ws://192.168.1.201:81//");
  wsc3 = new WebsocketClient(this, "ws://192.168.1.202:81//");
  for (int i=0; i<3; i++) {
    versore[i]=0;
    versore2[i]=0;
    versore3[i]=0;
  }
}

void webSocketEvent(String msg) {
  if (msg == "Ciao" || msg == null || msg == "0.0") return; 
  if (msg.charAt(0)=='a')
    dataStr = msg.substring(1, msg.length());
  if (msg.charAt(0)=='b')
    dataStr2 = msg.substring(1, msg.length());
  if (msg.charAt(0)=='c')
    dataStr3 = msg.substring(1, msg.length());
  println(dataStr3);
}
void draw() {
  background(255); 
  //if (dataStr != null)
  //  mpu6050.updateSensore(dataStr);
  //if (dataStr2 != null)
  //  mpu6050_2.updateSensore(dataStr2);
  if (dataStr3 != null)
    mpu6050_3.updateSensore(dataStr3);
 //mpu6050_3.drawTemplateCreator();
   // sistema.disegnaGriglia();
   // versore = mpu6050.getDirection();
  //  versore2 = mpu6050_2.getDirection();
   // versore3 = mpu6050_3.getDirection();

//    for (int i = 0; i < 3; i++) {
//      versore[i] *= l1 ;
//      versore2[i]*= l2;
//      versore3[i]*= l3;
//    }
//    stroke(0, 0, 0);
//    strokeWeight(3);
//    pA[0]= - versore[0];
//    pA[1]= +versore[2];
//    pA[2]= - versore[1];
//    line(0, 0,0, pA[0], pA[1], pA[2]);
//    pB[0]= pA[0] - versore2[0];
//    pB[1]= pA[1] + versore2[2];
//    pB[2]= pB[2] - versore2[1];
//    line( pA[0], pA[1], pA[2], pB[0], pB[1], pB[2]);
//    pC[0] = pB[0] - versore3[0];
//    pC[1] = pB[1] + versore3[2];
//    pC[2] = pB[2] - versore3[1];
//    line(pB[0], pB[1], pB[2], pC[0], pC[1], pC[2]);


mpu6050_3.drawDirection();
fill(255);
translate(0,0,-100);
rect(-100,-50,200,100);
translate(0,0,100);
}

void mouseDragged() {
  //mpu6050.mouseDragged();
  //mpu6050_2.mouseDragged();
  mpu6050_3.mouseDragged();
 // sistema.mouseDragged();
}
void mousePressed() {
  //mpu6050.mousePressed();
  //mpu6050_2.mousePressed();
  mpu6050_3.mousePressed();
//  sistema.mousePressed();
}
void mouseReleased() {
}
public void keyPressed() {
  //mpu6050.keyPressed(key, keyCode);
  //mpu6050_2.keyPressed(key, keyCode);
  mpu6050_3.keyPressed(key, keyCode);
//  sistema.keyPressed(key, keyCode);
}
public void keyReleased() {
  //mpu6050.keyReleased(key, keyCode);
  //mpu6050_2.keyReleased(key, keyCode);
  mpu6050_3.keyReleased(key, keyCode);
 // sistema.keyReleased(key, keyCode);
}