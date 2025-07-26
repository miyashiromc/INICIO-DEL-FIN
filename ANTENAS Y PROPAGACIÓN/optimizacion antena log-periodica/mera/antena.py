import numpy as np
import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle
from scipy.constants import speed_of_light
from mpl_toolkits.mplot3d import Axes3D

class LogPeriodicAntenna:
    def __init__(self, freq_low=100e6, freq_high=500e6, n_elements=12, tau=0.85, sigma=0.05):
        """
        Diseño de antena log-periódica con visualización de lóbulos de radiación
        
        Parámetros:
        - freq_low: Frecuencia más baja de operación (Hz)
        - freq_high: Frecuencia más alta de operación (Hz)
        - n_elements: Número de elementos (12)
        - tau: Relación de escalamiento (0.7-0.95)
        - sigma: Factor de espaciado (0.03-0.06)
        """
        self.freq_low = freq_low
        self.freq_high = freq_high
        self.n_elements = n_elements
        self.tau = tau
        self.sigma = sigma
        
        # Calcular dimensiones
        self.calculate_dimensions()
        
    def calculate_dimensions(self):
        """Calcula las dimensiones de la antena según los parámetros dados"""
        # Longitud de onda a la frecuencia más baja
        lambda_low = speed_of_light / self.freq_low
        
        # Longitud del elemento más largo (L1)
        self.L1 = 0.5 * lambda_low * 0.95  # Factor de acortamiento
        
        # Longitudes de los elementos (L1 a L12)
        self.lengths = [self.L1 * (self.tau**i) for i in range(self.n_elements)]
        
        # Espaciado entre elementos (D1 a D11)
        self.spacings = [2 * self.sigma * self.lengths[i] for i in range(self.n_elements-1)]
        
        # Ancho de los elementos (proporcional a la longitud)
        self.widths = [0.002 * self.lengths[i] for i in range(self.n_elements)]
        
        # Longitud total de la antena
        self.total_length = sum(self.spacings) + self.lengths[0]/2 + self.lengths[-1]/2
        
    def plot_antenna(self):
        """Visualiza el diseño de la antena"""
        fig, ax = plt.subplots(figsize=(12, 6))
        
        # Posición inicial (centrada en y)
        y_center = 0
        x_pos = 0
        
        # Dibujar cada elemento
        for i, (length, width, spacing) in enumerate(zip(self.lengths, self.widths, self.spacings + [0])):
            # Dibujar elemento (dipolo)
            element_top = Rectangle((x_pos, y_center - length/2), width, length, 
                                   linewidth=1, edgecolor='blue', facecolor='none')
            element_bottom = Rectangle((x_pos, y_center - length/2), -width, length, 
                                     linewidth=1, edgecolor='blue', facecolor='none')
            
            ax.add_patch(element_top)
            ax.add_patch(element_bottom)
            
            # Mover posición para el siguiente elemento
            x_pos += spacing + width
            
            # Etiquetar el elemento
            ax.text(x_pos - spacing/2 - width, y_center + length/2 + 0.02, 
                   f'L{i+1}\n{length*100:.2f}cm', ha='center', va='bottom', fontsize=8)
        
        # Configurar el gráfico
        ax.set_xlim(-self.lengths[0]/2, x_pos + self.lengths[-1]/2)
        ax.set_ylim(-self.lengths[0], self.lengths[0])
        ax.set_aspect('equal')
        ax.set_title(f'Diseño de Antena Log-Periodica ({self.n_elements} elementos)\n'
                    f'Frecuencia: {self.freq_low/1e6:.0f}-{self.freq_high/1e6:.0f} MHz\n'
                    f'τ={self.tau:.2f}, σ={self.sigma:.2f}')
        ax.set_xlabel('Posición (metros)')
        ax.set_ylabel('Altura (metros)')
        ax.grid(True)
        
        plt.tight_layout()
        plt.show()
    
    def calculate_radiation_pattern(self, freq=300e6):
        """
        Calcula un patrón de radiación teórico para la antena
        Esta es una aproximación simplificada para visualización
        """
        # Convertir ángulos a radianes
        theta = np.linspace(0, 2*np.pi, 360)
        
        # Patrón teórico de un arreglo log-periódico (simplificado)
        # Lóbulo principal en la dirección del eje de la antena (0°)
        # Ancho del haz basado en la longitud eléctrica
        wavelength = speed_of_light / freq
        electrical_length = self.total_length / wavelength
        
        # Patrón aproximado (esto es una simplificación)
        pattern = np.cos(theta)**2 * np.sinc(2 * electrical_length * np.sin(theta))**2
        
        # Normalizar
        pattern = np.abs(pattern)
        pattern = pattern / np.max(pattern)
        
        return theta, pattern
    
    def plot_radiation_pattern_2d(self, freq=300e6):
        """Grafica el patrón de radiación en 2D (vista superior)"""
        theta, pattern = self.calculate_radiation_pattern(freq)
        
        # Convertir a grados para el gráfico
        theta_deg = np.degrees(theta)
        
        fig, ax = plt.subplots(subplot_kw={'projection': 'polar'}, figsize=(8, 8))
        ax.plot(theta, pattern, linewidth=2, color='red')
        
        ax.set_title(f'Patrón de Radiación a {freq/1e6:.0f} MHz\n'
                    f'(Vista superior - Corte horizontal)', pad=20)
        ax.grid(True)
        
        # Marcar la dirección del lóbulo principal
        ax.annotate('Dirección máxima', xy=(0, 1), xytext=(0.15, 1.1),
                    arrowprops=dict(arrowstyle='->'), fontsize=10)
        
        plt.tight_layout()
        plt.show()
    
    def plot_radiation_pattern_3d(self, freq=300e6):
        """Grafica el patrón de radiación en 3D"""
        theta = np.linspace(0, 2*np.pi, 360)
        phi = np.linspace(0, np.pi, 180)
        
        # Crear malla de ángulos
        theta_grid, phi_grid = np.meshgrid(theta, phi)
        
        # Patrón aproximado en 3D (simplificado)
        # Lóbulo principal en la dirección del eje de la antena
        pattern = (np.cos(phi_grid)**2 * 
                  np.sinc(2 * (self.total_length / (speed_of_light / freq)) * 
                  np.sin(theta_grid))**2)
        
        # Convertir a coordenadas cartesianas para el gráfico 3D
        pattern = np.abs(pattern)
        pattern = pattern / np.max(pattern)
        
        x = pattern * np.sin(phi_grid) * np.cos(theta_grid)
        y = pattern * np.sin(phi_grid) * np.sin(theta_grid)
        z = pattern * np.cos(phi_grid)
        
        fig = plt.figure(figsize=(10, 8))
        ax = fig.add_subplot(111, projection='3d')
        
        # Graficar superficie
        surf = ax.plot_surface(x, y, z, rstride=1, cstride=1, cmap='jet',
                              linewidth=0, antialiased=False, alpha=0.7)
        
        # Configuraciones del gráfico
        ax.set_title(f'Patrón de Radiación 3D a {freq/1e6:.0f} MHz', pad=20)
        ax.set_xlabel('X')
        ax.set_ylabel('Y')
        ax.set_zlabel('Z')
        
        # Añadir barra de colores
        fig.colorbar(surf, shrink=0.5, aspect=5, label='Ganancia relativa')
        
        plt.tight_layout()
        plt.show()
    
    def print_dimensions(self):
        """Imprime las dimensiones de la antena en una tabla"""
        print("Dimensiones de la antena log-periódica:")
        print("="*60)
        print(f"{'Elemento':<10}{'Longitud (m)':<15}{'Espaciado (m)':<15}{'Ancho (m)':<15}")
        print("-"*60)
        
        for i in range(self.n_elements):
            length = self.lengths[i]
            width = self.widths[i]
            spacing = self.spacings[i] if i < len(self.spacings) else 0
            print(f"{f'L{i+1}':<10}{length:<15.4f}{spacing:<15.4f}{width:<15.4f}")
        
        print("="*60)
        print(f"Longitud total de la antena: {self.total_length:.2f} metros")

# Crear y visualizar la antena
antenna = LogPeriodicAntenna(freq_low=100e6, freq_high=500e6, n_elements=12, tau=0.85, sigma=0.05)

# Mostrar dimensiones
antenna.print_dimensions()

# Visualizar diseño
antenna.plot_antenna()

# Visualizar patrones de radiación
print("\nVisualización de patrones de radiación a 300 MHz:")
antenna.plot_radiation_pattern_2d(freq=300e6)
antenna.plot_radiation_pattern_3d(freq=300e6)