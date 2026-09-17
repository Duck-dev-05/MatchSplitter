import Link from "next/link";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { Accordion } from "@/components/ui/Accordion";
import { HelpCircle, MessageSquare, ArrowRight, ShieldCheck } from "lucide-react";

export const metadata = {
  title: "Frequently Asked Questions | MatchSplitter",
  description:
    "Find answers to common questions about team expense management, bank QR code settlements, and group permissions.",
};

const faqs = [
  {
    question: "How does the QR Code settlement work with banking apps?",
    answer:
      "MatchSplitter integrates standard dynamic QR protocols (PayOS, PromptPay, PayNow, and SEPA links). When you settle up, the app generates a QR containing the exact debt amount and payment reference. Your teammate scans it with their mobile banking app to authenticate and complete the transfer in seconds.",
  },
  {
    question: "Do all squad players need to download the app to participate?",
    answer:
      "Only the organizers/captains logging expenses need the full app. Teammates can be added as offline roster members, or they can join via a simple web invite link to view balances and scan payment QRs directly from any browser without installing anything.",
  },
  {
    question: "How does the Goalkeeper Plays Free feature work?",
    answer:
      "It is a grassroots football staple! In many squads, the goalkeeper does not pay pitch fees. MatchSplitter has a one-tap toggle for each match that automatically excludes the goalkeeper from the pitch cost division and splits it equally among the outfield players.",
  },
  {
    question: "What is the Smart Debt Minimizer algorithm?",
    answer:
      "If player A owes player B $10, and player B owes player C $10, our graph optimizer settles the chain directly (Player A pays Player C $10). In a squad of 15 players with dozens of fragmented payments, this reduces transfers by up to 80%, meaning far fewer banking transactions for everyone.",
  },
  {
    question: "Can we use multiple currencies for international friendly tours?",
    answer:
      "Yes. Pro squads can create groups with multi-currency enabled. You can log expenses in EUR, GBP, USD, THB, or VND, and the app automatically converts debts back to your squad's primary currency using real-time exchange rates.",
  },
  {
    question: "Is financial and personal data protected?",
    answer:
      "Completely. MatchSplitter does not require or store your bank credentials, passwords, or credit card numbers. All team ledger data is encrypted in transit and at rest, and group financial records are strictly private to your verified group members.",
  },
];

export default function FAQPage() {
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
          className="glow-orb glow-orb-cyan top-[500px] right-[-100px] w-[500px] h-[400px]"
          aria-hidden="true"
        />

        <section className="relative z-10 pt-32 pb-24 md:pt-40 md:pb-32">
          <div className="container-page max-w-4xl">
            {/* Header */}
            <div className="text-center max-w-2xl mx-auto mb-16">
              <div className="label-tag mb-3">
                <HelpCircle className="w-3.5 h-3.5 text-violet-400" />
                <span>Knowledge Base</span>
              </div>
              <h1 className="text-4xl sm:text-6xl font-black text-white tracking-tight mb-4">
                Frequently Asked <br />
                <span className="text-gradient-accent">Questions</span>
              </h1>
              <p className="text-slate-400 text-sm sm:text-base leading-relaxed">
                Everything you need to know about payments, squad balances, and matchday expense tracking.
              </p>
            </div>

            {/* Accordion Component */}
            <div className="mb-16">
              <Accordion items={faqs} />
            </div>

            {/* Need More Help Box */}
            <div className="glass-card-accent p-8 rounded-2xl flex flex-col sm:flex-row items-center justify-between gap-6">
              <div className="flex items-center gap-4 text-left">
                <div className="w-12 h-12 rounded-xl bg-violet-500/20 border border-violet-500/40 flex items-center justify-center text-violet-300 shrink-0">
                  <MessageSquare className="w-6 h-6" />
                </div>
                <div>
                  <h3 className="text-lg font-bold text-white mb-1">
                    Still have questions?
                  </h3>
                  <p className="text-xs sm:text-sm text-slate-300">
                    Our team is here to help with squad setup, custom club plans, and feature requests.
                  </p>
                </div>
              </div>

              <Link
                href="/support"
                className="btn-primary shrink-0 w-full sm:w-auto"
              >
                <span>Contact Support</span>
                <ArrowRight className="w-4 h-4" />
              </Link>
            </div>

            <div className="mt-12 text-center flex items-center justify-center gap-2 text-xs text-slate-500">
              <ShieldCheck className="w-4 h-4 text-violet-400" />
              <span>Verified FAQ documentation updated for version 2.4</span>
            </div>
          </div>
        </section>

        <Footer />
      </main>
    </>
  );
}
