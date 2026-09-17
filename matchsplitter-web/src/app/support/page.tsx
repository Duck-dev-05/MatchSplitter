"use client";

import { useState } from "react";
import { Navbar } from "@/components/layout/Navbar";
import { Footer } from "@/components/layout/Footer";
import { Mail, MessageSquare, Send, CheckCircle2, Clock, HelpCircle } from "lucide-react";

export default function SupportPage() {
  const [submitted, setSubmitted] = useState(false);
  const [loading, setLoading] = useState(false);

  const handleSubmit = (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setTimeout(() => {
      setLoading(false);
      setSubmitted(true);
    }, 800);
  };

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
            <div className="text-center max-w-xl mx-auto mb-16">
              <div className="label-tag mb-3">
                <HelpCircle className="w-3.5 h-3.5 text-violet-400" />
                <span>Contact & Support</span>
              </div>
              <h1 className="text-4xl sm:text-6xl font-black text-white tracking-tight mb-4">
                We&apos;re here to <br />
                <span className="text-gradient-accent">help your squad</span>
              </h1>
              <p className="text-slate-400 text-sm sm:text-base leading-relaxed">
                Found a bug, have a feature suggestion, or need assistance organizing an international club tournament? Drop us a line.
              </p>
            </div>

            <div className="grid grid-cols-1 md:grid-cols-12 gap-8 items-start">
              {/* Left: Info Cards */}
              <div className="md:col-span-5 space-y-4">
                <div className="glass-card p-6">
                  <div className="w-10 h-10 rounded-xl bg-violet-500/10 border border-violet-500/20 flex items-center justify-center text-violet-400 mb-4">
                    <Mail className="w-5 h-5" />
                  </div>
                  <h3 className="text-base font-bold text-white mb-1">Direct Support</h3>
                  <p className="text-xs text-slate-400 mb-3">
                    Email our team directly for custom inquiries and club partnerships.
                  </p>
                  <a
                    href="mailto:support@matchsplitter.com"
                    className="text-xs font-semibold text-violet-400 hover:text-violet-300 transition-colors"
                  >
                    support@matchsplitter.com →
                  </a>
                </div>

                <div className="glass-card p-6">
                  <div className="w-10 h-10 rounded-xl bg-cyan-500/10 border border-cyan-500/20 flex items-center justify-center text-cyan-400 mb-4">
                    <Clock className="w-5 h-5" />
                  </div>
                  <h3 className="text-base font-bold text-white mb-1">Fast Response Time</h3>
                  <p className="text-xs text-slate-400">
                    We typically respond to captain & organizer tickets within 12 hours on match days.
                  </p>
                </div>
              </div>

              {/* Right: Contact Form */}
              <div className="md:col-span-7">
                <div className="glass-card p-8 sm:p-10">
                  {submitted ? (
                    <div className="py-12 text-center space-y-4">
                      <div className="w-14 h-14 rounded-2xl bg-emerald-500/20 border border-emerald-500/40 flex items-center justify-center text-emerald-400 mx-auto">
                        <CheckCircle2 className="w-8 h-8" />
                      </div>
                      <h3 className="text-2xl font-bold text-white">Message Dispatched!</h3>
                      <p className="text-sm text-slate-400 max-w-sm mx-auto">
                        Thank you for reaching out. A team member will reply to your email shortly.
                      </p>
                      <button
                        onClick={() => setSubmitted(false)}
                        className="btn-secondary text-xs mt-4"
                      >
                        Send Another Message
                      </button>
                    </div>
                  ) : (
                    <form onSubmit={handleSubmit} className="space-y-5">
                      <div>
                        <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                          Your Name or Team Role
                        </label>
                        <input
                          type="text"
                          required
                          placeholder="e.g. Captain Dave, Red Star FC"
                          className="form-input"
                        />
                      </div>

                      <div>
                        <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                          Email Address
                        </label>
                        <input
                          type="email"
                          required
                          placeholder="dave@example.com"
                          className="form-input"
                        />
                      </div>

                      <div>
                        <label className="block text-xs font-semibold text-slate-300 uppercase tracking-wider mb-2">
                          Message / Feedback
                        </label>
                        <textarea
                          rows={4}
                          required
                          placeholder="Tell us what you need help with or any features you'd like to see..."
                          className="form-input resize-none"
                        />
                      </div>

                      <button
                        type="submit"
                        disabled={loading}
                        className="btn-primary w-full justify-center shadow-[0_4px_25px_rgba(139,92,246,0.4)]"
                      >
                        {loading ? (
                          <span>Sending message...</span>
                        ) : (
                          <>
                            <Send className="w-4 h-4" />
                            <span>Send Message</span>
                          </>
                        )}
                      </button>
                    </form>
                  )}
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
