import Link from "next/link";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { InteractiveCalculator } from "@/components/ui/InteractiveCalculator";
import {
  Activity,
  Split,
  QrCode,
  Zap,
  BarChart3,
  Globe,
  ShieldCheck,
  CheckCircle2,
  ArrowRight,
  Smartphone,
  Users,
  Receipt,
  Sparkles,
  Star,
  ChevronRight,
  CreditCard,
  Flame,
} from "lucide-react";

export const metadata = {
  title: "MatchSplitter — Split Football & Team Expenses Instantly",
  description:
    "Track football pitch costs, referee fees, kits, and post-match debts. Built for Sunday League and sports squads with instant QR settlements.",
};

const features = [
  {
    icon: Split,
    title: "Football-First Expense Engine",
    body: "Pre-configured for pitch rentals, referee payments, kit orders, and team drinks. Split equally, by minutes played, or custom shares.",
    badge: "Sports Specialized",
    wide: true,
  },
  {
    icon: Zap,
    title: "Debt Minimizer Algorithm",
    body: "Our graph optimization cuts 16 messy debts down to 3 simple transfers. Save your teammates time and eliminate group drama.",
    badge: "Smart Math",
    wide: false,
  },
  {
    icon: QrCode,
    title: "Instant QR Code Settlements",
    body: "Direct banking QR generation for PayOS, PromptPay, PayNow, and SEPA links. Teammates scan and pay in their banking app in 5 seconds.",
    badge: "Zero Friction",
    wide: false,
  },
  {
    icon: BarChart3,
    title: "Real-Time Squad Ledger",
    body: "Live balances show who paid, who owes, and who is settled. Color-coded debt statuses updated instantly via push notifications.",
    badge: "Live Sync",
    wide: false,
  },
  {
    icon: Globe,
    title: "Multi-Currency Tournaments",
    body: "Competing abroad or running an international tournament? Auto-convert exchange rates seamlessly across over 30 global currencies.",
    badge: "Global FX",
    wide: false,
  },
  {
    icon: ShieldCheck,
    title: "Private & Secure Architecture",
    body: "No intrusive bank credential requirements. Financial logs are strictly private to group members with end-to-end encryption.",
    badge: "Bank-Grade Privacy",
    wide: true,
  },
];

const steps = [
  {
    number: "01",
    title: "Create Squad or Scan QR",
    body: "Spin up a team group in seconds. Share an invite link or generate a join QR code on the pitch sidelines.",
    icon: Users,
  },
  {
    number: "02",
    title: "Log Any Match Expense",
    body: "Snap the pitch rental invoice, select who played, and let the algorithm calculate the exact split automatically.",
    icon: Receipt,
  },
  {
    number: "03",
    title: "Settle with 1 Tap",
    body: "Members tap to reveal payment QR codes directly inside their native mobile banking apps. Zero manual entry.",
    icon: QrCode,
  },
];

const stats = [
  { value: "$1.8M+", label: "Pitch & Match Costs Settled", icon: CreditCard },
  { value: "24,000+", label: "Matches & Tournaments Logged", icon: Flame },
  { value: "< 25s", label: "Average Settlement Speed", icon: Zap },
  { value: "4.9 / 5", label: "App Store Squad Rating", icon: Star },
];

const testimonials = [
  {
    quote:
      "Before MatchSplitter, chasing 14 guys for pitch hire took days of WhatsApp spam. Now everyone scans the QR code at the pub right after the final whistle.",
    author: "Marcus Vance",
    role: "Captain, North London Sunday League",
    team: "Hackney Strollers FC",
    rating: 5,
  },
  {
    quote:
      "The 'Goalie Plays Free' setting alone makes this the undisputed #1 app for grassroots football. Clean, dark UI and the smart debt minimizer is genius.",
    author: "Liam O'Connor",
    role: "Club Treasurer",
    team: "Celtic Futsal Academy",
    rating: 5,
  },
  {
    quote:
      "We took our squad to Barcelona for an international tournament. The multi-currency auto conversion saved us hours of currency conversion headaches.",
    author: "Daniel Reyes",
    role: "Squad Organizer",
    team: "Red Star 7s",
    rating: 5,
  },
];

