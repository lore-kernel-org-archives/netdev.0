From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: export IP6_RT_PRIO_* to userland
Date: Fri, 16 Nov 2012 01:48:27 -0500 (EST)
Message-ID: <20121116.014827.69854515282145042.davem@davemloft.net>
References: <5097F5DF.7040507@6wind.com>
	<20121105.124305.1002288640313724910.davem@davemloft.net>
	<5098127A.2040405@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51958 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750731Ab2KPGs3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Nov 2012 01:48:29 -0500
In-Reply-To: <5098127A.2040405@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Mon, 05 Nov 2012 20:24:42 +0100

> In IPv4, there is no such default metric. If you add a route with
> metric X, it remains X in the kernel, even if it's 0.

Ok, fair enough, applied to net-next, thanks.
