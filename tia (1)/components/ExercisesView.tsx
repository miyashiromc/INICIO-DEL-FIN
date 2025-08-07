
import React, { useState, useEffect, useCallback } from 'react';
import type { ExerciseContent } from '../types';
import { LoadingSpinner } from './LoadingSpinner';
import { VolumeUpIcon } from './icons/VolumeUpIcon';
import { StopCircleIcon } from './icons/StopCircleIcon';
import MarkdownRenderer from './MarkdownRenderer';

const exerciseTopics = [
    "Seno, Coseno y Tangente", "Teorema de Pitágoras", "Círculo Unitario",
    "Identidades Trigonométricas", "Leyes de Senos y Cosenos", "Radianes"
];

interface ExercisesViewProps {
    topic: string;
    initialExercise: ExerciseContent | null;
    onNewExercise: (topic: string) => void;
}

export default function ExercisesView({ topic: initialTopic, initialExercise, onNewExercise }: ExercisesViewProps): React.ReactNode {
    const [currentExercise, setCurrentExercise] = useState<ExerciseContent | null>(null);
    const [selectedOption, setSelectedOption] = useState<number | null>(null);
    const [isAnswered, setIsAnswered] = useState(false);
    const [isSpeaking, setIsSpeaking] = useState(false);
    const [currentTopic, setCurrentTopic] = useState(initialTopic);

    useEffect(() => {
        setCurrentExercise(initialExercise);
        setSelectedOption(null);
        setIsAnswered(false);
    }, [initialExercise]);

    const speakText = useCallback((text: string) => {
        window.speechSynthesis.cancel();
        const utterance = new SpeechSynthesisUtterance(text);
        utterance.lang = 'es-ES';
        utterance.onstart = () => setIsSpeaking(true);
        utterance.onend = () => setIsSpeaking(false);
        utterance.onerror = () => setIsSpeaking(false);
        window.speechSynthesis.speak(utterance);
    }, []);

    const handleSpeak = useCallback(() => {
        if (isSpeaking) {
            window.speechSynthesis.cancel();
            setIsSpeaking(false);
            return;
        }
        if (currentExercise) {
            const textToSpeak = `Pregunta: ${currentExercise.question}. Opciones: ${currentExercise.options.map((o, i) => `Opción ${String.fromCharCode(65 + i)}: ${o.text}`).join('. ')}. ${isAnswered ? `Explicación: ${currentExercise.explanation}` : ''}`;
            speakText(textToSpeak);
        }
    }, [isSpeaking, currentExercise, isAnswered, speakText]);

    useEffect(() => {
        return () => {
            window.speechSynthesis.cancel();
        }
    }, []);

    const handleSelectOption = (index: number) => {
        if (isAnswered) return;
        setSelectedOption(index);
        setIsAnswered(true);
    };

    const handleNewExercise = (newTopic: string) => {
        setCurrentTopic(newTopic);
        onNewExercise(newTopic);
    };

    const getButtonClass = (index: number) => {
        if (!isAnswered) {
            return "bg-base-100 dark:bg-dark-base-200 hover:bg-base-300 dark:hover:bg-dark-base-300";
        }
        if (index === currentExercise?.correctAnswerIndex) {
            return "bg-green-200 dark:bg-green-800 border-green-500";
        }
        if (index === selectedOption) {
            return "bg-red-200 dark:bg-red-800 border-red-500";
        }
        return "bg-base-100 dark:bg-dark-base-200 opacity-60";
    };

    return (
        <div className="p-4 md:p-8 max-w-4xl mx-auto">
            <h1 className="text-3xl font-bold mb-2 text-center">Ejercicios de Práctica</h1>
            <p className="text-center text-gray-500 dark:text-gray-400 mb-6">Selecciona un tema para generar un nuevo ejercicio.</p>

            <div className="flex flex-wrap justify-center gap-2 mb-8">
                {exerciseTopics.map(t => (
                    <button key={t} onClick={() => handleNewExercise(t)} className={`py-2 px-4 rounded-lg text-sm font-semibold transition-colors ${currentTopic === t ? 'bg-brand-primary text-white' : 'bg-base-100 dark:bg-dark-base-200 hover:bg-base-300 dark:hover:bg-dark-base-300'}`}>
                        {t}
                    </button>
                ))}
            </div>

            {currentExercise ? (
                <div className="bg-base-100 dark:bg-dark-base-200 rounded-2xl shadow-xl p-6 relative animate-fadeIn">
                    <button
                        onClick={handleSpeak}
                        className="absolute top-4 right-4 bg-brand-secondary text-white p-3 rounded-full hover:bg-brand-primary transition-colors"
                        aria-label={isSpeaking ? "Detener lectura" : "Leer ejercicio en voz alta"}
                    >
                        {isSpeaking ? <StopCircleIcon /> : <VolumeUpIcon />}
                    </button>

                    <h2 className="text-xl font-semibold mb-4 pr-12">{currentExercise.question}</h2>

                    <div className="grid grid-cols-1 md:grid-cols-2 gap-4 my-6">
                        {currentExercise.options.map((option, index) => (
                            <button key={index} onClick={() => handleSelectOption(index)} disabled={isAnswered} className={`p-4 rounded-lg border-2 text-left transition-all duration-300 ${getButtonClass(index)}`}>
                                <span className="font-bold mr-2">{String.fromCharCode(65 + index)}.</span>
                                {option.text}
                            </button>
                        ))}
                    </div>

                    {isAnswered && (
                        <div className="mt-6 p-4 bg-base-200 dark:bg-dark-base-300 rounded-lg animate-fadeIn">
                            <h3 className="font-bold text-lg mb-2">Explicación:</h3>
                            <MarkdownRenderer content={currentExercise.explanation} />
                        </div>
                    )}
                </div>
            ) : (
                <div className="text-center p-8 bg-base-100 dark:bg-dark-base-200 rounded-lg shadow-md">
                     <p className="text-lg text-gray-600 dark:text-gray-400">Selecciona un tema para comenzar a practicar.</p>
                </div>
            )}
        </div>
    );
}