/* ─── Mock Phone Card Component ─────────────────────────────────────────────── */
function HeroMockPhone() {
  return (
    <div className="relative w-full max-w-[380px] mx-auto">
      {/* Ambient glow behind device */}
      <div className="absolute inset-0 bg-gradient-to-tr from-violet-600/30 to-cyan-500/20 rounded-[36px] blur-2xl -z-10" />

      {/* Device Frame */}
      <div className="rounded-[32px] bg-[#0c101c] border border-white/[0.12] p-4 shadow-[0_25px_60px_-15px_rgba(0,0,0,0.9),inset_0_1px_0_0_rgba(255,255,255,0.15)] relative overflow-hidden">
        {/* Notch / Dynamic Island */}
        <div className="w-28 h-4 bg-[#05070a] rounded-full mx-auto mb-4 border border-white/[0.05]" />

        {/* App Topbar */}
        <div className="flex items-center justify-between pb-3 border-b border-white/[0.08] mb-4">
          <div className="flex items-center gap-2.5">
            <div className="w-8 h-8 rounded-lg bg-gradient-to-tr from-violet-600 to-cyan-400 flex items-center justify-center text-white shadow-sm">
              <Activity className="w-4 h-4" />
            </div>
            <div>
              <p className="text-xs font-bold text-white leading-tight">Sunday League 11s</p>
              <p className="text-[10px] text-slate-400">14 Squad Members</p>
            </div>
          </div>
          <span className="text-[10px] font-semibold px-2 py-0.5 rounded-full bg-emerald-500/10 text-emerald-400 border border-emerald-500/20">
            Active Match
          </span>
        </div>

        {/* Live Balance Banner */}
        <div className="bg-gradient-to-br from-violet-950/60 to-slate-900/90 border border-violet-500/30 rounded-xl p-3.5 mb-4 shadow-[0_4px_20px_rgba(139,92,246,0.15)]">
          <div className="flex justify-between items-center mb-1">
            <span className="text-[11px] font-medium text-slate-300">Your Net Balance</span>
            <span className="text-[10px] font-semibold text-violet-300">3 Owe You</span>
          </div>
          <div className="flex justify-between items-baseline">
            <span className="text-2xl font-black text-emerald-400">+$38.50</span>
            <button className="text-[10px] font-semibold px-2.5 py-1 bg-violet-600 hover:bg-violet-500 text-white rounded-lg transition-colors flex items-center gap-1 shadow-sm">
              <QrCode className="w-3 h-3" />
              <span>Show QR</span>
            </button>
          </div>
        </div>

        {/* Expense Feed List */}
        <div className="space-y-2 mb-4">
          <p className="text-[10px] font-bold text-slate-400 uppercase tracking-wider">
            Matchday Expenses
          </p>

          {[
            { title: "Turf Pitch Hire (90m)", payer: "Alex paid $140.00", split: "10 players", icon: "⚽" },
            { title: "Match Referee Fee", payer: "You paid $60.00", split: "10 players", icon: "⚖️" },
            { title: "Hydration & Energy", payer: "Sam paid $25.00", split: "8 players", icon: "🥤" },
          ].map((item, i) => (
            <div
              key={i}
              className="flex items-center justify-between p-2.5 rounded-lg bg-white/[0.03] border border-white/[0.05] hover:bg-white/[0.06] transition-colors"
            >
              <div className="flex items-center gap-2.5">
                <div className="w-7 h-7 rounded-md bg-white/[0.06] flex items-center justify-center text-xs">
                  {item.icon}
                </div>
                <div>
                  <p className="text-xs font-semibold text-slate-200 leading-tight">{item.title}</p>
                  <p className="text-[10px] text-slate-400">{item.payer}</p>
                </div>
              </div>
              <span className="text-[10px] font-medium text-slate-400 bg-white/[0.05] px-2 py-0.5 rounded">
                {item.split}
              </span>
            </div>
          ))}
        </div>

        {/* Bottom Floating Notification */}
        <div className="p-2 rounded-lg bg-emerald-500/10 border border-emerald-500/30 flex items-center gap-2">
          <CheckCircle2 className="w-4 h-4 text-emerald-400 shrink-0" />
          <p className="text-[10px] text-emerald-300 font-medium">
            PayOS Instant: Dave transferred $14.00
          </p>
        </div>
      </div>
    </div>
  );
}

