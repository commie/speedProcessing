//import java.awt.event.*;

import java.util.Scanner;
import java.util.Date;
import java.util.Calendar;
import java.text.DateFormat;


RangeControl speedControl;
RangeControl timeControl;
RangeControl distanceControl;

NumberControl decayControl;
NumberControl ffControl;

LineDrawer lineDrawer;

int desiredFrameRate = 30;

int mapWidth;
int mapHeight;

// Readme /////////////////////////////////////////////////

// 1. In setup(), 
//    a. set size(..), mapWidth and mapHeight to desired size,
//    b. set filePath to the current file,
//    c. manually update, if needed, the "lo" and "hi" values for filter controls for speed, duration and distance.
// 
// 2. Right below this block, set the desired center point for the stereographic projection and the desired zoom level.

// ////////////////////////////////////////////////////////

//float centerLat = radians( 39.8);     // contiguous US centroid
//float centerLon = radians(-98.6);

 float centerLat = radians(  0.0);     // western hemisphere
 float centerLon = radians(-85.0);

 //float centerLat = radians( 40.6968);  // Manhattan
 //float centerLon = radians(-74.0284);

// float centerLat = radians( 41.8369);  // Chicago
// float centerLon = radians(-87.6847);

float zoomScaleFactor = 1;  // 1.0 shows the entire hemisphere; 4.0 is good for contiguous US; tried 120 for Chicago; 600/400 for Manhattan


  
  

void setup () {
  
  // Add custom mouse wheel listener
  // http://wiki.processing.org/w/Wheel_mouse
  
  //addMouseWheelListener(new MouseWheelListener() {
  //  public void mouseWheelMoved(MouseWheelEvent mwe) { 
  //    mouseWheel(mwe.getWheelRotation());
  //  }
  //});
  

  //
  // Canvas setup
  //
  
  size(2000, 1300);

  mapWidth    = 2000;
  mapHeight   = 1300;

  // zoomOffsetX = (zoomScaleFactor - 1) * (0.5 * mapWidth);
  // zoomOffsetY = (zoomScaleFactor - 1) * (0.5 * mapHeight);

  // zoomScaleFactor = zoomScaleFactor * mapHeight;
  
  background(0);
  frameRate(desiredFrameRate);

  // colorMode(RGB, 255, 255, 255, 1000);
 
  
  //
  // Thread setup
  //
  
  // String filePath = "C:/Sasha/noBackup/data/movement/distributedReader.2.1.twitterCrawler01.2017.12.merged.movement.out";
  String filePath = "D:/Andrei/distributedReader.2.1.twitterCrawler01.2017.12.merged.movementOnly.out";
  
  LineReader lineReader = new LineReader(filePath);
  Thread readerThread = new Thread(lineReader);
  
  // Instead of running lineDrawer inside a thread, run it in the draw() method.
  lineDrawer = new LineDrawer(lineReader, readerThread);
  
  readerThread.start();
  



  //
  // Controls setup
  //
  
  float controlWidth = 80;

  //                                 x                          y                                      width         label      lo hi     min step
  //speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     0, 800,   0,  1);      // MPH
  //timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "seconds", 3600, 604800, 0,  10);  // seconds; week is 604800, day is 86400, 12 hrs is 43200, 1 hour is 3600
  //distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   0, 12500, 0,  10);      // miles; 12,500 is half the globe
  
  //class 0 'Twitting still' <2hr   <1 mile 
  //speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     0, 800,   0,  1);      // MPH
  //timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "minutes", 0, 7200, 0,  10); // sec
  //distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   0, 1,  0,  10); // miles
  
  //class 1 'Daily life' >22000sec   <31 mile 
  //speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     0, 800,   0,  1);      // MPH
  //timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "minutes", 0, 22000, 0,  10); // sec
  //distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   0, 31,  0,  10); // miles
  
  // //class 2 'Car-like' >15mph <75mph >3mile  <255 mile
  //speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     15, 75,   0,  1);      // MPH
  //timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "minutes", 0, 604800, 0,  10); // sec
  //distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   3, 255,  0,  10); // miles
  
  //class 3  air travel + late report  >75mph < 650mph >255mile
  //speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     75, 650,   0,  1);      // MPH
  //timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "minutes", 0, 604800, 0,  10); // sec
  //distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   255, 13000,  0,  10); // miles
     
  ////class 4 fast  >75mph >148sec < 3600 sec  
  //speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     75, 10000000,   0,  1);      // MPH
  //timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "minutes", 148, 3600, 0,  10); // sec
  //distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   0, 13000,  0,  10); // miles
  
  // //class 5 fast n furious  <148s >1200mile 
  //speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     0, 15000000,   0,  1);      // MPH
  //timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "minutes", 0, 148, 0,  10); // sec
  //distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   1200, 13000,  0,  10); // miles
  
  ////class 6 "good"  <650mph
  //speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     0, 650,   0,  1);      // MPH
  //timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "minutes", 0, 604800, 0,  10); // sec
  //distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   0, 13000,  0,  10); // miles
  
  //class 7 "not too fast"  >75mph <650mph >148sec <3600 sec
  speedControl    = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 3.6), controlWidth, "mph",     75, 650,   0,  1);      // MPH
  timeControl     = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth * 2.3), controlWidth, "minutes", 148, 3600, 0,  10); // sec
  distanceControl = new RangeControl(round(controlWidth * 0.8), round(mapHeight - controlWidth),       controlWidth, "miles",   0, 13000,  0,  10); // miles
  
  decayControl = new NumberControl(round(controlWidth * 2.1), round(mapHeight - controlWidth * 3.05), controlWidth, "decay", lineDrawer.getDecay(), false, 0.0, 100.0);
  ffControl = new NumberControl(round(controlWidth * 2.1), round(mapHeight - controlWidth * 1.75), controlWidth, "minutes/s", lineDrawer.getMinutesPerSecond(), false, 1.0, 60.0);  
  
}

