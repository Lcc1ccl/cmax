import { useTranslations } from "next-intl";
import { getTranslations } from "next-intl/server";
import { buildAlternates } from "../../../../i18n/seo";
import { Link } from "../../../../i18n/navigation";

export async function generateMetadata({ params }: { params: Promise<{ locale: string }> }) {
  const { locale } = await params;
  const t = await getTranslations({ locale, namespace: "blog.cmuxSsh" });
  return {
    title: t("metaTitle"),
    description: t("metaDescription"),
    keywords: [
      "cmux", "SSH", "remote development", "terminal", "macOS",
      "port forwarding", "notifications", "AI coding agents",
      "Claude Code", "remote workspace", "developer tools",
    ],
    openGraph: {
      title: t("metaTitle"),
      description: t("metaDescription"),
      type: "article",
      publishedTime: "2026-03-30T00:00:00Z",
    },
    twitter: {
      card: "summary_large_image",
      title: t("metaTitle"),
      description: t("metaDescription"),
    },
    alternates: buildAlternates(locale, "/blog/cmux-ssh"),
  };
}

export default function CmuxSshPage() {
  const t = useTranslations("blog.posts.cmuxSsh");
  const tc = useTranslations("common");

  return (
    <>
      <div className="mb-8">
        <Link
          href="/blog"
          className="text-sm text-muted hover:text-foreground transition-colors"
        >
          &larr; {tc("backToBlog")}
        </Link>
      </div>

      <h1>{t("title")}</h1>
      <time dateTime="2026-03-30" className="text-sm text-muted">
        {t("date")}
      </time>

      <p className="mt-6">
        {t.rich("p1", {
          code: (chunks) => <code>{chunks}</code>,
        })}
      </p>

      <video
        src="/blog/cmux-ssh-image-upload.mp4"
        width={1824}
        height={1080}
        autoPlay
        loop
        muted
        playsInline
        className="my-6 rounded-lg w-full h-auto"
      />

      <ul className="mt-4 space-y-1">
        <li>
          {t.rich("feature1", {
            code: (chunks) => <code>{chunks}</code>,
          })}
        </li>
        <li>{t("feature2")}</li>
        <li>{t("feature3")}</li>
        <li>
          {t.rich("feature4", {
            code: (chunks) => <code>{chunks}</code>,
          })}
        </li>
        <li>{t("feature5")}</li>
      </ul>

      <iframe
        className="my-6 rounded-lg w-full aspect-video"
        src="https://www.youtube.com/embed/RoR9pMOZWkk"
        title={t("videoTitle")}
        allow="accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture"
        allowFullScreen
      />

      <p className="mt-4">
        <Link href="/docs/ssh">
          {t("readSshDocs")} &rarr;
        </Link>
      </p>
    </>
  );
}
