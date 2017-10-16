import javax.swing.*;
import java.awt.*;
import javax.swing.event.*;

class Controls extends JFrame {
  
  private JPanel root, sliders;
  private final Insets i = new Insets(0, 10, 0, 10);
  private JLabel lblPasses, lblDownRes, lblQuality;
  private JLabel vPasses, vDownRes, vQuality;
  private JSlider sldPasses, sldDownRes, sldQuality;
  private JCheckBox cbEndUpScl, cbUpScl, cbLinScl;
  
  public Controls() {
    super("Crunch Controls");
    
    root = new JPanel();
    root.setLayout(new BoxLayout(root, BoxLayout.Y_AXIS));
    
    sliders = new JPanel();
    GridBagLayout l = new GridBagLayout();
    sliders.setLayout(l);

    lblPasses  = new JLabel("Passes");
    lblDownRes = new JLabel("Pixels (%)");
    lblQuality = new JLabel("Compression (%)");
    
    vPasses  = new JLabel();
    vDownRes = new JLabel();
    vQuality = new JLabel();
    
    sldPasses  = new JSlider(1, MAX_PASSES);
    sldDownRes = new JSlider(0, (int)(DOWNRES_PRECISION * MAX_DOWNRES));
    sldQuality = new JSlider(0, 100);

    sldPasses.setOrientation(JSlider.HORIZONTAL);
    sldPasses.setMinorTickSpacing(MAX_PASSES / 20);
    sldPasses.setMajorTickSpacing(MAX_PASSES / 5);
    sldPasses.setPaintTicks(true);
    sldPasses.setPaintLabels(true);
    
    sldDownRes.setOrientation(JSlider.HORIZONTAL);
    sldDownRes.setMinorTickSpacing((int)(MAX_DOWNRES * DOWNRES_PRECISION/5) / 6);
    sldDownRes.setMajorTickSpacing((int)(MAX_DOWNRES * DOWNRES_PRECISION/5));
    sldDownRes.setPaintTicks(true);
    sldDownRes.setPaintLabels(true);
    
    sldQuality.setOrientation(JSlider.HORIZONTAL);
    sldQuality.setMinorTickSpacing(5);
    sldQuality.setMajorTickSpacing(20);
    sldQuality.setPaintTicks(true);
    sldQuality.setPaintLabels(true);

    GridBagConstraints c;

    c = new GridBagConstraints();
    c.gridx = 0;
    c.gridy = 0;
    sliders.add(lblPasses, c);

    c = new GridBagConstraints();
    c.gridx = 1;
    c.gridy = 0;
    c.fill = GridBagConstraints.HORIZONTAL;
    c.weightx = 1;
    sliders.add(sldPasses, c);

    c = new GridBagConstraints();
    c.gridx = 2;
    c.gridy = 0;
    sliders.add(vPasses, c);

    c = new GridBagConstraints();
    c.gridx = 0;
    c.gridy = 1;
    sliders.add(lblDownRes, c);
    
    c = new GridBagConstraints();
    c.gridx = 1;
    c.gridy = 1;
    c.fill = GridBagConstraints.HORIZONTAL;
    c.weightx = 1;
    sliders.add(sldDownRes, c);
    
    c = new GridBagConstraints();
    c.gridx = 2;
    c.gridy = 1;
    sliders.add(vDownRes, c);
    
    c = new GridBagConstraints();
    c.gridx = 0;
    c.gridy = 2;
    sliders.add(lblQuality, c);
    
    c = new GridBagConstraints();
    c.gridx = 1;
    c.gridy = 2;
    c.fill = GridBagConstraints.HORIZONTAL;
    c.weightx = 1;
    sliders.add(sldQuality, c);
    
    c = new GridBagConstraints();
    c.gridx = 2;
    c.gridy = 2;
    sliders.add(vQuality, c);
    
    SliderChangeListener clPasses = new SliderChangeListener(vPasses, 1f);
    sldPasses.addChangeListener(clPasses);
    clPasses.update(sldPasses, true);
    
    SliderChangeListener clDownRes = new SliderChangeListener(vDownRes, 1f);
    sldDownRes.addChangeListener(clDownRes);
    clDownRes.update(sldDownRes, true);
    
    SliderChangeListener clQuality = new SliderChangeListener(vQuality, 100f);
    sldQuality.addChangeListener(clQuality);
    clQuality.update(sldQuality, true);
    
    root.add(sliders);
    
    /*cbEndUpScl = new JCheckBox("Scale image to original size when done");
    cbEndUpScl .setAlignmentX( Component.LEFT_ALIGNMENT );
    cbUpScl    = new JCheckBox("Scale image to original size before each pass");
    cbUpScl    .setAlignmentX( Component.LEFT_ALIGNMENT );
    cbLinScl   = new JCheckBox("Proceduarlly scale image");
    cbLinScl   .setAlignmentX( Component.LEFT_ALIGNMENT );
    
    root.add(cbEndUpScl);
    root.add(cbUpScl);
    root.add(cbLinScl);*/
    
    getContentPane().add(root);
    
    pack();
    
    int h = sliders.getHeight();

    Dimension pref;

    int h3 = 320;
    
    pref = new Dimension();
    pref.width = 300;
    pref.height = h3;
    this.setMinimumSize(pref);
    
    pref = new Dimension();
    pref.height = h3;
    pref.width = displayWidth * 2;
    this.setMaximumSize(pref);
    this.setVisible(true);  
  }
  
  class SliderChangeListener implements ChangeListener {
    private final JLabel v;
    private final float factor;
    
    public SliderChangeListener(JLabel v, float factor) {
      this.v = v;
      this.factor = factor;
    }
    
    public void update(JSlider s, boolean force) {
      int pos = s.getValue();
      
      if(!s.getValueIsAdjusting() || force) {
        v.setForeground(Color.BLACK);
        // Ugly hack
        if(s == sldPasses) {
          passes = pos;
        } else if(s == sldDownRes) {
          sclFac = (float)pos / DOWNRES_PRECISION;
        } else if(s == sldQuality) {
          quality = 1f - (pos / 100f);
        }
      } else {
        v.setForeground(Color.BLUE);
      }
      
      String vText;
      if(factor == 1f)
        vText = String.format("%03d", pos);
      else
        vText = String.format("%.2f", pos / factor);
      v.setText(vText);
    }
    
    @Override public void stateChanged(ChangeEvent e) {
      JSlider s = (JSlider) e.getSource();
      update(s, false);
    }
  }
  
  @Override public Insets getInsets() {
    return i;
  }
}