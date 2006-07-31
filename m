From: David Miller <davem@davemloft.net>
Subject: Re: BUG: warning at net/core/dev.c:1171/skb_checksum_help()
 2.6.18-rc3
Date: Sun, 30 Jul 2006 21:58:20 -0700 (PDT)
Message-ID: <20060730.215820.71162954.davem@davemloft.net>
References: <44CD8415.2020403@davidcoulson.net>
	<20060730213437.e2ce619d.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: david@davidcoulson.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15331
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751479AbWGaE6w (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 00:58:52 -0400
To: akpm@osdl.org
In-Reply-To: <20060730213437.e2ce619d.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrew Morton <akpm@osdl.org>
Date: Sun, 30 Jul 2006 21:34:37 -0700

> Several people are reporting this.  It's apparently harmless and
> serves as a(n odd) way for the net guys to remind themselves that
> this needs fixing.
>
> It'd be nice to not let this escape into 2.6.18, please?

I'll make sure it doesn't. :)

