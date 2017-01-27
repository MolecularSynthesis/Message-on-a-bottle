//Visual sulla base di Apollonio

//importa la libreria per la comunicazione seriale
  import processing.serial.*; //importo libreria seriale
  Serial myPort;  //l'oggetto porta seriale
  String valSerial;
   
//necessario vedere se c'è stato un contatto con il micro 
  boolean firstContact = false;

//booleano bottiglia
  boolean bottiglia = false;
  
//vettori circonferenze i(n)
  PVector i1;
  PVector i2;
  PVector i3;
  PVector i4;
  PVector i5;
  PVector i6;

//testi vari
  float SECONDS_PER_THING = 0.057;  //litri di carburante risparmiati (17,52 ogni secondo)
  float SECONDS_PER_THING2 = 0.221;  //Kg di CO2 risparmiati (4,53 ogni secondo) 
  float SECONDS_PER_THING3 = 0.015;  //bottiglie di plastica prodotte (190,26 ogni secondo)
  float SECONDS_PER_THING4 = 0.020;  //bottiglie di plastica riciclate (56,51 ogni secondo)
  float SECONDS_PER_THING5 = 0.007;  //litri di H2O risparmiati (389 ogni secondo)
  float SECONDS_PER_THING6 = 0.084;  //KWh di energia risparmiati (11,87 ogni secondo)
  
  int numero1 = 0, numero2 = 0, numero3 = 0, numero4 = 0, numero5 = 0, numero6 = 0;
  float time, ntime, time2, ntime2, time3, ntime3, time4, ntime4, time5, ntime5, time6, ntime6;
  
//font testi 
  PFont nitti;

//valori raggi
  float r1 = 50; 
  float r2 = 67;
  float r3 = 86;
  float r4 = 47; 
  float r5 = 65;
  float r6 = 73;

//variabili buzz
  float theMagnitude1, theMagnitude2, theMagnitude3, theMagnitude4, theMagnitude5, theMagnitude6;
  float v1 = 0, pv1 = 0, v2 = 0, pv2 = 0, v3 = 0, pv3 = 0, v4 = 0, pv4 = 0, v5 = 0, pv5 = 0, v6 = 0, pv6 = 0;
  float easing = 40;

  float multiplier = 190;  //settalo uguale agli fps

//variabili utili  
  float fps = 190;
  float limite = 100000; //limite del map per raggio e opacità

//<----------------------------------SETUP---------------------------------->

void setup() {
  
//setup comunicazione seriale con Arduino  
  myPort = new Serial(this, Serial.list()[0], 9600); //inizializza porta seriale baud 9600
  myPort.bufferUntil('\n');
  
//specifica le caratteristiche della finestra
    size(1920, 1080, P3D); //renderer (P3D funziona sul web)
    smooth(); //abilita antialiasing
    noStroke();
    frameRate(fps);
    noCursor();

    
    nitti = loadFont("NittiPX-Light-48.vlw");
    textFont(nitti);
  
//valori iniziali cerchi, vettore posizione x,y;
     i1 = new PVector(300, 540);
     i2 = new PVector(564, 540);
     i3 = new PVector(828, 540);
     i4 = new PVector(1092, 540);
     i5 = new PVector(1356, 540);
     i6 = new PVector(1620, 540);
  
}




/*---------------------------------DRAW----------------------------------*/

