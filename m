From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] mace: Fix build for mace due to
 netdev_alloc_skb
Date: Wed, 08 Feb 2012 15:23:58 -0500 (EST)
Message-ID: <20120208.152358.916104383646981710.davem@davemloft.net>
References: <1328695395-2565-1-git-send-email-netdev@pradeepdalvi.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: netdev@pradeepdalvi.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328695395-2565-1-git-send-email-netdev@pradeepdalvi.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pradeep A Dalvi <netdev@pradeepdalvi.com>
Date: Wed,  8 Feb 2012 15:33:15 +0530

> Refs:
> 1. pmac32_defconfig
> http://kisskb.ellerman.id.au/kisskb/buildresult/5583746/
> 2. ppc6xx_defconfig
> http://kisskb.ellerman.id.au/kisskb/buildresult/5584116/
> 
> Confirmed any such occurances from all failed defconfigs &
> in net-next sources with
> grep -nrs "netdev_alloc_skb" drivers/net/ethernet/ | grep -v ","
> 
> Reported-by: Geert Uytterhoeven <geert@linux-m68k.org>
> Signed-off-by: Pradeep A Dalvi <netdev@pradeepdalvi.com>

Applied.
