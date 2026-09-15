import Link from "next/link";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
export const metadata = {
  title: "MatchSplitter — Split Football Expenses Instantly",
  description:
    "Track football expenses, settle debts, and manage your team groups with zero hassle.",
};

const features = [
  {
    icon: "⚽",
    iconBg: "rgba(115,56,255,0.18)",
    title: "Football-First Splitting",
    body: "Designed for football groups — pitch costs, kit fees, travel, food — split any expense instantly with your team.",
  },
  {
    icon: "📊",
    iconBg: "rgba(29,212,240,0.15)",
    title: "Real-Time Balances",
    body: "See exactly who owes what across all your groups. Color-coded balances make it effortless to track debts at a glance.",
  },
  {
    icon: "📲",
    iconBg: "rgba(45,224,158,0.15)",
    title: "QR Code Join & Pay",
    body: "Share a QR code and teammates join your group instantly. Scan to pay — supports VietQR, PromptPay, PayPal and more.",
  },
  {
    icon: "🔄",
    iconBg: "rgba(255,176,32,0.15)",
    title: "Smart Settlements",
    body: "Our algorithm minimizes the number of payments needed. Settle up in seconds, not minutes.",
  },
  {
    icon: "📈",
    iconBg: "rgba(244,77,123,0.15)",
    title: "Spending Analytics",
    body: "Visualize your group spending by category. Know exactly where your money goes every match week.",
  },
  {
    icon: "🌍",
    iconBg: "rgba(115,56,255,0.18)",
    title: "Multi-Currency",
    body: "Play internationally? MatchSplitter handles multiple currencies automatically so your team is always in sync.",
  },
];

const steps = [
  {
    number: "01",
    title: "Create or Join a Group",
    body: "Set up a group for your team in seconds, or scan a QR code to join one instantly.",
  },
  {
    number: "02",
    title: "Log Any Expense",
    body: "Add pitch fees, food, transport — choose who paid and split equally or with custom amounts.",
  },
  {
    number: "03",
    title: "Settle Up",
    body: "View who owes who, then settle directly via your preferred payment method with a QR code.",
  },
];

const stats = [
  { number: "500+", label: "Groups Created", color: "var(--primary-light)" },
  { number: "12K+", label: "Expenses Tracked", color: "var(--secondary)" },
  { number: "3K+", label: "Friends Connected", color: "var(--success)" },
];

