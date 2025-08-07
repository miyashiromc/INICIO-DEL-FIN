import React, { useState, useEffect, useRef, useCallback } from 'react';
import { LoadingSpinner } from './LoadingSpinner';

interface GameViewProps {
    onBack: () => void;
    onGameEnd: (score: number) => void;
}

export default function GameView({ onBack, onGameEnd }: GameViewProps) {
    const canvasRef = useRef<HTMLCanvasElement>(null);
    const [score, setScore] = useState(0);
    const [timeLeft, setTimeLeft] = useState(60);
    const [gameState, setGameState] = useState<'loading' | 'ready' | 'playing' | 'over'>('loading');
    const [angle, setAngle] = useState(45);

    const projectiles = useRef<{ x: number, y: number, vx: number, vy: number }[]>([]);
    const targets = useRef<{ x: number, y: number, radius: number, points: number }[]>([]);
    
    const cannon = { x: 50, y: 550, length: 50, width: 20 };

    const fireProjectile = useCallback(() => {
        const rad = (180 - angle) * (Math.PI / 180); // Adjust angle for canvas coordinate system
        const speed = 15;
        projectiles.current.push({
            x: cannon.x + cannon.length * Math.cos(rad),
            y: cannon.y + cannon.length * Math.sin(rad),
            vx: speed * Math.cos(rad),
            vy: speed * Math.sin(rad)
        });
    }, [angle]);

    const spawnTarget = useCallback((canvasWidth: number) => {
        const radius = Math.random() * 15 + 10;
        targets.current.push({
            x: Math.random() * (canvasWidth - 200) + 150,
            y: Math.random() * 300 + 50,
            radius: radius,
            points: Math.round((30 - radius) * 100) // Smaller targets worth more
        });
    }, []);

    useEffect(() => {
        const handleResize = () => {
            if (canvasRef.current) {
                const parent = canvasRef.current.parentElement;
                if(parent) {
                    canvasRef.current.width = parent.clientWidth;
                    canvasRef.current.height = parent.clientHeight - 80;
                }
            }
        };

        const handleKeyDown = (e: KeyboardEvent) => {
            if (e.code === 'Space') {
                e.preventDefault();
                if (gameState === 'playing') fireProjectile();
            }
        };

        window.addEventListener('keydown', handleKeyDown);
        window.addEventListener('resize', handleResize);
        
        handleResize();
        setGameState('ready');

        return () => {
            window.removeEventListener('keydown', handleKeyDown);
            window.removeEventListener('resize', handleResize);
        }
    }, [gameState, fireProjectile]);
    
    useEffect(() => {
        if (gameState !== 'playing') return;

        const timer = setInterval(() => {
            setTimeLeft(prev => {
                if (prev <= 1) {
                    clearInterval(timer);
                    setGameState('over');
                    return 0;
                }
                return prev - 1;
            });
        }, 1000);
        
        const spawner = setInterval(() => {
            if (canvasRef.current && targets.current.length < 10) {
                spawnTarget(canvasRef.current.width);
            }
        }, 1500);

        return () => {
            clearInterval(timer);
            clearInterval(spawner);
        };
    }, [gameState, spawnTarget]);
    
    useEffect(() => {
        const canvas = canvasRef.current;
        if (!canvas || gameState !== 'playing') return;
        
        const ctx = canvas.getContext('2d');
        if (!ctx) return;
        
        let animationFrameId: number;

        const render = () => {
            ctx.clearRect(0, 0, canvas.width, canvas.height);
            
            // Draw Cannon
            ctx.save();
            ctx.translate(cannon.x, cannon.y);
            ctx.rotate((180 - angle) * (Math.PI / 180));
            ctx.fillStyle = '#4f46e5';
            ctx.fillRect(0, -cannon.width / 2, cannon.length, cannon.width);
            ctx.fillStyle = '#6366f1';
            ctx.fillRect(-20, -15, 40, 30);
            ctx.restore();

            // Update & Draw Projectiles
            projectiles.current = projectiles.current.filter(p => p.x > 0 && p.x < canvas.width && p.y < canvas.height);
            projectiles.current.forEach(p => {
                p.x += p.vx;
                p.y += p.vy;
                p.vy += 0.1; // gravity
                ctx.fillStyle = 'black';
                ctx.beginPath();
                ctx.arc(p.x, p.y, 5, 0, Math.PI * 2);
                ctx.fill();
            });

            // Update & Draw Targets
            let newTargets = [...targets.current];
            let hits = 0;
            projectiles.current.forEach((p, pi) => {
                newTargets = newTargets.filter(t => {
                    const dist = Math.hypot(p.x - t.x, p.y - t.y);
                    if (dist < t.radius) {
                        setScore(s => s + t.points);
                        hits++;
                        return false; // remove target
                    }
                    return true;
                });
            });
            if(hits > 0) projectiles.current = []; // remove projectile on hit
            targets.current = newTargets;

            targets.current.forEach(t => {
                ctx.fillStyle = '#ef4444';
                ctx.beginPath();
                ctx.arc(t.x, t.y, t.radius, 0, Math.PI * 2);
                ctx.fill();
            });

            // Draw UI
            ctx.fillStyle = 'black';
            ctx.font = '24px sans-serif';
            ctx.textAlign = 'left';
            ctx.fillText(`Puntuación: ${score}`, 10, 30);
            ctx.textAlign = 'right';
            ctx.fillText(`Tiempo: ${timeLeft}`, canvas.width - 10, 30);

            animationFrameId = requestAnimationFrame(render);
        };
        
        render();

        return () => cancelAnimationFrame(animationFrameId);
    }, [gameState, angle, score, timeLeft, spawnTarget]);

    const startGame = () => {
        setScore(0);
        setTimeLeft(60);
        projectiles.current = [];
        targets.current = [];
        if (canvasRef.current) {
            for(let i=0; i<3; i++) spawnTarget(canvasRef.current.width);
        }
        setGameState('playing');
    };

    if (gameState === 'loading') {
        return <div className="flex items-center justify-center h-96"><LoadingSpinner /></div>;
    }
    
    if (gameState === 'over') {
       onGameEnd(score);
       return <div className="flex items-center justify-center h-96"><p>Calculando resultados...</p><LoadingSpinner /></div>
    }

    return (
        <div className="w-full h-full flex flex-col items-center justify-center p-4 animate-fadeIn">
            <div className="w-full max-w-5xl bg-base-100/80 dark:bg-dark-base-200/80 backdrop-blur-sm p-4 rounded-xl shadow-lg relative">
                {gameState === 'ready' && (
                    <div className="absolute inset-0 z-10 bg-black/50 flex flex-col justify-center items-center rounded-xl">
                        <h2 className="text-4xl font-bold text-white mb-4">Disparador de Ángulos</h2>
                        <div className="flex gap-4">
                            <button onClick={startGame} className="bg-green-500 text-white py-3 px-6 rounded-lg text-lg font-bold">¡Empezar a Jugar!</button>
                            <button onClick={onBack} className="bg-gray-500 text-white py-3 px-6 rounded-lg text-lg font-bold">Volver a la Ruta</button>
                        </div>
                    </div>
                )}
                <canvas ref={canvasRef} className="w-full rounded-lg bg-sky-200 dark:bg-sky-900"></canvas>
                <div className="w-full flex items-center justify-center gap-4 mt-4 p-2 bg-base-200 dark:bg-dark-base-300 rounded-lg">
                    <label htmlFor="angle" className="font-bold">Ángulo: {angle}°</label>
                    <input type="range" min="0" max="180" value={angle} onChange={(e) => setAngle(parseInt(e.target.value))} id="angle" className="w-1/2" disabled={gameState !== 'playing'} />
                    <button onClick={fireProjectile} className="bg-brand-primary text-white py-2 px-4 rounded-lg font-bold disabled:bg-gray-400" disabled={gameState !== 'playing'}>¡Fuego! (Espacio)</button>
                </div>
            </div>
        </div>
    );
}