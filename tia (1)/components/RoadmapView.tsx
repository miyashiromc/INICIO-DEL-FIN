import React from 'react';
import type { RoadmapNode, UserProgress, NodeType } from '../types';
import { roadmapData } from '../data/roadmap';

const Icon = ({ children }: { children: React.ReactNode }) => (
    <svg xmlns="http://www.w3.org/2000/svg" className="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor" strokeWidth={2}>
        {children}
    </svg>
);

const ConceptIcon = () => <Icon><path strokeLinecap="round" strokeLinejoin="round" d="M12 6.253v13m0-13C10.832 5.477 9.246 5 7.5 5S4.168 5.477 3 6.253v13C4.168 18.477 5.754 18 7.5 18s3.332.477 4.5 1.253m0-13C13.168 5.477 14.754 5 16.5 5c1.747 0 3.332.477 4.5 1.253v13C19.832 18.477 18.246 18 16.5 18c-1.746 0-3.332.477-4.5 1.253" /></Icon>;
const PracticeIcon = () => <Icon><path strokeLinecap="round" strokeLinejoin="round" d="M15.232 5.232l3.536 3.536m-2.036-5.036a2.5 2.5 0 113.536 3.536L6.5 21.036H3v-3.536L16.732 3.732z" /></Icon>;
const GameIcon = () => <Icon><path strokeLinecap="round" strokeLinejoin="round" d="M11 4a2 2 0 114 0v1a1 1 0 001 1h3a1 1 0 011 1v3a1 1 0 01-1 1h-1a2 2 0 100 4h1a1 1 0 011 1v3a1 1 0 01-1 1h-3a1 1 0 01-1-1v-1a2 2 0 10-4 0v1a1 1 0 01-1 1H7a1 1 0 01-1-1v-3a1 1 0 00-1-1H4a2 2 0 110-4h1a1 1 0 001-1V7a1 1 0 011-1h3a1 1 0 001-1V4z" /></Icon>;
const PlaygroundIcon = () => <Icon><path strokeLinecap="round" strokeLinejoin="round" d="M15 15l-2 5L9 9l5-2 2 5z" /><path strokeLinecap="round" strokeLinejoin="round" d="M7 21a2 2 0 01-2-2V7a2 2 0 012-2h10a2 2 0 012 2v10a2 2 0 01-2 2H7z" /></Icon>;
const LockIcon = () => <Icon><path strokeLinecap="round" strokeLinejoin="round" d="M12 15v2m-6 4h12a2 2 0 002-2v-6a2 2 0 00-2-2H6a2 2 0 00-2 2v6a2 2 0 002 2zm10-10V7a4 4 0 00-8 0v4h8z" /></Icon>;
const CheckIcon = () => <Icon><path strokeLinecap="round" strokeLinejoin="round" d="M9 12l2 2 4-4m6 2a9 9 0 11-18 0 9 9 0 0118 0z" /></Icon>;


const NodeIcon = ({ type }: { type: NodeType }) => {
    switch (type) {
        case 'concept': return <ConceptIcon />;
        case 'practice': return <PracticeIcon />;
        case 'game': return <GameIcon />;
        case 'playground': return <PlaygroundIcon />;
        default: return null;
    }
}

interface RoadmapViewProps {
  userProgress: UserProgress;
  onSelectNode: (node: RoadmapNode) => void;
  firstIncompleteNode: RoadmapNode | null;
  username: string;
  onLogout: () => void;
}

