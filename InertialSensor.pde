import java.awt.*; //<>// //<>// //<>//
import javax.swing.SwingUtilities;
import java.awt.event.InputEvent;
import java.awt.event.KeyEvent;
import grafica.*;
class InertialSensor {
  private int[] ferma={0, 0, 0};
  private int[] ferma_={0, 0, 0};
  boolean isYprPeak = false;
  boolean isAccPeak = false;
  private int countYprHigh = 0;
  private int countAccHigh = 0;
  private ArrayList<Pattern> patterns = new ArrayList<Pattern>();
  private GPointsArray[] accPoints = new GPointsArray[3];
  private GPointsArray[] yprPoints = new GPointsArray[3];
  private GPointsArray[] velPoints = new GPointsArray[3];
  private GPointsArray[] posPoints = new GPointsArray[3];
  private GPlot accPlotX ;
  private GPlot yprPlotY;
  private GPlot accPlotY ;
  private GPlot yprPlotP;
  private GPlot accPlotZ ;
  private GPlot yprPlotR;
  private float tc = 0.02;
  public String fileName;
  private String inBuffer;
  private boolean holdLeftClick, holdRightClick;
  private Sistema sistema = new Sistema(width/3, height/15, -100, 0, 0, 0);
  private boolean mouseUsed;
  private boolean leftClick;
  private boolean rightClick;
  private int numeroCampioniOffset = 1000;
  private float[] offsetAcc = new float[3];
  private float distPiano;
  private int n; // Numero campione attuale. Serve per tenere conto a quale campione ci troviamo durante la calibrazione e per il campionamento
  private float xi, yi, zi;
  private float[] coordinateSchermo = new float[3];
  private float[] coordinateVersore = new float [3];
  private float[] mouse = new float[2];
  private float[] ypr = new float[3];
  private float[] acc = new float[3];
  private float[] definitiveAcc = new float[3];
  private float[] smothingAcc = new float[3];
  private float[] smothingYpr = new float[3];
  private float[] vel = new float[3];
  private boolean[] isMoovement = new boolean[3];
  private boolean[] positive= new boolean[3];
  private float[] picco = new float[3];
  private int[] inizio = new int[3];
  private int[] tzero = new int[3];
  private int[] deltaN = new int[3];
  private int[] durata = new int[3];
  private float[][] coefficients = new float[3][3];
  private float[] pos = new float[3];
  private float[] accHold = new float[3];
  private float[] yprHold = new float[3];
  private float[] velHold = new float[3];
  private float[] yprAccensione = new float[3];
  private String[] data = new String[7];
  private String[] dataName = { "y", "p", "r", "X", "Y", "Z", "d", "l"};
  private boolean isRealTimeApplication;
  private boolean sampling;
  private Window window;
  private SamplingButton samplingButton;


  public void setWindowDimension(int numberOfSamples) {
    isRealTimeApplication = true;
    window = new Window(numberOfSamples);
  }
  public Window getActualWindow() {
    return window;
  }
  public void setPattern(Pattern pattern) {
    patterns.add(pattern);
  }
  // Dichiaro un oggetto su cui scrivere nel caso io voglia effettuare un campionamento
  public PrintWriter output;
  // Il costruttore prende in ingresso solo la posizione iniziale del sensore e la distanza dal piano (valore che indica la sensibilità del mouse).
  public InertialSensor(float xi, float yi, float zi, float distPiano) {

    isRealTimeApplication = false;
    mouseUsed=false;
    this.distPiano = distPiano;
    this.xi = xi;
    this.yi = yi;
    this.zi = zi;
    isYprPeak=true;
    for (int i = 0; i < 3; i++) {

      data[i]="0.0";
      ypr[i] = 0;
      smothingYpr[i] = 0;
      yprAccensione[i] = 0;
      acc[i] = 0;
      smothingAcc[i] = 0;
      accHold[i] = 0;
      offsetAcc[i] = 0;
      vel[i]=0;
      pos[i]=0;
      coordinateSchermo[i]=0;
      inizio[i]=0;
      picco[i]=0;
      deltaN[i]=0;
      tzero[i]=0;
      isMoovement[i]=false;
      positive[i]=false;
      durata[i]=0;
      for (int j=0; j<3; j++) {
        coefficients[i][j]=0;
      }
      holdLeftClick=false;
    }
    n = 0;
  }
  // Costruttore nel caso vuoi campionare
  public InertialSensor(float xi, float yi, float zi, float distPiano, String fileName) { 
    this(xi, yi, zi, distPiano);  
    this. fileName = fileName;
    int dimension=500;
    color unclicked =#E39C9C; 
    color clicked = #BC6A6A;
    output = createWriter(this.fileName +" number 0.txt"); // Aggiungo una stringa in ingresso per determinare il nome del file su cui scrivere
    samplingButton = new SamplingButton(90, height*(1.0 - 1.0/10.0), width/20, clicked, unclicked);
    setWindowDimension(dimension);
    accPlotX = new GPlot(Kinetics.this);
    yprPlotY = new GPlot(Kinetics.this);
    accPlotY = new GPlot(Kinetics.this);
    yprPlotP = new GPlot(Kinetics.this);
    accPlotZ = new GPlot(Kinetics.this);
    yprPlotR = new GPlot(Kinetics.this);
  }

