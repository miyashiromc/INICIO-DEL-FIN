#include <OneWire.h>
#include <DallasTemperature.h>

// --- Configuración del Sensor de Temperatura DS18B20 ---
// Se requiere una resistencia de PULL-UP de 4.7kΩ entre el pin de DATOS y VCC (3.3V)
const int ONE_WIRE_BUS_PIN = 4; // Pin para los datos del DS18B20

// Inicializar los objetos para los sensores
OneWire oneWire(ONE_WIRE_BUS_PIN);
DallasTemperature tempSensor(&oneWire);

// --- Configuración del Sensor de Turbidez ---
// El pin 34 es un pin ADC1, perfecto para lecturas analógicas.
const int TURBIDITY_PIN = 34; // Pin para la señal analógica del sensor de turbidez

void setup() {
  // Iniciar comunicación serial a 115200 baudios
  Serial.begin(115200);
  Serial.println("\nIniciando sistema de monitoreo...");

  // Iniciar el sensor de temperatura
  tempSensor.begin();
  Serial.println("Sensor de Temperatura DS18B20 listo.");

  Serial.println("Sensor de Turbidez listo.");
  Serial.println("------------------------------------");
}

void loop() {
  // --- Leer Sensor de Temperatura ---
  tempSensor.requestTemperatures(); // Envía el comando para obtener la temperatura
  // Se usa getTempCByIndex(0) porque solo hay un sensor en el bus.
  float temperaturaC = tempSensor.getTempCByIndex(0);

  // --- Leer Sensor de Turbidez ---
  // Lee el valor analógico crudo (de 0 a 4095 en el ESP32 con ADC de 12 bits)
  int valorTurbidezRaw = analogRead(TURBIDITY_PIN);
  
  // Convierte el valor crudo a voltaje (asumiendo un rango de 0-3.3V en el ADC del ESP32)
  // Nota: Aunque el sensor pueda dar hasta 4.2V, el ADC del ESP32 saturará en 4095 a los 3.3V.
  float voltajeTurbidez = valorTurbidezRaw * (3.3 / 4095.0);

  // --- Mostrar los datos en el Monitor Serie ---
  Serial.print("Temperatura: ");
  // DEVICE_DISCONNECTED_C es -127, el valor que devuelve si no hay comunicación.
  if (temperaturaC != DEVICE_DISCONNECTED_C) {
    Serial.print(temperaturaC);
    Serial.print(" °C");
  } else {
    Serial.print("Error (Revisar conexión o resistencia pull-up)");
  }

  Serial.print("  |  Turbidez (Raw): ");
  Serial.print(valorTurbidezRaw);
  Serial.print("  |  Turbidez (Voltaje): ");
  Serial.print(voltajeTurbidez, 2); // Imprime el voltaje con 2 decimales
  Serial.println(" V");

  // Espera 2 segundos antes de la siguiente lectura
  delay(2000);
}