void draw () {
  lineDrawer.run();
}




//
// Event listeners
//

void mouseMoved() {

  speedControl.onMouseMove(mouseX, mouseY);
  timeControl.onMouseMove(mouseX, mouseY);
  distanceControl.onMouseMove(mouseX, mouseY);
  decayControl.onMouseMove(mouseX, mouseY);
  ffControl.onMouseMove(mouseX, mouseY);
}

void mousePressed() {
//  aSlider.mousePressed();
}

void mouseReleased() {
//  aSlider.mouseReleased();
}

//void mouseWheel(int delta) {

//  speedControl.onMouseWheel(delta, mouseX, mouseY);
//  timeControl.onMouseWheel(delta, mouseX, mouseY);
//  distanceControl.onMouseWheel(delta, mouseX, mouseY);
//  decayControl.onMouseWheel(delta, mouseX, mouseY);
//  ffControl.onMouseWheel(delta, mouseX, mouseY);
//}

void mouseWheel(MouseEvent event) {
  
  int delta = event.getCount();

  speedControl.onMouseWheel(delta, mouseX, mouseY);
  timeControl.onMouseWheel(delta, mouseX, mouseY);
  distanceControl.onMouseWheel(delta, mouseX, mouseY);
  decayControl.onMouseWheel(delta, mouseX, mouseY);
  ffControl.onMouseWheel(delta, mouseX, mouseY);
}



//
// Classes
//

class LineDrawer implements Runnable {
  
  private LineReader lineReader;
  private Thread readerThread;
  
  private Object[] newBatch;
  
  private long[] timestamp;
  private int[] duration;//, distance, speed; 
  private float[] distance, speed; 
  private float[] lat1, lon1, lat2, lon2;
  
  private int idxInBatch;            // position in the current batch
  private int batchLength;           // batch size

  private long msPerFrame = 120000;   // 30,000 ms per frame is 15 minutes per second @ 30 FPS (20k is 10', 10k is 5', 2k is 1')
  private long nextFrame = 0;
  
  private Boolean drawing;

  private Calendar calendar = Calendar.getInstance();
  
  private long recordsDrawn = 0;
  private long recordsTotal = 8297398;  // from line count for distributedReader.2.1.twitterCrawler01.2017.12.merged.movementOnly.out
  
  private float hourHandAngle;
  private float minuteHandAngle;
  
  private int decayRate = 0;    // 255: 12.75 or 13 = 5% opacity, 2.55 = 1% opacity
  
  private int timeLo = 0;
  private int speedLo = 0;
  private int distLo = 0;
  
  private int timeHi = Integer.MAX_VALUE; 
  private int speedHi = Integer.MAX_VALUE;
  private int distHi = Integer.MAX_VALUE; 

  private float cosCenterLat, sinCenterLat;
  