//crea la finestra con cui interagire
void draw() {
  
//mostra fps nella barra della finestra  
    surface.setTitle(int(frameRate) + " fps");
  
//sfondo
    background(255,255,255,100);
    ellipseMode(CENTER); 
 
//formula che crea i cerchi, r*2 perché nell'ellipse rappresenta il diametro
    fill(68,157,215,map(r1, 0, limite, 20, 100));                //mappa opacità in base al raggio attuale
    ellipse (i1.x, i1.y, theMagnitude1*2, theMagnitude1*2); 
    
    fill(68,157,215,map(r2, 0, limite, 20, 100));
    ellipse (i2.x, i2.y, theMagnitude2*2, theMagnitude2*2);
    
    fill(68,157,215,map(r3, 0, limite, 20, 100));
    ellipse (i3.x, i3.y, theMagnitude3*2, theMagnitude3*2);
    
    fill(68,157,215,map(r4, 0, limite, 20, 100));
    ellipse (i4.x, i4.y, theMagnitude4*2, theMagnitude4*2);
    
    fill(68,157,215,map(r5, 0, limite, 20, 100));
    ellipse (i5.x, i5.y, theMagnitude5*2, theMagnitude5*2);
    
    fill(68,157,215,map(r6, 0, limite, 20, 100));
    ellipse (i6.x, i6.y, theMagnitude6*2, theMagnitude6*2);

//buzz
    buzz();
    buzz2();
    buzz3();
    buzz4();
    buzz5();
    buzz6();
   
//testo
   testo1();
   testo2();
   testo3();
   testo4();
   testo5();
   testo6();
  
//numeri
   numerotesto1();
   numerotesto2();
   numerotesto3();
   numerotesto4();
   numerotesto5();
   numerotesto6();

//crea linee che uniscono centro cerchi con box di testo
stroke(126, 50);
line(300, 540, 300, i1.y + theMagnitude1  + 60);
line(564, 540, 564, i2.y - theMagnitude2  - 60);
line(828, 540, 828, i3.y + theMagnitude3  + 60);
line(1092, 540, 1092, i4.y - theMagnitude4  - 60);
line(1356, 540, 1356, i5.y + theMagnitude5  + 60);
line(1620, 540, 1620, i6.y - theMagnitude6  - 60);
noStroke();

}



//qui finisce il draw
//<--------------------------------FUNZIONI---------------------------------->

//funzione per la comunicazione seriale con Arduino
//Ogni volta che vede un carriage return viene chiamata
void serialEvent(Serial myPort) {
    //mette i dati in arrivo in una varibile - 
    // '\n' è il limite finale, indica la fine di un pacchetto completo
    valSerial = myPort.readStringUntil('\n');
    
    //si assicura che i dati non siano nulli prima di continuare
    if (valSerial != null) {
      //taglia spazie formatta i caratteri (like carriage return)
      valSerial = trim(valSerial);
      println(valSerial);
    
      //cerca la stringa 'A' per iniziare l'handshake
      //se è lì, pulisce il buffer, e manda una richiesta di dati
      if (firstContact == false) {
        if (valSerial.equals("A")) {
          myPort.clear();
          firstContact = true;
          myPort.write("A");
          println("contact");
        }
      }
      else { //se è già stato stabilito il contatto, continua a prendere e fare il parsing dei dati
        println(valSerial);
    
        if (valSerial.equals("BottigliaEntrata")) 
        {                           //se la finestra viene cliccata
          myPort.write(numero1);        //manda il numero delle bottiglie, come variabile?                       GUARDAMI
          println("Ok grazie");
          bottiglia = true;
        } else{ // if (valSerial.equals("AttendoBottiglia")) 
          bottiglia = false;
        }
    
        // finita la comunicazione, chiede altri dati scrivendo A:
        //myPort.write("A");
        }
      }
}

void buzz() {
 if (bottiglia == true) {
      pv1 = easing * 3; //--------------------------------------------------------------------------------------CAMBIAMI
      v1 -= (v1 - pv1) / easing;
      theMagnitude1 = r1 + v1; 
      //println(theMagnitude1); //Checking the lenght in the console                                             DEBUG
    } else {
      pv1 = 0;
      v1 -= (v1 - pv1) / easing;
      theMagnitude1 = r1 + v1; 
    }  
}

void buzz2() {
 if (bottiglia == true) {
      pv2 = easing * 1;
      v2 -= (v2 - pv2) / easing;
      theMagnitude2 = r2 + v2; 
    } else {
      pv2 = 0;
      v2 -= (v2 - pv2) / easing;
      theMagnitude2 = r2 + v2; 
    }  
}

void buzz3() {
 if (bottiglia == true) {
      pv3 = easing * 12;
      v3 -= (v3 - pv3) / easing;
      theMagnitude3 = r3 + v3; 
    } else {
      pv3 = 0;
      v3 -= (v3 - pv3) / easing;
      theMagnitude3 = r3 + v3; 
    }  
}

void buzz4() {
 if (bottiglia == true) {
      pv4 = easing * 4;
      v4 -= (v4 - pv4) / easing;
      theMagnitude4 = r4 + v4; 
    } else {
      pv4 = 0;
      v4 -= (v4 - pv4) / easing;
      theMagnitude4 = r4 + v4; 
    }  
}

void buzz5() {
 if (bottiglia == true) {
      pv5 = easing * 15;
      v5 -= (v5 - pv5) / easing;
      theMagnitude5 = r5 + v5; 
    } else {
      pv5 = 0;
      v5 -= (v5 - pv5) / easing;
      theMagnitude5 = r5 + v5; 
    }  
}

