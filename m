From: Andy Shevchenko <andy.shevchenko@gmail.com>
Subject: Re: [PATCH v4 6/6] stmmac: pci: Remove setup handler indirection via stmmac_pci_info
Date: Fri, 2 Jun 2017 13:44:50 +0300
Message-ID: <CAHp75VdH55X0LET5a-oo-79f81mAbCKoXoTd+7hdOQ32KoOZGg@mail.gmail.com>
References: <cover.1496388893.git.jan.kiszka@siemens.com> <1df4f24d4bb29a37a7b3b45a8ee359658c760878.1496388893.git.jan.kiszka@siemens.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Kiszka <jan.kiszka@siemens.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1df4f24d4bb29a37a7b3b45a8ee359658c760878.1496388893.git.jan.kiszka@siemens.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jun 2, 2017 at 10:34 AM, Jan Kiszka <jan.kiszka@siemens.com> wrote:
> By now, stmmac_pci_info only contains a single entry. Register this
> directly with the PCI device table, removing one indirection.

Please, drop this patch from the next version.

We can discuss it after the first 5 will be in.


-- 
With Best Regards,
Andy Shevchenko
