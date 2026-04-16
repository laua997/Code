int squeeze;

void setup() {
  pinMode(2, INPUT);
  pinMode(3, INPUT);
  Serial.begin(9600);
}

void loop() {
  int button1 = digitalRead(2);
  int button2 = digitalRead(3);
  int pot = analogRead(A0);
  Serial.print(button1);
  Serial.print(",");
  Serial.print(button2);
  Serial.print(",");
  Serial.println(pot);
}