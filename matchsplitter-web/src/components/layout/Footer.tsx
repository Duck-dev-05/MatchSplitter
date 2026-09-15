import Link from "next/link";

export function Footer() {
  return (
    <footer
      className="relative z-10"
      style={{
        borderTop: "1px solid rgba(255,255,255,0.06)",
        padding: "32px 0",
      }}
    >
      <div className="container-page">
        <div
          style={{
            display: "flex",
            flexWrap: "wrap",
            alignItems: "center",
            justifyContent: "space-between",
            gap: "16px",
          }}
        >
          <Link href="/" className="navbar-logo">
            <div className="navbar-logo-icon" style={{ width: 28, height: 28, fontSize: 14, borderRadius: 8 }}>⚽</div>
            <span className="navbar-brand" style={{ fontSize: "0.95rem" }}>
              Match<span>Splitter</span>
            </span>
          </Link>

          <div style={{ display: "flex", flexWrap: "wrap", gap: "24px" }}>
            <Link href="/#features" className="footer-link">
              Features
            </Link>
            <Link href="/pricing" className="footer-link">
              Pricing
            </Link>
            <Link href="/faq" className="footer-link">
              FAQ
            </Link>
            <Link href="/support" className="footer-link">
              Support
            </Link>
            <Link href="/#download" className="footer-link">
              Download
            </Link>
          </div>

          <p
            style={{
              fontSize: "0.8125rem",
              color: "rgba(255,255,255,0.3)",
            }}
          >
            © {new Date().getFullYear()} MatchSplitter. All rights reserved.
          </p>
        </div>
      </div>
    </footer>
  );
}