  // Contructor
  LineDrawer (LineReader lineReader, Thread readerThread) {
    
    this.lineReader = lineReader;
    this.readerThread = readerThread;
    
    this.drawing = false;

    // update projection parameters
    cosCenterLat = cos(centerLat);
    sinCenterLat = sin(centerLat);
    
    // Request 1st batch
    lineReader.requestNewBatch();
  }
  
  
  void run () {
    
    long currTimestamp = 0;
    int currDuration;//, currDistance, currSpeed;
    float currDistance, currSpeed;
    float x1, y1, x2, y2;

    float[] projectedLine;
    
    float screenDist;
    float transp;

    float latShift, lonShift;
    
    String prettyPercent;
      
    if (drawing) {
      
      // Paint over the old data
      
      noStroke();
      fill(0, decayRate);
      rectMode(CORNER);
      
      rect(0, 0, mapWidth, mapHeight);
      
      
      // Draw a slice of the current batch
      
      while ((currTimestamp < nextFrame) && (idxInBatch < batchLength)) {  // (recDrawn < recToDraw)
        
        currTimestamp = timestamp[idxInBatch];
        
        currDuration = duration[idxInBatch];
        currDistance = distance[idxInBatch];
        currSpeed = speed[idxInBatch];
        
        // y1 = ( 90 - lat1[idxInBatch] - 40) * (mapHeight / mapHeightDeg);  // lat 1
        // x1 = (180 + lon1[idxInBatch] - 54) * (mapWidth / mapWidthDeg);    // lon 1
        // y2 = ( 90 - lat2[idxInBatch] - 40) * (mapHeight / mapHeightDeg);  // lat 2
        // x2 = (180 + lon2[idxInBatch] - 54) * (mapWidth / mapWidthDeg);    // lon 2

        // if (timeLo <= currDuration && currDuration < timeHi &&
        //     distLo <= currDistance && currDistance < distHi && 
        //     speedLo <= currSpeed && currSpeed < speedHi ) {
          
        //   screenDist = dist(x1, y1, x2, y2);
          
        //   transp = 250 - sqrt(screenDist * 50);
        //   stroke(255, transp);
        //   strokeWeight(1);
          
        //   line(x1, y1, x2, y2);          
        // }

        projectedLine = projectLine(lat1[idxInBatch], lon1[idxInBatch], lat2[idxInBatch], lon2[idxInBatch]);

        if (projectedLine != null) {

          x1 = (projectedLine[0] + 1) * 0.5;// * mapHeight;  // after rotation, x and y are in the range of 0..2, hence 0.5 multiple to make them scale to map width correctly;
          x2 = (projectedLine[2] + 1) * 0.5;// * mapHeight;  // multiply all by map height to keep scale same along both axes

          y1 = (1 - projectedLine[1]) * 0.5;// * mapHeight;
          y2 = (1 - projectedLine[3]) * 0.5;// * mapHeight;

          // zoom into the center (i.e. 0.5 * mapWidth) of the screen

          // x1 = x1 * zoomScaleFactor - zoomOffsetX;
          // x2 = x2 * zoomScaleFactor - zoomOffsetX;

          // y1 = y1 * zoomScaleFactor - zoomOffsetY;
          // y2 = y2 * zoomScaleFactor - zoomOffsetY;


          // scale to screen height, zoom and center horizontally

          // x1 = (x1 * mapHeight * zoomScaleFactor - mapWidth * 0.5 * zoomScaleFactor + mapWidth * 0.5) + 0.5 * (mapWidth - mapHeight) * zoomScaleFactor;
          // x2 = (x2 * mapHeight * zoomScaleFactor - mapWidth * 0.5 * zoomScaleFactor + mapWidth * 0.5) + 0.5 * (mapWidth - mapHeight) * zoomScaleFactor;

          // y1 = (y1 * mapHeight * zoomScaleFactor - mapHeight * 0.5 * zoomScaleFactor + mapHeight * 0.5);
          // y2 = (y2 * mapHeight * zoomScaleFactor - mapHeight * 0.5 * zoomScaleFactor + mapHeight * 0.5);

          x1 = (x1 - 0.5) * mapHeight * zoomScaleFactor + mapWidth * 0.5;
          x2 = (x2 - 0.5) * mapHeight * zoomScaleFactor + mapWidth * 0.5;

          y1 = (y1 - 0.5) * mapHeight * zoomScaleFactor + mapHeight * 0.5;
          y2 = (y2 - 0.5) * mapHeight * zoomScaleFactor + mapHeight * 0.5;


          if (timeLo <= currDuration & currDuration < timeHi &
            distLo <= currDistance & currDistance < distHi & 
            speedLo <= currSpeed & currSpeed < speedHi ) {
            
            screenDist = dist(x1, y1, x2, y2);
            
            // set line opacity as a function of its length
           // transp = 250 - sqrt(screenDist * 50);

            // set fixed line opacity
             transp = 1;
            
            stroke(255, transp);
            strokeWeight(1);
            
            line(x1, y1, x2, y2);          
          }

        } else {

          // this line isn't drawn as one of it's point is "behind" the projected map
        }
        
        // Update counters
        idxInBatch++;
        recordsDrawn++;
      }
      
      
      // Draw clock
      
      calendar.setTimeInMillis(currTimestamp);
      
      hourHandAngle   = TWO_PI * (calendar.get(Calendar.HOUR_OF_DAY) + ((float) calendar.get(Calendar.MINUTE)) / 60) / 24;
      minuteHandAngle = TWO_PI * (calendar.get(Calendar.MINUTE) + ((float) calendar.get(Calendar.SECOND)) / 60) / 60; 
      
      drawClock (hourHandAngle, minuteHandAngle);
      
      
      // Draw the controls
      
      speedControl.run();
      timeControl.run();
      distanceControl.run();
      decayControl.run();
      ffControl.run();
      
      
      // Read control values
      
      setMsPerFrame(round(ffControl.getNumber()));  
      setDecayRate(round(decayControl.getNumber()));  
      
      timeLo = timeControl.getLoNumber();
      timeHi = timeControl.getHiNumber();
      
      distLo = distanceControl.getLoNumber();
      distHi = distanceControl.getHiNumber();
      
      speedLo = speedControl.getLoNumber();
      speedHi = speedControl.getHiNumber();
      
      
      // Only draw so far in time for the current frame
      
      if (!(currTimestamp < nextFrame)) {
        
        // I could set nextFrame to currTimestamp + msPerFrame but,
        // if currentTimestamp is too far into the future, I might
        // effectively skip frames.
        
        nextFrame += msPerFrame;
      }
      
      
      // Stop drawing, if hit the last record in the current batch
      
      if (!(idxInBatch < batchLength)) {
        
        drawing = false;
        
        //calendar.setTimeInMillis(currTimestamp);
        println("Timestamp of last record drawn: " + prettyDayOfWeek(calendar.get(Calendar.DAY_OF_WEEK)) + " " + (calendar.get(Calendar.MONTH) + 1) + "/" + calendar.get(Calendar.DAY_OF_MONTH) + " " + calendar.get(Calendar.HOUR_OF_DAY) + ":" + calendar.get(Calendar.MINUTE));
        
        prettyPercent = String.format("%.3f", ((float) recordsDrawn / recordsTotal) * 100);
        println("Drawing rate: " + frameRate + " fps, " + prettyPercent + "% of all records drawn so far.");
      }
      
    } else {
      
      // Check if the new batch has already been uploaded
      
      try {
      
        newBatch = lineReader.waitForNewBatch();     // This call will return immediately if new 
                                                     // batch is already there, and will cause 
                                                     // this thread to sleep if there's no new 
                                                     // data yet.
        
        timestamp = (long[]) newBatch[0];
        
        duration  = (int[]) newBatch[1];
        distance  = (float[]) newBatch[2];
        speed     = (float[]) newBatch[3]; 
        
        lat1 = (float[]) newBatch[4];
        lon1 = (float[]) newBatch[5];
        lat2 = (float[]) newBatch[6];
        lon2 = (float[]) newBatch[7];
        
        idxInBatch  = 0;
        batchLength = lat1.length;
        
        currTimestamp = timestamp[0];
        
        if (nextFrame == 0) {
          // Initialize nextFrame first time the app is run
          nextFrame = currTimestamp + msPerFrame;
        }
        
        //println("LineDrawer retrieved new batch.");
        
        // Put in a request for the next batch
        //println("LineDrawer requests next batch.");
        lineReader.requestNewBatch();
        
        // Now good to start drawing
        drawing = true;
        //println("LineDrawer is processing the current batch...");        
        
      } catch (InterruptedException e) {
        
        println("InterruptedException in LineDrawer.run() while waiting for a request");
        
        // Kill thread if interrupted
        return;
      }
      
      // End of else
    }
    
    // End of run()
  }
  
  
  private void drawClock (float hourHandAngle, float minuteHandAngle) {
    
    int clockWidth = 100;
    int clockPadding = 20;
        
    int hourHandWidth = 10;
    int hourHandHeight = clockWidth / 2 - hourHandWidth;
    
    int minuteHandWidth = 6;
    int minuteHandHeight = clockWidth / 2;
    
    pushMatrix();
  
      int x = mapWidth - round(clockWidth * 1.5);
      int y = mapHeight - round(clockWidth * 2.3);
  
      // Move to where the control belongs
      translate(x + clockPadding, y - clockPadding / 2);
      
      // Blank out the area under the control
      noStroke();
      fill(0);  // 255: 12.75 = 5% opacity, 2.55 = 1% opacity
      rectMode(CENTER);
      rect(0, 0, clockWidth + 5, clockWidth + 5);
      
      // Draw the dial
      
      pushMatrix();
      
        rotate(PI);
        
        noStroke();
        fill(255, 40);
        ellipseMode(CENTER);
        
        arc(0.0, 0.0, (float) clockWidth, (float) clockWidth, 0, PI);
      
      popMatrix();
      
      // Plot hour hand
      pushMatrix();
        
        rotate(hourHandAngle);
        
        noStroke();
        fill(255, 80);  // 255: 12.75 = 5% opacity, 2.55 = 1% opacity
        rectMode(CORNER);
        
        rect(-hourHandWidth / 2, -hourHandWidth / 2, hourHandWidth, hourHandHeight);
      
      popMatrix();
      
      // Plot minute hand
      pushMatrix();
        
        rotate(PI);  // minute clock should point up at 0 minutes of every hour
        rotate(minuteHandAngle);
        
        noStroke();
        fill(255, 120);  // 255: 12.75 = 5% opacity, 2.55 = 1% opacity
        rectMode(CORNER);
        
        rect(-minuteHandWidth / 2, -minuteHandWidth / 2, minuteHandWidth, minuteHandHeight);
      
      popMatrix();
      
    popMatrix();
   
  }
  
