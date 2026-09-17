"use client";

import Link from "next/link";
import { Navbar } from "@/components/layout/Navbar";
import { CheckCircle2, ArrowRight } from "lucide-react";

export default function JoinSuccessPage() {
  return (
    <>
      <Navbar />

      <main className="bg-page flex items-center justify-center min-h-[calc(100vh-64px)] px-4 py-16 relative">
        <div
          className="glow-orb glow-orb-primary top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px]"
          aria-hidden="true"
        />

        <div className="glass-card w-full max-w-md relative z-10 border-emerald-500/30 shadow-[0_20px_60px_rgba(16,185,129,0.15)]">
          <div className="flex flex-col items-center p-8 sm:p-10 text-center gap-6">
            <div className="w-16 h-16 rounded-2xl bg-emerald-500/10 border border-emerald-500/30 flex items-center justify-center text-emerald-400 shadow-[0_0_30px_rgba(16,185,129,0.3)]">
              <CheckCircle2 className="w-9 h-9" />
            </div>

            <div>
              <h2 className="text-2xl font-bold text-white tracking-tight mb-2">
                Successfully Joined!
              </h2>
              <p className="text-sm text-slate-400 max-w-xs leading-relaxed">
                You are now connected to the squad ledger. You can view all shared match expenses and settle debts instantly.
              </p>
            </div>

            <div className="flex flex-col gap-3 w-full max-w-xs pt-2">
              <Link href="/" className="btn-primary w-full justify-center">
                <span>Go to MatchSplitter</span>
                <ArrowRight className="w-4 h-4" />
              </Link>
            </div>
          </div>
        </div>
      </main>
    </>
  );
}
