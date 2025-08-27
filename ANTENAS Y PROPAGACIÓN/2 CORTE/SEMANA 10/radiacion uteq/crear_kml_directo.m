function mapa_de_calor_limpio()
    archivo_csv_entrada = 'AAADATA.csv';
    archivo_kml_salida = 'mapa_de_calor_final.kml';
    factor_escala_puntos = 1.5; 
    
    try
        opts = detectImportOptions(archivo_csv_entrada);
        opts.VariableNames = {'LATITUD', 'LONGITUD', 'RADIACION'};
        data = readtable(archivo_csv_entrada, opts);
        lat = data.LATITUD;
        lon = data.LONGITUD;
        rad = data.RADIACION;
    catch ME
        error('No se pudo leer el archivo CSV. Asegúrate de que la carpeta actual de MATLAB sea la correcta.');
    end

    rad_norm = (rad - min(rad)) / (max(rad) - min(rad));
    cmap = jet(256);

    fid = fopen(archivo_kml_salida, 'w');
    if fid == -1, error('No se pudo crear el archivo KML.'); end

    fprintf(fid, '<?xml version="1.0" encoding="UTF-8"?>\n');
    fprintf(fid, '<kml xmlns="http://www.opengis.net/kml/2.2">\n<Document>\n');
    fprintf(fid, '<name>Mapa de Calor de Radiacion</name>\n');

    for i = 1:256
        color_rgb = floor(cmap(i, :) * 255);
        color_hex = ['cc', dec2hex(color_rgb(3), 2), dec2hex(color_rgb(2), 2), dec2hex(color_rgb(1), 2)]; 
        fprintf(fid, '<Style id="heatmapEstilo_%d">\n', i);
        fprintf(fid, '  <IconStyle>\n');
        fprintf(fid, '    <color>%s</color>\n', color_hex);
        fprintf(fid, '    <scale>%.1f</scale>\n', factor_escala_puntos);
        fprintf(fid, '    <Icon><href>http://maps.google.com/mapfiles/kml/shapes/placemark_circle.png</href></Icon>\n');
        fprintf(fid, '  </IconStyle>\n');
        fprintf(fid, '</Style>\n');
    end

    fprintf(fid, '<Folder><name>Mapa de Calor - Radiacion</name>\n');
    for i = 1:length(lat)
        color_idx = floor(rad_norm(i) * 255) + 1;
        fprintf(fid, '<Placemark>\n');
        fprintf(fid, '  <name>Radiacion: %.2f</name>\n', rad(i));
        fprintf(fid, '  <styleUrl>#heatmapEstilo_%d</styleUrl>\n', color_idx);
        fprintf(fid, '  <Point><coordinates>%.6f,%.6f,0</coordinates></Point>\n', lon(i), lat(i));
        fprintf(fid, '</Placemark>\n');
    end
    fprintf(fid, '</Folder>\n');

    fprintf(fid, '</Document>\n</kml>\n');
    fclose(fid);
    
    disp(['¡Éxito! Se ha generado el archivo "', archivo_kml_salida, '".']);
end