  private String prettyDayOfWeek (int dayOfWeek) {
    
    String weekDay = "not a proper day";
    
    if (Calendar.MONDAY == dayOfWeek) {
        weekDay = "Mon";
    } else if (Calendar.TUESDAY == dayOfWeek) {
        weekDay = "Tue";
    } else if (Calendar.WEDNESDAY == dayOfWeek) {
        weekDay = "Wed";
    } else if (Calendar.THURSDAY == dayOfWeek) {
        weekDay = "Thu";
    } else if (Calendar.FRIDAY == dayOfWeek) {
        weekDay = "Fri";
    } else if (Calendar.SATURDAY == dayOfWeek) {
        weekDay = "Sat";
    } else if (Calendar.SUNDAY == dayOfWeek) {
        weekDay = "Sun";
    }
    
    return weekDay;
  }
  
  private void setMsPerFrame (int minutesPerSecond) {
    msPerFrame = round(minutesPerSecond * 60 * 1000 / desiredFrameRate);
  }  
  
  private void setDecayRate (int decay) {
    decayRate = round(2.55 * decay);
  }

  private float[] projectLine (float lat1, float lon1, float lat2, float lon2) {

    // stereographic projection with the earth radius set to 1
    // output x and y in the range of -1 to +1

    float x1, y1, x2, y2;
    float[] projectedLine = null;  // defaults to null

    lat1 = radians(lat1);
    lon1 = radians(lon1);
    lat2 = radians(lat2);
    lon2 = radians(lon2);

    // check if both points should be drawn
    float visibilityCheck1 = sinCenterLat * sin (lat1) + cosCenterLat * cos(lat1) * cos(lon1 - centerLon); // centerLon is defined at the start of the sketch
    float visibilityCheck2 = sinCenterLat * sin (lat2) + cosCenterLat * cos(lat2) * cos(lon2 - centerLon);

    if (visibilityCheck1 >= 0 & visibilityCheck2 >= 0) {

      x1 = cos(lat1) * sin(lon1 - centerLon);
      x2 = cos(lat2) * sin(lon2 - centerLon);

      y1 = cos(centerLat) * sin(lat1) - sin(centerLat) * cos(lat1) * cos(lon1 - centerLon);
      y2 = cos(centerLat) * sin(lat2) - sin(centerLat) * cos(lat2) * cos(lon2 - centerLon);

      projectedLine = new float[4];

      projectedLine[0] = x1;  // x and y are in the range of 0..1, y increasing "up"
      projectedLine[1] = y1;
      projectedLine[2] = x2;
      projectedLine[3] = y2;

    } else {

      // return null
    }

    return projectedLine;
  }

  
  
  
  //
  // API
  //
  
