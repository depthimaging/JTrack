import java.util.Iterator; //<>// //<>// //<>// //<>// //<>//
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
int pieY = 400;


//int oX =900;
//int oY = 850;
int oX =1188;
int oY = 670;
float Ok = 120;

int room_oX = 250;
int room_oY = 30;
int wd = 1110;
int ht = 615;


int rectX1 = 150, rectY1 = 46;      // Position of square button
int rectX2 = 270, rectY2 = rectY1;      // Position of square button
int rectSizeW = 50;     // Diameter of rect
int rectSizeH = 35;     // Diameter of rect
color rectColor = color(222);
color rectHighlight = color(100,100,100);
boolean rectOver1 = false;
boolean rectOver2 = false;


int circleX, circleY;  // Position of circle button
color currentColor;

int curTrk = -1;

int[][] angles;
//int[] angles = { 10, 20, 150};

int cx = 10, cy = 20;

int nstops = 0;


PImage timebg;

void setup() {

  loadData();

  fullScreen(); 

  reset();
}

void reset() {

  fill(255);
  rect(room_oX, room_oY, wd, ht);
  //bg = loadImage("bplan.jpg");
  PImage jelly = loadImage("b2pplan.jpg");
  jelly.resize(width, height);
  background(jelly);


  //timebg = loadImage("timebg.png");
  //timebg.resize(252,252);


  loadData();
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
}

