"use client";

import { useState } from "react";
import { ChevronDown } from "lucide-react";

interface AccordionProps {
  items: {
    question: string;
    answer: string;
  }[];
}

export function Accordion({ items }: AccordionProps) {
  const [openIndex, setOpenIndex] = useState<number | null>(0);

  const toggle = (idx: number) => {
    setOpenIndex(openIndex === idx ? null : idx);
  };

  return (
    <div className="space-y-3.5">
      {items.map((item, idx) => {
        const isOpen = openIndex === idx;
        return (
          <div
            key={idx}
            onClick={() => toggle(idx)}
            className={`glass-card p-5 sm:p-6 cursor-pointer transition-all duration-300 ${
              isOpen
                ? "border-violet-500/40 bg-[#111626]/90 shadow-[0_8px_30px_rgba(139,92,246,0.15)]"
                : "hover:border-white/[0.15]"
            }`}
          >
            <div className="flex justify-between items-center gap-4">
              <h3
                className={`text-base sm:text-lg font-semibold tracking-tight transition-colors ${
                  isOpen ? "text-violet-300" : "text-white"
                }`}
              >
                {item.question}
              </h3>
              <div
                className={`w-7 h-7 rounded-full flex items-center justify-center shrink-0 border transition-all duration-300 ${
                  isOpen
                    ? "bg-violet-500/20 border-violet-500/40 text-violet-300 rotate-180"
                    : "bg-white/[0.04] border-white/[0.08] text-slate-400 rotate-0"
                }`}
              >
                <ChevronDown className="w-4 h-4" />
              </div>
            </div>

            <div
              className={`grid transition-all duration-300 ease-in-out ${
                isOpen
                  ? "grid-rows-[1fr] opacity-100 mt-3 pt-3 border-t border-white/[0.06]"
                  : "grid-rows-[0fr] opacity-0"
              }`}
            >
              <div className="overflow-hidden">
                <p className="text-sm text-slate-300 leading-relaxed">
                  {item.answer}
                </p>
              </div>
            </div>
          </div>
        );
      })}
    </div>
  );
}