  public int getMinutesPerSecond () {
    return round((int) (msPerFrame * desiredFrameRate / (60 * 1000)));
  }
  
  public int getDecay () { 
    return round(decayRate * 100 / 255);
  }
  
  // End of LineDrawer
}

































class LineReader implements Runnable {
  
  private BufferedReader bufferedReader;
  private Scanner fileScanner;
  
  private Boolean needNewBatch  = false;
  private Boolean newBatchReady = false;
  private Boolean buildingBatch = false;
  
  private int batchSize = 100000;
  
  // Private data structures
  private long[] timestamp;
  private int[] duration;//, distance, speed;
  private float[] distance, speed;
  private float[] lat1, lon1, lat2, lon2;
  
  // Exported data structures
  private long[] timestampExport;
  private int[] durationExport;//, distanceExport, speedExport;
  private float[] distanceExport, speedExport;
  private float[] lat1export, lon1export, lat2export, lon2export;  
  
  
  LineReader (String filePath) {
    // Constructor
    println("\tLineReader opens file at " + filePath);
    
    bufferedReader = createReader(filePath);
    fileScanner = new Scanner(bufferedReader);
  }
  
  
  void run () {
    
    println("\tLineReader thread started.");
    
    mainLoop: while (true) {
      try {
        
        // Wait for a request and reset the "new request" flag once it comes in.
        
        waitForRequest();    // This call will return immediately if new 
                             // request is already there, and will cause 
                             // this thread to sleep if there's no new 
                             // requests yet.
        
        //
        // Process the new request
        //
        
        buildingBatch = true;
        
        // Initialize the arrays for the current batch
        
        timestamp = new long[batchSize];
        
        duration  = new int[batchSize];
        distance  = new float[batchSize];
        speed     = new float[batchSize];
        
        lat1 = new float[batchSize];
        lon1 = new float[batchSize];
        lat2 = new float[batchSize];
        lon2 = new float[batchSize];        
        
        int timerStart = millis();
        
        for (int i = 0; i < batchSize; i++) {
          
          // Parse a new line from the file

          // skip user ID and user name
          fileScanner.next();
          fileScanner.next();

          timestamp[i] = fileScanner.nextLong();
          
          duration[i]  = fileScanner.nextInt();
          distance[i]  = fileScanner.nextFloat(); // this is float now
          speed[i]     = fileScanner.nextFloat(); // this is float now
          
          lat1[i] = fileScanner.nextFloat();
          lon1[i] = fileScanner.nextFloat();
          lat2[i] = fileScanner.nextFloat();
          lon2[i] = fileScanner.nextFloat();

          // skip to next line
          fileScanner.nextLine();
          
//          // Check for interruptions
//          if (Thread.interrupted()) {
//            
//            println("\tBatch building interrupted");
//            
//            cancelCurrentBatch();  // reset the "buildingBatch" variable
//            continue mainLoop; 
//          }          
                    
        }
        
        println("\tRead speed - " + (batchSize * 1000 / (millis() - timerStart)) + " records per second.");
        
        // Upload new batch, set "ready" and reset "building" flag
        uploadNewBatch();
        
        // There's a certain amount of delay between now and when waitForRequest() is called
        // again, but this should be fine, as "new request" flag was reset during the last 
        // waitForRequest() call and we don't actually need to wait() in order to start
        // processing the new request.

      } catch (InterruptedException e) {
        
        println("InterruptedException in LineReader.run()");
        continue;    // What is the best strategy here?
      }
    }
    
    // End of run()
  }
  
  
  
  
  //
  // Private methods
  //
  
