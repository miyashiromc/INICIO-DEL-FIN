
import React, { useState, useEffect, useCallback } from 'react';
import type { GeneratedContent } from '../types';
import MarkdownRenderer from './MarkdownRenderer';
import { VolumeUpIcon } from './icons/VolumeUpIcon';
import { StopCircleIcon } from './icons/StopCircleIcon';

interface ContentViewProps {
    content: GeneratedContent;
}

export default function ContentView({ content }: ContentViewProps): React.ReactNode {
    const [isSpeaking, setIsSpeaking] = useState(false);
    const contentRef = React.useRef<HTMLDivElement>(null);

    // Detener la lectura al desmontar el componente o si el contenido cambia
    useEffect(() => {
        return () => {
            window.speechSynthesis.cancel();
            setIsSpeaking(false);
        };
    }, [content]);

    const handleSpeak = useCallback(() => {
        if (isSpeaking) {
            window.speechSynthesis.cancel();
            setIsSpeaking(false);
            return;
        }

        if (contentRef.current) {
            const textToSpeak = contentRef.current.innerText;
            const utterance = new SpeechSynthesisUtterance(textToSpeak);
            utterance.lang = 'es-ES';
            utterance.onstart = () => setIsSpeaking(true);
            utterance.onend = () => setIsSpeaking(false);
            utterance.onerror = () => setIsSpeaking(false);
            window.speechSynthesis.speak(utterance);
        }
    }, [isSpeaking, content]);

    return (
        <div className="p-4 md:p-8 max-w-5xl mx-auto w-full">
            <div className="bg-base-100 dark:bg-dark-base-200 rounded-2xl shadow-xl overflow-hidden">
                <div className="p-6 md:p-8 relative">
                     <button
                        onClick={handleSpeak}
                        className="absolute top-6 right-6 bg-brand-secondary text-white p-3 rounded-full hover:bg-brand-primary transition-colors"
                        aria-label={isSpeaking ? "Detener lectura" : "Leer contenido en voz alta"}
                    >
                        {isSpeaking ? <StopCircleIcon /> : <VolumeUpIcon />}
                    </button>
                    <div ref={contentRef}>
                        <MarkdownRenderer content={content.html} />
                    </div>
                </div>
            </div>
        </div>
    );
}