  public void setN(int n) {
    this.n=n;
  }
  // Metodi privati
  private void updateVelocity() {
    for (int i = 0; i<3; i++) {
      velHold[i] = vel[i];   
      if (window.getDefinitiveAccWindow()[i][window.getWindowSize()-1] != window.getDefinitiveAccWindow()[i][window.getWindowSize()-2]) 
        vel[i]+= window.getDefinitiveAccWindow()[i][window.getWindowSize()-1]*0.2;
      if (n<numeroCampioniOffset)
        vel[i]=0;
      if (window.getVelWindow()[i][window.getWindowSize()-1]== window.getVelWindow()[i][window.getWindowSize()-2]) {
        ferma_[i]++;
        if (ferma_[i]>5) {    
          vel[i]=0;
          ferma_[i]=0;
        }
      }
    }
  }
  private void updateDefinitiveAcc() {
    for (int i = 0; i<3; i++) {
      if (window.getSmothingDerivativeSmothingAccWindow()[i][window.getWindowSize()-1] != window.getSmothingDerivativeSmothingAccWindow()[i][window.getWindowSize()-2]) 
        definitiveAcc[i]+= window.getSmothingDerivativeSmothingAccWindow()[i][window.getWindowSize()-1];
      if (n<numeroCampioniOffset)
        definitiveAcc[i]=0;
      if (window.getDefinitiveAccWindow()[i][window.getWindowSize()-1]== window.getDefinitiveAccWindow()[i][window.getWindowSize()-2]) {
        //if (window.getDefinitiveAccWindow()[i][window.getWindowSize()-1]== window.getDefinitiveAccWindow()[i][window.getWindowSize()-2]) {
        ferma[i]++;
        if (ferma[i]>10) { 
          definitiveAcc[i]=0;
          ferma[i]=0;
        }
      }
      if (sqrt(pow(definitiveAcc[i], 2))<0.0002)
        definitiveAcc[i]=0;
    }
  }
  private void updatePosition() {
    for (int i = 0; i<3; i++) {
      pos[i]+=vel[i]*tc;
    }
  }
  public void setMouseUsed(boolean used) {
    this.mouseUsed=used;
  }
  public boolean isMouseUsed() {
    return this.mouseUsed;
  }
  // Calcola offset delle accelerazioni
  private void calcolaOffset() {
    for (int i = 0; i < 3; i++) {
      offsetAcc[i] += acc[i];
      if (n == numeroCampioniOffset - 1) {
        // Questa parte di codice viene eseguita solo una volta ogni volta che accendiamo il mouse e non viene mai eseguita ciclicamente, dunque quel vallore di acc[i] è il valore di acc[i]
        // in un determinato istante
        offsetAcc[i] = (offsetAcc[i] / float(numeroCampioniOffset));
      }
    }
  }
  private void adjustYpr() {
    for (int i = 0; i<3; i ++ ) {   
      yprHold[i] = ypr[i];
      ypr[i] = float(data[i])-yprAccensione[i]/1000.0;
    }
    if (ypr[0]>yprHold[0]+0.2||ypr[0]<yprHold[0]-0.2||ypr[1]>yprHold[1]+0.1||ypr[1]<yprHold[1]-0.1) {
      countYprHigh++;
      if (countYprHigh < 4) {
        isYprPeak = true;
      } else {
        isYprPeak = false;
        countYprHigh = 0;
      }
      if (isYprPeak) {
        for (int i = 0; i<3; i ++ ) {
          ypr[i] = yprHold[i];
        }
      }
    } else {
      isYprPeak = false;
      countYprHigh = 0;
    }
  }
  // Elimina i picchi indesiderati dai valori di accelerazione
  private void adjustAcc() {
    for (int i = 0; i < 3; i++) { 
      accHold[i]=acc[i];
      acc[i] = float(data[i+3])- offsetAcc[i] ;
    }
    if ((acc[0]>accHold[0]+1||acc[0]<accHold[0]-1) || (acc[1]>accHold[1]+1.5||acc[1]<accHold[1]-1.5)|| (acc[2]>accHold[2]+1.5||acc[2]<accHold[2]-1.5)) {
      countAccHigh++;
      if (countAccHigh < 4) {
        isAccPeak = true;
      } else {
        isAccPeak = false;
        countAccHigh = 0;
      }
      if (isAccPeak) {
        for (int i = 0; i<3; i ++ ) {
          acc[i] = accHold[i];
        }
      }
    } else {
      isAccPeak = false;
      countAccHigh = 0;
    }
  }