  private synchronized void waitForRequest () throws InterruptedException {
    
    while (!needNewBatch) {
      
      // Trap the execution in this "while" block
      // until someone sets "needNewBatch" to "true"
      // and calls .notifyAll() on this object.
      
      try {
        
        //println("\tLineReader waiting for a request");
        wait();
        println("\tLineReader wakes up to a request");
        
      } catch (InterruptedException e) {
        
        println("InterruptedException in LineReader.waitForRequest()");
        
        // Propagate the exception so that run() can return properly.
        throw e;
      }
      
      // This code is not guaranteed to follow an update in "needNewBatch" variable - 
      // .notifyAll() could have been called for an unrelated reason.
      
      // println("\tLineReader - instructions after try block in waitForRequest()");      
    }
    
    // println("\tLineReader - instructions after while block in waitForRequest()");
    needNewBatch = false;
  }
  
  private synchronized void uploadNewBatch () {
    
    // Export the latest batch
    
    timestampExport = timestamp;
    
    durationExport = duration;
    distanceExport = distance;
    speedExport = speed;

    lat1export = lat1;
    lon1export = lon1;
    lat2export = lat2;
    lon2export = lon2;
    
    
    // Drop local references to exported variables
    
    timestamp = null;
    
    duration = null;
    distance = null;
    speed = null;
    
    lat1 = null;
    lon1 = null;
    lat2 = null;
    lon2 = null;

    
    // Update flags    
    
    newBatchReady = true;    // doesn't check for previous state
    buildingBatch = false;
    
    notifyAll();    // alert clients that new batch is ready
  }
  
  private synchronized void cancelCurrentBatch () {
    buildingBatch = false;
  }
  
  
  
  
  //
  // API
  //
  
