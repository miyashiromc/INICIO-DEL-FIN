
import React, { useState, useEffect } from 'react';
import { csvParse } from 'd3-dsv';
import { CSV_DATA } from './constants';
import type { RadiationDataPoint } from './types';
import { MapVisualization } from './components/MapVisualization';
import { SunIcon } from './components/Icons';

const App: React.FC = () => {
  const [data, setData] = useState<RadiationDataPoint[]>([]);
  const [loading, setLoading] = useState<boolean>(true);

  useEffect(() => {
    // This timeout simulates a network request for a better loading experience.
    setTimeout(() => {
      const parsedData = csvParse(CSV_DATA, (d) => {
        const row = d as { lat: string; lon: string; RADIACION: string };
        if (row.lat && row.lon && row.RADIACION) {
          const lat = Number(row.lat);
          const lon = Number(row.lon);
          const radiation = Number(row.RADIACION);

          // Ensure all values are valid numbers before creating the data point.
          if (!isNaN(lat) && !isNaN(lon) && !isNaN(radiation)) {
            return { lat, lon, radiation };
          }
        }
        // Return null for rows that are incomplete or have invalid number formats.
        return null;
      }).filter((d): d is RadiationDataPoint => d !== null); // Filter out any null rows

      setData(parsedData);
      setLoading(false);
    }, 500);
  }, []);

  return (
    <div className="relative h-screen w-screen bg-slate-900 text-white flex flex-col antialiased">
      <header className="absolute top-0 left-0 right-0 z-[1000] p-4 bg-gradient-to-b from-slate-900/90 to-transparent pointer-events-none">
        <div className="container mx-auto flex items-center gap-3">
          <div className="bg-yellow-400/20 p-2 rounded-lg">
             <SunIcon className="w-8 h-8 text-yellow-400" />
          </div>
           <div>
            <h1 className="text-xl sm:text-2xl font-bold text-white tracking-tight">Visualizador de Radiación UTEQ</h1>
            <p className="text-xs sm:text-sm text-slate-300">Análisis geoespacial de datos de radiación</p>
           </div>
        </div>
      </header>
      
      <main className="flex-grow h-full w-full">
        {loading ? (
          <div className="flex items-center justify-center h-full text-slate-400">
            <svg className="animate-spin -ml-1 mr-3 h-5 w-5 text-white" xmlns="http://www.w3.org/2000/svg" fill="none" viewBox="0 0 24 24">
              <circle className="opacity-25" cx="12" cy="12" r="10" stroke="currentColor" strokeWidth="4"></circle>
              <path className="opacity-75" fill="currentColor" d="M4 12a8 8 0 018-8V0C5.373 0 0 5.373 0 12h4zm2 5.291A7.962 7.962 0 014 12H0c0 3.042 1.135 5.824 3 7.938l3-2.647z"></path>
            </svg>
            <p>Cargando datos del mapa...</p>
          </div>
        ) : (
          <MapVisualization data={data} />
        )}
      </main>
    </div>
  );
};

export default App;
