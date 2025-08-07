
import { GoogleGenAI, Type } from "@google/genai";
import type { ExerciseContent } from '../types';

/*
 * =========================================================================
 *  NOTA DE SEGURIDAD
 * =========================================================================
 *  La clave API se maneja a través de `process.env.API_KEY`. En un
 *  entorno de producción, esta clave nunca debe exponerse del lado del
 *  cliente. Para una implementación segura, se debe usar un servidor proxy.
 * =========================================================================
 */
if (!process.env.API_KEY) {
    throw new Error("La variable de entorno API_KEY no está configurada.");
}

const ai = new GoogleGenAI({ apiKey: process.env.API_KEY });
const textModel = "gemini-2.5-flash";

export async function generarContenidoEducativo(topic: string): Promise<{ html: string }> {
    const textPrompt = `Genera una página educativa completa sobre "${topic}" en español, dirigida a estudiantes de secundaria.
    Formato: Usa Markdown.
    Estructura:
    1.  **Título Principal**: Usa un H1 (#).
    2.  **Introducción**: Un párrafo (100-150 palabras) que explique qué es y por qué es importante.
    3.  **Conceptos Clave**: Usa un H2 (##) y luego una lista de viñetas (* o -) para explicar las ideas principales de forma clara.
    4.  **Elemento Interactivo (Idea)**: Usa un H2 (##) y describe brevemente una idea para un elemento interactivo, como una mini-calculadora o un quiz conceptual. Solo describe la idea.
    5.  **Fórmulas Importantes**: Usa un H2 (##) y muestra las fórmulas clave en bloques de código de Markdown.
    
    Asegúrate de que el contenido sea preciso, pedagógico y fácil de entender.`;

    const textResponse = await ai.models.generateContent({ model: textModel, contents: textPrompt });

    const html = textResponse.text;
    
    return { html };
}

export async function generarEjercicioTrigonometria(topic: string): Promise<ExerciseContent> {
     const exercisePrompt = `Crea un ejercicio de opción múltiple sobre "${topic}" en español. La pregunta debe ser relevante y de nivel de secundaria. Proporciona 4 opciones de respuesta (una correcta y tres incorrectas plausibles). Indica el índice de la respuesta correcta y una explicación clara y concisa de la solución.
    
    Ejemplo de tema: 'Ley de Senos'.
    
    Tu respuesta DEBE ser un objeto JSON válido con la siguiente estructura:
    {
      "question": "El texto de la pregunta...",
      "options": [
        { "text": "Opción A" },
        { "text": "Opción B" },
        { "text": "Opción C" },
        { "text": "Opción D" }
      ],
      "correctAnswerIndex": 2, // Índice de la respuesta correcta (0-3)
      "explanation": "Una explicación detallada de por qué esa es la respuesta correcta."
    }`;

    const exerciseResponse = await ai.models.generateContent({
        model: textModel,
        contents: exercisePrompt,
        config: { responseMimeType: "application/json" }
    });
    
    const exerciseData = JSON.parse(exerciseResponse.text);

    return exerciseData;
}