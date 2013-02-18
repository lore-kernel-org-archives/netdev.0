From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: optimize inet6_hash_frag()
Date: Mon, 18 Feb 2013 12:24:11 -0500 (EST)
Message-ID: <20130218.122411.1863066294447811214.davem@davemloft.net>
References: <1360988088.19353.46.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47456 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755566Ab3BRRYM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Feb 2013 12:24:12 -0500
In-Reply-To: <1360988088.19353.46.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 15 Feb 2013 20:14:48 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Use ipv6_addr_hash() and a single jhash invocation.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
