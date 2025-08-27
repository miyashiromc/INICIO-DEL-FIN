/*
 * Código para ESP32: Sensor de Temperatura DS18B20 con Firebase Realtime Database
 * Método: Peticiones HTTP directas con autenticación anónima.
 * * Este programa lee la temperatura de un sensor DS18B20 y sube el dato
 * a Firebase RTDB usando el método de conexión del "proyecto-iot-agua".
 */

#include <WiFi.h>
#include <HTTPClient.h>
#include <ArduinoJson.h>
#include <OneWire.h>
#include <DallasTemperature.h>

// =================================================================
// 1. CONFIGURACIÓN PERSONALIZADA
// =================================================================

// --- Configuración de tu Wi-Fi ---
#define WIFI_SSID "Jose Morales"
#define WIFI_PASSWORD "Miyako2000"

// --- Configuración de tu Proyecto Firebase ---
const char* WEB_API_KEY = "AIzaSyArNK2FpOQGR3Mu-KwK27TN196a5JXDR_4";
const char* RTDB_URL    = "https://proyecto-iot-agua-default-rtdb.firebaseio.com";

// --- Configuración del Sensor de Temperatura ---
#define ONE_WIRE_BUS_PIN 4 // Pin GPIO donde está conectado el sensor DS18B20

// =================================================================
// 2. OBJETOS Y VARIABLES GLOBALES
// =================================================================

// --- Firebase ---
String idToken; // Variable global para guardar el token de autenticación

// --- Sensor de Temperatura ---
OneWire oneWire(ONE_WIRE_BUS_PIN);
DallasTemperature tempSensor(&oneWire);

// =================================================================
// 3. FUNCIONES DE CONEXIÓN Y ENVÍO (Adaptadas)
// =================================================================

// --- Función para conectar al WiFi ---
bool wifiConnect() {
  if (WiFi.status() == WL_CONNECTED) return true;
  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  Serial.print("Conectando a la red WiFi");
  
  unsigned long startAttemptTime = millis();
  while (WiFi.status() != WL_CONNECTED && millis() - startAttemptTime < 15000) {
    delay(500);
    Serial.print(".");
  }
  Serial.println();

  if (WiFi.status() == WL_CONNECTED) {
    Serial.print("¡Conectado! IP: ");
    Serial.println(WiFi.localIP());
    return true;
  } else {
    Serial.println("Falló la conexión WiFi.");
    return false;
  }
}

// --- Función para autenticación anónima en Firebase ---
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
bool enviarTemperatura(float temperatura) {
  if (idToken.isEmpty()) {
    if (!firebaseAnonSignUp()) {
      return false;
    }
  }

  // Construye la URL. Guardaremos los datos en un nodo llamado "sensor_temperatura"
  String url = String(RTDB_URL) + "/sensor_temperatura.json?auth=" + idToken;
  
  // Crea el cuerpo del JSON que vamos a enviar: {"grados_celsius": 25.5}
  StaticJsonDocument<128> jsonDoc;
  // Usamos round() para redondear a 2 decimales y evitar enviar demasiados
  jsonDoc["grados_celsius"] = round(temperatura * 100.0) / 100.0;
  String payload;
  serializeJson(jsonDoc, payload);

  HTTPClient http;
  http.begin(url);
  http.addHeader("Content-Type", "application/json");
  int httpCode = http.PUT(payload);
  http.end();
  
  if (httpCode == 401) {
    Serial.println("Token expirado. Solicitando uno nuevo...");
    idToken = "";
    return enviarTemperatura(temperatura); // Reintenta con un token nuevo
  }

  Serial.printf("Enviando Temperatura: %.2f °C -> Código HTTP: %d\n", temperatura, httpCode);
  return (httpCode == 200);
}

// =================================================================
// 4. SETUP Y LOOP
// =================================================================

void setup() {
  Serial.begin(115200);
  delay(1000);
  
  // Iniciar el sensor de temperatura
  tempSensor.begin();
  Serial.println("Sensor de temperatura DS18B20 inicializado.");

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
  } else {
    // --- Leer la temperatura ---
    tempSensor.requestTemperatures(); 
    float tempC = tempSensor.getTempCByIndex(0);

    Serial.print("Lectura del sensor: ");
    
    // Comprobar si la lectura fue válida
    if (tempC != DEVICE_DISCONNECTED_C) {
      Serial.print(tempC);
      Serial.println(" °C");
      
      // --- Enviar la temperatura a Firebase ---
      if (enviarTemperatura(tempC)) {
          Serial.println(">> Dato de temperatura guardado en Firebase con éxito.");
      } else {
          Serial.println(">> Fallo al guardar el dato en Firebase.");
      }
    } else {
      Serial.println("Error al leer el sensor. Revisa la conexión.");
    }
  }
  
  Serial.println("------------------------------------");
  // Esperamos 10 segundos antes de la próxima lectura y envío
  delay(10000);
}
