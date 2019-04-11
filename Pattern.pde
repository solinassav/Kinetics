public class Pattern {
  private String label;
  float[] pearsonAcc = new float[3];
  float[] pearsonYpr = new float[3];
  Window pattern;
  public Pattern(Window window, String label) {
    pattern = new Window(window.getWindowSize());
    this.label =label;
    pattern.setAccWindow(window.getAccWindow());
  }
  public String getLabel() {
    return label;
  }
  public float getPearsonMean(Window window) {
    getPearsonAcc(window);
    getPearsonYpr(window);
    float output = 0;
    for (int i=0; i<3; i++) {
      output+=pearsonAcc[i];
      output+=pearsonYpr[i];
    }

    return output/6.0f;
  }
  public float[] getPearsonAcc(Window window) {
    for (int i = 0; i<3; i++) {
      pearsonAcc[i] = pearson( window.getAccWindow()[i], pattern.getAccWindow()[i]);
    }
    return pearsonAcc;
  }
  public float[] getPearsonYpr(Window window) {
    for (int i = 0; i<3; i++) {
      pearsonYpr[i] = pearson(window.getYprWindow()[i], pattern.getYprWindow()[i]);
    }
    return pearsonYpr;
  }
  private float pearson(float[] x, float[] y) {

    float meanX = 0; 
    float meanY = 0; 
    float covariance = 0; 
    float varianceX = 0; 
    float varianceY = 0; 
    float den=0; 
    for (int i = 0, j= 0; i< x.length-1 && j< y.length-1; i++, j++) {
      meanX += x[i]; 
      meanY += y[i];
      covariance += x[i]*y[i]; 
      varianceX+= x[i]*x[i]; 
      varianceY+= y[i]*y[i];
    }
    meanX/= (float) x.length; 
    meanY/= (float) y.length; 
    varianceX-=x.length*meanX*meanX;
    varianceY-=x.length*meanY*meanY;
    covariance -= x.length*meanX*meanY;
    den=sqrt(varianceX*varianceY); 
    println(covariance/den);
    if (covariance==den)
      return 1;

    return covariance/den;
  }
}