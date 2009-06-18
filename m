From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/1] Re: [BUG] fib_tries related Oops in 2.6.30
Date: Thu, 18 Jun 2009 00:26:05 -0700 (PDT)
Message-ID: <20090618.002605.92822150.davem@davemloft.net>
References: <20090615160800.GC2767@ami.dom.local>
	<20090617.185658.226201750.davem@davemloft.net>
	<20090618072300.GA6243@ff.dom.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: robert.olsson@its.uu.se, zheng.yan@oracle.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: jarkao2@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45361
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751460AbZFRH0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 03:26:02 -0400
In-Reply-To: <20090618072300.GA6243@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jarek Poplawski <jarkao2@gmail.com>
Date: Thu, 18 Jun 2009 07:23:00 +0000

> ipv4: Fix fib_trie rebalancing, part 3
> 
> Alas my fix, part 2, has one if too much again... (We can't repeat the
> same test because tn is different.)
> 
> Reported-by: Yan Zheng <zheng.yan@oracle.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>

Since I didn't push patch #2 out yet I'll combine it with
this one.
