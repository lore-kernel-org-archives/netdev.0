From: David Miller <davem@davemloft.net>
Subject: Re: when the MTU interface is modified, the promiscuous mode is
 reset in gianfar driver
Date: Wed, 05 Sep 2012 13:09:11 -0400 (EDT)
Message-ID: <20120905.130911.1579305809056694360.davem@davemloft.net>
References: <201208270838.AA02326@VF09040P.jp.fujitsu.com>
	<20120903.155332.1814926007061594344.davem@davemloft.net>
	<504757AC.90007@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: chikazawa.akifu@jp.fujitsu.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: claudiu.manoil@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <504757AC.90007@freescale.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Claudiu Manoil <claudiu.manoil@freescale.com>
Date: Wed, 5 Sep 2012 16:46:20 +0300

> I don't see how the promisc mode would be reset by changing the
> mtu. Maybe more details on the issue reproduction would help (or
> maybe a usecase involving multicast settings?)

Agreed, I can't see how this problem is even possible either.
