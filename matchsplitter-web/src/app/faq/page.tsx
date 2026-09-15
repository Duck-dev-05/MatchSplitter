import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { Accordion } from "@/components/ui/Accordion";

export const metadata = {
  title: "FAQ | MatchSplitter",
  description: "Frequently asked questions about MatchSplitter.",
};

const faqs = [
  {
    question: "How much does MatchSplitter cost?",
    answer: "MatchSplitter is free to download and use for basic expense tracking. We offer a Premium Team plan for advanced features like automated recurring payments and detailed analytics exports.",
  },
  {
    question: "Do my teammates need the app to join my group?",
    answer: "Yes, to track and settle balances properly, your teammates will need to download the app and join via your invite link or QR code.",
  },
  {
    question: "What payment methods are supported?",
    answer: "MatchSplitter currently supports QR-based settlements including VietQR, PromptPay, PayNow, and standard PayPal links. We do not process payments directly; we generate the exact QR code so your friends can pay you through their banking app.",
  },
  {
    question: "Can I use multiple currencies in one group?",
    answer: "Yes! MatchSplitter automatically handles currency conversions based on real-time exchange rates, so you can track expenses on international trips effortlessly.",
  },
  {
    question: "Is my data secure?",
    answer: "Absolutely. We use industry-standard encryption for all data in transit and at rest. Your financial tracking data is strictly private to your group members.",
  },
];

export default function FAQPage() {
  return (
    <>
      <Navbar />
      <main className="bg-page relative overflow-hidden" style={{ minHeight: "100vh" }}>
        {/* Ambient blobs */}
        <div className="blob blob-1" aria-hidden="true" />
        <div className="blob blob-3" aria-hidden="true" />

        <section className="relative z-10 section-padding" style={{ paddingTop: "120px" }}>
          <div className="container-page" style={{ maxWidth: "800px" }}>
            <div className="text-center mb-12 animate-fade-up">
              <span className="label-tag mb-6">Need Help?</span>
              <h1 className="hero-title mb-6">
                Frequently Asked <span>Questions</span>
              </h1>
              <p className="hero-subtitle">
                Everything you need to know about the app, payments, and splitting costs with your team.
              </p>
            </div>

            <div className="animate-fade-up" style={{ animationDelay: "0.2s" }}>
              <Accordion items={faqs} />
            </div>
            
            <div className="text-center mt-16 animate-fade-up" style={{ animationDelay: "0.4s" }}>
              <p style={{ color: "rgba(255,255,255,0.6)", marginBottom: "16px" }}>
                Still have questions?
              </p>
              <a href="/support" className="btn-primary" style={{ display: "inline-flex" }}>
                Contact Support
              </a>
            </div>
          </div>
        </section>

        <Footer />
      </main>
    </>
  );
}
