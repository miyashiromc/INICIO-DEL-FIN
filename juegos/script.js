const pizarra = document.getElementById('pizarra');
const contexto = pizarra.getContext('2d');

// --- ESTADO DE LA APLICACIÓN ---
let dibujando = false;
let arrastrandoLienzo = false;
let arrastrandoObjeto = false;
let spacePressed = false;

// --- HISTORIAL Y SELECCIÓN ---
let historial = [];
let indiceHistorial = -1;
let trazoActual = null;
let seleccionActual = null;

// --- TRANSFORMACIÓN DEL LIENZO ---
let transformacion = new DOMMatrix();
let ultimoPunto = { x: 0, y: 0 };

// --- OBTENER ELEMENTOS DE LA INTERFAZ ---
const colorInput = document.getElementById('color');
const grosorInput = document.getElementById('grosor');
const formaInput = document.getElementById('forma');
const lapizBoton = document.getElementById('lapiz');
const borradorBoton = document.getElementById('borrador');
const limpiarBoton = document.getElementById('limpiar');
const guardarBoton = document.getElementById('guardar');

// ====================================================================
//  NÚCLEO DE RENDERIZADO
// ====================================================================

function draw() {
    contexto.save();
    contexto.setTransform(1, 0, 0, 1, 0, 0);
    contexto.clearRect(0, 0, pizarra.width, pizarra.height);
    contexto.setTransform(transformacion);

    dibujarCuadricula();

    const historialVisible = historial.slice(0, indiceHistorial + 1);
    historialVisible.forEach(dibujarTrazo);

    if (trazoActual) dibujarTrazo(trazoActual);
    if (seleccionActual) dibujarBoundingBox(seleccionActual);

    contexto.restore();
}

function dibujarTrazo(trazo) {
    if (!trazo || trazo.puntos.length === 0) return;
    contexto.beginPath();
    contexto.strokeStyle = trazo.color;
    contexto.lineWidth = trazo.grosor;
    contexto.lineCap = trazo.forma;
    contexto.globalCompositeOperation = trazo.borrando ? 'destination-out' : 'source-over';
    contexto.moveTo(trazo.puntos[0].x, trazo.puntos[0].y);
    for (let i = 1; i < trazo.puntos.length; i++) {
        contexto.lineTo(trazo.puntos[i].x, trazo.puntos[i].y);
    }
    contexto.stroke();
}

function dibujarBoundingBox(trazo) {
    const bbox = calcularBoundingBox(trazo);
    contexto.save();
    contexto.strokeStyle = '#3498db';
    contexto.lineWidth = 2 / transformacion.a;
    contexto.globalCompositeOperation = 'source-over';
    contexto.setLineDash([5 / transformacion.a, 5 / transformacion.a]);
    contexto.strokeRect(bbox.minX, bbox.minY, bbox.maxX - bbox.minX, bbox.maxY - bbox.minY);
    contexto.restore();
}

function dibujarCuadricula() {
    const gridSize = 20;
    contexto.beginPath();
    contexto.lineWidth = 1 / transformacion.a;
    contexto.strokeStyle = 'rgba(236, 240, 241, 0.08)';
    const left = -transformacion.e / transformacion.a;
    const right = left + pizarra.width / transformacion.a;
    const top = -transformacion.f / transformacion.d;
    const bottom = top + pizarra.height / transformacion.d;
    for (let x = Math.floor(left / gridSize) * gridSize; x < right; x += gridSize) {
        contexto.moveTo(x, top);
        contexto.lineTo(x, bottom);
    }
    for (let y = Math.floor(top / gridSize) * gridSize; y < bottom; y += gridSize) {
        contexto.moveTo(left, y);
        contexto.lineTo(right, y);
    }
    contexto.stroke();
}

// ====================================================================
//  MANEJO DE EVENTOS
// ====================================================================

