From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6 netevent: Remove old_neigh from
 netevent_redirect.
Date: Mon, 14 Jan 2013 15:05:41 -0500 (EST)
Message-ID: <20130114.150541.370796345662666250.davem@davemloft.net>
References: <50F45C5B.8020507@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33095 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756010Ab3ANUFx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2013 15:05:53 -0500
In-Reply-To: <50F45C5B.8020507@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Date: Tue, 15 Jan 2013 04:28:27 +0900

> The only user is cxgb3 driver.
> 
> old_neigh is used to check device change, but it must not happen
> on redirect.  In this sense, we can remove old_neigh argument.
> 
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