  synchronized void requestNewBatch () {
    
    // This code will automatically start processing the latest request that
    // was issued even if the thread never got to wait(). It will, however,
    // ignore all the requests but the last one, as there's no queue to keep
    // track of them.
    
    if (buildingBatch) {
      println("\tNew request came in as the old batch was still in the making");
    }
    
    needNewBatch = true;
    notifyAll();   // wake up
  }
  
  synchronized Object[] waitForNewBatch () throws InterruptedException {
    
    // This code will return immediately if the new batch is already prepared, 
    // and will wait() if the new batch is still in the making.
    
    while (!newBatchReady) {
      
      // Trap the execution in this "while" block until someone sets "newBatchReady" 
      // to "true" and calls .notifyAll() on this object.
      
      try {
        
        println("\tLineDrawer is waiting for a new batch");
        wait();
        //println("\tA new batch is announced");
        
      } catch (InterruptedException e) {
        
        println("InterruptedException in LineReader.waitForNewBatch()");
        
        // Propagate the exception so that run() can return properly.
        throw e;
      }
      
      // Code here is not guaranteed to follow an update in "newBatchReady" variable - 
      // .notifyAll() could have been called for an unrelated reason.
    }
    
    newBatchReady = false;
    
    return new Object[] { timestampExport, durationExport, distanceExport, speedExport, lat1export, lon1export, lat2export, lon2export };
  } 
  
  
  // End of LineReader
}




























class NumberControl {
  
  int x;
  int y;
  float controlWidth = 80;
  
  String label;
  float number;
  float min;
  float max;
  String numberString;
   
  int labelTextSize = 12;
  int numberTextSize = 24;
  
  PFont labelFont;
  PFont numberFont;
  
  boolean mouseHover = false;
  
  int transparency = 20;
  boolean useFloat;
  
  // Constructor
  
  NumberControl(int x, int y, float controlWidth, String label, float number, boolean useFloat, float min, float max) {
    
    // Initialize local variables
    this.x        = x;
    this.y        = y;
    this.controlWidth = controlWidth;
    this.label    = label;
    this.number   = number;
    this.min      = min;
    this.max      = max;
    this.useFloat = useFloat;
    
    if (useFloat) {
      this.numberString = String.format("%.2f", number);
    } else {
      this.numberString = str(round(number));
    }
    
    //this.numberString = str(number);
    
    // Set up text drawing properties
    labelFont = createFont("Arial", labelTextSize);
    numberFont = createFont("Arial", numberTextSize);
    
  }
  
  
  //
  // Methods
  //
  
  void adjustNumber(int delta) {
    
    if (useFloat) {
      
      if ( min <= (number + delta * 0.1) && (number + delta * 0.1) <= max ) {
        number += delta * 0.1;
        numberString = String.format("%.2f", number);
      }

    } else {
      
      if ( min <= (number + delta) && (number + delta) <= max ) {
        number += delta;
        numberString = str(round(number));
      }
      
    }
    
  }
  
  public float getNumber () {
    return number;
  }
  
  
  
  //
  // Event listeners
  //
  
  void onMouseWheel(int delta, int ptX, int ptY) {
    
    if (x - controlWidth / 2 < ptX && ptX < x + controlWidth / 2) {
      if (y - controlWidth / 2 < ptY && ptY < y + controlWidth / 2) {
      
        adjustNumber(-delta);
      }
    }
    
  }
  
  void onMouseMove(int ptX, int ptY) {
    
    mouseHover = false;
    
    if (x - controlWidth / 2 < ptX && ptX < x + controlWidth / 2) {
      if (y - controlWidth / 2 < ptY && ptY < y + controlWidth / 2) {
        
        mouseHover = true;
      }
    }
    
  }
  

  
  
  //
  // Main loop
  //
  
  void run() {
    render();
  }
  
  void render() {
    
    pushMatrix();
    
      // Move to where the control belongs
      translate(x, y);
      
      // Blank out the area under the control
      
      noStroke();
      fill(0);
      rectMode(CENTER);
      
      rect(0, 0, controlWidth + 10, controlWidth + 10);
      
      
      // Highlight on mouse hover
      
      if (!mouseHover) {
        transparency = 110;
      } else {
        transparency = 255;
      }
      
      
      // Plot label
      
      fill(160, 0, 0, transparency);
      textFont(labelFont);
      textAlign(CENTER, CENTER);
      
      text(label, 0, controlWidth * 0.15);
      
      
      // Plot number
      
      fill(160, 0, 0, transparency);
      textFont(numberFont);
      textAlign(CENTER, CENTER);
      
      text(numberString, 0, -controlWidth * 0.13);
    
      
      // Plot circle
      
      noFill();
      strokeWeight(5);
      stroke(160, 0, 0, transparency);
      ellipseMode(CENTER);
      
      arc(0.0, 0.0, controlWidth, controlWidth, 0, TWO_PI);
      
    popMatrix();
    
    // end of render();
  }

