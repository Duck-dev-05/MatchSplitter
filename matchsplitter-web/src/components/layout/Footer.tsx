import Link from "next/link";
import { Activity, Mail, ShieldCheck } from "lucide-react";

export function Footer() {
  return (
    <footer className="relative z-10 bg-[#06070a] border-t border-white/[0.08] pt-16 pb-12 text-slate-400">
      <div className="container-page">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-10 md:gap-12 mb-16">
          {/* Brand Col */}
          <div className="md:col-span-2 max-w-sm">
            <Link href="/" className="flex items-center gap-2.5 mb-4 group">
              <div className="w-8 h-8 rounded-lg bg-gradient-to-tr from-violet-600 to-cyan-400 p-[1px] shadow-[0_0_15px_rgba(139,92,246,0.3)]">
                <div className="w-full h-full bg-[#08090d] rounded-[7px] flex items-center justify-center">
                  <Activity className="w-4 h-4 text-violet-300" />
                </div>
              </div>
              <span className="font-bold text-lg tracking-tight text-white">
                Match<span className="text-violet-400">Splitter</span>
              </span>
            </Link>
            <p className="text-sm text-slate-400 leading-relaxed mb-6">
              The modern expense splitting and settlement platform engineered specifically for football teams, Sunday leagues, and sports squads.
            </p>
            <div className="flex items-center gap-3">
              {/* X / Twitter */}
              <a
                href="https://x.com"
                target="_blank"
                rel="noreferrer"
                className="w-9 h-9 rounded-lg bg-white/[0.04] border border-white/[0.08] flex items-center justify-center text-slate-400 hover:text-white hover:border-violet-500/40 hover:bg-violet-500/10 transition-all"
                aria-label="X (formerly Twitter)"
              >
                <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
                  <path d="M18.244 2.25h3.308l-7.227 8.26 8.502 11.24H16.17l-5.214-6.817L4.99 21.75H1.68l7.73-8.835L1.254 2.25H8.08l4.713 6.231zm-1.161 17.52h1.833L7.084 4.126H5.117z" />
                </svg>
              </a>
              {/* Instagram */}
              <a
                href="https://instagram.com"
                target="_blank"
                rel="noreferrer"
                className="w-9 h-9 rounded-lg bg-white/[0.04] border border-white/[0.08] flex items-center justify-center text-slate-400 hover:text-white hover:border-violet-500/40 hover:bg-violet-500/10 transition-all"
                aria-label="Instagram"
              >
                <svg viewBox="0 0 24 24" width="16" height="16" fill="none" stroke="currentColor" strokeWidth="2" strokeLinecap="round" strokeLinejoin="round">
                  <rect width="20" height="20" x="2" y="2" rx="5" ry="5" />
                  <path d="M16 11.37A4 4 0 1 1 12.63 8 4 4 0 0 1 16 11.37z" />
                  <line x1="17.5" x2="17.51" y1="6.5" y2="6.5" />
                </svg>
              </a>
              {/* GitHub */}
              <a
                href="https://github.com"
                target="_blank"
                rel="noreferrer"
                className="w-9 h-9 rounded-lg bg-white/[0.04] border border-white/[0.08] flex items-center justify-center text-slate-400 hover:text-white hover:border-violet-500/40 hover:bg-violet-500/10 transition-all"
                aria-label="GitHub"
              >
                <svg viewBox="0 0 24 24" width="16" height="16" fill="currentColor">
                  <path fillRule="evenodd" clipRule="evenodd" d="M12 2C6.477 2 2 6.484 2 12.017c0 4.425 2.865 8.18 6.839 9.504.5.092.682-.217.682-.483 0-.237-.008-.868-.013-1.703-2.782.605-3.369-1.343-3.369-1.343-.454-1.158-1.11-1.466-1.11-1.466-.908-.62.069-.608.069-.608 1.003.07 1.53 1.032 1.53 1.032.892 1.53 2.341 1.088 2.91.832.092-.647.35-1.088.636-1.338-2.22-.253-4.555-1.113-4.555-4.951 0-1.093.39-1.988 1.029-2.688-.103-.253-.446-1.272.098-2.65 0 0 .84-.27 2.75 1.026A9.564 9.564 0 0112 6.844c.85.004 1.705.115 2.504.337 1.909-1.296 2.747-1.027 2.747-1.027.546 1.379.202 2.398.1 2.651.64.7 1.028 1.595 1.028 2.688 0 3.848-2.339 4.695-4.566 4.943.359.309.678.92.678 1.855 0 1.338-.012 2.419-.012 2.747 0 .268.18.58.688.482A10.019 10.019 0 0022 12.017C22 6.484 17.522 2 12 2z" />
                </svg>
              </a>
              {/* Mail */}
              <a
                href="mailto:support@matchsplitter.com"
                className="w-9 h-9 rounded-lg bg-white/[0.04] border border-white/[0.08] flex items-center justify-center text-slate-400 hover:text-white hover:border-violet-500/40 hover:bg-violet-500/10 transition-all"
                aria-label="Email"
              >
                <Mail className="w-4 h-4" />
              </a>
            </div>
          </div>

          {/* Links Col 1: Product */}
          <div>
            <h4 className="text-sm font-semibold text-white tracking-wider uppercase mb-4">
              Product
            </h4>
            <ul className="space-y-3 text-sm">
              <li>
                <Link href="/#features" className="hover:text-violet-300 transition-colors">
                  Features
                </Link>
              </li>
              <li>
                <Link href="/#how-it-works" className="hover:text-violet-300 transition-colors">
                  How It Works
                </Link>
              </li>
              <li>
                <Link href="/pricing" className="hover:text-violet-300 transition-colors">
                  Pricing Plans
                </Link>
              </li>
              <li>
                <Link href="/#download" className="hover:text-violet-300 transition-colors">
                  Download App
                </Link>
              </li>
              <li>
                <Link href="/faq" className="hover:text-violet-300 transition-colors">
                  FAQ
                </Link>
              </li>
            </ul>
          </div>

          {/* Links Col 2: Support & Company */}
          <div>
            <h4 className="text-sm font-semibold text-white tracking-wider uppercase mb-4">
              Resources
            </h4>
            <ul className="space-y-3 text-sm">
              <li>
                <Link href="/support" className="hover:text-violet-300 transition-colors">
                  Help & Support
                </Link>
              </li>
              <li>
                <a href="#" className="hover:text-violet-300 transition-colors">
                  Privacy Policy
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-violet-300 transition-colors">
                  Terms of Service
                </a>
              </li>
              <li className="pt-2">
                <div className="inline-flex items-center gap-2 px-3 py-1.5 rounded-md bg-emerald-500/10 border border-emerald-500/20 text-emerald-400 text-xs font-medium">
                  <span className="w-2 h-2 rounded-full bg-emerald-400 animate-pulse" />
                  <span>Systems Operational</span>
                </div>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom Bar */}
        <div className="pt-8 border-t border-white/[0.06] flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-500">
          <p>© {new Date().getFullYear()} MatchSplitter Technologies. All rights reserved.</p>
          <div className="flex items-center gap-1.5 text-slate-400">
            <ShieldCheck className="w-4 h-4 text-violet-400" />
            <span>End-to-End Encrypted Group Financials</span>
          </div>
        </div>
      </div>
    </footer>
  );
}