/* ─── Main Homepage ─────────────────────────────────────────────────────────── */
export default function Home() {
  return (
    <>
      <Navbar />

      <main className="bg-page relative selection:bg-violet-500/30 selection:text-violet-200">
        {/* Background Ambient Glows */}
        <div
          className="glow-orb glow-orb-primary top-[-150px] left-1/2 -translate-x-1/2 w-[700px] h-[500px]"
          aria-hidden="true"
        />
        <div
          className="glow-orb glow-orb-cyan top-[500px] right-[-150px] w-[500px] h-[500px]"
          aria-hidden="true"
        />

        {/* ════════════════════ HERO SECTION ════════════════════ */}
        <section className="relative z-10 pt-32 pb-20 md:pt-40 md:pb-28">
          <div className="container-page">
            <div className="grid grid-cols-1 lg:grid-cols-12 gap-12 lg:gap-8 items-center">
              {/* Left Copy */}
              <div className="lg:col-span-7 space-y-6 text-center lg:text-left">
                {/* Pill Tag */}
                <div className="inline-flex">
                  <div className="label-tag">
                    <Activity className="w-3.5 h-3.5 text-violet-400" />
                    <span>Engineered for Football & Sports Teams</span>
                  </div>
                </div>

                {/* Main Heading */}
                <h1 className="text-4xl sm:text-6xl lg:text-7xl font-black tracking-tight text-white leading-[1.1]">
                  Split Expenses. <br />
                  <span className="text-gradient-accent">Play Together.</span>
                </h1>

                {/* Subtitle */}
                <p className="text-base sm:text-lg text-slate-400 max-w-xl mx-auto lg:mx-0 leading-relaxed">
                  The automated team ledger built specifically for football squads. Track pitch fees,
                  referee payouts, and post-match rounds with seamless QR bank settlements. Zero spreadsheets.
                </p>

                {/* CTAs */}
                <div className="pt-2 flex flex-col sm:flex-row items-center justify-center lg:justify-start gap-4">
                  <Link href="#download" className="btn-primary w-full sm:w-auto">
                    <Smartphone className="w-4 h-4" />
                    <span>Download on iOS</span>
                    <ArrowRight className="w-4 h-4" />
                  </Link>
                  <Link href="#calculator" className="btn-secondary w-full sm:w-auto">
                    <Sparkles className="w-4 h-4 text-violet-400" />
                    <span>Try Split Simulator</span>
                  </Link>
                </div>

                {/* Feature Chips */}
                <div className="pt-4 flex flex-wrap items-center justify-center lg:justify-start gap-2.5 text-xs text-slate-400">
                  <span className="px-3 py-1 rounded-md bg-white/[0.03] border border-white/[0.06] flex items-center gap-1.5">
                    <Zap className="w-3.5 h-3.5 text-violet-400" /> Instant Splits
                  </span>
                  <span className="px-3 py-1 rounded-md bg-white/[0.03] border border-white/[0.06] flex items-center gap-1.5">
                    <QrCode className="w-3.5 h-3.5 text-cyan-400" /> PayOS & PromptPay
                  </span>
                  <span className="px-3 py-1 rounded-md bg-white/[0.03] border border-white/[0.06] flex items-center gap-1.5">
                    <Globe className="w-3.5 h-3.5 text-emerald-400" /> Multi-Currency
                  </span>
                  <span className="px-3 py-1 rounded-md bg-white/[0.03] border border-white/[0.06] flex items-center gap-1.5">
                    <ShieldCheck className="w-3.5 h-3.5 text-violet-400" /> 100% Private
                  </span>
                </div>
              </div>

              {/* Right: Phone Mockup */}
              <div className="lg:col-span-5 flex justify-center">
                <HeroMockPhone />
              </div>
            </div>
          </div>
        </section>

        {/* ════════════════════ INTERACTIVE SIMULATOR ════════════════════ */}
        <section id="calculator" className="relative z-10 section-padding border-t border-white/[0.06]">
          <div className="container-page max-w-4xl">
            <div className="text-center mb-10">
              <div className="label-tag-cyan mb-3">Live Playground</div>
              <h2 className="text-3xl sm:text-4xl font-black text-white tracking-tight mb-3">
                Experience the difference
              </h2>
              <p className="text-sm sm:text-base text-slate-400 max-w-lg mx-auto">
                No more confusing group messages or unreturned cash. See how cleanly MatchSplitter divides match fees.
              </p>
            </div>

            <InteractiveCalculator />
          </div>
        </section>

        {/* ════════════════════ STATS STRIP ════════════════════ */}
        <section className="relative z-10 py-12 border-y border-white/[0.06] bg-white/[0.01]">
          <div className="container-page">
            <div className="grid grid-cols-2 lg:grid-cols-4 gap-6 text-center">
              {stats.map((s, i) => {
                const IconComponent = s.icon;
                return (
                  <div key={i} className="p-4">
                    <div className="w-8 h-8 rounded-lg bg-violet-500/10 border border-violet-500/20 flex items-center justify-center text-violet-400 mx-auto mb-3">
                      <IconComponent className="w-4 h-4" />
                    </div>
                    <div className="text-2xl sm:text-3xl font-black text-white tracking-tight mb-1">
                      {s.value}
                    </div>
                    <div className="text-xs text-slate-400 font-medium">{s.label}</div>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* ════════════════════ BENTO GRID FEATURES ════════════════════ */}
        <section id="features" className="relative z-10 section-padding">
          <div className="container-page">
            <div className="text-center max-w-2xl mx-auto mb-16">
              <div className="label-tag mb-3">Built For Squads</div>
              <h2 className="text-3xl sm:text-5xl font-black text-white tracking-tight mb-4">
                Everything your squad <br />
                <span className="text-gradient-accent">actually needs</span>
              </h2>
              <p className="text-slate-400 text-sm sm:text-base leading-relaxed">
                Generic split apps don&apos;t know the difference between a goalkeeper playing free and a sub playing 20 minutes. MatchSplitter does.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 gap-6">
              {features.map((f, i) => {
                const IconComponent = f.icon;
                return (
                  <div
                    key={i}
                    className={`glass-card p-6 sm:p-8 flex flex-col justify-between group ${
                      f.wide ? "md:col-span-2 lg:col-span-2" : ""
                    }`}
                  >
                    <div>
                      <div className="flex items-center justify-between mb-5">
                        <div className="w-10 h-10 rounded-xl bg-violet-500/10 border border-violet-500/20 flex items-center justify-center text-violet-300 group-hover:scale-110 group-hover:bg-violet-500/20 transition-all">
                          <IconComponent className="w-5 h-5" />
                        </div>
                        <span className="text-[11px] font-semibold text-slate-400 bg-white/[0.04] border border-white/[0.08] px-2.5 py-1 rounded-full">
                          {f.badge}
                        </span>
                      </div>

                      <h3 className="text-lg sm:text-xl font-bold text-white mb-2.5 tracking-tight group-hover:text-violet-300 transition-colors">
                        {f.title}
                      </h3>
                      <p className="text-sm text-slate-400 leading-relaxed">
                        {f.body}
                      </p>
                    </div>

                    <div className="pt-6 mt-6 border-t border-white/[0.06] flex items-center gap-1.5 text-xs font-semibold text-violet-400 opacity-0 group-hover:opacity-100 transition-opacity">
                      <span>Learn more</span>
                      <ChevronRight className="w-3.5 h-3.5" />
                    </div>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* ════════════════════ HOW IT WORKS ════════════════════ */}
        <section id="how-it-works" className="relative z-10 section-padding border-t border-white/[0.06]">
          <div className="container-page">
            <div className="text-center max-w-xl mx-auto mb-16">
              <div className="label-tag-cyan mb-3">Simple Process</div>
              <h2 className="text-3xl sm:text-4xl font-black text-white tracking-tight mb-4">
                Settle up in 3 simple steps
              </h2>
              <p className="text-slate-400 text-sm sm:text-base">
                From pitch checkout to bank transfer receipt in under 60 seconds.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
              {steps.map((step, idx) => {
                const StepIcon = step.icon;
                return (
                  <div
                    key={idx}
                    className="glass-card p-6 sm:p-8 relative group"
                  >
                    <div className="flex items-center justify-between mb-6">
                      <span className="text-2xl font-black text-transparent bg-clip-text bg-gradient-to-r from-violet-400 to-cyan-300">
                        {step.number}
                      </span>
                      <div className="w-10 h-10 rounded-xl bg-white/[0.04] border border-white/[0.08] flex items-center justify-center text-slate-300">
                        <StepIcon className="w-5 h-5" />
                      </div>
                    </div>

                    <h3 className="text-lg font-bold text-white mb-2.5 tracking-tight">
                      {step.title}
                    </h3>
                    <p className="text-sm text-slate-400 leading-relaxed">
                      {step.body}
                    </p>
                  </div>
                );
              })}
            </div>
          </div>
        </section>

        {/* ════════════════════ TESTIMONIALS ════════════════════ */}
        <section className="relative z-10 section-padding border-t border-white/[0.06]">
          <div className="container-page">
            <div className="text-center max-w-xl mx-auto mb-16">
              <div className="label-tag mb-3">Verified Teams</div>
              <h2 className="text-3xl sm:text-4xl font-black text-white tracking-tight mb-4">
                Trusted by 500+ Grassroots Squads
              </h2>
              <p className="text-slate-400 text-sm sm:text-base">
                Here is why captains and treasurers refuse to manage match fees any other way.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-3 gap-6">
              {testimonials.map((t, idx) => (
                <div
                  key={idx}
                  className="glass-card p-6 sm:p-7 flex flex-col justify-between"
                >
                  <div>
                    {/* Stars */}
                    <div className="flex gap-1 text-amber-400 mb-4">
                      {Array.from({ length: t.rating }).map((_, si) => (
                        <Star key={si} className="w-4 h-4 fill-amber-400" />
                      ))}
                    </div>

                    <p className="text-sm text-slate-300 leading-relaxed mb-6 italic">
                      &ldquo;{t.quote}&rdquo;
                    </p>
                  </div>

                  <div className="pt-4 border-t border-white/[0.06] flex items-center gap-3">
                    <div className="w-9 h-9 rounded-full bg-gradient-to-tr from-violet-600 to-cyan-400 flex items-center justify-center text-white font-bold text-xs">
                      {t.author.charAt(0)}
                    </div>
                    <div>
                      <h4 className="text-xs font-bold text-white">{t.author}</h4>
                      <p className="text-[11px] text-slate-400">{t.role} • {t.team}</p>
                    </div>
                  </div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ════════════════════ DOWNLOAD CTA ════════════════════ */}
        <section id="download" className="relative z-10 section-padding border-t border-white/[0.06]">
          <div className="container-page max-w-4xl">
            <div className="glass-card-accent p-8 sm:p-14 rounded-3xl text-center relative overflow-hidden">
              {/* Center glow */}
              <div className="absolute top-1/2 left-1/2 -translate-x-1/2 -translate-y-1/2 w-96 h-96 bg-violet-600/20 rounded-full blur-3xl pointer-events-none" />

              <div className="relative z-10 max-w-xl mx-auto space-y-6">
                <div className="inline-flex">
                  <span className="label-tag">
                    <Smartphone className="w-3.5 h-3.5 text-violet-400" />
                    Available on iOS & Android
                  </span>
                </div>

                <h2 className="text-3xl sm:text-5xl font-black text-white tracking-tight leading-tight">
                  Ready to never chase <br />
                  <span className="text-gradient-accent">pitch fees again?</span>
                </h2>

                <p className="text-sm sm:text-base text-slate-300 leading-relaxed">
                  Download MatchSplitter today and set up your team group before this weekend&apos;s kickoff.
                </p>

                <div className="pt-4 flex flex-col sm:flex-row items-center justify-center gap-4">
                  <a
                    href="#"
                    className="btn-primary w-full sm:w-auto"
                  >
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                      <path d="M15.494 8.78c-.022 2.659 2.296 3.541 2.316 3.551-.018.061-.36 1.236-1.196 2.457-.723 1.054-1.488 2.097-2.656 2.118-1.149.02-1.524-.68-2.836-.68-1.31 0-1.724.66-2.815.702-1.13.04-2.001-1.144-2.73-2.195-1.498-2.161-2.645-6.103-1.118-8.751.758-1.312 2.097-2.14 3.565-2.16 1.109-.02 2.146.744 2.816.744.671 0 1.936-.897 3.287-.765 1.401.059 2.673.566 3.447 1.705-.03.018-2.059 1.199-2.08 3.274zm-2.28-5.32c.621-.75 1.041-1.791.927-2.83-.896.036-1.97.596-2.613 1.343-.574.664-1.077 1.733-.941 2.753.996.077 2.004-.51 2.627-1.266z" />
                    </svg>
                    <span>Download on App Store</span>
                  </a>
                  <a
                    href="#"
                    className="btn-secondary w-full sm:w-auto"
                  >
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="currentColor">
                      <path d="M19.67 11.23l-13.68-7.9c-1.18-.68-2.67.17-2.67 1.54v14.26c0 1.37 1.49 2.22 2.67 1.54l13.68-7.9c1.17-.68 1.17-2.86 0-3.54z" />
                    </svg>
                    <span>Get on Google Play</span>
                  </a>
                </div>

                <div className="pt-2 flex items-center justify-center gap-6 text-xs text-slate-400">
                  <span className="flex items-center gap-1.5">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" /> Free Forever Plan
                  </span>
                  <span className="flex items-center gap-1.5">
                    <CheckCircle2 className="w-3.5 h-3.5 text-emerald-400" /> No Card Required
                  </span>
                </div>
              </div>
            </div>
          </div>
        </section>

        <Footer />
      </main>
    </>
  );
}
