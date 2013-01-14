From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: Move comment to right place.
Date: Sun, 13 Jan 2013 21:05:31 -0500 (EST)
Message-ID: <20130113.210531.1875237932979927289.davem@davemloft.net>
References: <50F3671E.2090601@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49614 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754821Ab3ANCFd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Jan 2013 21:05:33 -0500
In-Reply-To: <50F3671E.2090601@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Mon, 14 Jan 2013 11:02:06 +0900

> IN6ADDR_* and in6addr_* are not exported to userspace, and are defined
> in include/linux/in6.h.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied.
