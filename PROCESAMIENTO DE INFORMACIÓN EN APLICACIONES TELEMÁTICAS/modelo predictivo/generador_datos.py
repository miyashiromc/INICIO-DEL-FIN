# -*- coding: utf-8 -*-
"""
Este script genera un archivo CSV con datos simulados de salarios 
basados en años de experiencia. Es ideal para crear un conjunto de datos
grande y realista para modelos de regresión lineal.
"""

import pandas as pd
import numpy as np

# --- PARÁMETROS DE CONFIGURACIÓN ---
# Puedes cambiar estos valores para generar diferentes datos
NUM_REGISTROS = 1500
NOMBRE_ARCHIVO = 'datos_salarios.csv'
SALARIO_BASE = 35000  # Salario inicial para alguien con 0 años de experiencia
INCREMENTO_POR_AÑO = 2500 # Incremento salarial promedio por cada año de experiencia
RUIDO_SALARIAL = 8000 # Factor de aleatoriedad para simular variaciones reales

def generar_datos():
    """
    Crea un DataFrame de pandas con datos simulados y lo guarda en un archivo CSV.
    """
    print(f"Iniciando la generación de {NUM_REGISTROS} registros...")
    
    # 1. Generar los años de experiencia
    # Generamos valores aleatorios entre 0 y 30 años.
    años_experiencia = np.random.rand(NUM_REGISTROS) * 30
    
    # 2. Calcular el salario teórico (la línea recta perfecta)
    salario_teorico = SALARIO_BASE + (años_experiencia * INCREMENTO_POR_AÑO)
    
    # 3. Añadir "ruido" para hacerlo más realista
    # En el mundo real, el salario no es perfecto y depende de muchos factores.
    # Usamos una distribución normal para simular esta variabilidad.
    ruido = np.random.randn(NUM_REGISTROS) * RUIDO_SALARIAL
    
    # 4. Calcular el salario final, asegurando que no sea negativo
    salario_anual = salario_teorico + ruido
    salario_anual = np.maximum(0, salario_anual) # Nos aseguramos de no tener salarios negativos
    
    # 5. Crear el DataFrame
    df = pd.DataFrame({
        'Años_Experiencia': años_experiencia.round(1),
        'Salario_Anual': salario_anual.round(2)
    })
    
    # 6. Guardar los datos en un archivo CSV
    try:
        df.to_csv(NOMBRE_ARCHIVO, index=False)
        print(f"¡Éxito! Se ha creado el archivo '{NOMBRE_ARCHIVO}' con {len(df)} filas.")
    except Exception as e:
        print(f"Error al guardar el archivo: {e}")

if __name__ == '__main__':
    generar_datos()
