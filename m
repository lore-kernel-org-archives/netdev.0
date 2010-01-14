From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for January 8 (net/ip.h, BUG=n)
Date: Wed, 13 Jan 2010 18:11:05 -0800 (PST)
Message-ID: <20100113.181105.144771363.davem@davemloft.net>
References: <20100113085418.GB6053@ff.dom.local>
	<201001132121.44763.opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jarkao2@gmail.com, mingo@elte.hu, randy.dunlap@oracle.com,
	sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	arnd@arndb.de
To: opurdila@ixiacom.com
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <201001132121.44763.opurdila@ixiacom.com>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Wed, 13 Jan 2010 21:21:44 +0200

> [PATCH] net: fix build erros with CONFIG_BUG=n, CONFIG_GENERIC_BUG=n
> 
> Fixed build errors introduced by commit 7ad6848c (ip: fix mc_loop checks for
> tunnels with multicast outer addresses)
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

Applied, thanks.

Let's make sure netdev is CC:'d on networking patches next
time.
