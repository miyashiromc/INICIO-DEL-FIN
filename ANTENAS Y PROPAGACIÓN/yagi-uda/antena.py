import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D
from scipy.constants import speed_of_light
from matplotlib import cm
from scipy.special import jv
import time
from typing import Tuple

class YagiUdaSimulator:
    def __init__(self, frequency: float = 650e6, num_directors: int = 3):
        """
        Simulador mejorado de patrones de radiación para antena Yagi-UDA
        
        Mejoras implementadas:
        - Validación de parámetros de entrada
        - Cálculo optimizado de patrones
        - Manejo de singularidades matemáticas
        - Visualizaciones mejoradas
        - Documentación ampliada
        
        Args:
            frequency (float): Frecuencia en Hz (650 MHz por defecto)
            num_directors (int): Número de directores (3 por defecto)
            
        Raises:
            ValueError: Si los parámetros están fuera de rangos válidos
        """
        if frequency <= 0:
            raise ValueError("La frecuencia debe ser positiva")
        if num_directors < 0 or num_directors > 10:
            raise ValueError("El número de directores debe estar entre 0 y 10")
            
        self.frequency = frequency
        self.wavelength = speed_of_light / frequency
        self.num_directors = num_directors
        
        # Configuración optimizada de la antena Yagi
        self.setup_antenna()
        
    def setup_antenna(self):
        """Configura los parámetros de la antena basados en diseño Yagi óptimo"""
        # Posiciones de los elementos (en longitudes de onda)
        base_positions = np.array([0.0, 0.15, 0.35, 0.50, 0.65, 0.80, 0.95, 1.10, 1.25, 1.40, 1.55])
        self.positions = base_positions[:self.num_directors+2] * self.wavelength
        
        # Longitudes de los elementos (en longitudes de onda)
        base_lengths = np.array([0.55, 0.50] + [0.45] * 9)
        self.lengths = base_lengths[:self.num_directors+2] * self.wavelength
        
        # Fases óptimas para los elementos (en radianes)
        base_phases = np.array([-np.pi/2, 0] + [np.pi/4] * 9)
        self.phases = base_phases[:self.num_directors+2]
        
        # Diámetro de los elementos (en metros)
        self.diameter = 0.01
        
    def current_distribution(self, z: np.ndarray, L: float) -> np.ndarray:
        """
        Distribución de corriente aproximada en un dipolo
        
        Args:
            z: Posiciones a lo largo del dipolo
            L: Longitud total del dipolo
            
        Returns:
            np.ndarray: Distribución de corriente normalizada
        """
        k = 2 * np.pi / self.wavelength
        I0 = 1.0  # Corriente máxima normalizada
        return I0 * np.sin(k * (L/2 - np.abs(z)))
    
    def element_pattern(self, theta: np.ndarray, L: float) -> np.ndarray:
        """
        Patrón de radiación de un elemento individual con manejo de singularidades
        
        Args:
            theta: Ángulos en radianes
            L: Longitud del elemento
            
        Returns:
            np.ndarray: Patrón de radiación del elemento
        """
        k = 2 * np.pi / self.wavelength
        theta = np.where(theta == 0, 1e-10, theta)  # Evitar división por cero
        theta = np.where(theta == np.pi, np.pi-1e-10, theta)
        
        return (np.cos(k * L/2 * np.cos(theta)) - np.cos(k * L/2)) / np.sin(theta)
    
    def calculate_3d_pattern(self, theta_res: float = 2, phi_res: float = 2) -> Tuple[np.ndarray, np.ndarray, np.ndarray]:
        """
        Calcula el patrón 3D preciso considerando:
        - Factor de array
        - Patrón de elemento
        - Acoplamiento mutuo aproximado
        
        Args:
            theta_res: Resolución en theta (grados)
            phi_res: Resolución en phi (grados)
            
        Returns:
            Tuple: (theta_grid, phi_grid, pattern_db)
        """
        start_time = time.time()
        
        theta = np.linspace(0, np.pi, int(180/theta_res)+1)
        phi = np.linspace(0, 2*np.pi, int(360/phi_res)+1)
        theta_grid, phi_grid = np.meshgrid(theta, phi)
        
        k = 2 * np.pi / self.wavelength
        
        # Inicializar patrón total
        total_pattern = np.zeros_like(theta_grid, dtype=complex)
        
        # Precalcular términos comunes
        cos_theta = np.cos(theta_grid)
        sin_theta = np.sin(theta_grid)
        
        for i, (pos, L, phase) in enumerate(zip(self.positions, self.lengths, self.phases)):
            # Factor de espacio para este elemento
            space_factor = np.exp(1j * (k * pos * cos_theta + phase))
            
            # Patrón del elemento
            element_pat = self.element_pattern(theta_grid, L)
            
            # Considerar acoplamiento mutuo aproximado
            coupling = 0.8 + 0.2j if i > 0 else 1.0
            
            # Contribución de este elemento al patrón total
            total_pattern += coupling * element_pat * space_factor
        
        # Normalizar y convertir a dB
        pattern = np.abs(total_pattern)**2
        pattern_db = 10 * np.log10(pattern / np.max(pattern) + 1e-10)
        
        print(f"Tiempo de cálculo del patrón: {time.time()-start_time:.2f} segundos")
        return theta_grid, phi_grid, pattern_db
    
    def plot_3d_radiation_pattern(self):
        """Visualización 3D mejorada del patrón de radiación"""
        start_time = time.time()
        theta, phi, pattern_db = self.calculate_3d_pattern()
        
        # Convertir a coordenadas cartesianas
        r = 30 + pattern_db  # Escalar para mejor visualización
        x = r * np.sin(theta) * np.cos(phi)
        y = r * np.sin(theta) * np.sin(phi)
        z = r * np.cos(theta)
        
        fig = plt.figure(figsize=(14, 10))
        ax = fig.add_subplot(111, projection='3d')
        
        # Crear superficie con mapeo de color
        norm = plt.Normalize(-30, 0)  # Rango de dB normalizado
        colors = cm.viridis(norm(pattern_db))  # Mejor mapa de colores
        
        surf = ax.plot_surface(x, y, z, facecolors=colors, 
                             rstride=1, cstride=1, 
                             linewidth=0.1, antialiased=True, 
                             shade=True, alpha=0.9)
        
        # Configuración del gráfico
        max_range = 30
        ax.set_xlim(-max_range, max_range)
        ax.set_ylim(-max_range, max_range)
        ax.set_zlim(-max_range, max_range)
        
        title = f'Patrón de Radiación 3D - Antena Yagi-UDA\nFrecuencia: {self.frequency/1e6:.1f} MHz\nDirectores: {self.num_directors}'
        ax.set_title(title, fontsize=14, pad=20)
        ax.set_xlabel('X (dB)')
        ax.set_ylabel('Y (dB)')
        ax.set_zlabel('Z (dB)')
        ax.xaxis.labelpad = 15
        ax.yaxis.labelpad = 15
        ax.zaxis.labelpad = 15
        
        # Barra de color mejorada
        mappable = cm.ScalarMappable(norm=norm, cmap=cm.viridis)
        mappable.set_array(pattern_db)
        
        cbar = fig.colorbar(mappable, ax=ax, shrink=0.5, aspect=10, pad=0.1)
        cbar.set_label('Ganancia Relativa (dB)', rotation=270, labelpad=20)
        cbar.ax.tick_params(labelsize=10)
        
        # Vista inicial mejorada
        ax.view_init(elev=25, azim=45)
        
        # Añadir rejilla
        ax.grid(True, linestyle=':', alpha=0.5)
        
        plt.tight_layout()
        print(f"Tiempo de renderizado 3D: {time.time()-start_time:.2f} segundos")
        plt.show()
    
    def plot_principal_cuts(self):
        """Grafica los cortes principales H y E con mejoras visuales"""
        start_time = time.time()
        theta, phi, pattern_db = self.calculate_3d_pattern(theta_res=1, phi_res=1)
        
        # Corte horizontal (plano H, theta=90°)
        h_cut_idx = np.argmin(np.abs(theta[0,:] - np.pi/2))
        h_cut = pattern_db[:, h_cut_idx]
        
        # Corte vertical (plano E, phi=0°)
        e_cut_idx = np.argmin(np.abs(phi[:,0]))
        e_cut = pattern_db[e_cut_idx, :]
        theta_deg = np.rad2deg(theta[0,:])
        
        plt.figure(figsize=(14, 7))
        plt.suptitle(f'Cortes Principales - Antena Yagi-UDA {self.frequency/1e6:.1f} MHz', y=1.05)
        
        # Gráfico del corte horizontal
        plt.subplot(121, polar=True)
        plt.plot(phi[:,0], h_cut, linewidth=2, color='blue', label='Plano H')
        plt.fill_between(phi[:,0], -30, h_cut, color='blue', alpha=0.1)
        plt.title('Corte Horizontal (Plano H)\nθ = 90°', pad=20)
        plt.grid(True, linestyle=':', alpha=0.7)
        plt.legend(loc='upper right')
        
        # Gráfico del corte vertical
        plt.subplot(122, polar=True)
        plt.plot(theta[0,:], e_cut, linewidth=2, color='red', label='Plano E')
        plt.fill_between(theta[0,:], -30, e_cut, color='red', alpha=0.1)
        plt.title('Corte Vertical (Plano E)\nφ = 0°', pad=20)
        plt.grid(True, linestyle=':', alpha=0.7)
        plt.legend(loc='upper right')
        
        plt.tight_layout()
        print(f"Tiempo de renderizado de cortes: {time.time()-start_time:.2f} segundos")
        plt.show()
    
    def plot_all(self):
        """Genera todas las visualizaciones con información de tiempo"""
        print("\n" + "="*50)
        print(f"Simulación para antena Yagi-UDA @ {self.frequency/1e6:.1f} MHz")
        print(f"Número de directores: {self.num_directors}")
        print("="*50 + "\n")
        
        start_time = time.time()
        self.plot_3d_radiation_pattern()
        self.plot_principal_cuts()
        print(f"\nTiempo total de simulación: {time.time()-start_time:.2f} segundos")

# Ejemplo de uso mejorado
if __name__ == "__main__":
    print("Simulador Avanzado Mejorado de Antena Yagi-UDA")
    print("---------------------------------------------")
    
    try:
        # Crear simulador para 650 MHz con 5 directores
        yagi_sim = YagiUdaSimulator(frequency=650e6, num_directors=5)
        
        # Generar todas las gráficas
        yagi_sim.plot_all()
        
    except ValueError as e:
        print(f"Error en los parámetros: {e}")