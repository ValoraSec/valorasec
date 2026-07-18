import Link from 'next/link';
import { Shield, ArrowLeft } from 'lucide-react';
import { Footer } from '@/components/layout/footer';

export default function AccessibilityPage() {
  return (
    <div className="bg-background min-h-screen">
      <header className="border-border/50 bg-background/95 sticky top-0 z-50 w-full border-b backdrop-blur">
        <div className="mx-auto flex h-16 max-w-7xl items-center justify-between px-6">
          <Link href="/" className="flex items-center gap-2" aria-label="ValoraSec Home">
            <Shield className="text-primary h-6 w-6" aria-hidden="true" />
            <span className="font-heading text-xl font-bold tracking-tight">
              Valora<span className="text-primary">Sec</span>
            </span>
          </Link>
        </div>
      </header>

      <main id="main-content" className="mx-auto max-w-3xl px-6 py-16">
        <Link
          href="/"
          className="text-muted-foreground hover:text-foreground mb-8 inline-flex items-center gap-1 text-sm transition-colors"
        >
          <ArrowLeft className="h-4 w-4" aria-hidden="true" />
          Back to Home
        </Link>

        <h1 className="font-heading mb-6 text-4xl font-bold">Accessibility Statement</h1>

        <p className="text-muted-foreground mb-6 leading-relaxed">
          ValoraSec is committed to ensuring digital accessibility for people with disabilities. We
          are continually improving the user experience for everyone and applying the relevant
          accessibility standards.
        </p>

        <section className="mb-8">
          <h2 className="mb-3 text-xl font-semibold">Conformance Status</h2>
          <p className="text-muted-foreground leading-relaxed">
            The Web Content Accessibility Guidelines (WCAG) defines requirements for designers and
            developers to improve accessibility for people with disabilities. It defines three
            levels of conformance: Level A, Level AA, and Level AAA. ValoraSec aims to be fully
            conformant with WCAG 2.1 Level AA.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="mb-3 text-xl font-semibold">Accessibility Features</h2>
          <ul className="text-muted-foreground space-y-2 leading-relaxed">
            <li>
              <strong className="text-foreground">Keyboard Navigation:</strong> All interactive
              elements are fully operable via keyboard (Tab, Enter, Escape).
            </li>
            <li>
              <strong className="text-foreground">Focus Indicators:</strong> Visible focus outlines
              are provided on all interactive elements.
            </li>
            <li>
              <strong className="text-foreground">Semantic HTML:</strong> Proper use of headings,
              landmarks, and ARIA attributes throughout the application.
            </li>
            <li>
              <strong className="text-foreground">Color Contrast:</strong> Text and interactive
              elements meet WCAG AA contrast ratios (4.5:1 for normal text, 3:1 for large text).
            </li>
            <li>
              <strong className="text-foreground">Screen Reader Support:</strong> All icons are
              accompanied by text labels or have{' '}
              <code className="text-foreground">aria-hidden</code> attributes. Icon-only buttons
              include descriptive <code className="text-foreground">aria-label</code> values.
            </li>
            <li>
              <strong className="text-foreground">Skip Navigation:</strong> A skip-to-content link
              is provided as the first focusable element on each page.
            </li>
            <li>
              <strong className="text-foreground">Form Labels:</strong> All form inputs have
              associated labels and appropriate autocomplete attributes.
            </li>
            <li>
              <strong className="text-foreground">Error Messaging:</strong> Form errors are
              announced to screen readers using{' '}
              <code className="text-foreground">role=&quot;alert&quot;</code>.
            </li>
          </ul>
        </section>

        <section className="mb-8">
          <h2 className="mb-3 text-xl font-semibold">Automated Testing</h2>
          <p className="text-muted-foreground leading-relaxed">
            We use <code className="text-foreground">jest-axe</code> and the{' '}
            <code className="text-foreground">eslint-plugin-jsx-a11y</code> ESLint plugin to
            automatically detect accessibility violations during development and in our CI pipeline.
            All pages are required to pass automated accessibility checks with zero violations
            before deployment.
          </p>
        </section>

        <section className="mb-8">
          <h2 className="mb-3 text-xl font-semibold">Feedback</h2>
          <p className="text-muted-foreground leading-relaxed">
            We welcome your feedback on the accessibility of ValoraSec. Please let us know if you
            encounter accessibility barriers by opening an issue on our{' '}
            <a
              href="https://github.com/valorasec/valorasec/issues"
              className="text-primary hover:underline"
              target="_blank"
              rel="noopener noreferrer"
            >
              GitHub repository
            </a>
            .
          </p>
        </section>

        <p className="text-muted-foreground text-sm leading-relaxed">
          Last updated:{' '}
          {new Date().toLocaleDateString('en-US', {
            year: 'numeric',
            month: 'long',
            day: 'numeric',
          })}
        </p>
      </main>

      <Footer />
    </div>
  );
}
