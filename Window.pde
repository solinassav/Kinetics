//La classe finestra contiene le finestre di segnale con come ultimo  //<>// //<>//
public class Window {
  public float[][] derivativeSmothingAccWindow;
  public float[][] smothingDerivativeSmothingAccWindow;
  public float[][] definitiveAccWindow;
  private float[][] accWindow;
  private float[][] smothingAccWindow;
  private float[][] smothingYprWindow;
  private float[][] velWindow;
  private float[][] posWindow;
  private float[][] yprWindow;
  private float[][] mouseWindow;
  private int numberOfSamples;
  private int numberOfElements = 0;
  private int numberOfAxis = 3;
  public Window(int numberOfSamples) {
    this.numberOfSamples = numberOfSamples;
    accWindow = new float[3][numberOfSamples];
    smothingAccWindow = new float[3][numberOfSamples];
    velWindow = new float[3][numberOfSamples];
    posWindow = new float[3][numberOfSamples];
    yprWindow = new float[3][numberOfSamples];
    smothingYprWindow = new float[3][numberOfSamples];
    mouseWindow = new float[3][numberOfSamples];
    derivativeSmothingAccWindow = new float[3][numberOfSamples];
    smothingDerivativeSmothingAccWindow = new float[3][numberOfSamples];
    definitiveAccWindow = new float[3][numberOfSamples];

    for (int j = 0; j<numberOfSamples; j++) {
      for (int i = 0; i<3; i ++ ) {
        mouseWindow[i][j]=0;
        accWindow[i][j]=0;
        velWindow[i][j]=0;
        posWindow[i][j]=0;
        yprWindow[i][j]=0;
        smothingAccWindow[i][j]=0;
        smothingYprWindow[i][j]=0;
        derivativeSmothingAccWindow[i][j]=0;
        derivativeSmothingAccWindow[i][j]=0;
        definitiveAccWindow[i][j]=0;
      }
    }
  }
  public int getWindowSize() {
    return numberOfSamples;
  }
  public float[][] getAccWindow() {
    return accWindow;
  }
  public float[][] getSmothingAccWindow() {
    return smothingAccWindow;
  }
  public float[] getSmothingAccNow() {
    float[]output=new float[3];
    output[0]= this.getSmothingAccWindow()[0][this.getWindowSize()-1];
    output[1]= this.getSmothingAccWindow()[1][this.getWindowSize()-1];
    output[2]=this.getSmothingAccWindow()[2][this.getWindowSize()-1];
    return output;
  }
  public float[][] getSmothingYprWindow() {
    return smothingYprWindow;
  }
  public float[] getSmothingYprNow() {
    float[]output=new float[3];
    output[0]= this.getSmothingYprWindow()[0][this.getWindowSize()-1]*1.1304/1.0602;
    output[1]= this.getSmothingYprWindow()[1][this.getWindowSize()-1]*0.8098/0.6256;
    output[2]= this.getSmothingYprWindow()[2][this.getWindowSize()-1]* 1.3046/0.7419;
    return output;
  }
  public float[][] getVelWindow() {
    return velWindow;
  }
  public float[][] getPosWindow() {
    return posWindow;
  }
  public float[][] getYprWindow() {
    return yprWindow;
  }  
  public float[][] getMouseWindow() {
    return mouseWindow;
  }
  public float[][] getDerivativeSmothingAccWindow() {
    return derivativeSmothingAccWindow;
  }
  public float[][] getSmothingDerivativeSmothingAccWindow() {
    return smothingDerivativeSmothingAccWindow;
  }
  private void setAccWindow(float[] acc) {
    accWindow = shiftMatrix(acc, accWindow);
  }
  private void setDefinitiveAccWindow(float[] acc) {
    definitiveAccWindow = shiftMatrix(acc, definitiveAccWindow);
  }
  public float[][] getDefinitiveAccWindow() {
    return definitiveAccWindow;
  }
  private void setDerivativeSmothingAccWindow(float[] derivativeSmothingAcc) {
    derivativeSmothingAccWindow = shiftMatrix(derivativeSmothingAcc, derivativeSmothingAccWindow);
  }
  private void setSmothingDerivativeSmothingAccWindow(float[] smothingDerivativeSmothingAcc) {
    smothingDerivativeSmothingAccWindow = shiftMatrix(smothingDerivativeSmothingAcc, smothingDerivativeSmothingAccWindow);
  }
  private void setAccWindow(float[][] acc) {
    accWindow = acc;
  }
  private void setVelWindow(float[] vel) {
    velWindow = shiftMatrix(vel, velWindow);
  }
  private void setPosWindow(float[] pos) {
    posWindow = shiftMatrix(pos, posWindow);
  }
  private void setYprWindow(float[] ypr) {
    yprWindow = shiftMatrix(ypr, yprWindow);
  }
  private void setSmothingAccWindow(float[] smothingAcc) {
    smothingAccWindow = shiftMatrix(smothingAcc, smothingAccWindow);
  }
  private void setSmothingYprWindow(float[] smothingYpr) {
    smothingYprWindow = shiftMatrix(smothingYpr, smothingYprWindow);
  }  
  private void setMouseWindow(float[] mouse) {
    mouseWindow = shiftMatrix(mouse, mouseWindow);
  }

