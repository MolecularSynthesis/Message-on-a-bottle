/*----------------------------------------------MESSAGE ON A BOTTLE-------------------------------------------*/
/*Codice per la macchina comunicativa "Message on a Bottle"
By molecular.
Martina Barri - Nicola Brignoli - Francesco D'Agostino - Gianluca Dellara
2017 Laboratorio di sintesi finale - C1*/


/*---------------------------------LIBRERIE-------------------------------------*/
#include <AccelStepper.h> //AccelStepper
#include <Servo.h> //ArduinoServo

/*---------------------------------OGGETTI-------------------------------------*/
Servo myServo;  //Servo
AccelStepper rotazione(1, 5, 6); //rotazione step=5 dir=6

/*---------------------------------VARIABILI-------------------------------------*/
/*-----------------SENSORE------------------*/
const int sensore = A0; //pin del sensore
const int valoreSensore = 180; 
const int valoreSensoreSotto = 280;
//Per calibrare imposta < 1
//AULA ESAME (luci accese) 399-435 | 100-283-224-87 (150-220)
//ATRIO SERA 400+ | 120 (attivo)
//AULA SOLE 620+ | 450 (attivo) | 500 (valore effettivo)
//AULA TENDE CHIUSE 350+ | 100 (attivo)

/*-----------------LED------------------*/
const int Rled = 9; //pin rosso
const int Gled = 10; //pin verde
const int Bled = 11; //pin blu
int Rbrightness; //luminosità R
int Gbrightness; //luminosità G
int Bbrightness; //luminosità B
/*-----------------SERVO------------------*/
const int pos0 = 163; //pos. iniziale
const int pos1 = 60; //pos. in fase di stampa <----------------------------------CALIBRARE->60
/*-----------------MOTORI------------------*/
//Elevatore
const int elevatoreStep = 3; //step su pin 3
const int elevatoreDir = 4; //dir su pin 4
/*-----------------MICROSWITCH------------------*/
const int switchSup = 8; //pin del microswitch superiore
const int switchInf = 7; //pin del microswitch inferiore




/*---------------------------------SETUP-------------------------------------*/
void setup() {
    Serial.begin(9600); //Serial monitor
    //DEBUG
    Serial.print("SETUP QUI");
    Serial.print("sensore: "); //calibrazione ---------------> non le scrive troppovelocemente nel monitor?
    Serial.print(analogRead(A0));
    Serial.print("\t");
    Serial.print("switch inferiore: "); //debug
    Serial.print(digitalRead(switchInf));
    Serial.print("\t");
    Serial.print("switch superiore: "); //debug
    Serial.print(digitalRead(switchSup));
    Serial.println("\t");
    /*-----------------SENSORE INFRAROSSO------------------*/
    pinMode(sensore, INPUT);
    /*-----------------INIZIALIZZAZIONE SERVO------------------*/
    myServo.attach(2); //Servo su pin 11
    myServo.write(pos0); //porta il servo alla base
    /*-----------------INIZIALIZZAZIONE MOTORI------------------*/
    /*Elevatore*/
    //BASE IN BASSO (CALIBRAZIONE INIZIALE)
    digitalWrite(elevatoreDir, HIGH); //Verso il basso (senso antiorario) - rosso giù
    while (digitalRead(switchInf) == 1) {
      digitalWrite(elevatoreStep, HIGH); 
      delayMicroseconds(500); //da 550 a 300
      digitalWrite(elevatoreStep, LOW); 
      delayMicroseconds(500); //da 550 a 300
    }
}




/*---------------------------------LOOP-------------------------------------*/
void loop() {
  /*-----------------SENSORE------------------*/
  Serial.print("sensore: "); //calibrazione ---------------> non le scrive troppovelocemente nel monitor?
  Serial.print(analogRead(A0));
  Serial.print("\t");
  Serial.print("switch inferiore: "); //debug
  Serial.print(digitalRead(switchInf));
  Serial.print("\t");
  Serial.print("switch superiore: "); //debug
  Serial.print(digitalRead(switchSup));
  Serial.println("\t");

  /*-----------------A- SE IL SENSORE E' ATTIVO------------------*/
  if(analogRead(A0) < valoreSensore) {//sensore ostruito da qualcosa ATRIO (18:40) -> 350+ (fermo), 75- (bottiglietta)
    /*-----------------1- LED SI ACCENDONO------------------*/
    /*for(int i=0; i<=255; i+=5) {
      Rbrightness = i;
      Gbrightness = i;
      Bbrightness = i;
      analogWrite(Bled, Bbrightness);
      analogWrite(Rled, Rbrightness);
      analogWrite(Gled, Gbrightness);
      delay(30);
    }*/
    delay(1800);//delay per assicurarsi che la bottiglia sia giù<------------------------------CALIBRARE
    

    /*-----------------2- SERVO POS1------------------*/
    myServo.write(pos1); //servo si posiziona per stampare
    delay(250);//<-----------------------------------------------------------------------------CALIBRARE
    

    /*-----------------3- MOTORE ROTAZIONE------------------*/
    rotazione.moveTo(550);//<------------------------------------------------------------------CALIBRARE!!!
    rotazione.setMaxSpeed(275);//<-------------------------------------------------------------CALIBRARE -> 150
    rotazione.setAcceleration(200);//<---------------------------------------------------------CALIBRARE
    while(rotazione.distanceToGo() != 0) { //finché non ha completato la distanza scritta in moveTo,
      rotazione.run(); //gira
    }
    rotazione.setCurrentPosition(0);//Correzione per continuare il ciclo
    
    
    /*-----------------4- SERVO POS0------------------*/
    myServo.write(pos0); //il servo torna alla posizione iniziale
    delay(500); //cerchiamo di non distruggere il carrello, quando siamo sicuri si può togliere


    /*-----------------5- ELEVATORE SU------------------*/
    digitalWrite(elevatoreDir, LOW); //Verso l'alto (senso orario)
    while (digitalRead(switchSup) == 1) {
      digitalWrite(elevatoreStep, HIGH); 
      delayMicroseconds(500); //da 550 a 300
      digitalWrite(elevatoreStep, LOW); 
      delayMicroseconds(500); //da 550 a 300
    }


    /*-----------------6- ELEVATORE FERMO------------------*/
    while (analogRead(A0) < valoreSensoreSotto) { 
      delay(20); //<------RISCHIO LOOP, forse
    }

    /*-----------------7- ELEVATORE GIù------------------*/
    digitalWrite(elevatoreDir, HIGH); //Verso il basso (senso antiorario)
    while (digitalRead(switchInf) == 1) {
      digitalWrite(elevatoreStep, HIGH); 
      delayMicroseconds(500); //da 550 a 300
      digitalWrite(elevatoreStep, LOW); 
      delayMicroseconds(500); //da 550 a 300
    }


    /*-----------------8- LED SI SPENGONO------------------*/
    /*for(int i=255; i>=0; i-=5) {
      Rbrightness = i;
      Gbrightness = i;
      Bbrightness = i;
      analogWrite(Bled, Bbrightness);
      analogWrite(Rled, Rbrightness);
      analogWrite(Gled, Gbrightness);
      delay(30);
    }*/
  }
  
  /*----------------B- SE IL SENSORE NON E'ATTIVO----------------*/
  delay(5); // Aspetta 0,01s
}
