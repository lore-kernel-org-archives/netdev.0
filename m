From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6 flowlabel: add __rcu annotations
Date: Thu, 07 Mar 2013 16:34:26 -0500 (EST)
Message-ID: <20130307.163426.820003275446137388.davem@davemloft.net>
References: <1362666032.15793.212.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46433 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754827Ab3CGVe3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Mar 2013 16:34:29 -0500
In-Reply-To: <1362666032.15793.212.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Mar 2013 06:20:32 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Commit 18367681a10b (ipv6 flowlabel: Convert np->ipv6_fl_list to RCU.)
> omitted proper __rcu annotations.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>

Applied, thanks.
