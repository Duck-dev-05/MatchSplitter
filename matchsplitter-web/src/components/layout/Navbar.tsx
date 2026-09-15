import Link from "next/link";

export function Navbar() {
  return (
    <nav className="navbar">
      <Link href="/" className="navbar-logo">
        <div className="navbar-logo-icon">⚽</div>
        <span className="navbar-brand">
          Match<span>Splitter</span>
        </span>
      </Link>
      <div style={{ display: "flex", gap: "12px", alignItems: "center" }}>
        <Link href="/pricing" className="footer-link" style={{ marginRight: "12px" }}>
          Pricing
        </Link>
        <Link href="/faq" className="footer-link" style={{ marginRight: "12px" }}>
          FAQ
        </Link>
        <Link href="/support" className="footer-link" style={{ marginRight: "16px" }}>
          Support
        </Link>
        <Link href="/#download" className="btn-primary btn-sm">
          Download App
        </Link>
      </div>
    </nav>
  );
}
