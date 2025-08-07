import React from 'react';

const trigKeywords = [
    'seno', 'coseno', 'tangente', 'cotangente', 'secante', 'cosecante',
    'ángulo', 'radianes', 'grados', 'triángulo rectángulo', 'hipotenusa', 'cateto opuesto', 'cateto adyacente',
    'teorema de pitágoras', 'identidades trigonométricas', 'círculo unitario', 'ley de senos', 'ley de cosenos',
    'funciones trigonométricas', 'gráficas trigonométricas', 'amplitud', 'periodo'
];

const identities = [
    { formula: 'sin²(θ) + cos²(θ) = 1', name: 'Identidad Pitagórica' },
    { formula: '1 + tan²(θ) = sec²(θ)', name: 'Identidad Pitagórica' },
    { formula: '1 + cot²(θ) = csc²(θ)', name: 'Identidad Pitagórica' },
    { formula: 'sin(α ± β) = sin(α)cos(β) ± cos(α)sin(β)', name: 'Suma/Diferencia de Ángulos' },
    { formula: 'cos(α ± β) = cos(α)cos(β) ∓ sin(α)sin(β)', name: 'Suma/Diferencia de Ángulos' },
    { formula: 'sin(2θ) = 2sin(θ)cos(θ)', name: 'Ángulo Doble' },
    { formula: 'cos(2θ) = cos²(θ) - sin²(θ)', name: 'Ángulo Doble' },
];

export default function ResourcesView(): React.ReactNode {
  return (
    <div className="p-4 md:p-8 max-w-5xl mx-auto text-base-content dark:text-dark-base-content">
      <h1 className="text-4xl font-bold mb-6 text-brand-primary">Recursos de Trigonometría</h1>
      
      <section className="mb-10">
        <h2 className="text-2xl font-semibold border-b-2 border-brand-secondary pb-2 mb-4">Identidades Fundamentales</h2>
        <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
            {identities.map((identity) => (
                <div key={identity.formula} className="bg-base-100 dark:bg-dark-base-200 p-4 rounded-lg shadow">
                    <p className="font-mono text-lg text-brand-primary">{identity.formula}</p>
                    <p className="text-sm text-gray-500 dark:text-gray-400">{identity.name}</p>
                </div>
            ))}
        </div>
      </section>

       <section className="mb-10">
        <h2 className="text-2xl font-semibold border-b-2 border-brand-secondary pb-2 mb-4">El Círculo Unitario</h2>
        <div className="bg-base-100 dark:bg-dark-base-200 p-4 rounded-lg shadow">
            <p className="mb-2">El círculo unitario es un círculo con un radio de 1 centrado en el origen. Es una herramienta fundamental porque nos permite extender las definiciones de seno y coseno a todos los números reales.</p>
            <ul className="list-disc list-inside space-y-1">
                <li>El valor de <code className="bg-base-200 dark:bg-dark-base-300 px-1 rounded">cos(θ)</code> es la coordenada <strong>x</strong> del punto en el círculo.</li>
                <li>El valor de <code className="bg-base-200 dark:bg-dark-base-300 px-1 rounded">sin(θ)</code> es la coordenada <strong>y</strong> del punto en el círculo.</li>
            </ul>
        </div>
      </section>

      <section>
        <h2 className="text-2xl font-semibold border-b-2 border-brand-secondary pb-2 mb-4">Palabras Clave para Búsqueda</h2>
        <div className="bg-base-100 dark:bg-dark-base-200 p-4 rounded-lg shadow">
            <p className="mb-3">Usa estos términos en el chat para obtener explicaciones detalladas:</p>
            <div className="flex flex-wrap gap-2">
                {trigKeywords.map(keyword => (
                    <span key={keyword} className="bg-brand-primary/10 text-brand-primary text-sm font-semibold px-3 py-1 rounded-full">
                        {keyword}
                    </span>
                ))}
            </div>
        </div>
      </section>
    </div>
  );
}
