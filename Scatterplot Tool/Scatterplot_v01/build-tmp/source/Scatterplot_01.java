import processing.core.*; 
import processing.data.*; 
import processing.event.*; 
import processing.opengl.*; 

import de.bezier.data.sql.*; 
import de.bezier.data.sql.mapper.*; 

import java.util.HashMap; 
import java.util.ArrayList; 
import java.io.File; 
import java.io.BufferedReader; 
import java.io.PrintWriter; 
import java.io.InputStream; 
import java.io.OutputStream; 
import java.io.IOException; 

public class Scatterplot_01 extends PApplet {



MySQL mysql;

//Screen Variables
int screenWidth = 1000;
int screenHeight = 700;

//Axis Variables
int[] origin = {50,screenHeight - 50};

dataPoint dp1 = new dataPoint(1);

public void setup() {
    size(screenWidth,screenHeight); 
    
    //Setup MySQL Server
    String user = "fimfic";
    String pass = "lyra04";
    String database = "test05";
    mysql = new MySQL( this, "localhost", database, user, pass );
}

public void initializePoints() {
    
}

public void drawAxes() {
    //Draw the X axis
    line(origin[0],origin[1],screenWidth-50,origin[1]);
    
    //Draw the Y axis
    line(origin[0],origin[1],origin[0],50);
}

public int getMaxViews() {
    if (mysql.connect()) {
        mysql.query("SELECT MAX(Views) AS Views FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
    }
    else {
        return 0;
    }
}

public int getMaxWords() {
    if (mysql.connect()) {
        mysql.query("SELECT MAX(Words) AS Words FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
    }
    else {
        return 0;
    }
}

public int getMaxLikes() {
    if (mysql.connect()) {
        mysql.query("SELECT MAX(Likes) AS Likes FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
    }
    else {
        return 0;
    }
}

public int getMaxKey() {
    if (mysql.connect()) {
        mysql.query("SELECT MAX(Prime_Key) AS Prime_Key FROM Stories;");
        mysql.next();
        return mysql.getInt(1);
    }
    else {
        return 0;
    }
}

public void draw() {
    background(255); 
    drawAxes();
    dp1.update();
}

class dataPoint {
    int xPos, yPos, size, pKey;
    
    dataPoint (int pKey) {
        mysql.connect();
        mysql.query("SELECT Words, Views, Likes FROM Stories WHERE Prime_Key = %s", pKey);
        mysql.next();
        xPos = mysql.getInt(1)/getMaxWords();
        yPos = mysql.getInt(2)/getMaxViews();
        size = mysql.getInt(3)/getMaxLikes();
    }
    
    public void update() {
        ellipseMode(RADIUS);
        fill(255,0,0);
        ellipse(xPos, yPos, size, size);
    }
}
    static public void main(String[] passedArgs) {
        String[] appletArgs = new String[] { "Scatterplot_01" };
        if (passedArgs != null) {
          PApplet.main(concat(appletArgs, passedArgs));
        } else {
          PApplet.main(appletArgs);
        }
    }
}
