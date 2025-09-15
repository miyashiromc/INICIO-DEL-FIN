# -*- coding: utf-8 -*-
"""
Este script implementa un modelo de regresión lineal para predecir una variable 
objetivo basándose en una variable predictora.
"""

# Paso 1: Importación de Bibliotecas
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
from sklearn.model_selection import train_test_split
from sklearn.linear_model import LinearRegression
from sklearn.metrics import mean_squared_error, r2_score

# --- NOTA: Reemplaza 'datos.csv' con el nombre de tu archivo de datos ---
DATA_FILE = 'datos_salarios.csv'

def cargar_y_analizar_datos(file_path):
    """Carga los datos y realiza un análisis exploratorio inicial."""
    try:
        df = pd.read_csv(file_path)
        print("--- Análisis Exploratorio de Datos ---")
        print("Primeras 5 filas de los datos:")
        print(df.head())
        print("\nResumen del DataFrame:")
        df.info()
        print("\nEstadísticas descriptivas:")
        print(df.describe())
        return df
    except FileNotFoundError:
        print(f"Error: El archivo '{file_path}' no fue encontrado.")
        print("Por favor, asegúrate de que el archivo de datos exista y esté en la misma carpeta que el script.")
        return None

def analizar_correlacion(df):
    """Calcula y visualiza la matriz de correlación."""
    print("\n--- Análisis de Correlación ---")
    plt.figure(figsize=(10, 8))
    sns.heatmap(df.corr(), annot=True, fmt=".2f", cmap='coolwarm')
    plt.title('Matriz de Correlación')
    plt.show()

def entrenar_y_evaluar_modelo(df, variable_predictora, variable_objetivo):
    """Selecciona variables, entrena el modelo y lo evalúa."""
    # Paso 4: Selección de Variables
    X = df[[variable_predictora]]
    y = df[variable_objetivo]
    
    # Paso 5: División de los Datos
    X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=0)
    
    # Paso 6: Entrenamiento del Modelo
    print("\n--- Entrenamiento del Modelo ---")
    modelo = LinearRegression()
    modelo.fit(X_train, y_train)
    print("Modelo de Regresión Lineal entrenado.")
    
    # Paso 7: Realización de Predicciones
    y_pred = modelo.predict(X_test)
    
    # Paso 8: Evaluación del Modelo
    print("\n--- Evaluación del Modelo ---")
    mse = mean_squared_error(y_test, y_pred)
    r2 = r2_score(y_test, y_pred)
    print(f"Error Cuadrático Medio (MSE): {mse:.2f}")
    print(f"Coeficiente de Determinación (R²): {r2:.2f}")
    
    # Paso 9: Visualización de los Resultados
    print("\n--- Visualización de los Resultados ---")
    plt.figure(figsize=(10, 6))
    plt.scatter(X_test, y_test, color='gray', label='Datos Reales')
    plt.plot(X_test, y_pred, color='red', linewidth=2, label='Línea de Regresión')
    plt.title('Regresión Lineal: Datos Reales vs. Predicciones')
    plt.xlabel(variable_predictora)
    plt.ylabel(variable_objetivo)
    plt.legend()
    plt.show()

def main():
    """Función principal para ejecutar el flujo del modelo predictivo."""
    df = cargar_y_analizar_datos(DATA_FILE)
    
    if df is not None and not df.empty:
        # --- NOTA: Reemplaza 'variable_predictora' y 'variable_objetivo' ---
        # --- con los nombres de las columnas de tu archivo CSV. ---
        
        # Identificar las columnas numéricas para el análisis
        columnas_numericas = df.select_dtypes(include=np.number).columns.tolist()
        
        if len(columnas_numericas) < 2:
            print("\nError: Se necesitan al menos dos columnas numéricas para la regresión lineal.")
            return
            
        # Analizar correlación
        analizar_correlacion(df[columnas_numericas])
        
        # Se definen las variables para el modelo a partir del archivo de ejemplo.
        # PUEDES CAMBIAR ESTAS VARIABLES SI USAS OTROS DATOS.
        variable_predictora = "Años_Experiencia"
        variable_objetivo = "Salario_Anual"
        
        print(f"\nVariable Predictora (X) seleccionada: '{variable_predictora}'")
        print(f"Variable Objetivo (y) seleccionada: '{variable_objetivo}'")
        
        entrenar_y_evaluar_modelo(df, variable_predictora, variable_objetivo)

if __name__ == '__main__':
    main()