function onMouseDown(e) {
    if (e.target.closest('.controles')) return;

    if (spacePressed) {
        arrastrandoLienzo = true;
        ultimoPunto = { x: e.clientX, y: e.clientY };
        pizarra.style.cursor = 'grabbing';
        return;
    }

    const punto = getTransformedPoint(e.clientX, e.clientY);

    if (e.button === 2) { // Clic Derecho: Seleccionar y Mover
        const trazoClicado = hitTest(punto);
        if (trazoClicado) {
            seleccionActual = trazoClicado;
            arrastrandoObjeto = true;
            ultimoPunto = punto;
            // Preparamos el historial para un nuevo estado
            const copiaDelHistorial = JSON.parse(JSON.stringify(historial.slice(0, indiceHistorial + 1)));
            historial.splice(indiceHistorial + 1);
            historial.push(...copiaDelHistorial);
            indiceHistorial = historial.length - 1;
        } else {
            seleccionActual = null;
        }
        draw();
        return;
    }

    // Clic Izquierdo: Dibujar
    seleccionActual = null;
    dibujando = true;
    historial.splice(indiceHistorial + 1);
    trazoActual = {
        puntos: [punto],
        color: colorInput.value,
        grosor: parseFloat(grosorInput.value),
        forma: formaInput.value,
        borrando: borradorBoton.classList.contains('activo')
    };
    draw();
}

function onMouseMove(e) {
    const punto = getTransformedPoint(e.clientX, e.clientY);

    if (arrastrandoLienzo) {
        const dx = e.clientX - ultimoPunto.x;
        const dy = e.clientY - ultimoPunto.y;
        transformacion.translateSelf(dx / transformacion.a, dy / transformacion.d);
        ultimoPunto = { x: e.clientX, y: e.clientY };
        draw();
        return;
    }

    if (arrastrandoObjeto && seleccionActual) {
        const dx = punto.x - ultimoPunto.x;
        const dy = punto.y - ultimoPunto.y;
        seleccionActual.puntos.forEach(p => {
            p.x += dx;
            p.y += dy;
        });
        ultimoPunto = punto;
        draw();
        return;
    }

    if (dibujando && trazoActual) {
        trazoActual.puntos.push(punto);
        draw();
    }
}

function onMouseUp() {
    if (arrastrandoLienzo) {
        arrastrandoLienzo = false;
        pizarra.style.cursor = spacePressed ? 'grab' : 'crosshair';
    }

    if (arrastrandoObjeto) {
        arrastrandoObjeto = false;
    }

    if (dibujando && trazoActual) {
        dibujando = false;
        if (trazoActual.puntos.length > 1) {
            historial.push(trazoActual);
            indiceHistorial++;
        }
        trazoActual = null;
    }
}

function onWheel(e) {
    e.preventDefault();
    const scaleAmount = 1.1;
    const punto = getTransformedPoint(e.clientX, e.clientY);
    const factor = e.deltaY < 0 ? scaleAmount : 1 / scaleAmount;

    if (e.ctrlKey) {
        transformacion.translateSelf(punto.x, punto.y);
        transformacion.scaleSelf(factor, factor);
        transformacion.translateSelf(-punto.x, -punto.y);
    } else if (e.shiftKey) {
        transformacion.translateSelf(-e.deltaY / transformacion.a, 0);
    } else {
        transformacion.translateSelf(0, -e.deltaY / transformacion.d);
    }
    draw();
}

function onKeyDown(e) {
    if (e.code === 'Space' && !spacePressed) {
        spacePressed = true;
        if (!arrastrandoLienzo) pizarra.style.cursor = 'grab';
    }
    if (e.ctrlKey && e.key === 'z') deshacer();
    if (e.ctrlKey && e.key === 'y') rehacer();
}

function onKeyUp(e) {
    if (e.code === 'Space') {
        spacePressed = false;
        if (!arrastrandoLienzo) pizarra.style.cursor = 'crosshair';
    }
}

// ====================================================================
//  LÓGICA DE SELECCIÓN Y FUNCIONES AUXILIARES
// ====================================================================

