import java.util.Iterator;  //<>//
import java.util.*;
import  java.lang.Object;
// Example of Reading from JSON and Visualisation of Visitor Tracks
// 1.2 / p3.3

String filename="test.json",metadata="meta.json";                    // temp. filename
Boolean isInit = false;
JSONObject json,meta;

JSONObject moment;

//Array of json arrays
JSONArray[] tracks;

float h;
int i0=0;
int i1=0;
int[] count;

float[][] x_coord;
float[][] y_coord;
int[][] stops;
float[][] h_height;
String[][] timestamps;

int[] lenght;
float[] h_mid;

float [][]tmeta;

String start_time, end_time;                    // Starting and ending time of all tracks in the file

int text_oX = 30;
int text_oY = 70;

int pieX = 200;
int pieY = 450;


//int oX =900;
//int oY = 850;
int oX =1188;
int oY = 670;
float Ok = 120;

int room_oX = 250;
int room_oY = 30;
int wd = 1110;
int ht = 615;

//---------------------------------
// interface. buttons
//---------------------------------
int rectX1 = 150, rectY1 = 46;      // Position of square button
int rectX2 = 270, rectY2 = rectY1;      // Position of square button
int rectSizeW = 50;     // Diameter of rect
int rectSizeH = 35;     // Diameter of rect
color rectColor = color(222);
color rectHighlight = color(100,100,100);
boolean rectOver1 = false;
boolean rectOver2 = false;
// heatmap button
int heatX = 30, heatY = rectY1+ 60;      // Position of square button
int heatW = 170;     // Diameter of rect
int heatH = 35;     // Diameter of rect
color heatColor = color(222);
color heatHighlight = color(100,100,100);
boolean heatOver = false;
//
// normal button
int norX = 250, norY = heatY;      // Position of square button
int norW = 170;     // Diameter of rect
int norH = 35;     // Diameter of rect
color norColor = color(222);
color norHighlight = color(100,100,100);
boolean norOver = false;
// End ofinterface. buttons
//---------------------------------


//---------------------------------
// heatmap
//---------------------------------
float[][] interp_array;
boolean showHeatMap = false;
// End of heatmap
//---------------------------------


int circleX, circleY;  // Position of circle button
color currentColor;

int curTrk = -1;

int[][] angles;
//int[] angles = { 10, 20, 150};

int cx = 10, cy = 20;

int nstops = 0;


PImage timebg;


PImage jelly;
PGraphics pg;

void setup() {
  loadData();
  fullScreen();
  reset();
  // heatmap
  int heatW = 880, heatH = 870;
  
  pg = createGraphics(heatW, heatH);
  interp_array = new float[heatW][heatH];
  makeArray();  
}


void reset() {
  rect(room_oX, room_oY, wd, ht);
  jelly = loadImage("b2pplan.jpg");
  jelly.resize(width, height);
  background(jelly);
  loadData();  
}


// Fill array with Perlin noise (smooth random) values
void makeArray() {
  for (int c = 0; c < interp_array.length; c++) {
    for (int r = 0; r < interp_array[c].length; r++) {
      // Range is 24.8 - 30.8      
      interp_array[c][r] = 24.8 + 5.0 * noise(r * 0.01, c * 0.01);
    }
  }
}


void applyColor() {  // Generate the heat map
  
  pushStyle();

  pg.beginDraw();

  colorMode(HSB, 1, 1, 1);
  pg.loadPixels();
  int p = 0;
  for (int c = 0; c < interp_array.length; c++) {
    for (int r = 0; r < interp_array[c].length; r++) {
      // Get the heat map value 
      float value = interp_array[c][r];
      // Constrain value to acceptable range.
      value = constrain(value, 25, 30);
      // Map the value to the hue
      // 0.2 blue
      // 1.0 red
      value = map(value, 25, 30, 0.2, 1.0);
      //println("value: ", value);
      //if (value < 0.5) {
      //  pg.pixels[p++] = color(value, 0.9, 1);  
      //} else {
      //p++;
      //}
      pg.pixels[p++] = color(value, 0.9, 1);
      
    }
  }
  pg.updatePixels();
  
  image(pg, 840, 25);
  pg.endDraw();
  
  popStyle();
  
}

void pieChart(float diameter, int[] data,boolean moving, int ox, int oy) {

  float lastAngle = 4.7;
  float startAngle = lastAngle;

  noStroke();
  for (int i = 0; i < data.length; i++) {
    if (moving==false) {
      fill(255);
    } else {
      fill(255, 0, 0);
    }
    moving = !moving;
    if(data[i]==0) {
       data[i] = 1;
    }
    arc(ox+600, oy+30, diameter, diameter, lastAngle, lastAngle+radians(data[i]));

    lastAngle += radians(data[i]);
  }
}