  // Ruota coordinate nello spazio
  private void rotate_(float x, float y, float z) {
    /*questa funzione mi serve anche a altro in altri programmi ma qua
     in pasto li do 0,1,0 chè è la direzine dell'asse y dell'accellerometro
     in quanto il modulo è unitario ovvero rappresenta un versore, so che la sua rotazione
     rappresentera a sua volta un versore
     dunque i dati in uscita saranno direttamente utilizzabili per parametrizzare una retta.
     */
    float x1, x2, x3, y1, y2, y3, z1, z2, z3;
    // Ruoto roll
    x1 = x;
    y1 = y * cos(smothingYpr[2]) - z * sin(smothingYpr[2]);
    z1 = y * sin(smothingYpr[2]) + z * cos(smothingYpr[2]);
    // Ruoto pitch
    x2 = x1 * cos(smothingYpr[1]) + z1 * sin(smothingYpr[1]);
    y2 = y1;
    z2 = z1 * cos(smothingYpr[1]) - x1 * sin(smothingYpr[1]);
    // Ruoto yaw
    x3 = x2 * cos(smothingYpr[0]) - y2 * sin(smothingYpr[0]);
    y3 = x2 * sin(smothingYpr[0]) + y2 * cos(smothingYpr[0]);
    z3 = z2;
    coordinateVersore[0] = x3;
    coordinateVersore[1] = y3;
    coordinateVersore[2] = z3;
  }
  // Interseca un piano a distanza distPiano, la distanza dal piano dipende dalla sensibilità richiesta nel costruttore
  private void intersecaPiano() {
    /*funzione calcola l'intersezione tra la direzione indicata e il piano chiaramente della coordinata y sullo schermo non c'è ne facciamo niente*/
    coordinateSchermo[0] = (distPiano - yi) * coordinateVersore[0] / coordinateVersore[1] + xi;
    coordinateSchermo[2] = (distPiano - yi) * coordinateVersore[2] / coordinateVersore[1] + zi;
    coordinateSchermo[1] = distPiano;
  }

  // Aggiorna le coordinate del mouse rispetto alla grandezza dello schermo
  private void updateCoordinateSchermo()
  {  
    intersecaPiano();
    mouse[0] = constrain(coordinateSchermo[0], -distPiano*sin(30.0*PI/180.0), distPiano*sin(30.0*PI/180.0));
    mouse[1] = constrain(coordinateSchermo[2], -distPiano*sin(10.0*PI/180.0), distPiano*sin(10.0*PI/180.0));
    mouse[0] = -map(mouse[0], 0, distPiano*sin(30.0*PI/180.0), 0, displayWidth/2) + displayWidth/2;
    mouse[1] =  map(mouse[1], 0, distPiano*sin(10.0*PI/180.0), 0, displayHeight/2) + displayHeight/2;
  }

  // Crea e scrive su file di testo tutti i dati sia in ingresso che elaborati ordinati in una matrica che ha per colonne in fila ypr + acc + coordinateVersore + mouse
  // Bisogna aggiungere una grafica che faccia intendere   quando si sta campionando
  private void createTxt(PrintWriter output) {
    for (int i = 0; i < 3; i++) {
      output.print(ypr[i] + "\t");
    }
    for (int i = 0; i < 3; i++) {
      output.print(definitiveAcc[i] + "\t");
    }
    for (int i = 0; i < 3; i++) {
      output.print(smothingAcc[i] + "\t");
    }
      for (int i = 0; i < 3; i++) {
      output.print(acc[i] + "\t");
    }
    //for (int i = 0; i < 3; i++) {
    //  output.print(vel[i] + "\t");
    //}
    //for (int i = 0; i < 3; i++) {
    //  output.print(pos[i] + "\t");
    //}
    //for (int i = 0; i < 3; i++) {
    //  output.print(coordinateVersore[i] + "\t");
    //}
    //for (int i = 0; i < 2; i++) {
    //  output.print(mouse[i] + "\t");
    //}
    output.println();
  }