  public void shiftWindow(float[] acc, float[] vel, float[] pos, float[] ypr, float[] mouse, float[] definitiveAcc) {
    this.setAccWindow(acc);
    this.setVelWindow(vel);
    this.setPosWindow(pos);
    this.setYprWindow(ypr);
    this.setSmothingAccWindow(mean(this.getAccWindow(), 20));
    this.setSmothingYprWindow(mean(this.getYprWindow(), 10));
    this.setDerivativeSmothingAccWindow(derivative(this.getSmothingAccWindow()));
    this.setSmothingDerivativeSmothingAccWindow(mean(this.getDerivativeSmothingAccWindow(), 10));
    // sull'accelerazione ho 15 campioni di ritardo
    this.setMouseWindow(mouse);
    this.setDefinitiveAccWindow(definitiveAcc);
  }
  private float[][] shiftMatrix(float[] inVector, float[][] inMatrix) {
    for ( int i = 0; i < inVector.length; i++) {
      for (int j = 2; j < numberOfSamples -1; j++) {
        inMatrix[i][j] = inMatrix[i][j+1];
      } 
      inMatrix[i][numberOfSamples -1] = inVector[i];
      inMatrix[i][0] = 1;
      inMatrix[i][1] = -1;
    }
    return inMatrix;
  }
  public float[] mean(float[][] inMatrix, int n) {
    float sumY = 0;
    float[] mean = new float [numberOfAxis];
    for (int i = 0; i < numberOfAxis; i++) {
      sumY=0;
      for (int j = numberOfSamples - 1; j > numberOfSamples-n-1; j--) {
        sumY+=inMatrix[i][j];
      }
      if (numberOfElements == 1)
        mean[i] = sumY/2;
      else
        mean[i] = sumY/(float)n;
    }
    return mean;
  }
  public float[] derivative(float[][] inMatrix) {
    float[] derivative = new float [numberOfAxis];
    for (int i = 0; i < numberOfAxis; i++) {
      derivative[i] =(inMatrix[i][numberOfSamples-1] - inMatrix[i][numberOfSamples-2] );
      if (derivative[i]>-0.008 && derivative[i]<0.008)
        derivative[i]=0;
    }
    return derivative;
  }
  public float derivative(float[] inVector) {
    float derivative = 0;
    for (int i = 0; i < numberOfAxis; i++) {
      derivative =inVector[numberOfSamples-1] - inVector[numberOfSamples-2];
    }
    return derivative;
  }
  public float mean(float[] inVector, int n) {
    float sumY = 0;
    sumY=0;
    for (int j = numberOfSamples - 1; j > numberOfSamples-n-1; j--) {
      sumY+=inVector[j];
    }
    if (numberOfElements == 1)
      sumY = sumY/2;
    else
      sumY = sumY/(float)n;
    return sumY;
  }
  public float[] slopOfLinearRegression(float[][] inMatrix, float tc) {
    float sumX = 0;
    float sumY = 0;
    float sumXY= 0;
    float sumX2= 0;
    float[] slope = new float [numberOfAxis];
    for (int i = 0; i < numberOfAxis; i++) {
      for (int j = numberOfSamples - 1; j >= numberOfSamples*3/4; j--) {
        sumX+= tc*j;
        sumX2+=(tc*j)*(tc*j);
        sumY+=inMatrix[i][j];
        sumXY+=tc*j*inMatrix[i][j];
      }
      if (numberOfElements == 1)
        slope[i] = (2*sumXY -sumX*sumY)/(2*sumX2 -sumX*sumX);
      else
        slope[i] = (numberOfElements/4 *sumXY -sumX*sumY)/(numberOfElements/4 *sumX2 -sumX*sumX);
    }
    return slope;
  }
  
}