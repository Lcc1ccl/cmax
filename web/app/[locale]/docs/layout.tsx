import { getTranslations } from "next-intl/server";
import { buildAlternates } from "../../../i18n/seo";
import { DocsNav } from "./docs-nav";
import { SiteHeader } from "../components/site-header";

export async function generateMetadata({
  params,
}: {
  params: Promise<{ locale: string }>;
}) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "docs" });
  return {
    title: {
      template: `%s — ${t("layoutTitle")}`,
      default: t("layoutTitle"),
    },
    openGraph: {
      siteName: "cmux",
      type: "article" as const,
    },
    alternates: buildAlternates(locale, "/docs"),
  };
}

export default async function DocsLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  const t = await getTranslations("nav");

  return (
    <div className="min-h-screen">
      <SiteHeader section={t("docs")} />
      <DocsNav>{children}</DocsNav>
    </div>
  );
}
