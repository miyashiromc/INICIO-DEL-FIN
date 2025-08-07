import React, { useState, useEffect, useCallback } from 'react';
import type { ExerciseContent, PracticeResults } from '../types';
import * as geminiService from '../services/geminiService';
import { LoadingSpinner } from './LoadingSpinner';
import MarkdownRenderer from './MarkdownRenderer';

const PRACTICE_SESSION_LENGTH = 5;

interface PracticeViewProps {
    topic: string;
    onComplete: (results: PracticeResults) => void;
    onBack: () => void;
}

export default function PracticeView({ topic, onComplete, onBack }: PracticeViewProps) {
    const [questions, setQuestions] = useState<ExerciseContent[]>([]);
    const [currentQuestionIndex, setCurrentQuestionIndex] = useState(0);
    const [selectedOption, setSelectedOption] = useState<number | null>(null);
    const [isAnswered, setIsAnswered] = useState(false);
    const [results, setResults] = useState<PracticeResults>({ correct: 0, incorrect: 0 });
    const [isLoading, setIsLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);

    const fetchQuestions = useCallback(async () => {
        setIsLoading(true);
        setError(null);
        setQuestions([]);
        try {
            const questionPromises = Array.from({ length: PRACTICE_SESSION_LENGTH }, () => geminiService.generarEjercicioTrigonometria(topic));
            const fetchedQuestions = await Promise.all(questionPromises);
            setQuestions(fetchedQuestions);
        } catch (err) {
            console.error(err);
            setError("No se pudieron cargar las preguntas de práctica. Inténtalo de nuevo.");
        } finally {
            setIsLoading(false);
        }
    }, [topic]);

    useEffect(() => {
        fetchQuestions();
    }, [fetchQuestions]);

    const handleSelectOption = (index: number) => {
        if (isAnswered) return;
        
        const isCorrect = index === questions[currentQuestionIndex].correctAnswerIndex;
        setSelectedOption(index);
        setIsAnswered(true);
        setResults(prev => ({
            ...prev,
            correct: isCorrect ? prev.correct + 1 : prev.correct,
            incorrect: !isCorrect ? prev.incorrect + 1 : prev.incorrect,
        }));
    };

    const handleNext = () => {
        if (currentQuestionIndex < questions.length - 1) {
            setCurrentQuestionIndex(prev => prev + 1);
            setSelectedOption(null);
            setIsAnswered(false);
        } else {
            onComplete(results);
        }
    };

    const getButtonClass = (index: number) => {
        if (!isAnswered) {
            return "bg-base-100 dark:bg-dark-base-200 hover:bg-base-200 dark:hover:bg-dark-base-300";
        }
        if (index === questions[currentQuestionIndex]?.correctAnswerIndex) {
            return "bg-green-200 dark:bg-green-800 border-green-500 ring-2 ring-green-500";
        }
        if (index === selectedOption) {
            return "bg-red-200 dark:bg-red-800 border-red-500 ring-2 ring-red-500";
        }
        return "bg-base-100 dark:bg-dark-base-200 opacity-60";
    };

    if (isLoading) {
        return <div className="flex flex-col items-center justify-center h-full p-8 text-center"><LoadingSpinner /><p className="mt-4">Generando sesión de práctica para "{topic}"...</p></div>;
    }

    if (error) {
        return (
            <div className="p-8 text-center text-red-500">
                <p>{error}</p>
                <button onClick={onBack} className="mt-4 bg-brand-primary text-white py-2 px-4 rounded">Volver</button>
            </div>
        );
    }
    
    const currentExercise = questions[currentQuestionIndex];
    if (!currentExercise) {
        return <div className="p-8 text-center">No hay preguntas disponibles.</div>
    }

    return (
        <div className="p-4 md:p-8 max-w-4xl mx-auto w-full animate-fadeIn">
            <div className="w-full flex justify-between items-center mb-4">
                <h1 className="text-xl font-bold">{topic}</h1>
                <div className="text-lg font-semibold bg-base-100 dark:bg-dark-base-200 px-4 py-2 rounded-lg shadow-sm">
                    Pregunta {currentQuestionIndex + 1} / {questions.length}
                </div>
            </div>
            
            <div className="bg-base-100/80 dark:bg-dark-base-200/80 backdrop-blur-sm rounded-2xl shadow-xl p-6 relative">
                 <h2 className="text-xl font-semibold mb-4">{currentExercise.question}</h2>

                 <div className="grid grid-cols-1 md:grid-cols-2 gap-4 my-6">
                    {currentExercise.options.map((option, index) => (
                        <button key={index} onClick={() => handleSelectOption(index)} disabled={isAnswered} className={`p-4 rounded-lg border-2 text-left transition-all duration-300 ${getButtonClass(index)}`}>
                            <span className="font-bold mr-2">{String.fromCharCode(65 + index)}.</span>
                            {option.text}
                        </button>
                    ))}
                </div>

                {isAnswered && (
                    <div className="animate-fadeIn">
                        <div className="mt-6 p-4 bg-base-200 dark:bg-dark-base-300 rounded-lg">
                            <h3 className="font-bold text-lg mb-2">Explicación:</h3>
                            <MarkdownRenderer content={currentExercise.explanation} />
                        </div>
                         <div className="mt-6 text-center">
                            <button onClick={handleNext} className="bg-brand-primary text-white font-bold py-3 px-8 rounded-lg shadow-lg hover:bg-brand-secondary transition-transform transform hover:scale-105">
                                {currentQuestionIndex < questions.length - 1 ? "Siguiente Pregunta" : "Ver Resultados"}
                            </button>
                        </div>
                    </div>
                )}
            </div>
        </div>
    );
}