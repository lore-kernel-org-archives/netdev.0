From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: Cleanups for net/ipv6/addrconf.c (kzalloc, early
 exit) v2
Date: Fri, 10 Mar 2006 03:02:58 -0800 (PST)
Message-ID: <20060310.030258.55767431.davem@davemloft.net>
References: <20060210.014853.13643277.yoshfuji@linux-ipv6.org>
	<200602111737.20010.ioe-lkml@rameria.de>
	<20060212.021103.76157181.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@rameria.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932235AbWCJLC5@vger.kernel.org>
To: yoshfuji@linux-ipv6.org
In-Reply-To: <20060212.021103.76157181.yoshfuji@linux-ipv6.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Sun, 12 Feb 2006 02:11:03 +0900 (JST)

> In article <200602111737.20010.ioe-lkml@rameria.de> (at Sat, 11 Feb 2006 17:37:18 +0100), Ingo Oeser <ioe-lkml@rameria.de> says:
> 
> > From: Ingo Oeser <ioe-lkml@rameria.de>
> > 
> > Here are some possible (and trivial) cleanups.
> > - use kzalloc() where possible
> > - remove unused label
> > - invert allocation failure test like
> :
> > Signed-off-by: Ingo Oeser <ioe-lkml@rameria.de>
> Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

This patch no longer applied cleanly, Ingo can you generate
a fresh version of your patch against my net-2.6.16 tree?

Thanks a lot!
