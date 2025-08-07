
import React, { useState, useCallback, useEffect } from 'react';
import Sidebar from './components/Sidebar';
import ChatView from './components/ChatView';
import ContentView from './components/ContentView';
import ExercisesView from './components/ExercisesView';
import ResourcesView from './components/ResourcesView';
import * as geminiService from './services/geminiService';
import type { View, ChatMessage, GeneratedContent, ExerciseContent } from './types';
import { LoadingSpinner } from './components/LoadingSpinner';

export default function App(): React.ReactNode {
  const [activeView, setActiveView] = useState<View>('exercises');
  const [history, setHistory] = useState<ChatMessage[]>([]);
  const [generatedContent, setGeneratedContent] = useState<GeneratedContent | null>(null);
  const [generatedExercise, setGeneratedExercise] = useState<ExerciseContent | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [currentExerciseTopic, setCurrentExerciseTopic] = useState("Seno, Coseno y Tangente");

  const handleTopicSubmit = useCallback(async (topic: string) => {
    setIsLoading(true);
    setError(null);
    setGeneratedContent(null);
    setActiveView('content');
    setHistory(prev => [...prev, { role: 'model', text: '', isLoading: true }]);

    try {
      const content = await geminiService.generarContenidoEducativo(topic);
      setGeneratedContent(content);
      setHistory(prev => {
        const newHistory = [...prev];
        const lastMessage = newHistory[newHistory.length - 1];
        if (lastMessage && lastMessage.role === 'model') {
          lastMessage.text = `Aquí tienes una explicación sobre **${topic}**.`;
          lastMessage.isLoading = false;
        }
        return newHistory;
      });

    } catch (err: any) {
      console.error(err);
      const errorMessage = err.message || "Ha ocurrido un error al generar el contenido. Por favor, inténtalo de nuevo.";
      setError(errorMessage);
       setHistory(prev => {
        return prev.slice(0, -2); // Remove user message and bot loading message
      });
      setActiveView('chat');
    } finally {
      setIsLoading(false);
    }
  }, []);
  
  const handleNewExercise = useCallback(async (topic: string) => {
    setIsLoading(true);
    setError(null);
    setGeneratedExercise(null);
    setCurrentExerciseTopic(topic);

    try {
        const exercise = await geminiService.generarEjercicioTrigonometria(topic);
        setGeneratedExercise(exercise);
    } catch (err) {
        console.error(err);
        setError("No se pudo generar un nuevo ejercicio. Por favor, inténtalo de nuevo.");
    } finally {
        setIsLoading(false);
    }
  }, []);
  
  // Pre-load an initial exercise when the app starts
  useEffect(() => {
    if (activeView === 'exercises' && !generatedExercise) {
      handleNewExercise(currentExerciseTopic);
    }
  }, [activeView, generatedExercise, handleNewExercise, currentExerciseTopic]);


  const renderView = () => {
    let viewContent;

    switch (activeView) {
      case 'chat':
        viewContent = <ChatView history={history} setHistory={setHistory} onTopicSubmit={handleTopicSubmit} isLoading={isLoading} error={error} setError={setError} />;
        break;
      case 'content':
        if (isLoading && !generatedContent) {
           viewContent = <div className="flex flex-col justify-center items-center h-full"><LoadingSpinner /><p className="mt-4">Generando contenido...</p></div>;
        } else if (generatedContent) {
           viewContent = <ContentView content={generatedContent} />;
        } else {
            viewContent = <div className="flex justify-center items-center h-full"><p className="text-center text-gray-500 p-8">Usa el chat para buscar un tema y ver el contenido aquí.</p></div>;
        }
        break;
      case 'exercises':
        if (isLoading && !generatedExercise) {
             viewContent = <div className="flex flex-col justify-center items-center h-full"><LoadingSpinner /><p className="mt-4">Generando ejercicio sobre "{currentExerciseTopic}"...</p></div>;
        } else {
             viewContent = <ExercisesView topic={currentExerciseTopic} initialExercise={generatedExercise} onNewExercise={handleNewExercise} />;
        }
        break;
      case 'resources':
        viewContent = <ResourcesView />;
        break;
      default:
        viewContent = <ChatView history={history} setHistory={setHistory} onTopicSubmit={handleTopicSubmit} isLoading={isLoading} error={error} setError={setError} />;
        break;
    }
     return viewContent;
  };

  return (
    <div className="flex h-screen bg-base-200 dark:bg-dark-base-100 text-base-content dark:text-dark-base-content">
      <Sidebar currentView={activeView} setView={setActiveView} />
      <main className="flex-1 overflow-y-auto">
        {renderView()}
      </main>
    </div>
  );
}