import React, { useState } from 'react';

interface LoginViewProps {
    onLogin: (username: string) => void;
}

export default function LoginView({ onLogin }: LoginViewProps) {
    const [username, setUsername] = useState('');

    const handleSubmit = (e: React.FormEvent<HTMLFormElement>) => {
        e.preventDefault();
        if (username.trim()) {
            onLogin(username.trim());
        }
    };

    return (
        <div className="min-h-screen flex items-center justify-center bg-gradient-to-br from-base-200 via-base-100 to-base-200 dark:from-dark-base-100 dark:via-dark-base-200 dark:to-dark-base-100">
            <div className="w-full max-w-sm mx-auto p-8 bg-base-100 dark:bg-dark-base-200 rounded-xl shadow-lg text-center">
                <h1 className="text-3xl font-bold text-base-content dark:text-dark-base-content">
                    Bienvenido a <span className="text-brand-primary">TrigTutor IA</span>
                </h1>
                <p className="mt-2 text-gray-600 dark:text-gray-400">
                    Por favor, ingresa un nombre de usuario para continuar
                </p>

                <form onSubmit={handleSubmit} className="mt-8 space-y-6">
                    <div>
                        <label htmlFor="username" className="sr-only">Nombre de usuario</label>
                        <input
                            id="username"
                            name="username"
                            type="text"
                            required
                            value={username}
                            onChange={(e) => setUsername(e.target.value)}
                            className="w-full p-3 border border-gray-300 dark:border-gray-600 rounded-lg bg-base-100 dark:bg-dark-base-200 text-base-content dark:text-dark-base-content focus:ring-2 focus:ring-brand-primary focus:outline-none"
                            placeholder="Nombre de usuario"
                            aria-label="Nombre de usuario"
                        />
                    </div>

                    <button
                        type="submit"
                        className="w-full p-3 bg-brand-primary text-white font-bold text-lg rounded-lg hover:bg-brand-secondary transition-colors duration-200 disabled:bg-gray-400"
                        disabled={!username.trim()}
                    >
                        Iniciar Sesión
                    </button>
                </form>
            </div>
        </div>
    );
}
