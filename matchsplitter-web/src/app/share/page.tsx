"use client";

import { Suspense, useState } from "react";
import { useSearchParams } from "next/navigation";
import { QRCodeSVG } from "qrcode.react";
import Link from "next/link";
import { Navbar } from "@/components/layout/Navbar";
import { Users, AlertCircle, Copy, Check, Share2, ArrowLeft } from "lucide-react";

function ShareContent() {
  const searchParams = useSearchParams();
  const id = searchParams.get("id");
  const [copied, setCopied] = useState(false);

  if (!id) {
    return (
      <div className="flex flex-col items-center p-10 sm:p-12 text-center gap-6">
        <div className="w-16 h-16 rounded-2xl bg-rose-500/10 border border-rose-500/20 flex items-center justify-center text-rose-400">
          <AlertCircle className="w-8 h-8" />
        </div>
        <div>
          <h2 className="text-xl font-bold text-white tracking-tight mb-2">
            Missing Squad ID
          </h2>
          <p className="text-sm text-slate-400 max-w-xs leading-relaxed">
            This URL doesn&apos;t specify a valid squad ID to generate an invite QR code.
          </p>
        </div>
        <Link href="/" className="btn-secondary w-full justify-center">
          <ArrowLeft className="w-4 h-4" />
          <span>Return to Home</span>
        </Link>
      </div>
    );
  }

  const joinLink =
    typeof window !== "undefined"
      ? `${window.location.origin}/join?id=${id}`
      : `https://matchsplitter.com/join?id=${id}`;

  const handleCopy = () => {
    navigator.clipboard.writeText(joinLink);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="flex flex-col items-center p-8 sm:p-10 text-center gap-6">
      <div className="w-14 h-14 rounded-2xl bg-gradient-to-tr from-violet-600 to-cyan-400 flex items-center justify-center text-white shadow-[0_0_25px_rgba(139,92,246,0.35)]">
        <Users className="w-7 h-7" />
      </div>

      <div>
        <h2 className="text-2xl font-bold text-white tracking-tight mb-1.5">
          Invite Squad Members
        </h2>
        <p className="text-xs sm:text-sm text-slate-400 max-w-xs leading-relaxed">
          Teammates can scan this QR code on the pitch to join your group immediately.
        </p>
      </div>

      {/* QR Code Container with sleek white canvas */}
      <div className="bg-white p-5 rounded-2xl shadow-[0_15px_35px_rgba(0,0,0,0.5)] border border-white/20">
        <QRCodeSVG value={joinLink} size={180} level="M" />
      </div>

      <div className="flex flex-col gap-3 w-full max-w-xs">
        <button
          onClick={handleCopy}
          className="btn-primary w-full justify-center"
        >
          {copied ? (
            <>
              <Check className="w-4 h-4 text-emerald-300" />
              <span>Link Copied to Clipboard</span>
            </>
          ) : (
            <>
              <Copy className="w-4 h-4" />
              <span>Copy Invite Link</span>
            </>
          )}
        </button>
      </div>

      <Link
        href="/"
        className="text-xs text-slate-500 hover:text-slate-300 transition-colors flex items-center gap-1"
      >
        <ArrowLeft className="w-3.5 h-3.5" />
        <span>Return to home</span>
      </Link>
    </div>
  );
}

export default function SharePage() {
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
                Generating QR code…
              </div>
            }
          >
            <ShareContent />
          </Suspense>
        </div>
      </main>
    </>
  );
}
