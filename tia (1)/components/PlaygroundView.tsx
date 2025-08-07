import React, { useState, useRef, useCallback, useEffect } from 'react';

export default function PlaygroundView({ onBack }: { onBack: () => void }) {
    const svgRef = useRef<SVGSVGElement>(null);
    const [angle, setAngle] = useState(45);
    const [isDragging, setIsDragging] = useState(false);

    const size = 500;
    const center = size / 2;
    const radius = size * 0.4;
    
    const rad = angle * (Math.PI / 180);
    const x = center + radius * Math.cos(rad);
    const y = center - radius * Math.sin(rad);

    const sinVal = Math.sin(rad);
    const cosVal = Math.cos(rad);
    const tanVal = Math.tan(rad);

    const handleInteraction = useCallback((clientX: number, clientY: number) => {
        if (!svgRef.current) return;
        const rect = svgRef.current.getBoundingClientRect();
        
        const svgX = clientX - rect.left;
        const svgY = clientY - rect.top;
        
        const dx = svgX - center;
        const dy = center - svgY;

        let newAngle = Math.atan2(dy, dx) * (180 / Math.PI);
        if (newAngle < 0) newAngle += 360;
        
        setAngle(newAngle);
    }, [center]);


    const handleMouseMove = useCallback((e: MouseEvent) => handleInteraction(e.clientX, e.clientY), [handleInteraction]);
    const handleTouchMove = useCallback((e: TouchEvent) => handleInteraction(e.touches[0].clientX, e.touches[0].clientY), [handleInteraction]);

    const handleMouseUp = useCallback(() => setIsDragging(false), []);

    const handleMouseDown = useCallback((e: React.MouseEvent) => {
        e.preventDefault();
        setIsDragging(true);
        handleInteraction(e.clientX, e.clientY);
    }, [handleInteraction]);

    const handleTouchStart = useCallback((e: React.TouchEvent) => {
        e.preventDefault();
        setIsDragging(true);
        handleInteraction(e.touches[0].clientX, e.touches[0].clientY);
    }, [handleInteraction]);
    
    useEffect(() => {
        if (isDragging) {
            document.addEventListener('mousemove', handleMouseMove);
            document.addEventListener('mouseup', handleMouseUp);
            document.addEventListener('touchmove', handleTouchMove);
            document.addEventListener('touchend', handleMouseUp);
        }

        return () => {
            document.removeEventListener('mousemove', handleMouseMove);
            document.removeEventListener('mouseup', handleMouseUp);
            document.removeEventListener('touchmove', handleTouchMove);
            document.removeEventListener('touchend', handleMouseUp);
        };
    }, [isDragging, handleMouseMove, handleMouseUp, handleTouchMove]);

    return (
        <div className="w-full max-w-6xl mx-auto p-4 md:p-8 animate-fadeIn">
            <div className="bg-base-100/80 dark:bg-dark-base-200/80 backdrop-blur-sm p-6 rounded-xl shadow-lg">
                 <h2 className="text-3xl font-bold text-center text-base-content dark:text-dark-base-content mb-2">
                    Laboratorio de <span className="text-brand-primary">Trigonometría</span>
                </h2>
                <p className="text-center text-gray-500 dark:text-gray-400 mb-6">
                    Arrastra el punto en el círculo para explorar los valores trigonométricos.
                </p>
                <div className="flex flex-col md:flex-row gap-8 items-center">
                    <div className="w-full md:w-2/3">
                        <svg ref={svgRef} viewBox={`0 0 ${size} ${size}`} onMouseDown={handleMouseDown} onTouchStart={handleTouchStart} className="cursor-pointer touch-none bg-white dark:bg-dark-base-100 rounded-full shadow-inner">
                            {/* Axes */}
                            <line x1="0" y1={center} x2={size} y2={center} strokeWidth="1" className="stroke-gray-300 dark:stroke-gray-600"/>
                            <line x1={center} y1="0" x2={center} y2={size} strokeWidth="1" className="stroke-gray-300 dark:stroke-gray-600" />

                            {/* Unit Circle */}
                            <circle cx={center} cy={center} r={radius} fill="none" strokeWidth="2" className="stroke-gray-800 dark:stroke-gray-200"/>
                            
                            {/* Angle Arc */}
                            <path d={`M ${center + radius * 0.2} ${center} A ${radius * 0.2} ${radius * 0.2} 0 0 1 ${center + radius * 0.2 * Math.cos(rad)} ${center - radius * 0.2 * Math.sin(rad)}`} fill="rgba(79, 70, 229, 0.2)" stroke="#4f46e5" strokeWidth="1" />
                            <text x={center + radius * 0.3 * Math.cos(rad/2)} y={center - radius * 0.3 * Math.sin(rad/2)} dy="0.3em" textAnchor="middle" fontSize="16" fill="#4f46e5" className="font-sans font-bold select-none">θ</text>
                            
                            {/* Triangle */}
                            <path d={`M ${center} ${center} L ${x} ${center} L ${x} ${y} Z`} fill="rgba(0, 0, 0, 0.05)" className="dark:fill-[rgba(255,255,255,0.05)]"/>
                            <line x1={center} y1={center} x2={x} y2={y} strokeWidth="2" className="stroke-gray-800 dark:stroke-white"/>
                            
                            {/* Cos and Sin lines */}
                            <line x1={center} y1={center} x2={x} y2={center} stroke="#3b82f6" strokeWidth="4" />
                            <text x={(center + x) / 2} y={center + 20} textAnchor="middle" fill="#3b82f6" className="font-bold select-none">cos(θ)</text>
                            <line x1={x} y1={center} x2={x} y2={y} stroke="#ef4444" strokeWidth="4" />
                             <text x={x + 15} y={(center + y) / 2} dominantBaseline="middle" fill="#ef4444" className="font-bold select-none">sin(θ)</text>
                           
                            {/* Draggable point */}
                            <circle cx={x} cy={y} r="10" fill="#4f46e5" className="cursor-grab" />
                        </svg>
                    </div>
                    <div className="w-full md:w-1/3 p-6 bg-base-200 dark:bg-dark-base-300 rounded-lg">
                        <h3 className="text-xl font-bold mb-4 text-center">Valores en Tiempo Real</h3>
                        <div className="space-y-3 font-mono text-lg">
                            <div className="flex justify-between items-center p-2 bg-base-100 dark:bg-dark-base-100 rounded">
                                <span>Ángulo (θ):</span>
                                <span className="font-bold text-brand-primary">{angle.toFixed(1)}°</span>
                            </div>
                            <div className="flex justify-between items-center p-2 bg-base-100 dark:bg-dark-base-100 rounded">
                                <span>Radianes:</span>
                                <span className="font-bold text-brand-primary">{rad.toFixed(3)}</span>
                            </div>
                            <div className="flex justify-between items-center p-2 bg-red-100/50 dark:bg-red-900/30 rounded">
                                <span className="text-red-600 dark:text-red-400">sin(θ):</span>
                                <span className="font-bold text-red-600 dark:text-red-400">{sinVal.toFixed(4)}</span>
                            </div>
                             <div className="flex justify-between items-center p-2 bg-blue-100/50 dark:bg-blue-900/30 rounded">
                                <span className="text-blue-600 dark:text-blue-400">cos(θ):</span>
                                <span className="font-bold text-blue-600 dark:text-blue-400">{cosVal.toFixed(4)}</span>
                            </div>
                            <div className="flex justify-between items-center p-2 bg-green-100/50 dark:bg-green-900/30 rounded">
                                <span className="text-green-600 dark:text-green-400">tan(θ):</span>
                                <span className="font-bold text-green-600 dark:text-green-400">{isFinite(tanVal) ? tanVal.toFixed(4) : "Indefinido"}</span>
                            </div>
                        </div>
                    </div>
                </div>
                 <div className="mt-8 pt-6 border-t border-base-200 dark:border-dark-base-300 flex justify-center">
                    <button onClick={onBack} className="bg-brand-primary text-white py-2 px-6 rounded-lg font-semibold hover:bg-brand-secondary transition-colors duration-200">
                        ← Volver a la Ruta
                    </button>
                </div>
            </div>
        </div>
    );
}