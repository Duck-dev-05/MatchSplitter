import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";

export const metadata = {
  title: "Support | MatchSplitter",
  description: "Get help with MatchSplitter.",
};

export default function SupportPage() {
  return (
    <>
      <Navbar />
      <main className="bg-page relative overflow-hidden" style={{ minHeight: "100vh" }}>
        {/* Ambient blobs */}
        <div className="blob blob-2" aria-hidden="true" />
        <div className="blob blob-3" aria-hidden="true" />

        <section className="relative z-10 section-padding" style={{ paddingTop: "120px" }}>
          <div className="container-page" style={{ maxWidth: "600px" }}>
            <div className="text-center mb-10 animate-fade-up">
              <span className="label-tag mb-6">Contact Us</span>
              <h1 className="hero-title mb-4">
                How can we <span>help?</span>
              </h1>
              <p className="hero-subtitle">
                Found a bug? Have a feature request? Let us know.
              </p>
            </div>

            <form className="glass-card animate-fade-up" style={{ padding: "40px", animationDelay: "0.2s" }}>
              <div style={{ display: "flex", flexDirection: "column", gap: "24px" }}>
                
                <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                  <label htmlFor="name" style={{ color: "rgba(255,255,255,0.8)", fontSize: "0.875rem", fontWeight: 600 }}>Name</label>
                  <input 
                    type="text" 
                    id="name"
                    placeholder="John Doe"
                    style={{
                      background: "rgba(255,255,255,0.03)",
                      border: "1px solid rgba(255,255,255,0.1)",
                      borderRadius: "12px",
                      padding: "12px 16px",
                      color: "white",
                      outline: "none",
                      transition: "all 0.2s ease"
                    }}
                    onFocus={(e) => {
                      e.currentTarget.style.borderColor = "var(--primary-light)";
                      e.currentTarget.style.boxShadow = "0 0 0 4px rgba(115,56,255,0.15)";
                    }}
                    onBlur={(e) => {
                      e.currentTarget.style.borderColor = "rgba(255,255,255,0.1)";
                      e.currentTarget.style.boxShadow = "none";
                    }}
                  />
                </div>

                <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                  <label htmlFor="email" style={{ color: "rgba(255,255,255,0.8)", fontSize: "0.875rem", fontWeight: 600 }}>Email Address</label>
                  <input 
                    type="email" 
                    id="email"
                    placeholder="john@example.com"
                    style={{
                      background: "rgba(255,255,255,0.03)",
                      border: "1px solid rgba(255,255,255,0.1)",
                      borderRadius: "12px",
                      padding: "12px 16px",
                      color: "white",
                      outline: "none",
                      transition: "all 0.2s ease"
                    }}
                    onFocus={(e) => {
                      e.currentTarget.style.borderColor = "var(--primary-light)";
                      e.currentTarget.style.boxShadow = "0 0 0 4px rgba(115,56,255,0.15)";
                    }}
                    onBlur={(e) => {
                      e.currentTarget.style.borderColor = "rgba(255,255,255,0.1)";
                      e.currentTarget.style.boxShadow = "none";
                    }}
                  />
                </div>

                <div style={{ display: "flex", flexDirection: "column", gap: "8px" }}>
                  <label htmlFor="message" style={{ color: "rgba(255,255,255,0.8)", fontSize: "0.875rem", fontWeight: 600 }}>Message</label>
                  <textarea 
                    id="message"
                    rows={5}
                    placeholder="How can we help you today?"
                    style={{
                      background: "rgba(255,255,255,0.03)",
                      border: "1px solid rgba(255,255,255,0.1)",
                      borderRadius: "12px",
                      padding: "12px 16px",
                      color: "white",
                      outline: "none",
                      transition: "all 0.2s ease",
                      resize: "vertical"
                    }}
                    onFocus={(e) => {
                      e.currentTarget.style.borderColor = "var(--primary-light)";
                      e.currentTarget.style.boxShadow = "0 0 0 4px rgba(115,56,255,0.15)";
                    }}
                    onBlur={(e) => {
                      e.currentTarget.style.borderColor = "rgba(255,255,255,0.1)";
                      e.currentTarget.style.boxShadow = "none";
                    }}
                  />
                </div>

                <button type="button" className="btn-primary" style={{ justifyContent: "center", marginTop: "8px" }}>
                  Send Message
                </button>
              </div>
            </form>
          </div>
        </section>

        <Footer />
      </main>
    </>
  );
}