  // end of NumberControl;
}































class RangeControl {
  
  int x;
  int y;
  float controlWidth = 80;
  
  String label;
  
  int numberLo;
  int numberHi;
  
  int min;
  int step;
  
  String numberLoString;
  String numberHiString;
   
  int labelTextSize = 12;
  int numberTextSize = 24;
  
  PFont labelFont;
  PFont numberFont;
  
  boolean mouseHover = false;
  boolean hiSelected = false;
  
  int controlTransparency = 50;
  int hiTransparency = controlTransparency;
  int loTransparency = controlTransparency;
  
  // Constructor
  
  RangeControl(int x, int y, float controlWidth, String label, int numberLo, int numberHi, int min, int step) {
    
    // Initialize local variables
    this.x       = x;
    this.y       = y;
    this.controlWidth = controlWidth;
    this.label   = label;
    this.numberLo = numberLo;
    this.numberHi = numberHi;
    this.min      = min;
    this.step     = step;
    
    this.numberLoString = str(numberLo);
    this.numberHiString = str(numberHi);
    
    // Set up text drawing properties
    labelFont = createFont("Arial", labelTextSize);
    numberFont = createFont("Arial", numberTextSize);
    
  }
  
  
  //
  // Methods
  //
  
  void adjustNumber(int delta) {
    
    if (hiSelected) {
      
      if ((numberHi + delta * step) > numberLo) {
        numberHi += delta * step;
        numberHiString = str(numberHi);
      }
      
    } else {
      
      if ( min <= (numberLo + delta * step) && (numberLo + delta * step) < numberHi) {
        numberLo += delta * step;
        numberLoString = str(numberLo);
      }
    }
    
  }
  
  public int getLoNumber () {
    return numberLo;
  }
  
  public int getHiNumber () {
    return numberHi;
  }
  
  
  
  //
  // Event listeners
  //
  
  void onMouseWheel(int delta, int ptX, int ptY) {
    
    if (x - controlWidth / 2 < ptX && ptX < x + controlWidth / 2) {
      if (y - controlWidth / 2 < ptY && ptY < y + controlWidth / 2) {
        
        hiSelected = false;
        
        if (ptY < y) {
          hiSelected = true;
        }
        
        adjustNumber(-delta);
      }
    }
    
  }
  
  void onMouseMove(int ptX, int ptY) {
    
    mouseHover = false;
    
    if (x - controlWidth / 2 < ptX && ptX < x + controlWidth / 2) {
      if (y - controlWidth / 2 < ptY && ptY < y + controlWidth / 2) {
        
        hiSelected = false;
        
        if (ptY < y) {
          hiSelected = true;
        }
        
        mouseHover = true;
      }
    }
    
  }
  

  
  
  //
  // Main loop
  //
  
  void run() {
    render();
  }
  
  void render() {
    
    pushMatrix();
    
      // Move to where the control belongs
      translate(x, y);
      
      // Blank out the area under the control
      
      noStroke();
      fill(0);
      rectMode(CENTER);
      
      rect(0, 0, controlWidth + 10, controlWidth + 10);
      
      
      // Highlight on mouse hover
      
      if (!mouseHover) {
        
        controlTransparency = 50;
        
        hiTransparency = controlTransparency;
        loTransparency = controlTransparency;
        
      } else {
        
        controlTransparency = 155;
        
        if (hiSelected) {
          
          hiTransparency = controlTransparency;
          loTransparency = 50;
          
        } else {
          
          hiTransparency = 50;
          loTransparency = controlTransparency;
        }
        
      }
      
      
      
      // Plot label
      
      fill(255, controlTransparency);
      textFont(labelFont);
      textAlign(CENTER, CENTER);
      
      text(label, 0, -controlWidth * 0.01);
      
      
      // Plot high number
      
      fill(255, hiTransparency);
      textFont(numberFont);
      textAlign(CENTER, CENTER);
      
      text(numberHiString, 0, -controlWidth * 0.29);
      
      
      // Plot low number
      
      fill(255, loTransparency);
      textFont(numberFont);
      textAlign(CENTER, CENTER);
      
      text(numberLoString, 0, controlWidth * 0.23);
    
      
      // Plot circle
      
      noFill();
      strokeWeight(5);
      stroke(255, controlTransparency);
      ellipseMode(CENTER);
      
      arc(0.0, 0.0, controlWidth, controlWidth, 0, TWO_PI);
      
    popMatrix();
    
    // end of render();
  }

  // end of RangeControl;
}
