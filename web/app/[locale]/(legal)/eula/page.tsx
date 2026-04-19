import type { Metadata } from "next";

type LegalPageProps = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: LegalPageProps): Promise<Metadata> {
  const { locale } = await params;
  const isZhCN = locale === "zh-CN";

  return {
    title: isZhCN ? "最终用户许可协议 — cmux" : "EULA — cmux",
    description: isZhCN ? "cmux 的最终用户许可协议" : "End-User License Agreement for cmux",
    alternates: { canonical: "https://cmux.com/eula" },
  };
}

export default async function EulaPage({ params }: LegalPageProps) {
  const { locale } = await params;
  const isZhCN = locale === "zh-CN";

  if (isZhCN) {
    return (
      <>
        <h1>最终用户许可协议</h1>
        <p>最后更新：2026 年 3 月 18 日</p>

        <p>在下载或使用 cmux 之前，请仔细阅读本最终用户许可协议。</p>

        <h2>解释与定义</h2>
        <p>在本协议中：</p>
        <ul>
          <li>
            <strong>“协议”</strong> 指本最终用户许可协议，构成您与公司之间就应用程序使用事项达成的完整协议。
          </li>
          <li>
            <strong>“应用程序”</strong> 指适用于 macOS 的 cmux 桌面应用程序，这是一款基于 Ghostty 构建的原生终端应用。
          </li>
          <li>
            <strong>“公司”</strong>（亦称“本公司”、“我们”）指 Manaflow。
          </li>
          <li>
            <strong>“内容”</strong> 指可由应用程序创建、处理或显示的文本、代码、图像或其他信息。
          </li>
          <li>
            <strong>“国家”</strong> 指美国。
          </li>
          <li>
            <strong>“设备”</strong> 指任何能够运行应用程序的 macOS 计算机。
          </li>
          <li>
            <strong>“您”</strong> 指访问或使用应用程序的个人。
          </li>
        </ul>

        <h2>确认</h2>
        <p>
          通过下载或使用应用程序，即表示您同意受本协议条款约束。如果您不同意，请不要下载或使用应用程序。
        </p>
        <p>应用程序由公司许可给您使用，而非出售给您，且仅可严格依据本协议条款使用。</p>

        <h2>许可</h2>

        <h3>许可范围</h3>
        <p>
          公司授予您一项可撤销、非独占、不可转让且有限的许可，允许您严格依据本协议下载、安装和使用应用程序，用于个人或内部业务目的，包括与软件开发相关的商业用途。
        </p>

        <h3>许可限制</h3>
        <p>您同意不会且不会允许他人：</p>
        <ul>
          <li>许可、出售、出租、出借、让与、分发、传输、托管或以其他方式商业化利用应用程序，或向任何第三方提供应用程序</li>
          <li>移除、变更或遮盖公司的任何专有声明（包括版权或商标声明）</li>
          <li>修改、制作衍生作品、反汇编、解密、反编译或逆向工程应用程序的任何部分</li>
        </ul>

        <h2>知识产权</h2>
        <p>
          应用程序及其中包含的所有版权、专利、商标、商业秘密及其他知识产权，均且始终为公司单独且专有的财产。
        </p>
        <p>对于您使用应用程序创建的任何代码或内容，您保留其所有权。</p>

        <h2>修改与更新</h2>
        <p>
          公司保留随时修改、暂停或停止应用程序的权利，无论是否另行通知，且无需因此向您承担责任。
        </p>
        <p>
          公司可能提供更新、补丁、缺陷修复及其他修改。更新可能会修改或移除某些功能。您同意所有更新均受本协议条款约束。
        </p>

        <h2>第三方服务</h2>
        <p>
          应用程序集成了第三方服务，包括 Ghostty（终端渲染引擎）、Sentry（错误跟踪）和 Sparkle（自动更新框架）。您确认，公司不对任何第三方服务负责，包括其准确性、完整性或质量。
        </p>

        <h2>期限与终止</h2>
        <p>本协议在您或公司终止前持续有效。公司可基于任何理由随时终止本协议。</p>
        <p>
          如果您未遵守本协议任何条款，本协议将立即终止。您也可以通过删除应用程序及设备中的所有副本来终止本协议。
        </p>
        <p>协议终止后，您应立即停止对应用程序的一切使用，并删除设备中的所有副本。</p>

        <h2>无保证</h2>
        <p>
          应用程序按“现状”和“可用”基础提供，不附带任何形式的保证。公司明确否认一切明示、默示、法定或其他保证，包括适销性、特定用途适用性、权利归属及不侵权等全部默示保证。
        </p>
        <p>某些司法辖区不允许排除某些类型的保证，因此上述部分排除可能不适用于您。</p>

        <h2>责任限制</h2>
        <p>
          公司在本协议项下的全部责任，以您就应用程序实际支付的金额为限；如果您未购买任何内容，则以 100 美元为限。
        </p>
        <p>在法律允许的最大范围内，公司在任何情况下均不对任何特殊、附带、间接或后果性损害承担责任。</p>

        <h2>赔偿</h2>
        <p>
          您同意就因您使用应用程序或违反本协议而导致的任何主张或请求（包括合理律师费），对公司进行赔偿并使其免责。
        </p>

        <h2>可分割性与弃权</h2>
        <p>
          如果本协议的任何条款被认定为不可执行，该条款应在最大可能范围内被修改和解释以实现其目的，其余条款仍应继续完全有效。
        </p>

        <h2>适用法律</h2>
        <p>本协议及您对应用程序的使用受美国法律管辖，但不适用法律冲突规则。</p>

        <h2>本协议的变更</h2>
        <p>
          公司保留随时修改本协议的权利。如果修订内容重大，我们将至少提前 30 天发出通知。在修订生效后继续使用应用程序，即表示您同意受修订后条款约束。
        </p>

        <h2>联系我们</h2>
        <p>如果您对本协议有任何疑问：</p>
        <ul>
          <li>
            发送电子邮件至{" "}
            <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>
          </li>
        </ul>
      </>
    );
  }

  return (
    <>
      <h1>EULA</h1>
      <p>Last updated: March 18, 2026</p>

      <p>
        Please read this End-User License Agreement carefully before
        downloading or using cmux.
      </p>

      <h2>Interpretation and Definitions</h2>
      <p>For the purposes of this Agreement:</p>
      <ul>
        <li>
          <strong>&ldquo;Agreement&rdquo;</strong> means this End-User License
          Agreement that forms the entire agreement between You and the Company
          regarding the use of the Application.
        </li>
        <li>
          <strong>&ldquo;Application&rdquo;</strong> means the cmux desktop
          application for macOS, a native terminal application built on Ghostty.
        </li>
        <li>
          <strong>&ldquo;Company&rdquo;</strong> (referred to as &ldquo;the
          Company&rdquo;, &ldquo;We&rdquo;, &ldquo;Us&rdquo; or
          &ldquo;Our&rdquo;) refers to Manaflow.
        </li>
        <li>
          <strong>&ldquo;Content&rdquo;</strong> refers to content such as text,
          code, images, or other information that can be created, processed, or
          displayed by the Application.
        </li>
        <li>
          <strong>&ldquo;Country&rdquo;</strong> refers to the United States.
        </li>
        <li>
          <strong>&ldquo;Device&rdquo;</strong> means any macOS computer that
          can run the Application.
        </li>
        <li>
          <strong>&ldquo;You&rdquo;</strong> means the individual accessing or
          using the Application.
        </li>
      </ul>

      <h2>Acknowledgment</h2>
      <p>
        By downloading or using the Application, You are agreeing to be bound
        by the terms of this Agreement. If You do not agree, do not download or
        use the Application.
      </p>
      <p>
        The Application is licensed, not sold, to You by the Company for use
        strictly in accordance with the terms of this Agreement.
      </p>

      <h2>License</h2>

      <h3>Scope of License</h3>
      <p>
        The Company grants You a revocable, non-exclusive, non-transferable,
        limited license to download, install and use the Application strictly in
        accordance with this Agreement, for your personal or internal business
        purposes including commercial use in connection with software
        development.
      </p>

      <h3>License Restrictions</h3>
      <p>You agree not to, and You will not permit others to:</p>
      <ul>
        <li>
          License, sell, rent, lease, assign, distribute, transmit, host, or
          otherwise commercially exploit the Application or make it available to
          any third party
        </li>
        <li>
          Remove, alter or obscure any proprietary notice (including copyright
          or trademark) of the Company
        </li>
        <li>
          Modify, make derivative works of, disassemble, decrypt, reverse
          compile or reverse engineer any part of the Application
        </li>
      </ul>

      <h2>Intellectual Property</h2>
      <p>
        The Application, including all copyrights, patents, trademarks, trade
        secrets and other intellectual property rights, is and shall remain the
        sole and exclusive property of the Company.
      </p>
      <p>
        You retain ownership of any code or content you create using the
        Application.
      </p>

      <h2>Modifications and Updates</h2>
      <p>
        The Company reserves the right to modify, suspend or discontinue the
        Application at any time, with or without notice and without liability to
        You.
      </p>
      <p>
        The Company may provide updates, patches, bug fixes, and other
        modifications. Updates may modify or remove certain features. You agree
        that all updates are subject to the terms of this Agreement.
      </p>

      <h2>Third-Party Services</h2>
      <p>
        The Application integrates with third-party services including Ghostty
        (terminal rendering engine), Sentry (error tracking), and Sparkle
        (auto-update framework). You acknowledge that the Company shall not be
        responsible for any third-party services, including their accuracy,
        completeness, or quality.
      </p>

      <h2>Term and Termination</h2>
      <p>
        This Agreement shall remain in effect until terminated by You or the
        Company. The Company may terminate this Agreement at any time for any
        reason.
      </p>
      <p>
        This Agreement will terminate immediately if you fail to comply with any
        provision. You may also terminate by deleting the Application and all
        copies from your Device.
      </p>
      <p>
        Upon termination, You shall cease all use of the Application and delete
        all copies from your Device.
      </p>

      <h2>No Warranties</h2>
      <p>
        The Application is provided &ldquo;AS IS&rdquo; and &ldquo;AS
        AVAILABLE&rdquo; without warranty of any kind. The Company expressly
        disclaims all warranties, whether express, implied, statutory or
        otherwise, including all implied warranties of merchantability, fitness
        for a particular purpose, title and non-infringement.
      </p>
      <p>
        Some jurisdictions do not allow the exclusion of certain types of
        warranties, so some of the above exclusions may not apply to You.
      </p>

      <h2>Limitation of Liability</h2>
      <p>
        The entire liability of the Company under this Agreement shall be
        limited to the amount actually paid by You for the Application, or 100
        USD if You haven&rsquo;t purchased anything.
      </p>
      <p>
        To the maximum extent permitted by law, in no event shall the Company
        be liable for any special, incidental, indirect, or consequential
        damages whatsoever.
      </p>

      <h2>Indemnification</h2>
      <p>
        You agree to indemnify and hold the Company harmless from any claim or
        demand, including reasonable attorneys&rsquo; fees, due to or arising
        out of your use of the Application or violation of this Agreement.
      </p>

      <h2>Severability and Waiver</h2>
      <p>
        If any provision of this Agreement is held to be unenforceable, it will
        be changed and interpreted to accomplish its objectives to the greatest
        extent possible, and the remaining provisions will continue in full
        force and effect.
      </p>

      <h2>Governing Law</h2>
      <p>
        The laws of the United States, excluding conflicts of law rules, shall
        govern this Agreement and your use of the Application.
      </p>

      <h2>Changes to This Agreement</h2>
      <p>
        The Company reserves the right to modify this Agreement at any time. If
        a revision is material, we will provide at least 30 days&rsquo; notice.
        By continuing to use the Application after revisions become effective,
        You agree to be bound by the revised terms.
      </p>

      <h2>Contact Us</h2>
      <p>If you have any questions about this Agreement:</p>
      <ul>
        <li>
          Email us at{" "}
          <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>
        </li>
      </ul>
    </>
  );
}
