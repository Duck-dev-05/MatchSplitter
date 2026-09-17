"use client";

import { useState, useEffect } from "react";
import Link from "next/link";
import { usePathname } from "next/navigation";
import { Activity, Menu, X, ArrowRight, Smartphone } from "lucide-react";

export function Navbar() {
  const pathname = usePathname();
  const [scrolled, setScrolled] = useState(false);
  const [mobileMenuOpen, setMobileMenuOpen] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setScrolled(window.scrollY > 20);
    };
    window.addEventListener("scroll", handleScroll);
    return () => window.removeEventListener("scroll", handleScroll);
  }, []);

  useEffect(() => {
    setMobileMenuOpen(false);
  }, [pathname]);

  const navLinks = [
    { name: "Features", href: "/#features" },
    { name: "How It Works", href: "/#how-it-works" },
    { name: "Pricing", href: "/pricing" },
    { name: "FAQ", href: "/faq" },
    { name: "Support", href: "/support" },
  ];

  return (
    <header
      className={`fixed top-0 left-0 right-0 z-50 transition-all duration-300 ${
        scrolled
          ? "bg-[#08090d]/85 backdrop-blur-xl border-b border-white/[0.08] shadow-[0_4px_30px_rgba(0,0,0,0.5)]"
          : "bg-transparent border-b border-transparent"
      }`}
    >
      <div className="container-page h-16 flex items-center justify-between">
        {/* Brand Logo */}
        <Link href="/" className="flex items-center gap-2.5 group">
          <div className="w-8 h-8 rounded-lg bg-gradient-to-tr from-violet-600 to-cyan-400 p-[1px] shadow-[0_0_15px_rgba(139,92,246,0.4)]">
            <div className="w-full h-full bg-[#08090d] rounded-[7px] flex items-center justify-center transition-colors group-hover:bg-transparent">
              <Activity className="w-4 h-4 text-violet-300 group-hover:text-white transition-colors" />
            </div>
          </div>
          <span className="font-bold text-lg tracking-tight text-white flex items-center">
            Match<span className="text-violet-400">Splitter</span>
          </span>
        </Link>

        {/* Desktop Nav Links */}
        <nav className="hidden md:flex items-center gap-1 bg-white/[0.03] border border-white/[0.06] px-3 py-1.5 rounded-full backdrop-blur-md">
          {navLinks.map((link) => {
            const isActive = pathname === link.href;
            return (
              <Link
                key={link.name}
                href={link.href}
                className={`px-3.5 py-1 text-sm font-medium rounded-full transition-all duration-200 ${
                  isActive
                    ? "text-white bg-white/[0.08] shadow-sm"
                    : "text-slate-400 hover:text-white hover:bg-white/[0.04]"
                }`}
              >
                {link.name}
              </Link>
            );
          })}
        </nav>

        {/* Right CTA */}
        <div className="hidden md:flex items-center gap-3">
          <Link
            href="/#download"
            className="btn-primary btn-sm group"
          >
            <Smartphone className="w-4 h-4" />
            <span>Download</span>
            <ArrowRight className="w-3.5 h-3.5 group-hover:translate-x-0.5 transition-transform" />
          </Link>
        </div>

        {/* Mobile Menu Button */}
        <button
          onClick={() => setMobileMenuOpen(!mobileMenuOpen)}
          className="md:hidden p-2 rounded-lg text-slate-400 hover:text-white hover:bg-white/[0.05] transition-colors"
          aria-label="Toggle Navigation"
        >
          {mobileMenuOpen ? <X className="w-6 h-6" /> : <Menu className="w-6 h-6" />}
        </button>
      </div>

      {/* Mobile Menu Dropdown */}
      {mobileMenuOpen && (
        <div className="md:hidden bg-[#0a0d14]/95 backdrop-blur-2xl border-b border-white/[0.08] px-6 py-5 flex flex-col gap-3 animate-in fade-in slide-in-from-top-2 duration-200">
          {navLinks.map((link) => (
            <Link
              key={link.name}
              href={link.href}
              className={`py-2 text-base font-medium rounded-lg px-3 transition-colors ${
                pathname === link.href
                  ? "text-white bg-white/[0.06]"
                  : "text-slate-300 hover:text-white hover:bg-white/[0.04]"
              }`}
            >
              {link.name}
            </Link>
          ))}
          <div className="pt-2 border-t border-white/[0.08]">
            <Link
              href="/#download"
              className="btn-primary w-full justify-center"
            >
              <Smartphone className="w-4 h-4" />
              <span>Download App</span>
            </Link>
          </div>
        </div>
      )}
    </header>
  );
}
