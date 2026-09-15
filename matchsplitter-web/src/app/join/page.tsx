"use client";

import { useEffect, useState } from "react";
import { useSearchParams } from "next/navigation";
import Link from "next/link";
import { Suspense } from "react";
import { Navbar } from "@/components/layout/Navbar";

function JoinContent() {
  const searchParams = useSearchParams();
  const id = searchParams.get("id");
  const [status, setStatus] = useState<"loading" | "redirected" | "failed">(
    "loading"
  );

  useEffect(() => {
    if (!id) {
      setStatus("failed");
      return;
    }
    const appScheme = `matchsplitter://join?id=${id}`;
    window.location.href = appScheme;
    const timeout = setTimeout(() => setStatus("redirected"), 2500);
    return () => clearTimeout(timeout);
  }, [id]);

  if (status === "loading") {
    return (
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          padding: "48px 32px",
          gap: "24px",
        }}
      >
        {/* Gradient spinner */}
        <div style={{ position: "relative", width: 80, height: 80 }}>
          <div
            className="join-spinner"
            style={{ width: 80, height: 80 }}
            role="status"
            aria-label="Loading"
          />
          {/* Inner icon */}
          <div
            style={{
              position: "absolute",
              inset: 0,
              display: "flex",
              alignItems: "center",
              justifyContent: "center",
              fontSize: "1.5rem",
            }}
          >
            ⚽
          </div>
        </div>
        <div style={{ textAlign: "center" }}>
          <h2
            style={{
              fontSize: "1.375rem",
              fontWeight: 800,
              color: "white",
              marginBottom: "8px",
              letterSpacing: "-0.02em",
            }}
          >
            Opening MatchSplitter…
          </h2>
          <p style={{ color: "rgba(255,255,255,0.5)", fontSize: "0.9375rem" }}>
            Redirecting you to the app
          </p>
        </div>
      </div>
    );
  }

  if (status === "failed") {
    return (
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          alignItems: "center",
          padding: "48px 32px",
          textAlign: "center",
          gap: "20px",
        }}
      >
        {/* Error icon */}
        <div
          style={{
            width: 72,
            height: 72,
            borderRadius: "50%",
            background: "rgba(244,77,123,0.15)",
            border: "1px solid rgba(244,77,123,0.3)",
            display: "flex",
            alignItems: "center",
            justifyContent: "center",
            fontSize: "2rem",
          }}
        >
          ⚠️
        </div>
        <div>
          <h2
            style={{
              fontSize: "1.375rem",
              fontWeight: 800,
              color: "white",
              marginBottom: "10px",
              letterSpacing: "-0.02em",
            }}
          >
            Invalid Invite Link
          </h2>
          <p
            style={{
              color: "rgba(255,255,255,0.55)",
              fontSize: "0.9375rem",
              lineHeight: 1.6,
              maxWidth: "320px",
            }}
          >
            This invite link appears to be broken or missing the group ID. Ask
            your teammate for a new link.
          </p>
        </div>
        <Link href="/" className="btn-primary" style={{ marginTop: "8px" }}>
          ← Go Home
        </Link>
      </div>
    );
  }

  // Redirected state
  return (
    <div
      style={{
        display: "flex",
        flexDirection: "column",
        alignItems: "center",
        padding: "40px 32px",
        textAlign: "center",
        gap: "20px",
      }}
    >
      {/* App icon */}
      <div
        style={{
          width: 88,
          height: 88,
          borderRadius: "22px",
          background: "linear-gradient(135deg, #7338ff, #1dd4f0)",
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          fontSize: "2.5rem",
          boxShadow: "0 12px 40px rgba(115,56,255,0.45)",
        }}
      >
        ⚽
      </div>

      <div>
        <h2
          style={{
            fontSize: "1.5rem",
            fontWeight: 800,
            color: "white",
            marginBottom: "10px",
            letterSpacing: "-0.02em",
          }}
        >
          Join the Group
        </h2>
        <p
          style={{
            color: "rgba(255,255,255,0.55)",
            fontSize: "0.9375rem",
            lineHeight: 1.6,
            maxWidth: "300px",
          }}
        >
          Don&apos;t have MatchSplitter yet? Download the app to join this
          expense group.
        </p>
      </div>

      {/* Download button */}
      <div
        style={{
          display: "flex",
          flexDirection: "column",
          gap: "12px",
          width: "100%",
          maxWidth: "320px",
        }}
      >
        <Link href="#" className="btn-primary" style={{ justifyContent: "center", display: "flex", alignItems: "center", gap: "8px" }}>
          <svg viewBox="0 0 24 24" width="20" height="20" fill="currentColor" style={{ display: "block" }}>
            <path d="M15.494 8.78c-.022 2.659 2.296 3.541 2.316 3.551-.018.061-.36 1.236-1.196 2.457-.723 1.054-1.488 2.097-2.656 2.118-1.149.02-1.524-.68-2.836-.68-1.31 0-1.724.66-2.815.702-1.13.04-2.001-1.144-2.73-2.195-1.498-2.161-2.645-6.103-1.118-8.751.758-1.312 2.097-2.14 3.565-2.16 1.109-.02 2.146.744 2.816.744.671 0 1.936-.897 3.287-.765 1.401.059 2.673.566 3.447 1.705-.03.018-2.059 1.199-2.08 3.274zm-2.28-5.32c.621-.75 1.041-1.791.927-2.83-.896.036-1.97.596-2.613 1.343-.574.664-1.077 1.733-.941 2.753.996.077 2.004-.51 2.627-1.266z" />
          </svg>
          <span>Download on App Store</span>
        </Link>

        <button
          onClick={() =>
            (window.location.href = `matchsplitter://join?id=${id}`)
          }
          className="btn-ghost"
          style={{ width: "100%", border: "1px solid rgba(255,255,255,0.12)" }}
        >
          I already have the app
        </button>
      </div>

      <Link href="/" className="footer-link" style={{ marginTop: "4px" }}>
        Return to home
      </Link>
    </div>
  );
}

export default function JoinPage() {
  return (
    <>
      {/* Shared navbar */}
      <Navbar />

      <main
        className="bg-page"
        style={{
          display: "flex",
          alignItems: "center",
          justifyContent: "center",
          minHeight: "calc(100vh - 64px)",
          padding: "32px 16px",
          position: "relative",
          overflow: "hidden",
        }}
      >
        {/* Ambient blobs */}
        <div className="blob blob-1" aria-hidden="true" />
        <div className="blob blob-2" aria-hidden="true" />

        <div
          className="glass-card"
          style={{
            width: "100%",
            maxWidth: "440px",
            position: "relative",
            zIndex: 1,
            border: "1px solid rgba(115,56,255,0.2)",
            boxShadow: "0 24px 80px rgba(115,56,255,0.18)",
          }}
        >
          <Suspense
            fallback={
              <div
                style={{
                  padding: "48px",
                  textAlign: "center",
                  color: "rgba(255,255,255,0.4)",
                }}
              >
                Loading…
              </div>
            }
          >
            <JoinContent />
          </Suspense>
        </div>
      </main>
    </>
  );
}
