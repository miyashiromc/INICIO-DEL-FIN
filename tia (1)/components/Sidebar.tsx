import React from 'react';
import type { View } from '../types';
import { ChatBubbleLeftRightIcon } from './icons/ChatBubbleLeftRightIcon';
import { DocumentTextIcon } from './icons/DocumentTextIcon';
import { ClipboardCheckIcon } from './icons/ClipboardCheckIcon';
import { BookOpenIcon } from './icons/BookOpenIcon';

interface SidebarProps {
  currentView: View;
  setView: (view: View) => void;
}

const NavItem = ({ icon, label, isActive, onClick }: { icon: React.ReactNode, label: string, isActive: boolean, onClick: () => void }) => (
  <button 
    onClick={onClick}
    className={`w-full flex flex-col items-center justify-center p-3 my-2 rounded-lg transition-colors duration-200 ${isActive ? 'bg-brand-primary text-white' : 'hover:bg-base-300 dark:hover:bg-dark-base-300'}`}
    aria-current={isActive ? 'page' : undefined}
    >
    {icon}
    <span className="text-xs mt-1 font-medium">{label}</span>
  </button>
);

export default function Sidebar({ currentView, setView }: SidebarProps): React.ReactNode {
  return (
    <aside className="w-24 bg-base-100 dark:bg-dark-base-200 p-2 flex flex-col items-center shadow-lg">
      <div className="text-brand-primary font-bold text-lg my-4">T.IA</div>
      <nav className="w-full">
        <NavItem 
          icon={<ChatBubbleLeftRightIcon />}
          label="Chat"
          isActive={currentView === 'chat'}
          onClick={() => setView('chat')}
        />
        <NavItem 
          icon={<DocumentTextIcon />}
          label="Contenido"
          isActive={currentView === 'content'}
          onClick={() => setView('content')}
        />
        <NavItem 
          icon={<ClipboardCheckIcon />}
          label="Ejercicios"
          isActive={currentView === 'exercises'}
          onClick={() => setView('exercises')}
        />
         <NavItem 
          icon={<BookOpenIcon />}
          label="Recursos"
          isActive={currentView === 'resources'}
          onClick={() => setView('resources')}
        />
      </nav>
    </aside>
  );
}
