From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] drivers: net: stmmac: fix spelling mistake "mulitcast"
 -> "multicast"
Date: Fri, 26 Aug 2016 11:50:19 -0700
Message-ID: <1472237419.4914.54.camel@perches.com>
References: <20160826183525.2366-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org
To: Colin King <colin.king@canonical.com>,
        Giuseppe Cavallaro <peppe.cavallaro@st.com>,
        Alexandre Torgue <alexandre.torgue@st.com>,
        netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160826183525.2366-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2016-08-26 at 19:35 +0100, Colin King wrote:
> Trivial fix to spelling mistake in dev_warn message.

Thanks Colin

Are you also fixing up comments and such?

$ git grep -i -E "\bmulit"
Documentation/networking/kcm.txt:Kernel Connection Mulitplexor
arch/arm/mach-s3c64xx/include/mach/irqs.h: * mulitple of 32 to allow the common code to work
arch/arm64/lib/strncmp.S:       * when limit is mulitply of 8, if not sub 1,
drivers/ata/ahci_xgene.c:        * for case of Port Mulitplier.
drivers/iommu/intel-iommu.c:/* si_domain contains mulitple devices */
drivers/net/ethernet/stmicro/stmmac/dwmac1000_core.c:           pr_debug("STMMAC: err in setting mulitcast filter\n");
drivers/net/wan/cosa.c: * interested in the SMP and/or muliti-channel success/failure reports
drivers/rtc/rtc-m41t80.c:                * WDS = 1 (0x80), mulitplier = WD_TIMO, resolution = 1s (0x02)
fs/fat/namei_vfat.c: * lowercase char, muliti bytes char, etc. In this case numtail is not
include/net/dn_dev.h:   int mode;                 /* Broadcast, Unicast, Mulitpoint     */
include/uapi/drm/i915_drm.h:    int num_cliprects;      /* mulitpass with multiple cliprects? */
include/uapi/drm/i915_drm.h:    int num_cliprects;      /* mulitpass with multiple cliprects? */
net/netfilter/ipvs/ip_vs_sync.c:  The master mulitcasts messages (Datagrams) to the backup load balancers
scripts/spelling.txt:mulitplied||multiplied
sound/soc/codecs/wm9713.h:/* MCLK clock mulitipliers */
