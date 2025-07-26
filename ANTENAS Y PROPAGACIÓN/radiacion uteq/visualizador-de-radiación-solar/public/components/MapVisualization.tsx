
import React, { useMemo } from 'react';
import { MapContainer, TileLayer, CircleMarker, Popup, Tooltip } from 'react-leaflet';
import { scaleSequential } from 'd3-scale';
import { interpolateInferno } from 'd3-scale-chromatic';
import { extent } from 'd3-array';
import type { RadiationDataPoint } from '../types';
import type { LatLngExpression } from 'leaflet';

// Legend component defined within the same file as it's tightly coupled.
const Legend: React.FC<{ min: number; max: number; colorScale: (val: number) => string }> = ({ min, max, colorScale }) => {
  const legendSteps = 5;
  const valueStep = (max - min) / (legendSteps - 1);
  const legendItems = Array.from({ length: legendSteps }, (_, i) => min + i * valueStep);

  const fromColor = colorScale(min);
  const toColor = colorScale(max);

  return (
    <div className="absolute bottom-4 right-4 z-[1000] p-3 bg-slate-800/80 backdrop-blur-sm rounded-lg shadow-lg border border-slate-700 w-48">
      <h3 className="text-sm font-bold text-slate-100 mb-2">Radiación</h3>
      <div className="flex items-center space-x-2">
        <div className="w-4 h-20 rounded" style={{ background: `linear-gradient(to top, ${fromColor}, ${toColor})` }}></div>
        <div className="flex flex-col justify-between h-20 text-xs text-slate-300">
           <span>{max.toFixed(1)}</span>
           <span>{min.toFixed(1)}</span>
        </div>
      </div>
       <p className="text-xs text-slate-400 mt-2">Valores aproximados.</p>
    </div>
  );
};


export const MapVisualization: React.FC<{ data: RadiationDataPoint[] }> = ({ data }) => {
  const { center, radiationDomain, colorScale } = useMemo(() => {
    if (!data || data.length === 0) {
      return {
        center: [-1.01, -79.46] as LatLngExpression,
        radiationDomain: [0, 1] as [number, number],
        colorScale: scaleSequential(interpolateInferno).domain([0, 1])
      };
    }

    const centerLat = data.reduce((sum, p) => sum + p.lat, 0) / data.length;
    const centerLon = data.reduce((sum, p) => sum + p.lon, 0) / data.length;
    
    const domain = extent(data, d => d.radiation) as [number, number];
    
    const scale = scaleSequential(interpolateInferno).domain(domain);

    return {
      center: [centerLat, centerLon] as LatLngExpression,
      radiationDomain: domain,
      colorScale: scale,
    };
  }, [data]);

  if (!data || data.length === 0) {
    return <div className="flex justify-center items-center h-full"><p>No data available to display.</p></div>;
  }
  
  return (
    <div className="h-full w-full relative">
      <MapContainer center={center} zoom={13} scrollWheelZoom={true} className="h-full w-full">
        <TileLayer
          attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors &copy; <a href="https://carto.com/attributions">CARTO</a>'
          url="https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png"
        />
        {data.map((point, index) => (
          <CircleMarker
            key={index}
            center={[point.lat, point.lon]}
            radius={5}
            pathOptions={{
              color: colorScale(point.radiation),
              fillColor: colorScale(point.radiation),
              fillOpacity: 0.7,
              weight: 1,
            }}
          >
            <Popup>
              <div className="text-sm">
                <p className="font-bold">Punto de Datos</p>
                <p><strong>Latitud:</strong> {point.lat.toFixed(4)}</p>
                <p><strong>Longitud:</strong> {point.lon.toFixed(4)}</p>
                <p><strong>Radiación:</strong> {point.radiation.toFixed(2)}</p>
              </div>
            </Popup>
            <Tooltip direction="top" offset={[0, -5]} opacity={0.9}>
                <span>Radiación: {point.radiation.toFixed(2)}</span>
            </Tooltip>
          </CircleMarker>
        ))}
      </MapContainer>
      <Legend min={radiationDomain[0]} max={radiationDomain[1]} colorScale={colorScale} />
    </div>
  );
};
