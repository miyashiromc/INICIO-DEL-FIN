# -*- coding: utf-8 -*-

def get_initial_lpda_dimensions():
    initial_design = {
        "BoardLength": 0.33658,
        "BoardWidth": 0.42244,
        "ArmLength": [
            0.174, 0.14616, 0.12277, 0.10313, 0.08663, 0.07277, 0.06113,
            0.05135, 0.04313, 0.03623, 0.03043, 0.02556, 0.02147, 0.01804
        ],
        "ArmWidth": [
            0.00032, 0.00031999, 0.00032003, 0.00031998, 0.00031998, 0.00032005,
            0.00031997, 0.00031996, 0.00031996, 0.0003199, 0.00032008,
            0.00032003, 0.00031998, 0.00038082
        ],
        "ArmSpacing": [
            0.05568, 0.04677, 0.03929, 0.033, 0.02772, 0.02329, 0.01956,
            0.01643, 0.0138, 0.01159, 0.00974, 0.00818, 0.00687
        ]
    }
    return initial_design

def get_hardcoded_optimized_lpda_dimensions():
    optimized_design = {
        "BoardLength": 0.195,
        "BoardWidth": 0.65,
        "ArmLength": [
            0.3, 0.255, 0.2168, 0.1842, 0.1566, 0.1331, 0.1131, 0.0962,
            0.0817, 0.0695, 0.0591, 0.0502, 0.0427, 0.0363
        ],
        "ArmWidth": [
            0.0005, 0.00054, 0.00057, 0.00061, 0.00064, 0.00068, 0.00071,
            0.00075, 0.00079, 0.00082, 0.00086, 0.00089, 0.00093, 0.001
        ],
        "ArmSpacing": [
            0.03, 0.0255, 0.0217, 0.0184, 0.0157, 0.0133, 0.0113, 0.0096,
            0.0082, 0.007, 0.0059, 0.005, 0.0043
        ]
    }
    return optimized_design

def calculate_percentage_change(initial_value, optimized_value):
    if initial_value == 0:
        return None
    return ((optimized_value - initial_value) / initial_value) * 100

def process_and_compare_dimensions(initial_design, optimized_design):
    comparison_results = {}

    print("\n--- Comparación de Dimensiones (Cambio Porcentual) ---")

    for param in ["BoardLength", "BoardWidth"]:
        initial_val = initial_design[param]
        optimized_val = optimized_design[param]
        percentage_change = calculate_percentage_change(initial_val, optimized_val)
        comparison_results[param] = {
            "initial": initial_val,
            "optimized": optimized_val,
            "percentage_change": percentage_change
        }
        if percentage_change is not None:
            print(f"{param}:")
            print(f"  Inicial: {initial_val:.5f} m")
            print(f"  Optimizado: {optimized_val:.5f} m")
            print(f"  Cambio: {percentage_change:.2f}%")
        else:
            print(f"{param}: Inicial: {initial_val}, Optimizado: {optimized_val}, Cambio: N/A (valor inicial cero)")

    for param_list_name in ["ArmLength", "ArmWidth", "ArmSpacing"]:
        initial_list = initial_design[param_list_name]
        optimized_list = optimized_design[param_list_name]
        changes = []
        print(f"\n{param_list_name}:")
        min_len = min(len(initial_list), len(optimized_list))
        for i in range(min_len):
            initial_val = initial_list[i]
            optimized_val = optimized_list[i]
            percentage_change = calculate_percentage_change(initial_val, optimized_val)
            changes.append({
                "initial": initial_val,
                "optimized": optimized_val,
                "percentage_change": percentage_change
            })
            if percentage_change is not None:
                print(f"  Elemento {i+1}:")
                print(f"    Inicial: {initial_val:.5f} m")
                print(f"    Optimizado: {optimized_val:.5f} m")
                print(f"    Cambio: {percentage_change:.2f}%")
            else:
                print(f"  Elemento {i+1}: Inicial: {initial_val}, Optimizado: {optimized_val}, Cambio: N/A (valor inicial cero)")
        comparison_results[param_list_name] = changes

    return comparison_results

def genetic_algorithm_optimize_lpda(initial_parameters, objective_function=None, generations=100, population_size=50):
    print("\n--- Iniciando Optimización Conceptual con Algoritmo Genético ---")
    print(f"  Generaciones: {generations}, Tamaño de Población: {population_size}")
    print("  (Nota: En una implementación real, esto implicaría simulaciones electromagnéticas)")
    
    optimized_design_result = get_hardcoded_optimized_lpda_dimensions()
    print("  Optimización conceptual completada. Se han 'encontrado' las dimensiones optimizadas.")

    return optimized_design_result

if __name__ == "__main__":
    initial_lpda_dims = get_initial_lpda_dimensions()

    print("--- Dimensiones del Diseño Inicial de la Antena LPDA ---")
    for key, value in initial_lpda_dims.items():
        if isinstance(value, list):
            print(f"{key}: {', '.join(f'{x:.5f}' for x in value)} m")
        else:
            print(f"{key}: {value:.5f} m")

    optimized_lpda_dims = genetic_algorithm_optimize_lpda(initial_lpda_dims)

    print("\n--- Dimensiones del Diseño Optimizado de la Antena LPDA (Resultado de Optimización Conceptual) ---")
    for key, value in optimized_lpda_dims.items():
        if isinstance(value, list):
            print(f"{key}: {', '.join(f'{x:.5f}' for x in value)} m")
        else:
            print(f"{key}: {value:.5f} m")

    comparison_results = process_and_compare_dimensions(initial_lpda_dims, optimized_lpda_dims)

    print("\nProcesamiento completado. Los resultados detallados están disponibles en la variable 'comparison_results'.")
