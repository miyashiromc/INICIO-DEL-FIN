import React from 'react';
import type { ChatMessage } from '../types';
import { SendIcon } from './icons/SendIcon';
import { BotIcon } from './icons/BotIcon';
import { UserIcon } from './icons/UserIcon';
import { LoadingSpinner } from './LoadingSpinner';
import MarkdownRenderer from './MarkdownRenderer';

interface ChatViewProps {
  history: ChatMessage[];
  setHistory: React.Dispatch<React.SetStateAction<ChatMessage[]>>;
  onTopicSubmit: (topic: string) => void;
  isLoading: boolean;
  error: string | null;
  setError: (error: string | null) => void;
}

export default function ChatView({ history, setHistory, onTopicSubmit, isLoading, error, setError }: ChatViewProps): React.ReactNode {
  const inputRef = React.useRef<HTMLInputElement>(null);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    const topic = inputRef.current?.value;
    if (topic && !isLoading) {
      setHistory(prev => [...prev, { role: 'user', text: topic }]);
      onTopicSubmit(topic);
      if (inputRef.current) {
        inputRef.current.value = '';
      }
    }
  };

  return (
    <div className="flex flex-col h-full max-w-4xl mx-auto p-4">
      <div className="flex-1 overflow-y-auto pr-4">
        {history.length === 0 && (
            <div className="flex flex-col items-center justify-center h-full text-center text-gray-500 dark:text-gray-400">
                <div className="bg-base-100 dark:bg-dark-base-200 p-8 rounded-2xl shadow-lg">
                    <h1 className="text-3xl font-bold text-base-content dark:text-dark-base-content">Bienvenido a <span className="text-brand-primary">TrigTutor IA</span></h1>
                    <p className="mt-2">Escribe un tema de trigonometría en el cuadro de abajo para empezar a aprender.</p>
                </div>
            </div>
        )}
        {history.map((msg, index) => (
          <div key={index} className={`flex items-start gap-4 my-6 ${msg.role === 'user' ? 'justify-end' : ''}`}>
            {msg.role === 'model' && <div className="flex-shrink-0 w-10 h-10 rounded-full bg-brand-secondary text-white flex items-center justify-center"><BotIcon /></div>}
            <div className={`max-w-xl p-4 rounded-2xl shadow ${msg.role === 'user' ? 'bg-brand-primary text-white' : 'bg-base-100 dark:bg-dark-base-200'}`}>
              <MarkdownRenderer content={msg.text} />
            </div>
            {msg.role === 'user' && <div className="flex-shrink-0 w-10 h-10 rounded-full bg-base-300 dark:bg-dark-base-300 text-base-content dark:text-dark-base-content flex items-center justify-center"><UserIcon /></div>}
          </div>
        ))}
        {isLoading && (
             <div className="flex items-start gap-4 my-6">
                <div className="flex-shrink-0 w-10 h-10 rounded-full bg-brand-secondary text-white flex items-center justify-center"><BotIcon /></div>
                <div className="max-w-xl p-4 rounded-2xl shadow bg-base-100 dark:bg-dark-base-200">
                   <LoadingSpinner />
                </div>
            </div>
        )}
      </div>
      <div className="mt-4">
         {error && <div className="bg-red-100 border border-red-400 text-red-700 px-4 py-3 rounded-lg relative mb-4" role="alert">
            <span className="block sm:inline">{error}</span>
            <span className="absolute top-0 bottom-0 right-0 px-4 py-3" onClick={() => setError(null)}>
                <svg className="fill-current h-6 w-6 text-red-500" role="button" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 20 20"><title>Cerrar</title><path d="M14.348 14.849a1.2 1.2 0 0 1-1.697 0L10 11.819l-2.651 3.029a1.2 1.2 0 1 1-1.697-1.697l2.758-3.15-2.759-3.152a1.2 1.2 0 1 1 1.697-1.697L10 8.183l2.651-3.031a1.2 1.2 0 1 1 1.697 1.697l-2.758 3.152 2.758 3.15a1.2 1.2 0 0 1 0 1.698z"/></svg>
            </span>
        </div>}
        <form onSubmit={handleSubmit} className="flex items-center gap-2 p-2 bg-base-100 dark:bg-dark-base-200 rounded-xl shadow-lg">
          <input
            ref={inputRef}
            type="text"
            placeholder="Escribe un tema de trigonometría (ej. 'Ley de Cosenos')"
            className="w-full p-4 bg-transparent focus:outline-none text-base-content dark:text-dark-base-content"
            disabled={isLoading}
          />
          <button type="submit" className="bg-brand-primary p-3 rounded-lg text-white disabled:bg-gray-400" disabled={isLoading}>
            <SendIcon />
          </button>
        </form>
      </div>
    </div>
  );
}