function hitTest(punto) {
    const historialVisible = historial.slice(0, indiceHistorial + 1).reverse();
    const tolerancia = 10 / transformacion.a;
    for (const trazo of historialVisible) {
        for (let i = 0; i < trazo.puntos.length - 1; i++) {
            if (distanciaPuntoSegmentoCuadrada(punto, trazo.puntos[i], trazo.puntos[i + 1]) < tolerancia * tolerancia) {
                return trazo;
            }
        }
    }
    return null;
}

function distanciaPuntoSegmentoCuadrada(p, a, b) {
    const l2 = (b.x - a.x) ** 2 + (b.y - a.y) ** 2;
    if (l2 === 0) return (p.x - a.x) ** 2 + (p.y - a.y) ** 2;
    let t = ((p.x - a.x) * (b.x - a.x) + (p.y - a.y) * (b.y - a.y)) / l2;
    t = Math.max(0, Math.min(1, t));
    const proyeccion = { x: a.x + t * (b.x - a.x), y: a.y + t * (b.y - a.y) };
    return (p.x - proyeccion.x) ** 2 + (p.y - proyeccion.y) ** 2;
}

function calcularBoundingBox(trazo) {
    let minX = Infinity, minY = Infinity, maxX = -Infinity, maxY = -Infinity;
    trazo.puntos.forEach(p => {
        minX = Math.min(minX, p.x);
        minY = Math.min(minY, p.y);
        maxX = Math.max(maxX, p.x);
        maxY = Math.max(maxY, p.y);
    });
    const padding = trazo.grosor / 2 + 5 / transformacion.a;
    return { minX: minX - padding, minY: minY - padding, maxX: maxX + padding, maxY: maxY + padding };
}

function getTransformedPoint(x, y) {
    return new DOMPoint(x, y).matrixTransform(transformacion.inverse());
}

function deshacer() {
    if (indiceHistorial >= 0) {
        indiceHistorial--;
        seleccionActual = null;
        draw();
    }
}

function rehacer() {
    if (indiceHistorial < historial.length - 1) {
        indiceHistorial++;
        seleccionActual = null;
        draw();
    }
}

function limpiarCanvas() {
    historial = [];
    indiceHistorial = -1;
    trazoActual = null;
    seleccionActual = null;
    draw();
}

function guardarImagen() {
    const tempCanvas = document.createElement('canvas');
    tempCanvas.width = pizarra.width;
    tempCanvas.height = pizarra.height;
    const tempCtx = tempCanvas.getContext('2d');
    tempCtx.drawImage(pizarra, 0, 0);
    guardarBoton.parentElement.href = tempCanvas.toDataURL('image/png');
}

function inicializar() {
    pizarra.width = window.innerWidth;
    pizarra.height = window.innerHeight;
    pizarra.style.cursor = 'crosshair';

    pizarra.addEventListener('mousedown', onMouseDown);
    pizarra.addEventListener('mousemove', onMouseMove);
    pizarra.addEventListener('mouseup', onMouseUp);
    pizarra.addEventListener('mouseleave', onMouseUp);
    pizarra.addEventListener('wheel', onWheel, { passive: false });
    pizarra.addEventListener('contextmenu', e => e.preventDefault());
    window.addEventListener('keydown', onKeyDown);
    window.addEventListener('keyup', onKeyUp);
    window.addEventListener('resize', () => {
        pizarra.width = window.innerWidth;
        pizarra.height = window.innerHeight;
        draw();
    });

    lapizBoton.addEventListener('click', () => {
        borradorBoton.classList.remove('activo');
        lapizBoton.classList.add('activo');
    });
    borradorBoton.addEventListener('click', () => {
        lapizBoton.classList.remove('activo');
        borradorBoton.classList.add('activo');
    });
    limpiarBoton.addEventListener('click', limpiarCanvas);
    guardarBoton.addEventListener('click', guardarImagen);

    lapizBoton.classList.add('activo');
    draw();
}

inicializar();