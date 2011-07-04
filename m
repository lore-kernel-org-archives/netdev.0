From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sh_eth: remove __flush_purge_region
Date: Sun, 03 Jul 2011 20:10:57 -0700 (PDT)
Message-ID: <20110703.201057.720436216770672101.davem@davemloft.net>
References: <4E0D8ABD.9030102@renesas.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: yoshihiro.shimoda.uh@renesas.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <4E0D8ABD.9030102@renesas.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
Date: Fri, 01 Jul 2011 17:52:13 +0900

> It is a function of SuperH architecture. There is no good to use
> the function on a driver generally. So, the driver uses
> dma_map_single() instead of __flush_purge_region.
> 
> Signed-off-by: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>

Applied.
