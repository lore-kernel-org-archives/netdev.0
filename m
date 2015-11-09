From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: hisilicon: NET_VENDOR_HISILICON should depend on
 HAS_DMA
Date: Mon, 09 Nov 2015 11:22:43 -0500 (EST)
Message-ID: <20151109.112243.1323660785793515062.davem@davemloft.net>
References: <1447061670-19681-1-git-send-email-geert@linux-m68k.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: huangdaode@hisilicon.com, arnd@arndb.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: geert@linux-m68k.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1447061670-19681-1-git-send-email-geert@linux-m68k.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Geert Uytterhoeven <geert@linux-m68k.org>
Date: Mon,  9 Nov 2015 10:34:30 +0100

> If NO_DMA=y:
 ...
> As this affects all of HNS_ENET, HNS_DSAF, HNS, HIX5HD2_GMAC, and
> HIP04_ETH, add a dependency on HAS_DMA to the main NET_VENDOR_HISILICON
> symbol to fix this.
> 
> Signed-off-by: Geert Uytterhoeven <geert@linux-m68k.org>

Applied, thanks.
