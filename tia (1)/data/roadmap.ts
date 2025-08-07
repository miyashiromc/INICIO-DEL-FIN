import type { RoadmapSection } from '../types';

export const roadmapData: RoadmapSection[] = [
    {
        title: "Principiante",
        nodes: [
            { id: "c1", type: "concept", title: "Introducción a Triángulos Rectángulos", topic: "Triángulos Rectángulos" },
            { id: "p1", type: "practice", title: "Práctica: Teorema de Pitágoras", topic: "Teorema de Pitágoras", requires: ["c1"], requiredScore: 60 },
            { id: "c2", type: "concept", title: "SOHCAHTOA", topic: "SOHCAHTOA (Seno, Coseno, Tangente)", requires: ["p1"] },
            { id: "p2", type: "practice", title: "Práctica: Encontrar Lados Faltantes", topic: "Encontrar Lados Faltantes usando SOHCAHTOA", requires: ["c2"], requiredScore: 60 },
        ]
    },
    {
        title: "Intermedio",
        nodes: [
            { id: "c3", type: "concept", title: "Funciones Trigonométricas Inversas", topic: "Funciones Trigonométricas Inversas", requires: ["p2"] },
            { id: "p3", type: "practice", title: "Práctica: Encontrar Ángulos Faltantes", topic: "Encontrar Ángulos Faltantes usando funciones inversas", requires: ["c3"], requiredScore: 80 },
            { id: "c4", type: "concept", title: "Introducción al Círculo Unitario", topic: "El Círculo Unitario", requires: ["p3"] },
            { id: "p4", type: "practice", title: "Práctica: Círculo Unitario", topic: "Coordenadas en el Círculo Unitario", requires: ["c4"], requiredScore: 80 },
            { id: "g1", type: "game", title: "Juego: Disparador de Ángulos", topic: "Juego de Ángulos", requires: ["p4"], requiredScore: 5000 },
        ]
    },
    {
        title: "Avanzado",
        nodes: [
            { id: "c5", type: "concept", title: "Leyes de Senos y Cosenos", topic: "Leyes de Senos y Cosenos", requires: ["g1"] },
            { id: "p5", type: "practice", title: "Práctica: Aplicando Leyes", topic: "Problemas con Ley de Senos y Cosenos", requires: ["c5"], requiredScore: 80 },
            { id: "pg1", type: "playground", title: "Laboratorio de Trigonometría", topic: "Laboratorio Interactivo del Círculo Unitario", requires: ["p5"]},
            { id: "g2", type: "game", title: "Juego: Disparador de Ángulos Avanzado", topic: "Juego de Ángulos Avanzado", requires: ["pg1"], requiredScore: 10000 },
        ]
    }
];