void mousePressed() {
  if (rectOver1) {
    currentColor = rectColor;
    reset();
    curTrk = curTrk-1;
  }
  if (rectOver2) {
    currentColor = rectColor;
    reset();
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
  println("cur: ", curTrk);
}


boolean overRect(int x, int y, int width, int height) {
  if (mouseX >= x && mouseX <= x+width && 
    mouseY >= y && mouseY <= y+height) {
    return true;
  } else {
    return false;
  }
}

void pieChart(float diameter, int[] data) {

  float lastAngle = 4.7;
  float startAngle = lastAngle;
  boolean moving = false;

  noStroke();
  for (int i = 0; i < data.length; i++) {
    if (moving) {
      fill(255);
    } else {
      fill(255, 0, 0);
    }
    moving = !moving;
    if(data[i]==0) {
       data[i] = 1;
    }
    
    if(i == data.length-1){
      arc(pieX, pieY, diameter, diameter, lastAngle, startAngle);
    }
    else {
      arc(pieX, pieY, diameter, diameter, lastAngle, lastAngle+radians(data[i]));
    }
    
    lastAngle += radians(data[i]);
    //14.4
    //342
    //3.6
  }
  //image(timebg, pieX-126,pieY-126);
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
  rect(text_oX,text_oY+40,390,60);
  
}

void drawMov(int total, int nstops, int oX, int oY) {
 
  fill(255); 
  text("Total time: ", oX, oY);
  text(total+" seconds", oX+200, oY);

  fill(0, 255, 0);
  text("Move: ", oX, oY+60);
  fill(255); 
  text(total-nstops+ " s", oX+100, oY+60);

  fill(255, 0, 0);
  text("Stop: ", oX+200, oY+60);
  fill(255); 
  text(nstops+ " s", oX+300, oY+60);

}
void draw() {
  update(mouseX, mouseY);

  color curtrkColor = color( (curTrk%3)* 255, ((curTrk+1)%3) * 255, ((curTrk+2)%3) * 255 );

  drawSummary(curtrkColor);
  
  stroke(rectColor);
  fill(27,35,48);
  if (rectOver1) {
    fill(rectHighlight);
  }
  rect(rectX1, rectY1, rectSizeW, rectSizeH);
  fill(27,35,48);
  
  if(rectOver2){
    fill(rectHighlight); 
  }
  rect(rectX2, rectY2, rectSizeW, rectSizeH);
  
  fill(curtrkColor); 
  textSize(32);
  text("<", rectX1+12, rectY1+27);
  text(">", rectX2+12, rectY2+27);


  int i = curTrk;

  if (i==-1) {
    return;
  }

  //for (int i = 0; i < lenght.length; i++) {

  //color trkColor = color( (i%3)* 255, ((i+1)%3) * 255, ((i+2)%3) * 255 );

  fill(curtrkColor);
  if (count[i]<lenght[i]) {

    stroke(curtrkColor);

    try {
      float xes = x_coord[i][count[i]]*Ok;
      float yes = y_coord[i][count[i]]*Ok;

      if (count[i]<lenght[i]-1) 
        line(oX+xes, oY-yes, oX+(x_coord[i][count[i]+1]*Ok), oY-(y_coord[i][count[i]+1]*Ok));

      ellipse(oX+xes, oY-yes, 10, 10);

      fill(6);
      rect(cx, cy-30, 300, 40);
      fill(255);
      textSize(16);
      text(" x= "+xes+" , y= "+yes, cx, cy);

      count[i]++;
    } 
    catch (Exception e) {
    };
  }
  delay(50);
  //}




  textSize(28);
  //angles[i] = new int[]{ 90, 90,90,90 };
  int stops = getStopTimes(i)/2;

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

int getStopTimes(int i) {
  
  float onePece = 360/lenght[i];
  float sum = onePece;
  
  
  angles[i] = new int[7];

  int k=0;
  int totalMove = 0;
  int totalStop = 0;
  int subseq = 0;
  
  
  for (int j=1; j<lenght[i]; j++) {


    int step = stops[i][j];
    int preStep = stops[i][j-1];
    if (step != preStep) {
      //println(k);
      angles[i][k] = (int)sum;
      //println("sum added at ",k," . sum=",angles[i][k]);
      //println("total stop ",totalStop," . totalmove=",totalMove);
      //println(stops[i]);
      sum = 0;
      k++;
      subseq++;
    }  
    if (step==0) {
      totalStop += 1;
    } else {
      totalMove += 1;
    }
    sum+= onePece;
  }
  
  
  
  println(" the angles[: ", i, "] : ", angles[i]);

  try {
    
    int counter = tmeta.length;
    println("counter= ",counter);
    int[] newangles = new int[counter];
    
    for (k=0; k<counter; k++) {
      println("k= ",k);
      newangles[k] = (int) (tmeta[k][4] * 3.6) ;
    }
  
  
    println(" newangles ----- ", newangles[0]);
    println(" newangles ----- ", newangles[1]);
    println(" newangles ----- ", newangles[2]);
    println(" newangles size----- ", newangles.length);
    
    //println(" newangles ----- ", newangles[3]);
    //println(" newangles ----- ", newangles[4]);
    
  
  
  
    pieChart(250, newangles);
  } catch (Exception e){}
  return totalStop;
}

void loadMetadata(String trk){

  try {
    
  meta = loadJSONObject(metadata);  
  JSONObject s = meta.getJSONObject("tracks");
  
  println("  ppppaream: ",trk);
  JSONArray track = s.getJSONArray(trk);  
  tmeta = new float[track.size()][5];
  
  for (int i = 0; i < track.size(); i++) {
     try {
       tmeta[i][0] = track.getJSONObject(i).getInt("stop");
//       tmeta[i][1] = track.getJSONObject(i).getInt("nop");
//       tmeta[i][2] = track.getJSONObject(i).getInt("perc");
       tmeta[i][3] = track.getJSONObject(i).getInt("duration");
       tmeta[i][4] = track.getJSONObject(i).getInt("percentage");
       
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
  
 } catch (Exception e){
     }
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
      //println("kei is: ",key);
      tracks[j] = o.getJSONArray(key);      

      lenght[j]=tracks[j].size();                                   // Size of the dataset

      init2(j, lenght[j]);

      for (int i = 0; i < lenght[j]; i++) {
        //println("key: ",key);
        moment = tracks[j].getJSONObject(i);                      
        // fist and last time stamps
        if ((i==0) & (j==0)) start_time=moment.getString("time").substring(0, 11);                 
        if ((i==lenght[j]-1) & (j==0)) end_time=moment.getString("time").substring(0, 11);
        //if ((i==lenght[j]-1) & (j!=0)) println ("!!");
        float x=moment.getFloat("x");                                  
        float y=moment.getFloat("y");
        timestamps[j][i]=moment.getString("time").substring(0, 11);
        //h_height[j][i]=moment.getFloat("height");
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

      //println("Track "+j+" time: "+timestamps[j][0]);

      //println("Track "+j+" end time: "+timestamps[j][lenght[j]-1]);

      println();

      //println(start_time);
      //println(end_time);
      //ids = json.keys();
      j++;
    } 
    catch (Exception e) 
    {
    }
  }
}  //loadData()

void loadData3() {

  json = loadJSONObject(filename);


  int noTracks = json.getJSONArray("tracks").size();
  tracks = new JSONArray[noTracks];
  println(noTracks);

  //JSONArray tracks2;
  //  tracks2 = new JSONArray();

  // tracks2 = json.getJSONArray("tracks");


  JSONObject o = (JSONObject) json;

  Set keyset = o.keys();
  Iterator<String> keys = keyset.iterator();
  int j = 0;

  while ( keys.hasNext() ) {

    String key = (String)keys.next();

    tracks[j] = o.getJSONArray(key);      
    println(key);
    //      if (!isInit){ init(noTracks, 1000); isInit = true;}


    //      lenght[j]=tracks[j].size();                                   // Size of the dataset

    //      for (int i = 0; i < lenght[j]; i++) {
    //  //    println("key: ",key);
    //        //JSONObject item = tracks[j].getJSONObject(i);
    //      moment = tracks[j].getJSONObject(i);                         

    //       // fist and last time stamps
    //       if ((i==0) & (j==0)) start_time=moment.getString("time").substring(0,11);                 
    //       if ((i==lenght[j]-1) & (j==0)) end_time=moment.getString("time").substring(0,11);

    //       if((i==lenght[j]-1) & (j!=0)) println ("!!");

    //       float x=moment.getFloat("x");                                  
    //       float y=moment.getFloat("y");

    //       timestamps[j][i]=moment.getString("time").substring(0,11);

    //       h_height[j][i]=moment.getFloat("height");

    //       h=h+h_height[j][i];                                           

    //       x_coord[j][i]=x*140;                                            
    //       y_coord[j][i]=y*140;  

    //     // println(item);
  }

  //     h_mid[j]=h/lenght[j]; h=0;                                      

  //     //println("Track "+j+" time: "+timestamps[j][0]);

  //     //println("Track "+j+" end time: "+timestamps[j][lenght[j]-1]);

  //     println();

  //     //println(start_time);
  //     //println(end_time);
  //  //ids = json.keys();
  //  j++;
  //}
}