void drawSummary(int curtrkColor) {
  textSize(28);
  //color trkColor = color( (i%3)* 255, ((i+1)%3) * 255, ((i+2)%3) * 255 );
  fill(255); 
  text("Track #", text_oX, text_oY);
  fill(curtrkColor); 
  text(curTrk, text_oX+190, text_oY);
  fill(255);
  text(" of "+lenght.length, text_oX+300, text_oY); 

  noFill();
  stroke(255);
  rect(text_oX,text_oY+100,390,60);
  
}

void drawMov(int total, int nstops, int oX, int oY) {
 
  fill(255); 
  text("Total time: ", oX, oY+60);
  text(total+" seconds", oX+200, oY+60);

  fill(0, 255, 0);
  text("Move: ", oX, oY+130);
  fill(255); 
  text(total-nstops+ " s", oX+100, oY+130);

  fill(255, 0, 0);
  text("Stop: ", oX+200, oY+130);
  fill(255); 
  text(nstops+ " s", oX+300, oY+130);

  getStopTimes(curTrk,oX,oY);
}

void drawInterface() {

  color curtrkColor = color( (curTrk%3)* 255, ((curTrk+1)%3) * 255, ((curTrk+2)%3) * 255 );

  
  fill(rectHighlight);
  if (rectOver1) {
    fill(rectColor);
  }
  rect(rectX1, rectY1, rectSizeW, rectSizeH);
  
  fill(rectHighlight);  
  if(rectOver2){
    fill(rectColor); 
  }
  rect(rectX2, rectY2, rectSizeW, rectSizeH);
  
  fill(0);  
  textSize(32);
  text("<", rectX1+12, rectY1+27);
  text(">", rectX2+12, rectY2+27);

  // heatmap button
  fill(rectHighlight);  
  if(heatOver){
    fill(rectColor); 
  }
  rect(heatX, heatY, heatW, heatH);
  textSize(28);
  fill(255,255,255);
  text("Heat Map", heatX+10, heatY+27);
  
  
  // normal map button
  fill(norHighlight);  
  if(norOver){
    fill(norColor); 
  }
  rect(norX, norY, norW, norH);
  textSize(28);
  fill(255,255,255);
  text("Traj. Map", norX+10, norY+27);
  
  
  // items panel
  fill(1);
  rect(20, oY-40, 800, 250);
}

void draw() {
  update(mouseX, mouseY);
  color curtrkColor = color( (curTrk%3)* 255, ((curTrk+1)%3) * 255, ((curTrk+2)%3) * 255 );
  drawSummary(curtrkColor);
  
  drawInterface();

  int i = curTrk;

  if (i==-1) {
    return;
  }

  //for (int i = 0; i < lenght.length; i++) {

  //color trkColor = color( (i%3)* 255, ((i+1)%3) * 255, ((i+2)%3) * 255 );

  fill(curtrkColor);
  if (count[i]<lenght[i] && !showHeatMap) {

    stroke(curtrkColor);

    try {
      float xes = x_coord[i][count[i]]*Ok;
      float yes = y_coord[i][count[i]]*Ok;

      if (count[i]<lenght[i]-1) 
        line(oX+xes, oY-yes, oX+(x_coord[i][count[i]+1]*Ok), oY-(y_coord[i][count[i]+1]*Ok));

      ellipse(oX+xes, oY-yes, 10, 10);

      //fill(6);
      //rect(cx, cy-30, 300, 40);
      //fill(255);
      //textSize(16);
      //text(" x= "+xes+" , y= "+yes, cx, cy);

      count[i]++;
    } 
    catch (Exception e) {
    };
  } 
  
  if(showHeatMap == true) {
    applyColor();
  }
  delay(50);
  //}




  textSize(28);
  //angles[i] = new int[]{ 90, 90,90,90 };
  

  int total = lenght[i]/2;

  drawMov(total,nstops,text_oX+10,text_oY+80 );
  
}  


void init1(int noTracks) {

  x_coord=new float[noTracks][];
  y_coord=new float[noTracks][];
  stops=new int[noTracks][];
  h_height=new float[noTracks][];
  timestamps=new String[noTracks][];

  lenght=new int[noTracks];
  h_mid=new float[noTracks];
  angles = new int[noTracks][];
}

void init2(int i, int no_elements) {

  x_coord[i]=new float[no_elements];
  y_coord[i]=new float[no_elements];
  stops[i]=new int[no_elements];
  h_height[i]=new float[no_elements];
  timestamps[i]=new String[no_elements];
}

