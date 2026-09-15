import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";

export const metadata = {
  title: "Pricing | MatchSplitter",
  description: "Simple, transparent pricing for your team.",
};

export default function PricingPage() {
  return (
    <>
      <Navbar />
      <main className="bg-page relative overflow-hidden" style={{ minHeight: "100vh" }}>
        {/* Ambient blobs */}
        <div className="blob blob-1" aria-hidden="true" />
        <div className="blob blob-2" aria-hidden="true" />

        <section className="relative z-10 section-padding" style={{ paddingTop: "120px" }}>
          <div className="container-page text-center">
            <span className="label-tag mb-6 animate-fade-up">Pricing</span>
            <h1 className="hero-title mb-6 animate-fade-up" style={{ animationDelay: "0.1s" }}>
              Simple pricing for <span>every team</span>
            </h1>
            <p className="hero-subtitle mx-auto animate-fade-up" style={{ animationDelay: "0.2s", maxWidth: "600px" }}>
              Whether you&apos;re a casual weekend squad or a serious Sunday League team, we have a plan for you.
            </p>

            <div 
              style={{ 
                display: "grid", 
                gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))", 
                gap: "32px", 
                marginTop: "64px",
                maxWidth: "900px",
                margin: "64px auto 0"
              }}
            >
              {/* Free Plan */}
              <div className="glass-card animate-fade-up" style={{ padding: "40px", textAlign: "left", animationDelay: "0.3s" }}>
                <h3 style={{ fontSize: "1.5rem", fontWeight: 700, color: "white", marginBottom: "8px" }}>Free</h3>
                <p style={{ color: "rgba(255,255,255,0.6)", marginBottom: "24px" }}>Perfect for casual friend groups.</p>
                <div style={{ display: "flex", alignItems: "baseline", gap: "8px", marginBottom: "32px" }}>
                  <span style={{ fontSize: "3rem", fontWeight: 800, color: "white" }}>$0</span>
                  <span style={{ color: "rgba(255,255,255,0.5)" }}>/ forever</span>
                </div>
                
                <ul style={{ listStyle: "none", padding: 0, margin: "0 0 40px 0", display: "flex", flexDirection: "column", gap: "16px" }}>
                  <FeatureItem text="Up to 3 active groups" />
                  <FeatureItem text="Unlimited members per group" />
                  <FeatureItem text="Basic expense tracking" />
                  <FeatureItem text="QR code settlements" />
                </ul>
                <button className="btn-ghost" style={{ width: "100%", justifyContent: "center" }}>
                  Get Started
                </button>
              </div>

              {/* Pro Plan */}
              <div 
                className="accent-card animate-fade-up" 
                style={{ 
                  padding: "40px", 
                  textAlign: "left", 
                  animationDelay: "0.4s",
                  border: "1px solid var(--primary-light)",
                  position: "relative"
                }}
              >
                <div style={{ position: "absolute", top: "-14px", right: "32px", background: "var(--primary-gradient)", color: "white", padding: "4px 16px", borderRadius: "100px", fontSize: "0.875rem", fontWeight: 700 }}>
                  POPULAR
                </div>
                <h3 style={{ fontSize: "1.5rem", fontWeight: 700, color: "white", marginBottom: "8px" }}>Premium Team</h3>
                <p style={{ color: "rgba(255,255,255,0.8)", marginBottom: "24px" }}>For teams that play every week.</p>
                <div style={{ display: "flex", alignItems: "baseline", gap: "8px", marginBottom: "32px" }}>
                  <span style={{ fontSize: "3rem", fontWeight: 800, color: "white" }}>$4</span>
                  <span style={{ color: "rgba(255,255,255,0.7)" }}>/ month</span>
                </div>
                
                <ul style={{ listStyle: "none", padding: 0, margin: "0 0 40px 0", display: "flex", flexDirection: "column", gap: "16px" }}>
                  <FeatureItem text="Unlimited active groups" />
                  <FeatureItem text="Advanced analytics & charts" />
                  <FeatureItem text="Recurring expenses" />
                  <FeatureItem text="Export to CSV / Excel" />
                  <FeatureItem text="Priority support" />
                </ul>
                <button className="btn-primary" style={{ width: "100%", justifyContent: "center" }}>
                  Start 14-Day Free Trial
                </button>
              </div>
            </div>
          </div>
        </section>

        <Footer />
      </main>
    </>
  );
}

function FeatureItem({ text }: { text: string }) {
  return (
    <li style={{ display: "flex", alignItems: "center", gap: "12px", color: "white" }}>
      <span style={{ color: "var(--success)" }}>✓</span>
      {text}
    </li>
  );
}