void buzz6() {
 if (bottiglia == true) {   
      pv6 = easing * 2;
      v6 -= (v6 - pv6) / easing;
      theMagnitude6 = r6 + v6; 
    } else {
      pv6 = 0;
      v6 -= (v6 - pv6) / easing;
      theMagnitude6 = r6 + v6; 
    }  
}


void numerotesto1() {
    textSize(40);
    fill(68,157,215);
    text(numero1 + " ", i1.x - 60, i1.y + theMagnitude1  + 85, 150, 80);  // Text wraps within text box
    
    time++;
      if ( time > ntime )
      {
          ntime = time + ( multiplier * SECONDS_PER_THING );
          numero1++;
          r1 = map (numero1, 0, limite, 25, height/2 - 100);
      }
    }

void testo1() {
    textSize(15);
    fill(50);
    text("Litri di carburante risparmiato", i1.x - 60, i1.y + theMagnitude1  + 130, 150, 80);  // Text wraps within text box
    }


void numerotesto2() {
    textSize(40);
    fill(68,157,215);
    text(numero2 + " ", i2.x - 60, i2.y - theMagnitude2 - 165, 150, 80);  // Text wraps within text box
    
    time2++;
      if ( time2 > ntime2 )
      {
          ntime2 = time2 + ( multiplier * SECONDS_PER_THING2 );
          numero2++;
          r2 = map (numero2, 0, limite, 10, height/2 - 100);
      }
    }

void testo2() {
    textSize(15);
    fill(50);
    text("Kg di CO2 non emessi", i2.x - 60, i2.y - theMagnitude2  - 120, 150, 80);  // Text wraps within text box
    }
    
    
void numerotesto3() {
    textSize(40);
    fill(68,157,215);
    text(numero3 + " ", i3.x - 60, i3.y + theMagnitude3  + 85, 150, 80);  // Text wraps within text box
    
    time3++;
      if ( time3 > ntime3 )
      {
          ntime3 = time3 + ( multiplier * SECONDS_PER_THING3 );
          numero3++;
          r3 = map (numero3, 0, limite, 150, height/2 - 100);
      }
    }    
    
void testo3() {
    textSize(15);
    fill(50);
    text("Bottiglie di plastica prodotte", i3.x - 60, i3.y + theMagnitude3  + 130, 150, 80);  // Text wraps within text box
    }   
    
    
    
void numerotesto4() {
    textSize(40);
    fill(68,157,215);
    text(numero4 + " ", i4.x - 60, i4.y - theMagnitude4  - 165, 150, 95);  // Text wraps within text box
    
    time4++;
      if ( time4 > ntime4 )
      {
          ntime4 = time4 + ( multiplier * SECONDS_PER_THING4 );
          numero4++;
          r4 = map (numero4, 0, limite, 100, height/2 - 100);
      }
    }
    
void testo4() {
    textSize(15);
    fill(50);
    text("Bottiglie di plastica riciclate", i4.x - 60, i4.y - theMagnitude4  - 120, 150, 80);  // Text wraps within text box
    }
    
    
void numerotesto5() {
    textSize(40);
    fill(68,157,215);
    text(numero5 + " ", i5.x - 60, i5.y + theMagnitude5 + 85, 150, 80);  // Text wraps within text box
    
    time5++;
      if ( time5 > ntime5 )
      {
          ntime5 = time5 + ( multiplier * SECONDS_PER_THING5 );
          numero5++;
          r5 = map (numero5, 0, limite, 200, height/2 - 100);
      }
    }    
    
void testo5() {
    textSize(15);
    fill(50);
    text("Litri di H2O risparmiati", i5.x - 60, i5.y + theMagnitude5  + 130, 150, 80);  // Text wraps within text box
    }
    
    
void numerotesto6() {
    textSize(40);
    fill(68,157,215);
    text(numero6 + " ", i6.x - 60, i6.y - theMagnitude6  - 165, 150, 80);  // Text wraps within text box
    
    time6++;
      if ( time6 > ntime6 )
      {
          ntime6 = time6 + ( multiplier * SECONDS_PER_THING6 );
          numero6++;
          r6 = map (numero6, 0, limite, 17, height/2 - 100);
      }
    }    
    
void testo6() {
    textSize(15);
    fill(50);
    text("KWh di corrente risparmiati", i6.x - 60, i1.y - theMagnitude6  - 120, 150, 80);  // Text wraps within text box
    }