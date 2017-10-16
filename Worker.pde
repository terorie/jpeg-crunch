import java.awt.image.BufferedImage;
import java.io.ByteArrayInputStream;
import java.io.ByteArrayInputStream;
import javax.imageio.*;
import javax.imageio.plugins.jpeg.JPEGImageWriteParam;

class Worker implements Runnable {
  private File inFile;
  
  public Worker(File inFile) {
    this.inFile = inFile;
  }
  
  @Override public void run() {
    // Read file
    try {
      if(inFile != null) {
        origImg = ImageIO.read(inFile);
        println("Done reading file into memory.");
        orig = new PImage(origImg);
      }
      
      if(passes == 0) {
        println("Zero passes.");
        enc = orig;
      } else {
        BufferedImage img = origImg;
        ImageWriter w = ImageIO.getImageWritersByFormatName("jpg").next();
        
        // Immediate Resize
        if(!linearScale && sclFac != 1f) {
          int tgtW = (int)(img.getWidth() * sclFac);
          int tgtH = (int)(img.getHeight() * sclFac);
          int srcW = img.getWidth();
          int srcH = img.getHeight();
          img = resizeImg(img, tgtW, tgtH);
          System.out.printf("Immediate image scaling from %dx%d to %dx%d\n", srcW, srcH, tgtW, tgtH);
        }
        
        for(currentPass = 0; currentPass < passes; ++currentPass) {
          long beginTime = System.currentTimeMillis();

          // Per-step up scale
          if(steppedUpScale && currentPass != 0) {
            int srcW = img.getWidth();
            int srcH = img.getHeight();
            int tgtW = origImg.getWidth();
            int tgtH = origImg.getHeight();
            img = resizeImg(img, tgtW, tgtH);
            System.out.printf("\tPass #%d: Image rescaling from %dx%d to original size\n", currentPass, srcW, srcH);
          }

          // Linear Resize
          if(linearScale && sclFac != 1f) {
            float deltaScl = sclFac - 1;
            float deltaSubScl = deltaScl * ((float) (currentPass+1) / passes);
            float subScl = 1f + deltaSubScl;
            int srcW = origImg.getWidth();
            int srcH = origImg.getHeight();
            int tgtW = (int)(srcW * subScl);
            int tgtH = (int)(srcH * subScl);
            img = resizeImg(img, tgtW, tgtH);
            System.out.printf("\tPass #%d: Linear image rescaling from %dx%d to %dx%d\n", currentPass, srcW, srcH, tgtW, tgtH);
          }
          
          // Encode
          JPEGImageWriteParam jpeg = new JPEGImageWriteParam(null);
          jpeg.setCompressionMode(ImageWriteParam.MODE_EXPLICIT);
          jpeg.setCompressionQuality(quality);
          w.setOutput(ImageIO.createImageOutputStream(oBuf.getOStream()));
          w.write(img);
          System.out.printf("\tPass #%d: Encoded image\n", currentPass);
          
          // Decode
          img = ImageIO.read(oBuf.getIStream());
          System.out.printf("\tPass #%d: Decoded image\n", currentPass);

          // Display in processing
          enc = new PImage(img);
          requireRedraw = true;
       
          long endTime = System.currentTimeMillis();
          System.out.printf("Done pass #%02d in %05d ms\n", currentPass, endTime-beginTime);
        }
        
        // Final rescale
        if(upScale) {
          int srcW = img.getWidth();
          int srcH = img.getHeight();
          int tgtW = origImg.getWidth();
          int tgtH = origImg.getHeight();
          img = resizeImg(img, tgtW, tgtH);
          System.out.printf("Final rescaling from %dx%d to original size\n", currentPass, srcW, srcH);
        }
      }
      currentPass = 0;
    } catch(Exception e) {
      e.printStackTrace();
      error = true;
    } catch(ThreadDeath e) {
      println("Rest in peace thread.");
      return;
    }
    
    println("Done.");
    requireRedraw = done = true;
  }
  
  public BufferedImage resizeImg(BufferedImage src, int tgtW, int tgtH) {
    if(src.getWidth() == tgtW && src.getHeight() == tgtH)
      return src;
      
    if(tgtW < 1) tgtW = 1;
    if(tgtH < 1) tgtH = 1;
    
    Image sclImg = src.getScaledInstance(tgtW, tgtH, Image.SCALE_FAST);
    BufferedImage img = new BufferedImage(tgtW, tgtH, BufferedImage.TYPE_INT_RGB);
    
    Graphics2D g2d = img.createGraphics();
    g2d.drawImage(sclImg, 0, 0, null);
    g2d.dispose();
    
    return img;
  }
}