void calcFFT() {
  fft.forward(song.mix);

  avg = 0;
  max = 0;
  for (int i = 0 ; i < av.length ; i ++) {
    float temp = 0;
    for (int k = i ; k < fft.specSize() ; k += i + 1) {
      temp += fft.getBand(k);
    }
    temp /= av.length / (i + 1);
    temp = pow(temp,1.8);
    avg += temp;
    av[i] = temp;
  }
  avg /= av.length;

  for (int i = 0 ; i < av.length ; i ++) {
    if (av[i] < avg*1.5) {
      av[i] /= 2;
    } else {
      av[i] += (av[i] - avg * 1.5) /2;
    }
    if (av[i] > max) max = av[i];
  }

}

void mousePressed() {
  float temp = ((float)mouseX / width) * song.length();
  int tempBeat = (int)(temp/60000.0*bpm);
  for (Event event : events) {
    if (tempBeat <= event.time) {
      event.spawned = false;
      event.finished = false;
      if (currBeat >= event.time && currBeat < event.timeEnd) {
        event.end();
      }
    }
  }
  song.cue((int)temp);
  currBeat = tempBeat;
}

void keyPressed() {
	if (key == 'e') {
		if (!cam.lock) {
			cam.lock = true;
			cam.ang.P.set(cam.dang.x, cam.dang.y, cam.dang.z);
		} else {
			cam.lock = false;
		}
		println("Cam lock: " + cam.lock);
	} else {
		println("KEY: " + key + " " + currTime + " " + currBeat + " FRAMERATE: " + frameRate);
	}
}

void drawPitches() {
  push();
  fill(255);
  translate(0,height,0);
  for (int i = 0 ; i < binCount ; i ++) {
    float w = width/(float)binCount;
    translate(w, 0,0);
    rect(0,0,w,av[i]*10);
  }
  pop();
}

void drawBorders() {
  noFill();
  stroke(255);
  push();
  translate(0,0,-aw);
  rect(0,0,de*2,de*2);
  pop();
  line(de,de,aw,de,de,-aw);
  line(de,-de,aw,de,-de,-aw);
  line(-de,de,aw,-de,de,-aw);
  line(-de,-de,aw,-de,-de,-aw);
}

void renderQuad(PVector p1, PVector p2, PVector p3, PVector p4) {
  beginShape();
  vertex(p1.x, p1.y, p1.z);
  vertex(p2.x, p2.y, p2.z);
  vertex(p3.x, p3.y, p3.z);
  vertex(p4.x, p4.y, p4.z);
  vertex(p1.x, p1.y, p1.z);
  endShape();
}

void drawWidthBox(float w) {
  push();
  textSize(w/10);
  push();
  translate(0,0,0);
  text("0,0,0",0,0);
  pop();

  push();
  translate(w,w,w);
  text("1,1,1",0,0);
  pop();

  push();
  translate(-w,w,w);
  text("-1,1,1",0,0);
  pop();

  push();
  translate(-w,-w,w);
  text("-1,-1,1",0,0);
  pop();

  push();
  translate(w,-w,w);
  text("1,-1,-1",0,0);
  pop();

  push();
  translate(w,w,-w);
  text("1,1,-1",0,0);
  pop();

  push();
  translate(-w,w,-w);
  text("-1,1,-1",0,0);
  pop();

  push();
  translate(-w,-w,-w);
  text("-1,-1,-1",0,0);
  pop();

  push();
  translate(w,-w,-w);
  text("1,-1,-1",0,0);
  pop();
  pop();
}

class BeatTimer {
  int offset;
  float bpm;
  float sec;
  int threshold;
  boolean beat = false;
  boolean beatAlready = false;
  int tick = 1;

  BeatTimer(int threshold, int offset, float bpm) {
    this.bpm = bpm;
    this.sec = sec;
    this.offset = offset;
    this.threshold = threshold;
  }

  void update() {
    float currMil = (currTime + offset) % (60000.0/bpm/2);
    if (!beatAlready && currMil < threshold) {
      beat = true;
      beatAlready = true;
      tick ++;
      if (tick > 4) tick = 1;
    } else {
      beat = false;
    }
    if (currMil > threshold) {
      beatAlready = false;
    }
  }
}

class Camera {
  Point p;
  Point ang;
  PVector dp;
  PVector dang;
  boolean lock = true;

  Camera(float x, float y, float z) {
    this.p = new Point(x, y, z);
    this.dp = this.p.p.copy();
    this.ang = new Point();
    this.dang = new PVector();
    this.ang.mass = 10;
    this.ang.vMult = 0.5;
  }

  void update() {
  if (!lock) {
    cam.ang.P.y = (float)mouseX/width*2*PI - PI;
    cam.ang.P.x = -(float)mouseY/height*2*PI - PI;
  }
    p.update();
    ang.update();
  }

  void render() {
    camera();
    translate(p.p.x,p.p.y,p.p.z);
    rotateX(ang.p.x);
    rotateY(ang.p.y);
    rotateZ(ang.p.z);
  }
}