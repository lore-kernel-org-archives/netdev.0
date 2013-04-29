From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: fix kernel warn on
 cpsw irq enable
Date: Mon, 29 Apr 2013 14:08:16 -0400 (EDT)
Message-ID: <20130429.140816.128860616603400300.davem@davemloft.net>
References: <1366975848-31503-1-git-send-email-mugunthanvnm@ti.com>
	<517A6D0C.6020702@linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mugunthanvnm@ti.com, netdev@vger.kernel.org,
	linux-omap@vger.kernel.org
To: bigeasy@linutronix.de
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <517A6D0C.6020702@linutronix.de>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Date: Fri, 26 Apr 2013 14:03:24 +0200

> David, how did this happen? The patch I've sent
> 
>    http://www.spinics.net/lists/netdev/msg234240.html
> 
> adds this to the probe function, according to the net-next tree it was
> added to cpsw_probe_dual_emac(). The context is similar but not exact
> the same.

This is usually I ask people to respin patches even if there are minor
fuzz differences when I try to apply this patch.

I tried to be nice and save you some work this time, 'patch' accepted
it with minor offsets, and with a cursory glance I didn't see any
problems.

Next time I'll be a hardliner and request a respin :-)
