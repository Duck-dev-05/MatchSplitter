"use client";

import { useEffect, useState, Suspense } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { Navbar } from "@/components/layout/Navbar";
import { Activity, AlertCircle, Smartphone, ArrowRight, ExternalLink } from "lucide-react";

function JoinContent() {
  const searchParams = useSearchParams();
  const id = searchParams.get("id");
  const [status, setStatus] = useState<"loading" | "redirected" | "failed">(
    "loading"
  );

  useEffect(() => {
    if (!id) {
      setStatus("failed");
      return;
    }
    const appScheme = `matchsplitter://join?id=${id}`;
    window.location.href = appScheme;
    const timeout = setTimeout(() => setStatus("redirected"), 2500);
    return () => clearTimeout(timeout);
  }, [id]);

  if (status === "loading") {
    return (
      <div className="flex flex-col items-center p-10 sm:p-12 text-center gap-6">
        <div className="relative w-20 h-20 flex items-center justify-center">
          <div className="absolute inset-0 rounded-full border-2 border-violet-500/20 border-t-violet-500 animate-spin" />
          <div className="w-12 h-12 rounded-xl bg-violet-600/20 border border-violet-500/40 flex items-center justify-center text-violet-300">
            <Activity className="w-6 h-6 animate-pulse" />
          </div>
        </div>

        <div>
          <h2 className="text-xl font-bold text-white tracking-tight mb-2">
            Opening MatchSplitter…
          </h2>
          <p className="text-sm text-slate-400">
            Connecting you directly to the squad ledger
          </p>
        </div>
      </div>
    );
  }

  if (status === "failed") {
    return (
      <div className="flex flex-col items-center p-10 sm:p-12 text-center gap-6">
        <div className="w-16 h-16 rounded-2xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center text-rose-400">
          <AlertCircle className="w-8 h-8" />
        </div>

        <div>
          <h2 className="text-xl font-bold text-white tracking-tight mb-2">
            Invalid Invite Link
          </h2>
          <p className="text-sm text-slate-400 max-w-xs leading-relaxed">
            This group invitation link appears to be broken or expired. Ask your squad captain to share a new invite QR or link.
          </p>
        </div>

        <Link href="/" className="btn-secondary w-full justify-center">
          Return to Home
        </Link>
      </div>
    );
  }

  // Redirected state (App wasn't opened automatically)
  return (
    <div className="flex flex-col items-center p-8 sm:p-10 text-center gap-6">
      <div className="w-16 h-16 rounded-2xl bg-gradient-to-tr from-violet-600 to-cyan-400 p-[1px] shadow-[0_0_25px_rgba(139,92,246,0.35)]">
        <div className="w-full h-full bg-[#0c101c] rounded-[15px] flex items-center justify-center">
          <Activity className="w-8 h-8 text-violet-300" />
        </div>
      </div>

      <div>
        <h2 className="text-2xl font-bold text-white tracking-tight mb-2">
          Join Your Squad
        </h2>
        <p className="text-sm text-slate-400 max-w-sm leading-relaxed">
          If MatchSplitter didn&apos;t launch automatically, tap below to open it, or download the app on the App Store.
        </p>
      </div>

      <div className="flex flex-col gap-3 w-full max-w-xs">
        <a
          href={`matchsplitter://join?id=${id}`}
          className="btn-primary w-full justify-center"
        >
          <span>Open in App</span>
          <ExternalLink className="w-4 h-4" />
        </a>

        <a
          href="https://apps.apple.com"
          target="_blank"
          rel="noreferrer"
          className="btn-secondary w-full justify-center"
        >
          <Smartphone className="w-4 h-4" />
          <span>Download on App Store</span>
        </a>
      </div>

      <Link href="/" className="text-xs text-slate-500 hover:text-slate-300 transition-colors">
        Return to MatchSplitter home
      </Link>
    </div>
  );
}

export default function JoinPage() {
  return (
    <>
      <Navbar />

      <main className="bg-page flex items-center justify-center min-h-[calc(100vh-64px)] px-4 py-16 relative">
        <div
          className="glow-orb glow-orb-primary top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-[500px] h-[500px]"
          aria-hidden="true"
        />

        <div className="glass-card w-full max-w-md relative z-10">
          <Suspense
            fallback={
              <div className="p-12 text-center text-sm text-slate-400">
                Loading invitation…
              </div>
            }
          >
            <JoinContent />
          </Suspense>
        </div>
      </main>
    </>
  );
}