export default function Home() {
  return (
    <>
      {/* ── Navbar ── */}
      <Navbar />

      <main className="bg-page relative overflow-hidden">
        {/* Ambient blobs */}
        <div className="blob blob-1" aria-hidden="true" />
        <div className="blob blob-2" aria-hidden="true" />
        <div className="blob blob-3" aria-hidden="true" />

        {/* ── Hero ── */}
        <section className="relative z-10 section-padding">
          <div className="container-page text-center">
            {/* Label */}
            <div className="flex justify-center mb-6 animate-fade-up">
              <span className="label-tag">⚽ For Football Teams</span>
            </div>

            {/* Headline */}
            <h1
              className="animate-fade-up-delay-1"
              style={{
                fontSize: "clamp(2.5rem, 6vw, 5rem)",
                fontWeight: 900,
                letterSpacing: "-0.04em",
                lineHeight: 1.05,
                marginBottom: "1.5rem",
                color: "white",
              }}
            >
              Split Expenses.
              <br />
              <span className="text-gradient">Play Together.</span>
            </h1>

            {/* Subtext */}
            <p
              className="animate-fade-up-delay-2"
              style={{
                fontSize: "clamp(1rem, 2.5vw, 1.25rem)",
                color: "rgba(255,255,255,0.6)",
                maxWidth: "560px",
                margin: "0 auto 2.5rem",
                lineHeight: 1.7,
              }}
            >
              The only app built for football teams to track shared costs, settle
              debts, and manage groups — with zero spreadsheets.
            </p>

            {/* CTA Buttons */}
            <div
              className="animate-fade-up-delay-3"
              style={{
                display: "flex",
                flexWrap: "wrap",
                gap: "12px",
                justifyContent: "center",
                marginBottom: "3rem",
              }}
            >
              <Link href="#download" className="btn-primary pulse-glow">
                <span>🍎</span> Download on iOS
              </Link>
              <Link href="#features" className="btn-ghost">
                See Features →
              </Link>
            </div>

            {/* Badge strip */}
            <div
              className="animate-fade-up-delay-4"
              style={{
                display: "flex",
                flexWrap: "wrap",
                gap: "10px",
                justifyContent: "center",
              }}
            >
              {[
                "⚡ Instant Split",
                "📲 QR Pay",
                "🌍 Multi-Currency",
                "🔒 Private & Secure",
              ].map((badge) => (
                <span key={badge} className="hero-badge">
                  {badge}
                </span>
              ))}
            </div>
          </div>
        </section>

        {/* ── Features Grid ── */}
        <section id="features" className="relative z-10 section-padding">
          <div className="container-page">
            <div className="section-label">
              <span>Features</span>
            </div>
            <h2
              className="text-center"
              style={{
                fontSize: "clamp(1.75rem, 4vw, 2.75rem)",
                fontWeight: 800,
                letterSpacing: "-0.03em",
                marginBottom: "3.5rem",
                color: "white",
              }}
            >
              Everything your team{" "}
              <span className="text-gradient">actually needs</span>
            </h2>

            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(300px, 1fr))",
                gap: "20px",
              }}
            >
              {features.map((f) => (
                <div key={f.title} className="feature-card">
                  <div
                    className="feature-icon"
                    style={{ background: f.iconBg }}
                  >
                    {f.icon}
                  </div>
                  <h3
                    style={{
                      fontSize: "1.1rem",
                      fontWeight: 700,
                      color: "white",
                      marginBottom: "10px",
                      letterSpacing: "-0.01em",
                    }}
                  >
                    {f.title}
                  </h3>
                  <p
                    style={{
                      fontSize: "0.9375rem",
                      color: "rgba(255,255,255,0.55)",
                      lineHeight: 1.7,
                    }}
                  >
                    {f.body}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <div className="gradient-divider container-page" />

        {/* ── How It Works ── */}
        <section className="relative z-10 section-padding">
          <div className="container-page">
            <div className="section-label">
              <span>How It Works</span>
            </div>
            <h2
              className="text-center"
              style={{
                fontSize: "clamp(1.75rem, 4vw, 2.75rem)",
                fontWeight: 800,
                letterSpacing: "-0.03em",
                marginBottom: "3.5rem",
                color: "white",
              }}
            >
              Up and running in{" "}
              <span className="text-gradient">3 steps</span>
            </h2>

            <div
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(260px, 1fr))",
                gap: "32px",
              }}
            >
              {steps.map((step, i) => (
                <div
                  key={step.number}
                  className="glass-card"
                  style={{ padding: "32px 28px", position: "relative" }}
                >
                  {/* Connector line (desktop only) */}
                  {i < steps.length - 1 && (
                    <div
                      aria-hidden="true"
                      style={{
                        position: "absolute",
                        right: "-16px",
                        top: "40px",
                        width: "32px",
                        height: "2px",
                        background:
                          "linear-gradient(to right, rgba(115,56,255,0.5), rgba(29,212,240,0.3))",
                        display: "none",
                      }}
                    />
                  )}
                  <div className="step-number" style={{ marginBottom: "20px" }}>
                    {step.number}
                  </div>
                  <h3
                    style={{
                      fontSize: "1.1rem",
                      fontWeight: 700,
                      color: "white",
                      marginBottom: "10px",
                      letterSpacing: "-0.01em",
                    }}
                  >
                    {step.title}
                  </h3>
                  <p
                    style={{
                      fontSize: "0.9375rem",
                      color: "rgba(255,255,255,0.55)",
                      lineHeight: 1.7,
                    }}
                  >
                    {step.body}
                  </p>
                </div>
              ))}
            </div>
          </div>
        </section>

        <div className="gradient-divider container-page" />

        {/* ── Stats ── */}
        <section className="relative z-10 section-padding">
          <div className="container-page">
            <div
              className="accent-card"
              style={{
                display: "grid",
                gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))",
              }}
            >
              {stats.map((s, i) => (
                <div
                  key={s.label}
                  className="stat-card"
                  style={{
                    borderRight:
                      i < stats.length - 1
                        ? "1px solid rgba(255,255,255,0.07)"
                        : "none",
                  }}
                >
                  <div
                    className="stat-number shimmer-text"
                    style={{ color: s.color }}
                  >
                    {s.number}
                  </div>
                  <div className="stat-label">{s.label}</div>
                </div>
              ))}
            </div>
          </div>
        </section>

        {/* ── Download CTA ── */}
        <section id="download" className="relative z-10 section-padding">
          <div className="container-page text-center">
            <div
              className="glass-card"
              style={{
                padding: "clamp(40px, 8vw, 80px) clamp(24px, 6vw, 60px)",
                background:
                  "linear-gradient(135deg, rgba(115,56,255,0.15) 0%, rgba(29,212,240,0.06) 100%)",
                border: "1px solid rgba(115,56,255,0.25)",
                boxShadow: "0 30px 80px rgba(115,56,255,0.2)",
                position: "relative",
                overflow: "hidden",
              }}
            >
              {/* Background glow */}
              <div
                aria-hidden="true"
                style={{
                  position: "absolute",
                  top: "50%",
                  left: "50%",
                  transform: "translate(-50%,-50%)",
                  width: "400px",
                  height: "400px",
                  background:
                    "radial-gradient(circle, rgba(115,56,255,0.15) 0%, transparent 70%)",
                  pointerEvents: "none",
                }}
              />

              <div style={{ position: "relative", zIndex: 1 }}>
                <div
                  style={{
                    fontSize: "3rem",
                    marginBottom: "16px",
                    lineHeight: 1,
                  }}
                >
                  ⚽
                </div>
                <h2
                  style={{
                    fontSize: "clamp(1.75rem, 4vw, 2.75rem)",
                    fontWeight: 900,
                    letterSpacing: "-0.03em",
                    color: "white",
                    marginBottom: "14px",
                  }}
                >
                  Ready to split smarter?
                </h2>
                <p
                  style={{
                    fontSize: "1.0625rem",
                    color: "rgba(255,255,255,0.6)",
                    marginBottom: "36px",
                    maxWidth: "400px",
                    margin: "0 auto 36px",
                    lineHeight: 1.7,
                  }}
                >
                  Download MatchSplitter and get your team organized before the
                  next match.
                </p>

                <div
                  style={{
                    display: "flex",
                    flexWrap: "wrap",
                    gap: "14px",
                    justifyContent: "center",
                  }}
                >
                  <Link href="#" className="store-badge">
                    <span className="store-badge-icon">
                      <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor"><path d="M15.494 8.78c-.022 2.659 2.296 3.541 2.316 3.551-.018.061-.36 1.236-1.196 2.457-.723 1.054-1.488 2.097-2.656 2.118-1.149.02-1.524-.68-2.836-.68-1.31 0-1.724.66-2.815.702-1.13.04-2.001-1.144-2.73-2.195-1.498-2.161-2.645-6.103-1.118-8.751.758-1.312 2.097-2.14 3.565-2.16 1.109-.02 2.146.744 2.816.744.671 0 1.936-.897 3.287-.765 1.401.059 2.673.566 3.447 1.705-.03.018-2.059 1.199-2.08 3.274zm-2.28-5.32c.621-.75 1.041-1.791.927-2.83-.896.036-1.97.596-2.613 1.343-.574.664-1.077 1.733-.941 2.753.996.077 2.004-.51 2.627-1.266z" /></svg>
                    </span>
                    <div className="store-badge-text">
                      <small>Download on the</small>
                      <strong>App Store</strong>
                    </div>
                  </Link>
                  <Link href="#" className="store-badge">
                    <span className="store-badge-icon">
                      <svg viewBox="0 0 24 24" width="24" height="24" fill="currentColor"><path d="M19.67 11.23l-13.68-7.9c-1.18-.68-2.67.17-2.67 1.54v14.26c0 1.37 1.49 2.22 2.67 1.54l13.68-7.9c1.17-.68 1.17-2.86 0-3.54z" /></svg>
                    </span>
                    <div className="store-badge-text">
                      <small>Get it on</small>
                      <strong>Google Play</strong>
                    </div>
                  </Link>
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
