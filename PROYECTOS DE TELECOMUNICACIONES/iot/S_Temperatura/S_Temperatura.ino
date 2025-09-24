/*
 * Código para ESP32: Sensores de Temperatura y Turbidez con Firebase Realtime Database
 * Método: Peticiones HTTP con POST para crear un historial de registros.
 * Mentor: PROG-TIA
 * Versión: 2.0 - Conexión a múltiples redes Wi-Fi
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// =================================================================
// 1. CONFIGURACIÓN PERSONALIZADA
// =================================================================

// --- [NUEVO] Configuración de tus redes Wi-Fi (en orden de prioridad) ---
struct WifiCredential {
  const char* ssid;
  const char* password;
};

// [NUEVO] Lista de redes a las que el ESP32 intentará conectarse
WifiCredential networks[] = {
  {"Lab_Robotica", "robotica2024"},
  {"Jose Morales", "Miyako2000"},
  {"Miyako", "miyako123"} // <-- ¡Aquí está!
};

// --- Configuración de tu Proyecto Firebase ---
const char* WEB_API_KEY = "AIzaSyArNK2FpOQGR3Mu-KwK27TN196a5JXDR_4";
const char* RTDB_URL    = "https://proyecto-iot-agua-default-rtdb.firebaseio.com";

// --- Configuración del Sensor de Temperatura ---
#define ONE_WIRE_BUS_PIN 4

// --- Configuración del Sensor de Turbidez ---
const int turbidityPin = 34;
const int numSamples = 50;
const int CLEAN_WATER_ANALOG_VALUE = 225;

// =================================================================
// 2. OBJETOS Y VARIABLES GLOBALES
// =================================================================

String idToken;
OneWire oneWire(ONE_WIRE_BUS_PIN);
DallasTemperature tempSensor(&oneWire);

// =================================================================
// 3. FUNCIONES DE CONEXIÓN Y ENVÍO
// =================================================================

// --- [MODIFICADO] Función de conexión Wi-Fi inteligente ---
bool wifiConnect() {
  if (WiFi.status() == WL_CONNECTED) {
    return true; // Si ya estamos conectados, no hacemos nada.
  }

  Serial.println("Buscando redes Wi-Fi...");

  // Contamos cuántas redes hemos configurado en la lista.
  int numNetworks = sizeof(networks) / sizeof(networks[0]);

  // Bucle para intentar conectarse a cada red de la lista.
  for (int i = 0; i < numNetworks; i++) {
    const char* current_ssid = networks[i].ssid;
    const char* current_password = networks[i].password;

    WiFi.begin(current_ssid, current_password);
    Serial.print("Intentando conectar a: ");
    Serial.print(current_ssid);

    // Damos un tiempo de espera para cada red (ej. 10 segundos).
    unsigned long startAttemptTime = millis();
    while (WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < 10000) {
      delay(500);
      Serial.print(".");
    }
    Serial.println();

    // Si la conexión fue exitosa, salimos del bucle y de la función.
    if (WiFi.status() == WL_CONNECTED) {
      Serial.print("¡Conexión exitosa! Red: ");
      Serial.print(current_ssid);
      Serial.print(" | IP: ");
      Serial.println(WiFi.localIP());
      return true;
    } else {
      Serial.println("... Falló la conexión. Probando la siguiente red.");
      WiFi.disconnect(true); // Nos aseguramos de desconectar antes del siguiente intento.
      delay(100);
    }
  }

  // Si el bucle termina y no nos conectamos a ninguna red.
  Serial.println("No se pudo conectar a ninguna de las redes Wi-Fi configuradas.");
  return false;
}


bool firebaseAnonSignUp() {
  HTTPClient http;
  String url = String("https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=") + WEB_API_KEY;

  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  int httpCode = http.POST("{\"returnSecureToken\":true}");

  if (httpCode != 200) {
    Serial.printf("Error en la autenticación anónima, código: %d\n", httpCode);
    http.end();
    return false;
  }

  DynamicJsonDocument doc(1024);
  deserializeJson(doc, http.getString());
  http.end();

  idToken = (const char*)doc["idToken"];

  if (idToken.length() > 0) {
    Serial.println("Autenticación anónima exitosa. Token obtenido.");
    return true;
  } else {
    Serial.println("Fallo al obtener el idToken de la respuesta.");
    return false;
  }
}

// --- Función para enviar la LECTURA DE TEMPERATURA a Firebase RTDB ---
bool enviarTemperatura(float temperaturaC) {
  if (idToken.isEmpty()) {
    if (!firebaseAnonSignUp()) return false;
  }

  String url = String(RTDB_URL) + "/historial_temperatura.json?auth=" + idToken;

  StaticJsonDocument<128> jsonDoc;
  float temperaturaF = DallasTemperature::toFahrenheit(temperaturaC);

  jsonDoc["celsius"] = round(temperaturaC * 100.0) / 100.0;
  jsonDoc["fahrenheit"] = round(temperaturaF * 100.0) / 100.0;

  String payload;
  serializeJson(jsonDoc, payload);

  HTTPClient http;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  int httpCode = http.POST(payload);

  http.end();

  if (httpCode == 401) {
    Serial.println("Token de temperatura expirado. Solicitando uno nuevo...");
    idToken = "";
    return enviarTemperatura(temperaturaC);
  }

  Serial.printf("Enviando Temperatura: %.2f °C -> Código HTTP: %d\n", temperaturaC, httpCode);
  return (httpCode == 200);
}

// --- Función para enviar la LECTURA DE TURBIDEZ a Firebase RTDB ---
bool enviarTurbidez(float ntu, float voltaje, int valorAnalogico) {
  if (idToken.isEmpty()) {
    if (!firebaseAnonSignUp()) return false;
  }

  String url = String(RTDB_URL) + "/historial_turbidez.json?auth=" + idToken;

  StaticJsonDocument<128> jsonDoc;
  jsonDoc["ntu"] = round(ntu * 100.0) / 100.0;
  jsonDoc["voltaje"] = round(voltaje * 100.0) / 100.0;
  jsonDoc["valor_analogico"] = valorAnalogico;

  String payload;
  serializeJson(jsonDoc, payload);

  HTTPClient http;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");

  int httpCode = http.POST(payload);

  http.end();

  if (httpCode == 401) {
    Serial.println("Token de turbidez expirado. Solicitando uno nuevo...");
    idToken = "";
    return enviarTurbidez(ntu, voltaje, valorAnalogico);
  }

  Serial.printf("Enviando Turbidez: %.2f NTU -> Código HTTP: %d\n", ntu, httpCode);
  return (httpCode == 200);
}

// =================================================================
// 4. SETUP Y LOOP
// =================================================================

void setup() {
  Serial.begin(115200);
  delay(1000);

  tempSensor.begin();
  Serial.println("Sensor de temperatura DS18B20 inicializado.");

  analogSetAttenuation(ADC_11db);
  Serial.println("Sensor de turbidez configurado.");

  if (wifiConnect()) {
    Serial.println("Setup completado. Listo para enviar datos.");
  } else {
    Serial.println("No se pudo conectar a WiFi. El programa no podrá enviar datos.");
  }
  Serial.println("------------------------------------");
}

void loop() {
  if (WiFi.status() != WL_CONNECTED) {
    wifiConnect();
  }
  
  // Solo continuamos si hay conexión a WiFi
  if(WiFi.status() == WL_CONNECTED) {
    // --- 1. Leer y enviar TURBIDEZ ---
    float sensorSum = 0;
    for (int i = 0; i < numSamples; i++) {
      sensorSum += analogRead(turbidityPin);
      delay(5);
    }
    int sensorValue = sensorSum / numSamples;
    float voltage = sensorValue * (3.3 / 4095.0);
    float ntu = 0.0;

    if (sensorValue <= CLEAN_WATER_ANALOG_VALUE) {
      ntu = 0.4; // Valor base para agua muy clara
    } else {
      // Mapeo simple. Para mayor precisión, se requeriría una curva de calibración.
      ntu = map(sensorValue, CLEAN_WATER_ANALOG_VALUE, 4095, 0, 3000);
    }

    Serial.printf("Lectura Turbidez: %d | %.2f V | %.2f NTU\n", sensorValue, voltage, ntu);
    if (enviarTurbidez(ntu, voltage, sensorValue)) {
      Serial.println(">> Dato de turbidez guardado en Firebase con éxito.");
    } else {
      Serial.println(">> Fallo al guardar el dato de turbidez en Firebase.");
    }
    Serial.println();

    // --- 2. Leer y enviar TEMPERATURA ---
    tempSensor.requestTemperatures();
    float tempC = tempSensor.getTempCByIndex(0);

    if (tempC != DEVICE_DISCONNECTED_C) {
      Serial.printf("Lectura Temperatura: %.2f °C\n", tempC);
      if (enviarTemperatura(tempC)) {
        Serial.println(">> Dato de temperatura guardado en Firebase con éxito.");
      } else {
        Serial.println(">> Fallo al guardar el dato de temperatura en Firebase.");
      }
    } else {
      Serial.println("Error al leer el sensor de temperatura. Revisa la conexión.");
    }
  }

  Serial.println("------------------------------------");
  delay(10000);
}