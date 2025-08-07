import React from 'react';
import { PracticeResults } from '../types';

const ProgressCircle = ({ percentage }: { percentage: number }) => {
    const radius = 60;
    const circumference = 2 * Math.PI * radius;
    const strokeDashoffset = circumference - (percentage / 100) * circumference;

    return (
        <div className="relative w-48 h-48">
            <svg className="w-full h-full" viewBox="0 0 140 140">
                <circle
                    stroke="#e5e7eb"
                    className="dark:stroke-gray-600"
                    cx="70"
                    cy="70"
                    r={radius}
                    strokeWidth="15"
                    fill="transparent"
                />
                {percentage > 0 && (
                     <circle
                        className="text-green-500 transition-all duration-1000 ease-out"
                        stroke="currentColor"
                        cx="70"
                        cy="70"
                        r={radius}
                        strokeWidth="15"
                        fill="transparent"
                        strokeDasharray={circumference}
                        strokeDashoffset={strokeDashoffset}
                        transform="rotate(-90 70 70)"
                        style={{ transition: 'stroke-dashoffset 1s ease-out' }}
                    />
                )}
            </svg>
            <div className="absolute inset-0 flex flex-col items-center justify-center">
                <span className="text-3xl font-bold text-green-500">{percentage.toFixed(0)}%</span>
                <span className="text-sm text-base-content dark:text-dark-base-content">Correctas</span>
            </div>
        </div>
    );
};

interface ResultsViewProps {
    topic: string;
    results: PracticeResults;
    onBack: () => void;
    onRetry: () => void;
}

export default function ResultsView({ topic, results, onBack, onRetry }: ResultsViewProps) {
    const { correct, incorrect } = results;
    const isGame = incorrect === 0 && correct > 100; // Heuristic for game score
    const total = correct + incorrect;
    const percentage = !isGame && total > 0 ? (correct / total) * 100 : 0;
    
    let feedbackMessage = '';
    let title = "Resultados de Práctica";

    if (isGame) {
        title = "Puntuación Final del Juego";
        if (correct >= 10000) {
            feedbackMessage = "¡Puntuación increíble! Eres un verdadero profesional.";
        } else if (correct >= 5000) {
            feedbackMessage = "¡Gran puntuación! Sigue así.";
        } else {
            feedbackMessage = "¡Buen juego! La práctica te hará imbatible.";
        }
    } else {
        if (percentage === 100) {
            feedbackMessage = "¡Excelente trabajo! ¡Dominas este tema!";
        } else if (percentage >= 80) {
            feedbackMessage = "¡Muy bien hecho! Estás muy cerca de la perfección.";
        } else if (percentage >= 60) {
            feedbackMessage = "¡Buen intento! Sigue practicando para fortalecer tus habilidades.";
        } else {
            feedbackMessage = "¡No te rindas! La práctica hace al maestro.";
        }
    }


    return (
        <div className="w-full max-w-2xl mx-auto p-4 md:p-8 flex flex-col items-center animate-fadeIn">
            <div className="w-full bg-base-100/80 dark:bg-dark-base-200/80 backdrop-blur-sm p-8 rounded-2xl shadow-lg text-center">
                <h2 className="text-3xl font-bold text-base-content dark:text-dark-base-content mb-2">{title}</h2>
                <p className="text-xl text-brand-primary font-semibold mb-6">{topic}</p>
                
                <div className="flex justify-center my-8">
                    { isGame ? 
                        <div className="text-5xl font-bold text-green-500">{correct.toLocaleString()} pts</div> 
                        : <ProgressCircle percentage={percentage} /> 
                    }
                </div>

                <p className="text-lg text-gray-600 dark:text-gray-400 mb-6">{feedbackMessage}</p>

                { !isGame && (
                    <div className="flex justify-center gap-8 text-xl mb-8">
                        <div className="text-center">
                            <p className="font-bold text-green-500 text-3xl">{correct}</p>
                            <p className="text-sm">Correctas</p>
                        </div>
                        <div className="text-center">
                            <p className="font-bold text-red-500 text-3xl">{incorrect}</p>
                            <p className="text-sm">Incorrectas</p>
                        </div>
                        <div className="text-center">
                            <p className="font-bold text-gray-700 dark:text-gray-300 text-3xl">{total}</p>
                            <p className="text-sm">Total</p>
                        </div>
                    </div>
                )}

                <div className="flex flex-col sm:flex-row justify-center gap-4 mt-4">
                    <button onClick={onRetry} className="w-full sm:w-auto bg-brand-primary text-white py-3 px-6 rounded-lg font-semibold hover:bg-brand-secondary transition-colors duration-200">
                        {isGame ? 'Jugar de Nuevo' : 'Practicar de Nuevo'}
                    </button>
                    <button onClick={onBack} className="w-full sm:w-auto bg-base-200 dark:bg-dark-base-300 text-base-content dark:text-dark-base-content py-3 px-6 rounded-lg font-semibold hover:bg-base-300 dark:hover:bg-dark-base-100 transition-colors duration-200">
                        Volver a la Ruta
                    </button>
                </div>
            </div>
        </div>
    );
}