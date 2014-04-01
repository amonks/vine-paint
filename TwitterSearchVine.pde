// =============================================================================
//
// Copyright (c) 2009-2014 Christopher Baker <http://christopherbaker.net>
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//
// =============================================================================

import processing.video.*;
import processing.serial.*; 
import java.util.Timer;
import java.util.Vector;
import java.io.UnsupportedEncodingException;
import controlP5.*;

ControlP5 cp5;

int noisePad = 1000;
float noisePos = 1000.00;
float noiseInc = .005;

TwitterSimpleSearch simpleSearch;

Vector<Vine> vines = new Vector<Vine>();
int currentVine = 0;

Movie mov = null;
int X = 0;



int brushWidth = 50;

void setup() {
  cp5 = new ControlP5(this);
  cp5.addSlider("brushWidth", 10, 500, 50, 10, 10, 100, 10);
  cp5.addSlider("noiseInc", 1, 100, 10, 10, 30, 100, 10);
  
  size(displayWidth, displayHeight);
  frameRate(30);
  background(0);

  String query = "vine.co/v/ AND painting"; // Search for tweets that include the word "love"
  int searchPollInterval = 30 * 1000; // Search every 30 seconds.

  // To use, go to https://dev.twitter.com/ and register a new application.
  // Call it whatever you like.  Normally people might make an application 
  // for others to use, but this one is just for you.
  //
  // Make sure the application has read AND write settings.  Make sure your
  // tokens and keys also have read AND write settings.  If they don't,
  // regenerate them.

  String oAuthConsumerKey = "JGM8gHh5LAUqKUnToPx2n2Ayn";
  String oAuthConsumerSecret = "nQCRRvZecF0SLhsDvddb6NJVPbOnMcCZbB4fIkNkQGfovpSOKc";
  String oAuthAccessToken = "2267708910-8aVLq3mlh1t8WbClHvi4zRZTthtcJaPUFBXLpIW";
  String oAuthTokenSecret = "f0fcwitWdVnUt0tK9XceGfKgYIgiNf2jtUXq8gUWJ9Wiq";

  simpleSearch = new TwitterSimpleSearch(this, query, 30 * 1000, oAuthConsumerKey, oAuthConsumerSecret, oAuthAccessToken, oAuthTokenSecret);
}  

void draw() {
  if (mov != null) {
    if (mov.available() || abs(mov.time() - mov.duration()) > 0.01) {
      mov.read();
     // if ( mousePressed == true && (mouseY > 20 || mouseX > 100 ) ) {
        image(mov,noise(noisePos) * displayWidth, noise(noisePos + noisePad) * displayHeight, brushWidth, brushWidth);
     // }
    }
    else
    {
      mov = null; // clear movie
    }
  }
  else
  {
    if ( vines.size() > currentVine)
    {
      Vine vine = vines.get(currentVine);

      mov = new Movie(this, "media/" + vine.getId() + ".mp4");
      mov.play();

      currentVine++;
    }
  }
  noisePos += noiseInc;
}

void newTweets(Vector<Status> tweets) {
  for (Status tweet : tweets)
  {

    if (!tweet.isRetweet())
    {
      Vector<String> urls = Utils.parseUrls(tweet.getText());

      for (String url : urls)
      {

        try
        {
          byte[] rawBytes = loadBytes(url);
          String html = new String(rawBytes, "UTF-8");

          Vine vine = Utils.parseVine(html);

          if (vine != null)
          {
            rawBytes = loadBytes(vine.getImgURL());
            saveBytes("data/media/" + vine.getId() + ".jpg", rawBytes);

            rawBytes = loadBytes(vine.getVidURL());
            saveBytes("data/media/" + vine.getId() + ".mp4", rawBytes);

            vines.add(vine);
          }
        }
        catch(UnsupportedEncodingException exc)
        {
        }
      }
    }
  }
}


void keyPressed() {
  int keyIndex = -1;
  if (key >= 'A' && key <= 'Z') {
    keyIndex = key - 'A';
  } else if (key >= 'a' && key <= 'z') {
    keyIndex = key - 'a';
  }
  if (keyIndex == -1) {
    // If it's not a letter key, clear the screen
    background(0);
  } else { 
    background(255);
  }
}


// an event from slider sliderA will change the value of textfield textA here
public void brushWidth(int theValue) {
  brushWidth = theValue;
}

// an event from slider sliderA will change the value of textfield textA here
public void noiseInc(int theValue) {
  noiseInc = theValue / 1000.0;
}