void getStopTimes(int i,int ox, int oy) {
  int k=0;
  try {    
    int counter = tmeta.length;
    println("counter= ",counter);
    int[] newangles = new int[counter];
    
    for (k=0; k<counter; k++) {
      println("k= ",k);
      newangles[k] = (int) (tmeta[k][2] * 3.6) ;
    }
  
    println(" newangles ----- ", newangles[0]);
    println(" newangles ----- ", newangles[1]);
    println(" newangles ----- ", newangles[2]);
    println(" newangles size----- ", newangles.length);
  
    boolean x = false;
    if(tmeta[1][0] == 1) {
      x = true;
    }
    pieChart(250, newangles,x,ox,oy);
  } catch (Exception e){}
}

void loadMetadata(String trk){
  try {
  meta = loadJSONObject(metadata);  
  JSONObject s = meta.getJSONObject("tracks");
  
  println("  ppppaream: ",trk);
  JSONArray track = s.getJSONArray(trk);  
  tmeta = new float[track.size()][3];
  
  for (int i = 0; i < track.size(); i++) {
     try {
       tmeta[i][0] = track.getJSONObject(i).getInt("stop");
       tmeta[i][1] = track.getJSONObject(i).getInt("duration");
       tmeta[i][2] = track.getJSONObject(i).getInt("percentage");
       
     } catch (Exception e){
     }
     
  }

  println("ads--------- tmetaaaaa  "+tmeta[1][0]);
  println("ads--------- tmetaaaaa  "+tmeta[1][1]);
  println("ads--------- tmetaaaaa  "+tmeta[1][2]);
  println("ads--------- tmetaaaaa  "+tmeta[1][3]);
  println("ads--------- tmetaaaaa  "+tmeta[1][4]);
  
  
  println("ads--------- tmetaaaaa  "+tmeta[2][0]);
  println("ads--------- tmetaaaaa  "+tmeta[2][1]);
  println("ads--------- tmetaaaaa  "+tmeta[2][2]);
  println("ads--------- tmetaaaaa  "+tmeta[2][3]);
  println("ads--------- tmetaaaaa  "+tmeta[2][4]);
  
 } catch (Exception e){}
}

void loadData() {
  
  json = loadJSONObject(filename);
  int noTracks = json.size();
  tracks = new JSONArray[noTracks];
  count=new int[noTracks];
  JSONObject o = (JSONObject) json;
  init1(noTracks);
  Set keyset = o.keys();
  Iterator<String> keys = keyset.iterator();
  int j = 0;
  while ( keys.hasNext() ) 
  {
    try 
    {
      String key = (String)keys.next();
      tracks[j] = o.getJSONArray(key);      
      lenght[j]=tracks[j].size();
      init2(j, lenght[j]);
      for (int i = 0; i < lenght[j]; i++) {
        moment = tracks[j].getJSONObject(i);                      
        // fist and last time stamps
        if ((i==0) & (j==0)) start_time=moment.getString("time").substring(0, 11);                 
        if ((i==lenght[j]-1) & (j==0)) end_time=moment.getString("time").substring(0, 11);
        float x=moment.getFloat("x");                                  
        float y=moment.getFloat("y");
        timestamps[j][i]=moment.getString("time").substring(0, 11);
        h=h+h_height[j][i];                                           
        x_coord[j][i]=x;                                            
        y_coord[j][i]=y;  
        try {
          stops[j][i] = moment.getInt("stop");
        } 
        catch(Exception e) {
        }
      }
      h_mid[j]=h/lenght[j]; 
      h=0;                                      
      j++;
    } catch (Exception e) {}
  }
}


void update(int x, int y) {
  if ( overRect(rectX1, rectY1, rectSizeW, rectSizeH) ) {
    rectOver1 = true;
  } else {
    rectOver1 = false;
  }

  if ( overRect(rectX2, rectY2, rectSizeW, rectSizeH) ) {
    rectOver2 = true;
  } else {
    rectOver2 = false;
  }
  
  if ( overRect(heatX, heatY, heatW, heatH) ) {
    heatOver = true;
  } else {
    heatOver = false;
  }
  
  if ( overRect(norX, norY, norW, norH) ) {
    norOver = true;
  } else {
    norOver = false;
  }
}


boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void mousePressed() {
  boolean doreset = false;
  if (rectOver1) {
    currentColor = rectColor;
    doreset = true;
    curTrk = curTrk-1;
  }
  if (rectOver2) {
    currentColor = rectColor;
    doreset = true;
    curTrk = curTrk+1;
  }
  if (curTrk<0) {
    curTrk = lenght.length-1;
  } 
  if (curTrk >= lenght.length) {
    curTrk = 0;
  }
  
  
  if(curTrk<9) {
    int x = curTrk+1;
    loadMetadata("t0"+x);
  }
   else {
     int x = curTrk+1;
     loadMetadata("t0"+curTrk);
   }
   
   if (heatOver) {
     showHeatMap = true;
     doreset = true;
   }
   
   if (norOver) {
     showHeatMap = false;
     doreset = true;
   }
  
  if(doreset == true) {
    reset();
  }
}