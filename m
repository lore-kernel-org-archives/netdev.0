From: Fabio Estevam <festevam@gmail.com>
Subject: Re: [PATCH] fsl/fman: add dependency on HAS_DMA
Date: Mon, 26 Jun 2017 12:20:47 -0300
Message-ID: <CAOMZO5AWgPv6bOFjpt4vC1PSMNpC+dpR2A90+fc2Z_uojoUAmA@mail.gmail.com>
References: <1498489947-17272-1-git-send-email-madalin.bucur@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Geert Uytterhoeven <geert@linux-m68k.org>,
        "linuxppc-dev@lists.ozlabs.org" <linuxppc-dev@lists.ozlabs.org>,
        linux-kernel <linux-kernel@vger.kernel.org>
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1498489947-17272-1-git-send-email-madalin.bucur@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jun 26, 2017 at 12:12 PM, Madalin Bucur <madalin.bucur@nxp.com> wrote:
> A previous commit inserted a dependency on DMA API that requires
> HAS_DMA to be added in Kconfig.

It would be nice to specify the commit that caused this.
