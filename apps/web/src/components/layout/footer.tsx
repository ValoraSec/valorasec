import { Shield } from 'lucide-react';
import Link from 'next/link';

export function Footer() {
  return (
    <footer className="border-border/50 bg-background/95 border-t backdrop-blur">
      <div className="mx-auto max-w-7xl px-6 py-8">
        <div className="grid grid-cols-1 gap-8 md:grid-cols-4">
          <div className="md:col-span-1">
            <Link href="/" className="mb-3 flex items-center gap-2" aria-label="ValoraSec Home">
              <Shield className="text-primary h-5 w-5" aria-hidden="true" />
              <span className="font-heading text-lg font-bold">
                Valora<span className="text-primary">Sec</span>
              </span>
            </Link>
            <p className="text-muted-foreground text-sm">
              Open-source security platform for Soroban smart contracts.
            </p>
          </div>
          <div>
            <h3 className="mb-3 text-sm font-semibold">Product</h3>
            <ul className="text-muted-foreground space-y-2 text-sm" role="list">
              <li>
                <Link href="/" className="hover:text-foreground transition-colors">
                  Home
                </Link>
              </li>
              <li>
                <Link href="/docs" className="hover:text-foreground transition-colors">
                  Documentation
                </Link>
              </li>
              <li>
                <Link href="/accessibility" className="hover:text-foreground transition-colors">
                  Accessibility
                </Link>
              </li>
            </ul>
          </div>
          <div>
            <h3 className="mb-3 text-sm font-semibold">Community</h3>
            <ul className="text-muted-foreground space-y-2 text-sm" role="list">
              <li>
                <a
                  href="https://github.com/valorasec/valorasec"
                  className="hover:text-foreground transition-colors"
                  target="_blank"
                  rel="noopener noreferrer"
                  aria-label="ValoraSec on GitHub (opens in new tab)"
                >
                  GitHub
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-foreground transition-colors" aria-label="Join our Discord community">
                  Discord
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-foreground transition-colors" aria-label="Follow us on Twitter">
                  Twitter
                </a>
              </li>
            </ul>
          </div>
          <div>
            <h3 className="mb-3 text-sm font-semibold">Legal</h3>
            <ul className="text-muted-foreground space-y-2 text-sm" role="list">
              <li>
                <a href="#" className="hover:text-foreground transition-colors">
                  Privacy Policy
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-foreground transition-colors">
                  Terms of Service
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-foreground transition-colors">
                  MIT License
                </a>
              </li>
            </ul>
          </div>
        </div>
        <div className="border-border/50 text-muted-foreground mt-8 border-t pt-6 text-center text-sm">
          <p>&copy; {new Date().getFullYear()} ValoraSec. All rights reserved.</p>
        </div>
      </div>
    </footer>
  );
}
