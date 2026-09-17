"use client";

import { useState } from "react";
import { Users, DollarSign, Sparkles, CheckCircle2, QrCode } from "lucide-react";

export function InteractiveCalculator() {
  const [totalCost, setTotalCost] = useState(120);
  const [playerCount, setPlayerCount] = useState(8);
  const [goalieFree, setGoalieFree] = useState(false);

  // If goalie plays free, split amongst (playerCount - 1)
  const payingPlayers = goalieFree ? Math.max(1, playerCount - 1) : playerCount;
  const perPlayer = (totalCost / payingPlayers).toFixed(2);

  return (
    <div className="glass-card p-6 sm:p-8 relative overflow-hidden border border-violet-500/20 shadow-[0_20px_50px_rgba(139,92,246,0.15)]">
      {/* Top ambient glow */}
      <div className="absolute top-0 right-0 w-64 h-64 bg-violet-600/10 rounded-full blur-3xl pointer-events-none" />

      <div className="flex flex-col sm:flex-row items-start sm:items-center justify-between gap-4 mb-6 pb-6 border-b border-white/[0.08]">
        <div>
          <div className="inline-flex items-center gap-1.5 px-2.5 py-1 rounded-full bg-violet-500/10 border border-violet-500/20 text-violet-300 text-xs font-semibold mb-2">
            <Sparkles className="w-3.5 h-3.5" />
            <span>Interactive Simulator</span>
          </div>
          <h3 className="text-xl font-bold text-white tracking-tight">
            See how MatchSplitter works
          </h3>
          <p className="text-xs sm:text-sm text-slate-400">
            Adjust the match fee and squad size to see real-time settlements
          </p>
        </div>

        <button
          onClick={() => setGoalieFree(!goalieFree)}
          className={`px-3.5 py-2 rounded-xl text-xs font-semibold border transition-all flex items-center gap-2 ${
            goalieFree
              ? "bg-violet-500/20 border-violet-500/50 text-violet-200 shadow-[0_0_15px_rgba(139,92,246,0.3)]"
              : "bg-white/[0.03] border-white/[0.08] text-slate-400 hover:text-white hover:border-white/[0.15]"
          }`}
        >
          <div className={`w-3.5 h-3.5 rounded-full flex items-center justify-center border ${goalieFree ? "bg-violet-500 border-violet-400" : "border-slate-500"}`}>
            {goalieFree && <CheckCircle2 className="w-3.5 h-3.5 text-white" />}
          </div>
          <span>Keeper Plays Free 🧤</span>
        </button>
      </div>

      <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-center">
        {/* Sliders and controls */}
        <div className="space-y-6">
          {/* Total Cost Slider */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <label className="text-sm font-medium text-slate-300 flex items-center gap-2">
                <DollarSign className="w-4 h-4 text-violet-400" />
                Match Total Expense
              </label>
              <span className="text-lg font-bold text-white">${totalCost}</span>
            </div>
            <input
              type="range"
              min="40"
              max="400"
              step="10"
              value={totalCost}
              onChange={(e) => setTotalCost(Number(e.target.value))}
              className="w-full h-2 bg-slate-800 rounded-lg appearance-none cursor-pointer accent-violet-500"
            />
            <div className="flex justify-between text-[11px] text-slate-500 mt-1">
              <span>$40 (Futsal)</span>
              <span>$200 (Full 11s)</span>
              <span>$400 (Tournament)</span>
            </div>
          </div>

          {/* Squad Size Slider */}
          <div>
            <div className="flex justify-between items-center mb-2">
              <label className="text-sm font-medium text-slate-300 flex items-center gap-2">
                <Users className="w-4 h-4 text-cyan-400" />
                Squad Players Attending
              </label>
              <span className="text-lg font-bold text-white">{playerCount} players</span>
            </div>
            <input
              type="range"
              min="4"
              max="18"
              step="1"
              value={playerCount}
              onChange={(e) => setPlayerCount(Number(e.target.value))}
              className="w-full h-2 bg-slate-800 rounded-lg appearance-none cursor-pointer accent-cyan-400"
            />
            <div className="flex justify-between text-[11px] text-slate-500 mt-1">
              <span>4 players (Futsal)</span>
              <span>10 players (5-a-side)</span>
              <span>18 players (Full squad)</span>
            </div>
          </div>

          {/* Roster preview tags */}
          <div className="pt-2">
            <p className="text-xs font-semibold text-slate-400 uppercase tracking-wider mb-2.5">
              Simulated Split ({payingPlayers} paying {goalieFree ? "+ 1 free keeper" : ""}):
            </p>
            <div className="flex flex-wrap gap-1.5">
              {Array.from({ length: playerCount }).map((_, idx) => {
                const isFreeGoalie = goalieFree && idx === 0;
                return (
                  <span
                    key={idx}
                    className={`text-xs px-2.5 py-1 rounded-lg border font-medium transition-all ${
                      isFreeGoalie
                        ? "bg-emerald-500/10 border-emerald-500/30 text-emerald-300"
                        : "bg-white/[0.04] border-white/[0.08] text-slate-300"
                    }`}
                  >
                    {isFreeGoalie ? "🧤 GK: $0.00" : `Player ${idx + 1}: $${perPlayer}`}
                  </span>
                );
              })}
            </div>
          </div>
        </div>

        {/* Calculated Result Card */}
        <div className="bg-[#0b0e18]/90 border border-violet-500/30 rounded-2xl p-6 relative flex flex-col items-center text-center shadow-[inset_0_1px_0_0_rgba(167,139,250,0.2)]">
          <div className="w-12 h-12 rounded-xl bg-gradient-to-br from-violet-600 to-cyan-400 flex items-center justify-center text-white mb-4 shadow-[0_0_20px_rgba(139,92,246,0.5)]">
            <QrCode className="w-6 h-6" />
          </div>

          <p className="text-xs uppercase font-bold tracking-widest text-slate-400 mb-1">
            Each Player Pays
          </p>
          <div className="text-4xl sm:text-5xl font-black text-transparent bg-clip-text bg-gradient-to-r from-white via-violet-200 to-cyan-300 tracking-tight mb-2">
            ${perPlayer}
          </div>

          <p className="text-xs text-slate-400 mb-6 max-w-xs">
            {goalieFree
              ? `Split evenly among ${payingPlayers} players. Goalkeeper plays free.`
              : `Total match fee $${totalCost} divided equally across all ${playerCount} teammates.`}
          </p>

          <div className="w-full pt-4 border-t border-white/[0.08] flex items-center justify-between text-xs text-slate-400">
            <span className="flex items-center gap-1.5 text-emerald-400 font-medium">
              <CheckCircle2 className="w-3.5 h-3.5" />
              Auto QR Settlement Ready
            </span>
            <span className="text-slate-500">Zero rounding loss</span>
          </div>
        </div>
      </div>
    </div>
  );
}
