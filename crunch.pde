import java.nio.file.*;

// How often the image gets encoded to JPEG
int passes; 

// How "good" the image will look
float quality;

// The final image size
float sclFac;

// Scaling method
// false=Immediately scale image,
// true=bring the image closer to end dimensions every step
boolean linearScale = true;

// Bring image to original size after every compression?
boolean steppedUpScale = true;

// Bring image to original size afterwards?
boolean upScale = true;

PImage orig, enc;
PFont font;

int topX, topY, topH;
int ifoX, ifoY, ifoH;
int botX, botY, botH;
float ifoStackHeight = 0.1f;

BufferedImage origImg;
Thread w;
volatile int currentPass;
final SuccEs oBuf = new SuccEs();

volatile boolean requireRedraw, error, done;

// Settings
static final int MAX_PASSES = 500;
static final float MAX_DOWNRES = 1.5f;
static final int DOWNRES_PRECISION = 100;

Controls c;

void setup() {
  size(500, 800, FX2D);
  println("SQUEEEEEEZE");
  
  font = createFont("Sans Serif", 25);
  c = new Controls();
  
  topX = 0;
  topY = 0;
  topH = (int)((1f - ifoStackHeight)/2 * height);
  
  ifoX = 0;
  ifoY = topH;
  ifoH = (int)(ifoStackHeight * height);
  
  botX = 0;
  botY = ifoY + ifoH;
  botH = topH;
  
  textFont(font);
  
  render();
}

void draw() {
  if(!requireRedraw)
    return;
  
  render();
  requireRedraw = false;
}

void mousePressed() {
  if(mouseButton != LEFT)
    return;
  
  if(mouseX < 0 || mouseX > width || mouseY < 0 || mouseY > height)
    return;
  
  if(mouseY < topH) {
    // Top clicked
    selectInput("Select image to JPEG-crunch", "processImg");
  } else if(mouseY < ifoY+ifoH) {
    // Ifo clicked
    if(done)
      startWorker(null);
  } else {
    // Bot clicked
    if(done)
      selectOutput("Select path for crunched JPEG", "saveResult");
  }
}

void processImg(File f) {
  if(f == null) return;
  
  startWorker(f);
  System.out.printf("Started processing %s\n", f);  
}

void startWorker(File f) {
  if(w != null) {
    w.stop();
    enc = null;
    w = null;
    
    currentPass = 0;
  }
  
  w = new Thread(new Worker(f));
  w.start();
}

void saveResult(File f) {
  try {
    Path p = f.toPath();
    String pStr = p.toString();
    // No file ending
    if(!pStr.contains(".jp")) {
      pStr += ".jpg";
      Path newPath = Paths.get(pStr);
      if(Files.notExists(newPath))
        p = Paths.get(pStr);
    }
    
    Files.copy(oBuf.getIStream(), p, StandardCopyOption.REPLACE_EXISTING);
  } catch(IOException e) {
    e.printStackTrace();
  }
}

void render() {
  background(0xCC);
  
  drawTop();
  drawIfo();
  drawBot();
  
  if(error) {
    fill(255, 0, 0);
    textAlign(CENTER);
    textSize(500);
    text("!", width/2, height*0.66f);
  }
}

void drawTop() {
  if(orig == null) {
    strokeWeight(10);
    stroke(0xCC);
    fill(0x55);
    rect(topX, topY, width, topH);
    textAlign(CENTER);
    textSize(25);
    fill(0xFF);
    text("Click to load input image", width/2, topY + topH / 2);
  } else {
    noStroke();
    if(orig.width != width || orig.height != topH) {
      orig.resize(width, topH);
    }
    image(orig, topX, topY);
  }
}

void drawIfo() {
  // Draw progress bar
  if(currentPass != 0) {
    float progress = (float)currentPass/passes;
    float barWidth = progress * width;
    fill(0x77, 0xFF, 0x77);
    noStroke();
    rect(ifoX, ifoY, barWidth, ifoH);
  } else if(done) {
    fill(0x33); // x3 xD x0
    textSize(18);
    text("Repeat", width/2, ifoY + ifoH / 2);
  }
}

void drawBot() {
  if(enc == null) {
    strokeWeight(10);
    stroke(0xCC);
    fill(0x55);
    rect(botX, botY, width, botH);
    textAlign(CENTER);
    textSize(25);
    fill(0xFF);
    text("Got no output yet", width/2, botY + botH / 2);
  } else {
    if(done) {
      noStroke();
    } else {
      strokeWeight(10);
      stroke(0xCC);
    }
    if(enc.width != width || enc.height != botH) {
      enc.resize(width, botH);
    }
    image(enc, botX, botY);
  }
}