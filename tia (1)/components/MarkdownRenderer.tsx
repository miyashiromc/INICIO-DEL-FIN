import React, { useEffect, useRef } from 'react';

interface MarkdownRendererProps {
    content: string;
    className?: string;
}

declare global {
    interface Window {
        marked: any;
        hljs: any;
    }
}

const MarkdownRenderer: React.FC<MarkdownRendererProps> = ({ content, className = "" }) => {
    const contentRef = useRef<HTMLDivElement>(null);

    useEffect(() => {
        if (contentRef.current && window.marked && window.hljs) {
             window.marked.setOptions({
                highlight: (code: string, lang: string) => {
                    const language = window.hljs.getLanguage(lang) ? lang : 'plaintext';
                    return window.hljs.highlight(code, { language }).value;
                },
                langPrefix: 'hljs language-',
                gfm: true,
                breaks: true,
            });
            const parsedHtml = window.marked.parse(content || '');
            contentRef.current.innerHTML = parsedHtml;
        }
    }, [content]);

    return <div ref={contentRef} className={`markdown-content ${className}`}></div>;
};

export default MarkdownRenderer;
