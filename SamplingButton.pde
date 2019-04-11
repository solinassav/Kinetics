public class SamplingButton extends Button {
  private boolean sampling;
  private int setNumber;
  private color normalColor;
  public SamplingButton(float rectX, float rectY, float rectSize, color rectColor, color rectHighlight ) {
    super(rectX, rectY, rectSize, rectColor, rectHighlight );
    setNumber = 1;
    sampling =false;
  }
  public boolean buttonPressed(InertialSensor sensor) {
    if (super.rectOver) {
      if (!sampling) {
        invertColor();       
        sampling = true;
      } else {
        invertColor(); 
        sensor.closeTxt(sensor.output);
        sensor.setPattern(new Pattern(sensor.getActualWindow(), "Pattern "+ setNumber));
        sampling = false;
        sensor.output = createWriter(sensor.fileName +" number " + setNumber +".txt");
        setNumber++;
      }
    }
    return sampling;
  }
  private void invertColor() {
    normalColor=super.rectColor;
    super.rectColor=super.rectHighlight;
    super.rectHighlight=normalColor;
  }
}