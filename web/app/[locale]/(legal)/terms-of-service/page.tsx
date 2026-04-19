import type { Metadata } from "next";

type LegalPageProps = {
  params: Promise<{ locale: string }>;
};

export async function generateMetadata({ params }: LegalPageProps): Promise<Metadata> {
  const { locale } = await params;
  const isZhCN = locale === "zh-CN";

  return {
    title: isZhCN ? "服务条款 — cmux" : "Terms of Service — cmux",
    description: isZhCN ? "cmux 的服务条款" : "Terms of service for cmux",
    alternates: { canonical: "https://cmux.com/terms-of-service" },
  };
}

export default async function TermsOfServicePage({ params }: LegalPageProps) {
  const { locale } = await params;
  const isZhCN = locale === "zh-CN";

  if (isZhCN) {
    return (
      <>
        <h1>服务条款</h1>
        <p>最后修订：2026 年 3 月 18 日</p>

        <p>
          位于 <a href="https://cmux.com">cmux.com</a>
          的网站（以下简称“网站”）以及 cmux 桌面应用程序（以下简称“应用程序”）均为 Manaflow（以下简称“公司”、“我们”）拥有版权的作品。本使用条款（以下简称“本条款”）规定了您使用网站和应用程序所适用的具有法律约束力的条款和条件。
        </p>
        <p>
          一旦访问或使用网站或应用程序，即表示您接受本条款，并声明和保证您具有签署本条款所需的权利、授权和能力。如果您未满 18 周岁，则不得访问或使用网站或应用程序。如果您不同意本条款的全部内容，请勿访问和/或使用网站或应用程序。
        </p>

        <h2>1. 许可</h2>
        <p>
          在您遵守本条款的前提下，公司授予您一项不可转让、非独占、可撤销且有限的许可，允许您出于个人或内部业务目的使用和访问网站及应用程序，包括在与软件开发活动相关的情况下进行商业使用。
        </p>

        <h3>限制</h3>
        <p>授予您的权利受以下限制：</p>
        <ul>
          <li>您不得许可、出售、出租、出借、转让、让与、分发、托管或以其他方式商业化利用应用程序</li>
          <li>您不得修改、制作衍生作品、反汇编、反编译或逆向工程应用程序的任何部分</li>
          <li>您不得为了构建类似或竞争产品而访问应用程序</li>
        </ul>

        <h3>修改</h3>
        <p>
          公司保留随时修改、暂停或停止网站或应用程序的权利，无论是否另行通知。对于任何修改、暂停或停止，公司均不对您或任何第三方承担责任。
        </p>

        <h3>所有权</h3>
        <p>
          您确认，应用程序及其内容中的所有知识产权，包括版权、专利、商标和商业秘密，均归公司或公司的供应商所有。本条款不会向您转让上述知识产权的任何权利、所有权或利益，除上文所述有限许可外，公司及其供应商保留本条款未明确授予的全部权利。
        </p>

        <h3>反馈</h3>
        <p>
          如果您向公司提供任何与应用程序有关的反馈或建议，您在此将该等反馈中的全部权利转让给公司，并同意公司有权以其认为适当的任何方式使用该等反馈。
        </p>

        <h2>2. 用户内容</h2>
        <p>
          对于您使用应用程序创建或处理的所有代码、文件和内容，您保留完整所有权。应用程序在您的设备本地运行，在正常使用过程中，您的内容不会传输到我们的服务器。
        </p>

        <h2>3. 赔偿</h2>
        <p>
          您同意就因以下原因导致的任何第三方主张或请求，对公司（及其管理人员、员工和代理人）进行赔偿并使其免责，包括相关费用和律师费：(a) 您对应用程序的使用；(b) 您违反本条款；或 (c) 您违反适用法律或法规。
        </p>

        <h2>4. 第三方链接</h2>
        <p>
          网站可能包含指向第三方网站和服务的链接。此类链接不受公司控制，公司亦不对其负责。您需自行承担使用任何第三方链接的风险。
        </p>

        <h2>5. 免责声明</h2>
        <p>
          应用程序按“现状”和“可用”基础提供。公司明确否认任何形式的明示、默示或法定保证与条件，包括适销性、特定用途适用性、权利归属及不侵权等全部保证。
        </p>
        <p>某些司法辖区不允许排除默示保证，因此上述排除可能不适用于您。</p>

        <h2>6. 责任限制</h2>
        <p>
          在法律允许的最大范围内，公司在任何情况下均不对您或任何第三方因本条款或您使用应用程序而产生或与之相关的利润损失、数据丢失，或任何间接性、后果性、示范性、附带性、特殊性或惩罚性损害承担责任。
        </p>
        <p>
          在法律允许的最大范围内，我们对您承担的任何损害赔偿责任在任何时候均以 50 美元为上限。
        </p>

        <h2>7. 期限与终止</h2>
        <p>
          只要您使用应用程序，本条款即持续有效。我们可自行决定基于任何理由随时暂停或终止您的权利。终止后，您应立即停止对应用程序的一切使用，并从您的设备中删除所有副本。
        </p>

        <h2>8. 争议解决</h2>
        <p>
          您同意，凡您与公司之间因应用程序或本条款产生或与之相关的任何争议，均应通过具有约束力的仲裁解决，而非诉诸法院；但任一方均可在小额索赔法院提起个别化主张，或就知识产权被滥用寻求衡平救济。仲裁将由 JAMS 按其适用规则进行。
        </p>
        <p>您与公司均放弃任何在法院起诉以及由法官或陪审团审理案件的宪法和法定权利。</p>
        <p>您与公司同意，双方仅可基于个人身份向对方提出主张，不得以集体、代表人或共同诉讼的形式提出主张。</p>
        <p>
          您有权在首次受本仲裁协议约束之日起 30 天内，通过发送书面通知至
          <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>
          选择退出本仲裁协议。
        </p>

        <h2>9. 一般条款</h2>
        <p>
          本条款构成您与公司之间就应用程序使用事项达成的完整协议。我们未行使或执行任何权利或条款，不构成对该等权利或条款的放弃。如本条款任何规定被认定为无效，其余规定仍应保持完全有效。
        </p>

        <h2>10. 联系方式</h2>
        <p>
          如您对本条款有任何疑问，请发送至
          <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>。
        </p>

        <p>Copyright &copy; {new Date().getFullYear()} Manaflow. 保留所有权利。</p>
      </>
    );
  }

  return (
    <>
      <h1>Terms of Service</h1>
      <p>Last revised on: March 18, 2026</p>

      <p>
        The website located at{" "}
        <a href="https://cmux.com">cmux.com</a> (the
        &ldquo;Site&rdquo;) and the cmux desktop application (the
        &ldquo;Application&rdquo;) are copyrighted works belonging to Manaflow
        (&ldquo;Company&rdquo;, &ldquo;us&rdquo;, &ldquo;our&rdquo;, and
        &ldquo;we&rdquo;). These Terms of Use (these &ldquo;Terms&rdquo;) set
        forth the legally binding terms and conditions that govern your use of
        the Site and Application.
      </p>
      <p>
        By accessing or using the Site or Application, you are accepting these
        Terms and you represent and warrant that you have the right, authority,
        and capacity to enter into these Terms. You may not access or use the
        Site or Application if you are not at least 18 years old. If you do not
        agree with all of the provisions of these Terms, do not access and/or
        use the Site or Application.
      </p>

      <h2>1. License</h2>
      <p>
        Subject to these Terms, Company grants you a non-transferable,
        non-exclusive, revocable, limited license to use and access the Site and
        Application for your personal or internal business purposes, including
        commercial use in connection with your software development activities.
      </p>

      <h3>Restrictions</h3>
      <p>The rights granted to you are subject to the following restrictions:</p>
      <ul>
        <li>
          You shall not license, sell, rent, lease, transfer, assign,
          distribute, host, or otherwise commercially exploit the Application
        </li>
        <li>
          You shall not modify, make derivative works of, disassemble, reverse
          compile or reverse engineer any part of the Application
        </li>
        <li>
          You shall not access the Application in order to build a similar or
          competitive product
        </li>
      </ul>

      <h3>Modification</h3>
      <p>
        Company reserves the right, at any time, to modify, suspend, or
        discontinue the Site or Application with or without notice to you.
        Company will not be liable to you or any third party for any
        modification, suspension, or discontinuation.
      </p>

      <h3>Ownership</h3>
      <p>
        You acknowledge that all intellectual property rights, including
        copyrights, patents, trademarks, and trade secrets, in the Application
        and its content are owned by Company or Company&rsquo;s suppliers.
        These Terms do not transfer to you any rights, title or interest in such
        intellectual property, except for the limited license above. Company and
        its suppliers reserve all rights not granted in these Terms.
      </p>

      <h3>Feedback</h3>
      <p>
        If you provide Company with any feedback or suggestions regarding the
        Application, you hereby assign to Company all rights in such feedback
        and agree that Company shall have the right to use such feedback in any
        manner it deems appropriate.
      </p>

      <h2>2. User Content</h2>
      <p>
        You retain full ownership of all code, files, and content you create or
        process using the Application. The Application runs locally on your
        device and your content is not transmitted to our servers during normal
        use.
      </p>

      <h2>3. Indemnification</h2>
      <p>
        You agree to indemnify and hold Company (and its officers, employees,
        and agents) harmless, including costs and attorneys&rsquo; fees, from
        any claim or demand made by any third party due to or arising out of (a)
        your use of the Application, (b) your violation of these Terms, or (c)
        your violation of applicable laws or regulations.
      </p>

      <h2>4. Third-Party Links</h2>
      <p>
        The Site may contain links to third-party websites and services. Such
        links are not under the control of Company, and Company is not
        responsible for them. You use all third-party links at your own risk.
      </p>

      <h2>5. Disclaimers</h2>
      <p>
        THE APPLICATION IS PROVIDED ON AN &ldquo;AS-IS&rdquo; AND &ldquo;AS
        AVAILABLE&rdquo; BASIS. COMPANY EXPRESSLY DISCLAIMS ANY AND ALL
        WARRANTIES AND CONDITIONS OF ANY KIND, WHETHER EXPRESS, IMPLIED, OR
        STATUTORY, INCLUDING ALL WARRANTIES OF MERCHANTABILITY, FITNESS FOR A
        PARTICULAR PURPOSE, TITLE, AND NON-INFRINGEMENT.
      </p>
      <p>
        SOME JURISDICTIONS DO NOT ALLOW THE EXCLUSION OF IMPLIED WARRANTIES, SO
        THE ABOVE EXCLUSION MAY NOT APPLY TO YOU.
      </p>

      <h2>6. Limitation on Liability</h2>
      <p>
        TO THE MAXIMUM EXTENT PERMITTED BY LAW, IN NO EVENT SHALL COMPANY BE
        LIABLE TO YOU OR ANY THIRD PARTY FOR ANY LOST PROFITS, LOST DATA, OR ANY
        INDIRECT, CONSEQUENTIAL, EXEMPLARY, INCIDENTAL, SPECIAL OR PUNITIVE
        DAMAGES ARISING FROM OR RELATING TO THESE TERMS OR YOUR USE OF THE
        APPLICATION.
      </p>
      <p>
        TO THE MAXIMUM EXTENT PERMITTED BY LAW, OUR LIABILITY TO YOU FOR ANY
        DAMAGES WILL AT ALL TIMES BE LIMITED TO FIFTY US DOLLARS ($50).
      </p>

      <h2>7. Term and Termination</h2>
      <p>
        These Terms will remain in effect while you use the Application. We may
        suspend or terminate your rights at any time for any reason at our sole
        discretion. Upon termination, you shall cease all use of the Application
        and delete all copies from your devices.
      </p>

      <h2>8. Dispute Resolution</h2>
      <p>
        You agree that any dispute between you and Company relating to the
        Application or these Terms will be resolved by binding arbitration,
        rather than in court, except that either party may assert individualized
        claims in small claims court or seek equitable relief for intellectual
        property misuse. The arbitration will be conducted by JAMS under their
        applicable rules.
      </p>
      <p>
        YOU AND COMPANY WAIVE ANY CONSTITUTIONAL AND STATUTORY RIGHTS TO SUE IN
        COURT AND HAVE A TRIAL IN FRONT OF A JUDGE OR A JURY.
      </p>
      <p>
        YOU AND COMPANY AGREE THAT EACH MAY BRING CLAIMS AGAINST THE OTHER ONLY
        ON AN INDIVIDUAL BASIS AND NOT ON A CLASS, REPRESENTATIVE, OR COLLECTIVE
        BASIS.
      </p>
      <p>
        You have the right to opt out of this arbitration agreement by sending
        written notice to{" "}
        <a href="mailto:founders@manaflow.com">founders@manaflow.com</a> within 30
        days of first becoming subject to it.
      </p>

      <h2>9. General</h2>
      <p>
        These Terms constitute the entire agreement between you and Company
        regarding the use of the Application. Our failure to exercise or enforce
        any right or provision shall not operate as a waiver. If any provision
        is held to be invalid, the remaining provisions will remain in full
        force and effect.
      </p>

      <h2>10. Contact</h2>
      <p>
        Questions about these Terms should be sent to{" "}
        <a href="mailto:founders@manaflow.com">founders@manaflow.com</a>.
      </p>

      <p>
        Copyright &copy; {new Date().getFullYear()} Manaflow. All rights reserved.
      </p>
    </>
  );
}