export default function RoadmapView({ userProgress, onSelectNode, firstIncompleteNode, username, onLogout }: RoadmapViewProps) {
  return (
    <div className="w-full max-w-3xl mx-auto p-4 md:p-8">
        <header className="text-center mb-8">
            <div className="flex justify-between items-center mb-4">
                 <div className="text-left">
                    <p className="text-sm text-gray-500 dark:text-gray-400">Bienvenido de nuevo,</p>
                    <p className="font-bold text-xl text-base-content dark:text-dark-base-content">{username}</p>
                </div>
                 <button onClick={onLogout} className="text-sm bg-base-100 dark:bg-dark-base-200 py-2 px-4 rounded-lg shadow hover:bg-base-200 dark:hover:bg-dark-base-300 transition">Cerrar Sesión</button>
            </div>
            <h1 className="text-4xl font-bold text-base-content dark:text-dark-base-content">Tu Ruta de Aprendizaje</h1>
            <p className="text-gray-500 dark:text-gray-400 mt-2">Completa cada paso para desbloquear el siguiente y dominar la trigonometría.</p>
        </header>

        <div className="my-8 text-center">
             <button
                onClick={() => firstIncompleteNode && onSelectNode(firstIncompleteNode)}
                disabled={!firstIncompleteNode}
                className="bg-green-500 text-white font-bold py-3 px-8 rounded-lg text-xl shadow-lg hover:bg-green-600 transition-all duration-200 transform hover:scale-105 disabled:bg-gray-500 disabled:cursor-not-allowed disabled:transform-none disabled:shadow-none"
                aria-label={firstIncompleteNode ? `Continuar con: ${firstIncompleteNode.title}` : "¡Felicidades! Has completado la ruta."}
            >
                {firstIncompleteNode ? `Continuar: ${firstIncompleteNode.title}` : '¡Ruta Completada!'}
            </button>
        </div>


        {roadmapData.map((section) => (
            <div key={section.title} className="relative pb-8">
                 {section.nodes.length > 0 && <div className="absolute top-12 left-1/2 -translate-x-1/2 h-full w-1 bg-base-300 dark:bg-dark-base-300 rounded-full"></div>}
                
                <div className="flex items-center gap-4 mb-8">
                    <div className="flex-grow h-px bg-base-300 dark:bg-dark-base-300"></div>
                    <h2 className="text-2xl font-bold text-brand-primary">{section.title}</h2>
                    <div className="flex-grow h-px bg-base-300 dark:bg-dark-base-300"></div>
                </div>

                <div className="space-y-8">
                    {section.nodes.map((node) => {
                        const isCompleted = userProgress[node.id]?.completed;
                        const isLocked = !(node.requires?.every(reqId => userProgress[reqId]?.completed) ?? true);
                        const isActive = node.id === firstIncompleteNode?.id;

                        let nodeClasses = 'bg-base-100 dark:bg-dark-base-200 hover:bg-base-200 dark:hover:bg-dark-base-300';
                        if (isLocked) nodeClasses = 'bg-base-200 dark:bg-dark-base-300 cursor-not-allowed opacity-60';
                        else if (isCompleted) nodeClasses = 'bg-emerald-500 text-white node-completed-glow';
                        else if (isActive) nodeClasses = 'bg-brand-primary text-white node-pulse';
                        
                        return (
                            <div key={node.id} className="relative flex items-center justify-center">
                                <button
                                    onClick={() => onSelectNode(node)}
                                    disabled={isLocked}
                                    className={`w-full max-w-lg flex items-center gap-4 p-4 rounded-xl shadow-lg transition-all duration-200 transform ${!isLocked && 'hover:scale-105'} ${nodeClasses}`}
                                >
                                    <div className={`flex-shrink-0 w-12 h-12 rounded-full flex items-center justify-center ${isCompleted || isActive ? 'bg-white/20' : 'bg-brand-primary/10'}`}>
                                        {isLocked ? <LockIcon /> : <NodeIcon type={node.type} />}
                                    </div>
                                    <div className="text-left flex-grow">
                                        <p className="font-bold text-lg">{node.title}</p>
                                        <p className="text-sm opacity-80 capitalize">{node.type}</p>
                                    </div>
                                    {isCompleted && (
                                        <div className="ml-auto text-white">
                                           <CheckIcon />
                                        </div>
                                    )}
                                </button>
                            </div>
                        );
                    })}
                </div>
            </div>
        ))}
    </div>
  );
}