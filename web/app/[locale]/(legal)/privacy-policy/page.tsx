import type { Metadata } from "next";
import { Link } from "../../../../i18n/navigation";

type LegalPageProps = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: LegalPageProps): Promise<Metadata> {
  const { locale } = await params;
  const isZhCN = locale === "zh-CN";

  return {
    title: isZhCN ? "隐私政策 — cmux" : "Privacy Policy — cmux",
    description: isZhCN ? "cmux 的隐私政策" : "Privacy policy for cmux",
    alternates: { canonical: "https://cmux.com/privacy-policy" },
  };
}

export default async function PrivacyPolicyPage({ params }: LegalPageProps) {
  const { locale } = await params;
  const isZhCN = locale === "zh-CN";

  if (isZhCN) {
    return (
      <>
        <h1>隐私政策</h1>
        <p>最后更新：2026 年 3 月 18 日</p>

        <p>
          Manaflow（以下简称“公司”）致力于为用户提供稳健的隐私保护。本隐私政策旨在帮助您了解我们如何收集、使用和保护您向我们提供的信息。
        </p>
        <p>
          在本政策中，“网站”指公司的网站 <a href="https://cmux.com">cmux.com</a>。
          “应用程序”指适用于 macOS 的 cmux 桌面应用。“服务”统指网站与应用程序。“我们”指公司。“您”指服务的用户。
        </p>
        <p>
          当您使用我们的服务时，即表示您接受本隐私政策以及我们的
          <Link href="/terms-of-service">服务条款</Link>，并同意我们按照本文所述方式收集、存储、使用和披露您的信息。
        </p>

        <h2>一、我们收集的信息</h2>
        <p>
          我们会收集“非个人信息”和“个人信息”。非个人信息包括无法直接识别您身份的信息，例如匿名使用数据、平台类型和崩溃诊断信息。个人信息包括您在选择联系我们时提供的电子邮箱地址。
        </p>

        <h3>1. 通过技术手段自动收集的信息</h3>
        <p>应用程序可能会自动收集以下信息：</p>
        <ul>
          <li>崩溃报告和错误诊断信息（通过 Sentry）</li>
          <li>操作系统版本和应用程序版本</li>
          <li>匿名使用模式</li>
        </ul>
        <p>
          应用程序会通过 Sparkle 检查更新，该过程可能会向我们的更新服务器传输您的操作系统版本和应用程序版本。
        </p>
        <p>
          网站使用 PostHog 进行匿名分析，包括页面浏览和导航模式。PostHog 会存储一个 Cookie 以区分不同访客。分析过程中不会收集可识别个人身份的信息。您可以通过使用阻止跟踪脚本的浏览器扩展来选择退出。
        </p>

        <h3>2. 您直接提供的信息</h3>
        <p>
          如果您通过电子邮件或我们的联系页面与我们联系，我们会收集您提供的信息，例如您的姓名和电子邮箱地址。
        </p>

        <h3>3. 儿童隐私</h3>
        <p>
          本服务不面向 13 岁以下人士。我们不会故意收集 13 岁以下人士的信息。如果您认为我们收集了此类信息，请通过
          <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>
          与我们联系。
        </p>

        <h2>二、第三方服务</h2>
        <p>应用程序集成了以下第三方服务：</p>
        <ul>
          <li>
            <strong>Sentry</strong> — 错误跟踪与崩溃报告。可能收集错误日志、堆栈跟踪、设备信息和操作系统版本。
          </li>
          <li>
            <strong>Sparkle</strong> — 自动更新框架。会传输应用程序版本和操作系统版本以检查更新。
          </li>
          <li>
            <strong>Ghostty / libghostty</strong> — 终端渲染引擎。完全在您的设备本地运行。
          </li>
          <li>
            <strong>PostHog</strong> — 网站分析。通过第一方代理收集匿名页面浏览数据、导航模式和浏览器元数据。不收集可识别个人身份的信息。
          </li>
          <li>
            <strong>Resend</strong> — 事务性邮件投递服务。用于投递应用程序中的反馈提交。仅当您主动提交反馈时，您的电子邮箱地址才会传输给 Resend。
          </li>
        </ul>
        <p>上述各项服务均有其各自的隐私政策，用于规范其对您数据的收集和使用。</p>

        <h2>三、我们如何使用和共享信息</h2>
        <p>
          我们不会将您的个人信息出售、交易、出租或以其他方式与第三方共享用于营销。我们仅会将崩溃报告和诊断信息用于改进应用程序。如果我们基于善意认为披露信息对于满足法律程序要求或防止损害是必要的，我们也可能共享相关信息。
        </p>

        <h2>四、我们如何保护信息</h2>
        <p>
          我们采取了旨在防止未经授权访问的安全措施来保护您的信息，包括加密和安全服务器软件。但任何传输或存储方式都无法保证 100% 安全。使用我们的服务即表示您知悉并同意承担这些风险。
        </p>

        <h2>五、您的权利</h2>
        <p>
          根据您所在地区适用的数据保护法律（如 GDPR 或 CCPA），您可能享有以下权利：
        </p>
        <ul>
          <li>获取我们持有的与您有关的数据副本的权利</li>
          <li>请求更正不准确数据的权利</li>
          <li>请求删除您的数据的权利</li>
          <li>数据可携带权</li>
          <li>限制或反对处理的权利</li>
        </ul>
        <p>
          如需行使上述任何权利，请通过
          <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>
          与我们联系。
        </p>

        <h2>六、其他网站链接</h2>
        <p>
          本服务可能提供指向第三方网站的链接。我们不对这些网站的隐私实践负责。本隐私政策仅适用于由我们收集的信息。
        </p>

        <h2>七、本政策的变更</h2>
        <p>
          我们保留随时修改本政策的权利。重大变更将在发出通知后 30 天生效。您应定期查看网站以了解更新。
        </p>

        <h2>八、联系我们</h2>
        <p>
          如果您对本隐私政策有任何疑问，请通过
          <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>
          与我们联系。
        </p>

        <h2>九、数据保留</h2>
        <p>
          崩溃报告和诊断信息仅会在诊断和修复问题所需的期限内保留。您可以通过
          <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>
          联系我们，请求删除任何与您相关的数据。
        </p>
      </>
    );
  }

  return (
    <>
      <h1>Privacy Policy</h1>
      <p>Last updated: March 18, 2026</p>

      <p>
        Manaflow (the &ldquo;Company&rdquo;) is committed to maintaining robust
        privacy protections for its users. This Privacy Policy is designed to
        help you understand how we collect, use and safeguard the information you
        provide to us.
      </p>
      <p>
        For purposes of this policy, &ldquo;Site&rdquo; refers to the
        Company&rsquo;s website at{" "}
        <a href="https://cmux.com">cmux.com</a>.
        &ldquo;Application&rdquo; refers to the cmux desktop application for
        macOS. &ldquo;Service&rdquo; refers to the Site and Application
        collectively. The terms &ldquo;we,&rdquo; &ldquo;us,&rdquo; and
        &ldquo;our&rdquo; refer to the Company. &ldquo;You&rdquo; refers to
        you, as a user of our Service.
      </p>
      <p>
        By using our Service, you accept this Privacy Policy and our{" "}
        <Link href="/terms-of-service">Terms of Service</Link>, and you consent to
        our collection, storage, use and disclosure of your information as
        described here.
      </p>

      <h2>I. Information We Collect</h2>
      <p>
        We collect &ldquo;Non-Personal Information&rdquo; and &ldquo;Personal
        Information.&rdquo; Non-Personal Information includes information that
        cannot be used to personally identify you, such as anonymous usage data,
        platform types, and crash diagnostics. Personal Information includes
        your email address if you choose to contact us.
      </p>

      <h3>1. Information collected via Technology</h3>
      <p>
        The Application may collect the following information automatically:
      </p>
      <ul>
        <li>Crash reports and error diagnostics (via Sentry)</li>
        <li>Operating system version and application version</li>
        <li>Anonymous usage patterns</li>
      </ul>
      <p>
        The Application checks for updates via Sparkle, which may transmit your
        operating system version and application version to our update server.
      </p>
      <p>
        The Site uses PostHog for anonymous analytics, including page views and
        navigation patterns. PostHog stores a cookie to distinguish unique
        visitors. No personally identifiable information is collected through
        analytics. You can opt out by using a browser extension that blocks
        tracking scripts.
      </p>

      <h3>2. Information you provide directly</h3>
      <p>
        If you contact us via email or our contact page, we collect the
        information you provide such as your name and email address.
      </p>

      <h3>3. Children&rsquo;s Privacy</h3>
      <p>
        The Service is not directed to anyone under the age of 13. We do not
        knowingly collect information from anyone under 13. If you believe we
        have collected such information, please contact us at{" "}
        <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>.
      </p>

      <h2>II. Third-Party Services</h2>
      <p>
        The Application integrates with the following third-party services:
      </p>
      <ul>
        <li>
          <strong>Sentry</strong> &mdash; error tracking and crash reporting.
          May collect error logs, stack traces, device information, and OS
          version.
        </li>
        <li>
          <strong>Sparkle</strong> &mdash; auto-update framework. Transmits
          application and OS version to check for updates.
        </li>
        <li>
          <strong>Ghostty / libghostty</strong> &mdash; terminal rendering
          engine. Runs entirely locally on your device.
        </li>
        <li>
          <strong>PostHog</strong> &mdash; website analytics. Collects anonymous
          page view data, navigation patterns, and browser metadata via a
          first-party proxy. No personally identifiable information is collected.
        </li>
        <li>
          <strong>Resend</strong> &mdash; transactional email delivery. Used to
          deliver feedback submissions from the Application. Your email address
          is transmitted to Resend only if you voluntarily submit feedback.
        </li>
      </ul>
      <p>
        Each of these services has its own privacy policy governing the
        collection and use of your data.
      </p>

      <h2>III. How We Use and Share Information</h2>
      <p>
        We do not sell, trade, rent or otherwise share your Personal Information
        with third parties for marketing purposes. We use crash reports and
        diagnostics solely to improve the Application. We may share information
        if we have a good-faith belief that disclosure is necessary to meet
        legal process or protect against harm.
      </p>

      <h2>IV. How We Protect Information</h2>
      <p>
        We implement security measures designed to protect your information from
        unauthorized access, including encryption and secure server software.
        However, no method of transmission or storage is 100% secure. By using
        our Service, you acknowledge and agree to assume these risks.
      </p>

      <h2>V. Your Rights</h2>
      <p>
        Depending on your location, you may have rights under applicable data
        protection laws (such as GDPR or CCPA), including:
      </p>
      <ul>
        <li>Right to access a copy of data we hold about you</li>
        <li>Right to request correction of inaccurate data</li>
        <li>Right to request deletion of your data</li>
        <li>Right to data portability</li>
        <li>Right to restrict or object to processing</li>
      </ul>
      <p>
        To exercise any of these rights, please contact us at{" "}
        <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>.
      </p>

      <h2>VI. Links to Other Websites</h2>
      <p>
        The Service may provide links to third-party websites. We are not
        responsible for the privacy practices of those websites. This Privacy
        Policy applies solely to information collected by us.
      </p>

      <h2>VII. Changes to This Policy</h2>
      <p>
        We reserve the right to change this policy at any time. Significant
        changes will go into effect 30 days following notification. You should
        periodically check the Site for updates.
      </p>

      <h2>VIII. Contact Us</h2>
      <p>
        If you have any questions regarding this Privacy Policy, please contact
        us at{" "}
        <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>.
      </p>

      <h2>IX. Data Retention</h2>
      <p>
        Crash reports and diagnostics are retained only as long as needed to
        diagnose and fix issues. You may request deletion of any data associated
        with you by contacting us at{" "}
        <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>.
      </p>
    </>
  );
}