  private void closeTxt(PrintWriter output) {
    // se s ono arrivato all'ultimo elemento chiudo il file
    output.flush();
    output.close();
  }
  public float[] getAcc() {
    return acc;
  }
  // Da in uscita un vettore con gli angoli Yaw Pitch Roll in questo ordine
  public float[] getYpr() {
    return ypr;
  }
  // Da in uscita un vettore contenente le cordinate X Y del mouse sullo schermo
  public float[] getMouse() {
    if (inBuffer != null) {
      updateCoordinateSchermo();
    }
    return mouse;
  } 
  // Disegna sullo schermo il mouse di colore (r,g,b) grande dim
  public void drawMouse(int r, int g, int b, int dim) {

    mouse = getMouse();

    stroke(r, g, b);
    fill(r, g, b);
    ellipse(mouse[0], mouse[1], dim, dim);
    fill(0, 0, 0);
  }
  //Permette di utilizzare il dispositivo in un puntatore capace di muovere il mouse
  public void mouse() {
    mouse = getMouse();
    mouseUsed=true;    
    try { 
      Robot robot = new Robot();
      window.setMouseWindow(mouse);
      //robot.mouseMove( round(window.mean(window.getMouseWindow(), 10)[0]), round(window.mean(window.getMouseWindow(), 10)[1]));
      robot.mouseMove( round(mouse[0]), round(mouse[1]));
      if (leftClick&&!holdLeftClick) {
        robot.mousePress(InputEvent.BUTTON1_MASK);
      } else if (!leftClick&&holdLeftClick) {
        robot.mouseRelease(InputEvent.BUTTON1_MASK);
      }
      holdLeftClick=leftClick;
      if (rightClick&&!holdRightClick) {
        robot.mousePress(InputEvent.BUTTON3_MASK);
      } else if (!rightClick&&holdRightClick) {
        robot.mouseRelease(InputEvent.BUTTON3_MASK);
      }
      holdLeftClick=leftClick;
      holdRightClick=rightClick;
    }
    catch (AWTException e) {
    }
  }
  // Da in uscita un vettore con le coordinate del versore che indica la direzione
  public float[] getDirection() {
    if (inBuffer != null) {
    }
    return coordinateVersore;
  }
  public float[] getVelocity() {
    return vel;
  }
  public float[] getPosition() {
    return pos;
  }
  public void drawTemplateCreator() {
    fill(90);
    textSize(32);
    text("Orientation", width*3/4, height/12);
    samplingButton.drawButton();
    generateAllPoints();
    drawAllGraph();
    drawDirection();
  }
  private void drawAllGraph() { 
    float dimX=width/4;
    float posX = width*2/30 +width/4;
    accPlotX.setPos(25, 25);
    accPlotX.setDim(dimX, (height)/5);
    accPlotX.setTitleText("Acceleration X ");
    accPlotX.getXAxis().setAxisLabelText("t[ms]");
    accPlotX.getYAxis().setAxisLabelText("g");
    accPlotX.setPoints(accPoints[0]);
    accPlotX.beginDraw();
    accPlotX.drawBox();
    accPlotX.drawXAxis();
    accPlotX.drawYAxis();
    accPlotX.drawTitle();
    accPlotX.drawGridLines(GPlot.BOTH);
    accPlotX.drawLines();
    accPlotX.drawLabels();
    accPlotX.endDraw();
    yprPlotY.setPos(posX, 25);
    yprPlotY.setDim(dimX, (height)/5);
    yprPlotY.setTitleText("Yaw ");
    yprPlotY.getXAxis().setAxisLabelText("t[ms]");
    yprPlotY.getYAxis().setAxisLabelText("Radiants");
    yprPlotY.setPoints(yprPoints[0]);
    yprPlotY.beginDraw();
    yprPlotY.drawBox();
    yprPlotY.drawXAxis();
    yprPlotY.drawYAxis();
    yprPlotY.drawTitle();
    yprPlotY.drawGridLines(GPlot.BOTH);
    yprPlotY.drawLines();
    yprPlotY.drawLabels();
    yprPlotY.endDraw();
    accPlotY.setPos(25, (height)/4 +50);
    accPlotY.setDim(dimX, (height)/5);
    accPlotY.setTitleText("Acceleration Y ");
    accPlotY.getXAxis().setAxisLabelText("t[ms]");
    accPlotY.getYAxis().setAxisLabelText("g");
    accPlotY.setPoints(accPoints[1]);
    accPlotY.beginDraw();
    accPlotY.drawBox();
    accPlotY.drawXAxis();
    accPlotY.drawYAxis();
    accPlotY.drawTitle();
    accPlotY.drawGridLines(GPlot.BOTH);
    accPlotY.drawLines();
    accPlotY.drawLabels();
    accPlotY.endDraw();
    yprPlotP.setPos(posX, height/4 +50);
    yprPlotP.setDim(dimX, (height)/5);
    yprPlotP.setTitleText("Pitch ");
    yprPlotP.getXAxis().setAxisLabelText("t[ms]");
    yprPlotP.getYAxis().setAxisLabelText("radiants");
    yprPlotP.setPoints(yprPoints[1]);
    yprPlotP.beginDraw();
    yprPlotP.drawBox();
    yprPlotP.drawXAxis();
    yprPlotP.drawYAxis();
    yprPlotP.drawTitle();
    yprPlotP.drawGridLines(GPlot.BOTH);
    yprPlotP.drawLines();
    yprPlotP.drawLabels();
    yprPlotP.endDraw();
    accPlotZ.setPos(25, 2*(height)/4 +75);
    accPlotZ.setDim(dimX, (height)/5);
    accPlotZ.setTitleText("Acceleration Z ");
    accPlotZ.getXAxis().setAxisLabelText("t[ms]");
    accPlotZ.getYAxis().setAxisLabelText("g");
    accPlotZ.setPoints(accPoints[2]);
    accPlotZ.beginDraw();
    accPlotZ.drawBox();
    accPlotZ.drawXAxis();
    accPlotZ.drawYAxis();
    accPlotZ.drawTitle();
    accPlotZ.drawGridLines(GPlot.BOTH);
    accPlotZ.drawLines();
    accPlotZ.drawLabels();
    accPlotZ.endDraw();
    yprPlotR.setPos(posX, 2*(height)/4 +75);
    yprPlotR.setDim(dimX, (height)/5);
    yprPlotR.setTitleText("Roll");
    yprPlotR.getXAxis().setAxisLabelText("t[ms]");
    yprPlotR.getYAxis().setAxisLabelText("radiants");
    yprPlotR.setPoints(yprPoints[2]);
    yprPlotR.beginDraw();
    yprPlotR.drawBox();
    yprPlotR.drawXAxis();
    yprPlotR.drawYAxis();
    yprPlotR.drawTitle();
    yprPlotR.drawGridLines(GPlot.BOTH);
    yprPlotR.drawLines();
    yprPlotR.drawLabels();
    yprPlotR.endDraw();
  }
  private void drawAllGraph2() { 
    float dimX=width/4;
    float posX = width*2/30 +width/4;
    accPlotX.setPos(25, 25);
    accPlotX.setDim(dimX, (height)/5);
    accPlotX.setTitleText("Acceleration X ");
    accPlotX.getXAxis().setAxisLabelText("t[ms]");
    accPlotX.getYAxis().setAxisLabelText("g");
    accPlotX.setPoints(accPoints[0]);
    accPlotX.beginDraw();
    accPlotX.drawBox();
    accPlotX.drawXAxis();
    accPlotX.drawYAxis();
    accPlotX.drawTitle();
    accPlotX.drawGridLines(GPlot.BOTH);
    accPlotX.drawLines();
    accPlotX.drawLabels();
    accPlotX.endDraw();
    yprPlotY.setPos(posX, 25);
    yprPlotY.setDim(dimX, (height)/5);
    yprPlotY.setTitleText("Speed X  ");
    yprPlotY.getXAxis().setAxisLabelText("t[ms]");
    yprPlotY.getYAxis().setAxisLabelText("m/s");
    yprPlotY.setPoints(velPoints[0]);
    yprPlotY.beginDraw();
    yprPlotY.drawBox();
    yprPlotY.drawXAxis();
    yprPlotY.drawYAxis();
    yprPlotY.drawTitle();
    yprPlotY.drawGridLines(GPlot.BOTH);
    yprPlotY.drawLines();
    yprPlotY.drawLabels();
    yprPlotY.endDraw();
    accPlotY.setPos(25, (height)/4 +50);
    accPlotY.setDim(dimX, (height)/5);
    accPlotY.setTitleText("Acceleration Y ");
    accPlotY.getXAxis().setAxisLabelText("t[ms]");
    accPlotY.getYAxis().setAxisLabelText("g");
    accPlotY.setPoints(accPoints[1]);
    accPlotY.beginDraw();
    accPlotY.drawBox();
    accPlotY.drawXAxis();
    accPlotY.drawYAxis();
    accPlotY.drawTitle();
    accPlotY.drawGridLines(GPlot.BOTH);
    accPlotY.drawLines();
    accPlotY.drawLabels();
    accPlotY.endDraw();
    yprPlotP.setPos(posX, height/4 +50);
    yprPlotP.setDim(dimX, (height)/5);
    yprPlotP.setTitleText("Speed Y ");
    yprPlotP.getXAxis().setAxisLabelText("t[ms]");
    yprPlotP.getYAxis().setAxisLabelText("m/s");
    yprPlotP.setPoints(velPoints[1]);
    yprPlotP.beginDraw();
    yprPlotP.drawBox();
    yprPlotP.drawXAxis();
    yprPlotP.drawYAxis();
    yprPlotP.drawTitle();
    yprPlotP.drawGridLines(GPlot.BOTH);
    yprPlotP.drawLines();
    yprPlotP.drawLabels();
    yprPlotP.endDraw();
    accPlotZ.setPos(25, 2*(height)/4 +75);
    accPlotZ.setDim(dimX, (height)/5);
    accPlotZ.setTitleText("Acceleration Z ");
    accPlotZ.getXAxis().setAxisLabelText("t[ms]");
    accPlotZ.getYAxis().setAxisLabelText("g");
    accPlotZ.setPoints(accPoints[2]);
    accPlotZ.beginDraw();
    accPlotZ.drawBox();
    accPlotZ.drawXAxis();
    accPlotZ.drawYAxis();
    accPlotZ.drawTitle();
    accPlotZ.drawGridLines(GPlot.BOTH);
    accPlotZ.drawLines();
    accPlotZ.drawLabels();
    accPlotZ.endDraw();
    yprPlotR.setPos(posX, 2*(height)/4 +75);
    yprPlotR.setDim(dimX, (height)/5);
    yprPlotR.setTitleText("Speed z");
    yprPlotR.getXAxis().setAxisLabelText("t[ms]");
    yprPlotR.getYAxis().setAxisLabelText("m/s");
    yprPlotR.setPoints(velPoints[2]);
    yprPlotR.beginDraw();
    yprPlotR.drawBox();
    yprPlotR.drawXAxis();
    yprPlotR.drawYAxis();
    yprPlotR.drawTitle();
    yprPlotR.drawGridLines(GPlot.BOTH);
    yprPlotR.drawLines();
    yprPlotR.drawLabels();
    yprPlotR.endDraw();
  }
  private void drawAllGraph3() { 
    float dimX=width/4;
    float posX = width*2/30 +width/4;
    accPlotX.setPos(25, 25);
    accPlotX.setDim(dimX, (height)/5);
    accPlotX.setTitleText("Vel X ");
    accPlotX.getXAxis().setAxisLabelText("t[ms]");
    accPlotX.getYAxis().setAxisLabelText("g");
    accPlotX.setPoints(velPoints[0]);
    accPlotX.beginDraw();
    accPlotX.drawBox();
    accPlotX.drawXAxis();
    accPlotX.drawYAxis();
    accPlotX.drawTitle();
    accPlotX.drawGridLines(GPlot.BOTH);
    accPlotX.drawLines();
    accPlotX.drawLabels();
    accPlotX.endDraw();
    yprPlotY.setPos(posX, 25);
    yprPlotY.setDim(dimX, (height)/5);
    yprPlotY.setTitleText("Pos X  ");
    yprPlotY.getXAxis().setAxisLabelText("t[ms]");
    yprPlotY.getYAxis().setAxisLabelText("m/s");
    yprPlotY.setPoints(posPoints[0]);
    yprPlotY.beginDraw();
    yprPlotY.drawBox();
    yprPlotY.drawXAxis();
    yprPlotY.drawYAxis();
    yprPlotY.drawTitle();
    yprPlotY.drawGridLines(GPlot.BOTH);
    yprPlotY.drawLines();
    yprPlotY.drawLabels();
    yprPlotY.endDraw();
    accPlotY.setPos(25, (height)/4 +50);
    accPlotY.setDim(dimX, (height)/5);
    accPlotY.setTitleText("Vel Y ");
    accPlotY.getXAxis().setAxisLabelText("t[ms]");
    accPlotY.getYAxis().setAxisLabelText("g");
    accPlotY.setPoints(velPoints[1]);
    accPlotY.beginDraw();
    accPlotY.drawBox();
    accPlotY.drawXAxis();
    accPlotY.drawYAxis();
    accPlotY.drawTitle();
    accPlotY.drawGridLines(GPlot.BOTH);
    accPlotY.drawLines();
    accPlotY.drawLabels();
    accPlotY.endDraw();
    yprPlotP.setPos(posX, height/4 +50);
    yprPlotP.setDim(dimX, (height)/5);
    yprPlotP.setTitleText("Pos Y ");
    yprPlotP.getXAxis().setAxisLabelText("t[ms]");
    yprPlotP.getYAxis().setAxisLabelText("m/s");
    yprPlotP.setPoints(posPoints[1]);
    yprPlotP.beginDraw();
    yprPlotP.drawBox();
    yprPlotP.drawXAxis();
    yprPlotP.drawYAxis();
    yprPlotP.drawTitle();
    yprPlotP.drawGridLines(GPlot.BOTH);
    yprPlotP.drawLines();
    yprPlotP.drawLabels();
    yprPlotP.endDraw();
    accPlotZ.setPos(25, 2*(height)/4 +75);
    accPlotZ.setDim(dimX, (height)/5);
    accPlotZ.setTitleText("Vel Z ");
    accPlotZ.getXAxis().setAxisLabelText("t[ms]");
    accPlotZ.getYAxis().setAxisLabelText("g");
    accPlotZ.setPoints(velPoints[2]);
    accPlotZ.beginDraw();
    accPlotZ.drawBox();
    accPlotZ.drawXAxis();
    accPlotZ.drawYAxis();
    accPlotZ.drawTitle();
    accPlotZ.drawGridLines(GPlot.BOTH);
    accPlotZ.drawLines();
    accPlotZ.drawLabels();
    accPlotZ.endDraw();
    yprPlotR.setPos(posX, 2*(height)/4 +75);
    yprPlotR.setDim(dimX, (height)/5);
    yprPlotR.setTitleText("Pos z");
    yprPlotR.getXAxis().setAxisLabelText("t[ms]");
    yprPlotR.getYAxis().setAxisLabelText("m/s");
    yprPlotR.setPoints(posPoints[2]);
    yprPlotR.beginDraw();
    yprPlotR.drawBox();
    yprPlotR.drawXAxis();
    yprPlotR.drawYAxis();
    yprPlotR.drawTitle();
    yprPlotR.drawGridLines(GPlot.BOTH);
    yprPlotR.drawLines();
    yprPlotR.drawLabels();
    yprPlotR.endDraw();
  }
  // Disegna il vettore che rappresenta l'orientamento del sensore in uno spazio tridimensionale
  public void drawDirection() {
    sistema.disegnaGriglia();
    for (int i = 0; i < 3; i++) {
      coordinateVersore[i] *= 200.0;
    }
    stroke(0, 0, 0);
    strokeWeight(3);
    line(xi, yi, zi, xi  - coordinateVersore[0], yi +  coordinateVersore[2], zi - coordinateVersore[1]);
  }
  public void drawPoint() {
    sistema.disegnaGriglia();
    stroke(0, 0, 0);
    strokeWeight(3);
    translate(window.mean(window.getAccWindow(), 20)[0]*10, window.mean(window.getAccWindow(), 20)[1] *10, window.mean(window.getAccWindow(), 20)[2]*10);
    sphere( 10);
    translate(-window.mean(window.getAccWindow(), 20)[0]*10, -window.mean(window.getAccWindow(), 20)[1]*10, -window.mean(window.getAccWindow(), 20)[2]*10);
  }
  // Aggiorna i dati ricavati dal sensore e quelli che ne vengono calcolati
  public void updateSensore(String inBuffer) {
    this.inBuffer = inBuffer;
    int l, m;
    for (int i = 0; i <=6; i++) {
      l = inBuffer.length();
      m = inBuffer.indexOf(dataName[i]); 
      data[i] = inBuffer.substring(0, m-1);
      inBuffer = inBuffer.substring(m+1, l);

      if (i==6) {
        if (int(data[i])==1)
          rightClick=true;
        if (int(data[i])==0)
          rightClick=false;

        if (inBuffer.charAt(0)=='1')
          leftClick = true;
        if (inBuffer.charAt(0)=='0')
          leftClick = false;
      }
    }
    if (n>0 && n< 1000) {
      for (int i = 0; i < 3; i++) {
        yprAccensione[i] += float(data[i]);
        ypr[i] = float(data[i]);
      }
    } else if (n==1000) {
      for (int i =0; i<3; i++)
        ypr[i] = float(data[i])-yprAccensione[i]/1000.0f;
    } else {
      adjustYpr();
    }
    if (n < numeroCampioniOffset) {
      for (int i = 0; i < 3; i++)  
        acc[i] = float(data[i+3]);
      calcolaOffset();
    } else if (n==numeroCampioniOffset) {
      for (int i = 0; i < 3; i++) {
        acc[i] = float(data[i+3])- offsetAcc[i] ;
        offsetAcc[i]+=acc[i];
      }
    } else {
      adjustAcc();
    }
    // L'update di velocità e posizione deve essere fatto in questo ordine dopo tutti i calcoli sulle accelerazioni

    if (n>numeroCampioniOffset) {      
      updateDefinitiveAcc();
      updateVelocity();
    }
    updatePosition();
    //aiAcc("exp");
    if ( isRealTimeApplication ) {
      window.shiftWindow(acc, vel, pos, ypr, mouse, definitiveAcc);
    }
    smothingAcc= window.getSmothingAccNow();
    smothingYpr= window.getSmothingYprNow();

    if (n == 0) {
      println("calibrazione");
    }
    if (n == 1000) {
      println("pronto");
    }
    rotate_(0.0, 1.0, 0.0);
    n++;
    if (sampling) {
      createTxt(output);
    }
  }
  // Metodi per gli eventi 
  // cosa succede se draggo
  public void mouseDragged() {
    sistema.mouseDragged();
  }
  // cosa succede se clicco
  public void mousePressed() {
    sampling = samplingButton.buttonPressed(this);

    sistema.mousePressed();
  }// cosa succede quando mollo il click
  public void mouseReleased() {
  }
  public void keyPressed(char key, int keyCode) {
    sistema.keyPressed(key, keyCode);
  }
  public void keyReleased(char key, int keyCode) {
    sistema.keyReleased(key, keyCode);
  }
  private void generateAllPoints() {
    for ( int i = 0; i < 3; i++) {
      if (n>numeroCampioniOffset)
        accPoints[i] = createPoints(window.getDefinitiveAccWindow()[i]);
      else
      accPoints[i] = createPoints(window.getSmothingAccWindow()[i]);
      yprPoints[i] = createPoints(window.getSmothingYprWindow()[i]);
      velPoints[i] = createPoints(window.getVelWindow()[i]);
      posPoints[i] = createPoints(window.getPosWindow()[i]);
    }
  }
  private GPointsArray createPoints(float[] vector) {
    int n = vector.length;
    GPointsArray points = new GPointsArray(n);
    for (int i = 0; i < n; i++) {
      points.add((float)i*tc, vector[i]);
    }
    return points;
  }
  public boolean[] patternRecognition() {
    boolean[] check = new boolean[patterns.size()];
    for ( int i = 0; i < patterns.size(); i++) {
      if (patterns.get(i).getPearsonMean(getActualWindow())>0.6) {
        text("Recognize pattern " +i, width-100, 300); 
        check[i] = true;
      } else
        check[i] = false;
    } 
    return check;
  }
  private float approssima(float[] coefficients, int tzero, String mode) {
    int x=n-tzero;
    if (mode=="exp")
      return coefficients[0]*x*exp(1-pow(x/coefficients[1], 2));
    return coefficients[1]*sin(coefficients[0]*n);
  }
  private float[] calculateCoefficients(float picco, int deltaN, String mode) {
    float[] coefficients = new float[3];
    if (mode=="exp") {
      coefficients[1]=2*pow(deltaN, 2);
      coefficients[0]= (picco/float(- deltaN))*exp(-(1-pow(deltaN/coefficients[1], 2)));
      coefficients[2]= n +3*deltaN;
    }
    if (mode=="sin") {
      coefficients[1]=picco;
      coefficients[0]= PI/(2*deltaN);
      coefficients[2]= n +3*deltaN;
    }
    return coefficients;
  }
  private boolean isMoovementPeak(float[] definitiveAcc, float soglia) {
    int l= definitiveAcc.length;
    if ((isMax(definitiveAcc, 2, l-2, 1)&& definitiveAcc[l-2]>soglia)||(isMin(definitiveAcc, 2, l-2, 1))&& definitiveAcc[l-2]<-soglia) {
      return true;
    }
    return false;
  }
  private boolean isMax(float[] v, int n, int pos, int m) {
    for (int i= pos-n; i<pos+m ||pos+m>v.length; i++)
      if (v[pos]<v[i]) return false;
    return true;
  }
  private boolean isMin(float[] v, int n, int pos, int m) {
    for (int i= pos-n; i<pos+m ||pos+m>v.length; i++)
      if (v[pos]>v[i]) return false;
    return true;
  }
  private void aiAcc(String mode) {
    for (int i = 0; i<3; i++) {
      if (!isMoovement[i]) {
        if (definitiveAcc[i]==0)
          inizio[i]=n;
        if (isMoovementPeak(window.getDefinitiveAccWindow()[i], 0.2)) {
          int l=window.getDefinitiveAccWindow()[i].length;
          positive[i]=isMax(window.getDefinitiveAccWindow()[i], 2, l-2, 1);
          picco[i]=definitiveAcc[i];
          isMoovement[i]=true;
          deltaN[i]=n-inizio[i];
          durata[i]=n+3*deltaN[i];
          if (mode=="sin") {
            tzero[i]=n-deltaN[i];
            coefficients[i]=calculateCoefficients(picco[i], deltaN[i], "sin");
          }
          if (mode=="exp") {
            tzero[i]=n+deltaN[i];
            coefficients[i]=calculateCoefficients(picco[i], deltaN[i], "exp");
          }
        }
      }
      if (isMoovement[i]) {
        if (n<durata[i]) {
          if (mode=="sin")
            definitiveAcc[i]=approssima(coefficients[i], tzero[i], "sin");
          if ( mode=="exp")
            definitiveAcc[i]=approssima(coefficients[i], tzero[i], "exp");
          if (positive[i]) {
            if (vel[i]<0) vel[i]=0;
          }
          if (!positive[i]) {
            if (vel[i]>0) vel[i]=0;
          }
        }  
        if (n==durata[i]) {
          vel[i]=0;
          definitiveAcc[i]=0;
          isMoovement[i]=false;
          inizio[i]=n;
        }
      }
    }
  }
}