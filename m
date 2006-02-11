From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [PATCH] IPv6: Cleanups for net/ipv6/addrconf.c (kzalloc, early
 exit) v2
Date: Sun, 12 Feb 2006 02:11:03 +0900 (JST)
Message-ID: <20060212.021103.76157181.yoshfuji@linux-ipv6.org>
References: <200602091736.18000.ioe-lkml@rameria.de>
	<20060210.014853.13643277.yoshfuji@linux-ipv6.org>
	<200602111737.20010.ioe-lkml@rameria.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ioe-lkml@rameria.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932345AbWBKRJm@vger.kernel.org>
To: davem@davemloft.net
In-Reply-To: <200602111737.20010.ioe-lkml@rameria.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

In article <200602111737.20010.ioe-lkml@rameria.de> (at Sat, 11 Feb 2006 17:37:18 +0100), Ingo Oeser <ioe-lkml@rameria.de> says:

> From: Ingo Oeser <ioe-lkml@rameria.de>
> 
> Here are some possible (and trivial) cleanups.
> - use kzalloc() where possible
> - remove unused label
> - invert allocation failure test like
:
> Signed-off-by: Ingo Oeser <ioe-lkml@rameria.de>
Acked-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

--yoshfuji
