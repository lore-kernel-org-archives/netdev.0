From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use kfree_skb_list() helper
Date: Sat, 21 Dec 2013 22:29:43 -0500 (EST)
Message-ID: <20131221.222943.1901742643194354446.davem@davemloft.net>
References: <1387578548.19078.471.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48784 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752229Ab3LVD3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Dec 2013 22:29:45 -0500
In-Reply-To: <1387578548.19078.471.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 20 Dec 2013 14:29:08 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> We can use kfree_skb_list() instead of open coding it.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
