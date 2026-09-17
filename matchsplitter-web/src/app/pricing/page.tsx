import Link from "next/link";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { Check, Sparkles, Zap, ArrowRight, ShieldCheck, HelpCircle } from "lucide-react";

export const metadata = {
  title: "Pricing Plans | MatchSplitter",
  description: "Transparent, simple pricing designed for grassroots squads and competitive sports clubs.",
};

interface FeatureProps {
  text: string;
  highlight?: boolean;
}

function FeatureItem({ text, highlight }: FeatureProps) {
  return (
    <li className="flex items-center gap-3 text-sm">
      <div className="w-5 h-5 rounded-full bg-emerald-500/10 border border-emerald-500/20 flex items-center justify-center shrink-0">
        <Check className="w-3 h-3 text-emerald-400" />
      </div>
      <span className={highlight ? "text-white font-medium" : "text-slate-300"}>
        {text}
      </span>
    </li>
  );
}

export default function PricingPage() {
  return (
    <>
      <Navbar />

      <main className="bg-page relative selection:bg-violet-500/30 selection:text-violet-200">
        {/* Ambient Glows */}
        <div
          className="glow-orb glow-orb-primary top-[-100px] left-1/2 -translate-x-1/2 w-[600px] h-[400px]"
          aria-hidden="true"
        />
        <div
          className="glow-orb glow-orb-cyan top-[600px] right-[-100px] w-[500px] h-[400px]"
          aria-hidden="true"
        />

        <section className="relative z-10 pt-32 pb-24 md:pt-40 md:pb-32">
          <div className="container-page max-w-5xl">
            {/* Header */}
            <div className="text-center max-w-2xl mx-auto mb-16">
              <div className="label-tag mb-3">
                <Sparkles className="w-3.5 h-3.5 text-violet-400" />
                <span>Simple & Transparent</span>
              </div>
              <h1 className="text-4xl sm:text-6xl font-black text-white tracking-tight mb-4">
                Priced for teams, <br />
                <span className="text-gradient-accent">not corporations</span>
              </h1>
              <p className="text-slate-400 text-sm sm:text-base leading-relaxed">
                Whether you run a casual 5-a-side weekly kickabout or manage multiple competitive squads across weekend leagues.
              </p>
            </div>

            {/* Pricing Cards Grid */}
            <div className="grid grid-cols-1 md:grid-cols-2 gap-8 items-stretch mb-20">
              {/* Free Tier */}
              <div className="glass-card p-8 sm:p-10 flex flex-col justify-between">
                <div>
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-white/[0.04] border border-white/[0.08] text-xs font-semibold text-slate-300 mb-6">
                    <span>Casual Squads</span>
                  </div>

                  <h3 className="text-2xl font-bold text-white mb-2">Free Kick</h3>
                  <p className="text-sm text-slate-400 mb-6">
                    Essential expense tracking for casual weekly matches and friendly kickabouts.
                  </p>

                  <div className="flex items-baseline gap-2 mb-8 pb-6 border-b border-white/[0.08]">
                    <span className="text-5xl font-black text-white tracking-tight">$0</span>
                    <span className="text-xs text-slate-400 uppercase font-semibold tracking-wider">
                      / forever
                    </span>
                  </div>

                  <ul className="space-y-3.5 mb-8">
                    <FeatureItem text="Up to 3 active teams or groups" />
                    <FeatureItem text="Unlimited players per squad" />
                    <FeatureItem text="Standard equal expense splits" />
                    <FeatureItem text="Direct QR code banking settlements" />
                    <FeatureItem text="Real-time live squad balance ledger" />
                  </ul>
                </div>

                <Link
                  href="/#download"
                  className="btn-secondary w-full justify-center"
                >
                  Get Started Free
                </Link>
              </div>

              {/* Pro Tier */}
              <div className="glass-card-accent p-8 sm:p-10 rounded-3xl flex flex-col justify-between relative shadow-[0_20px_60px_rgba(139,92,246,0.25)]">
                {/* Popular Pill */}
                <div className="absolute -top-3.5 right-8">
                  <span className="px-3.5 py-1 rounded-full bg-gradient-to-r from-violet-600 to-cyan-400 text-[11px] font-bold text-white shadow-md tracking-wider uppercase">
                    Most Popular
                  </span>
                </div>

                <div>
                  <div className="inline-flex items-center gap-1.5 px-3 py-1 rounded-full bg-violet-500/20 border border-violet-500/40 text-xs font-semibold text-violet-300 mb-6">
                    <Zap className="w-3.5 h-3.5" />
                    <span>Competitive Clubs</span>
                  </div>

                  <h3 className="text-2xl font-bold text-white mb-2">Captain Pro</h3>
                  <p className="text-sm text-slate-300 mb-6">
                    Advanced splitting logic, international currencies, and automated reminders for club treasurers.
                  </p>

                  <div className="flex items-baseline gap-2 mb-8 pb-6 border-b border-white/[0.12]">
                    <span className="text-5xl font-black text-white tracking-tight">$4.99</span>
                    <span className="text-xs text-violet-300 uppercase font-semibold tracking-wider">
                      / month per squad
                    </span>
                  </div>

                  <ul className="space-y-3.5 mb-8">
                    <FeatureItem text="Unlimited active teams & tournaments" highlight />
                    <FeatureItem text="Advanced splits: Goalie Free & Minute Weights" highlight />
                    <FeatureItem text="Smart Graph Debt Minimizer (Cut debts 80%)" highlight />
                    <FeatureItem text="Multi-currency support (30+ auto-converted FX)" highlight />
                    <FeatureItem text="Exportable PDF & CSV treasurer reports" />
                    <FeatureItem text="Automated WhatsApp & SMS payment reminders" />
                  </ul>
                </div>

                <Link
                  href="/#download"
                  className="btn-primary w-full justify-center shadow-[0_4px_25px_rgba(139,92,246,0.5)]"
                >
                  <span>Start 14-Day Free Trial</span>
                  <ArrowRight className="w-4 h-4" />
                </Link>
              </div>
            </div>

            {/* Guarantees Strip */}
            <div className="glass-card p-6 rounded-2xl flex flex-col sm:flex-row items-center justify-between gap-4 text-xs text-slate-400">
              <div className="flex items-center gap-2">
                <ShieldCheck className="w-4 h-4 text-violet-400" />
                <span>30-Day Money-Back Guarantee. Cancel anytime without penalty.</span>
              </div>
              <div className="flex items-center gap-2">
                <HelpCircle className="w-4 h-4 text-cyan-400" />
                <Link href="/support" className="text-slate-300 hover:text-white underline">
                  Have questions about club licenses? Talk to us.
                </Link>
              </div>
            </div>
          </div>
        </section>

        <Footer />
      </main>
    </>
  );
}
