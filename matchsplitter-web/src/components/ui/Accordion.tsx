"use client";

import { useState } from "react";

interface AccordionProps {
  items: {
    question: string;
    answer: string;
  }[];
}

export function Accordion({ items }: AccordionProps) {
  const [openIndex, setOpenIndex] = useState<number | null>(null);

  return (
    <div style={{ display: "flex", flexDirection: "column", gap: "12px" }}>
      {items.map((item, idx) => {
        const isOpen = openIndex === idx;
        return (
          <div
            key={idx}
            className="glass-card"
            style={{
              padding: "20px 24px",
              cursor: "pointer",
              transition: "all 0.3s ease",
              border: isOpen
                ? "1px solid var(--primary-light)"
                : "1px solid rgba(255,255,255,0.06)",
              boxShadow: isOpen ? "0 8px 32px rgba(115,56,255,0.15)" : "none",
            }}
            onClick={() => setOpenIndex(isOpen ? null : idx)}
          >
            <div
              style={{
                display: "flex",
                justifyContent: "space-between",
                alignItems: "center",
              }}
            >
              <h3
                style={{
                  fontSize: "1.125rem",
                  fontWeight: 600,
                  color: isOpen ? "white" : "rgba(255,255,255,0.8)",
                  margin: 0,
                }}
              >
                {item.question}
              </h3>
              <div
                style={{
                  fontSize: "1.25rem",
                  color: isOpen ? "var(--primary-light)" : "rgba(255,255,255,0.5)",
                  transform: isOpen ? "rotate(45deg)" : "rotate(0deg)",
                  transition: "transform 0.3s ease",
                }}
              >
                +
              </div>
            </div>
            
            <div
              style={{
                maxHeight: isOpen ? "200px" : "0",
                opacity: isOpen ? 1 : 0,
                overflow: "hidden",
                transition: "all 0.3s ease",
                marginTop: isOpen ? "16px" : "0",
              }}
            >
              <p
                style={{
                  color: "rgba(255,255,255,0.6)",
                  lineHeight: 1.6,
                  margin: 0,
                }}
              >
                {item.answer}
              </p>
            </div>
          </div>
        );
      })}
    </div>
  );
}
