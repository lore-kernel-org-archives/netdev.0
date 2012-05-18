From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv6: bool conversions phase1
Date: Fri, 18 May 2012 02:24:23 -0400 (EDT)
Message-ID: <20120518.022423.204511864401551325.davem@davemloft.net>
References: <1337321651.3403.92.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38584 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755479Ab2ERG0Y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 May 2012 02:26:24 -0400
In-Reply-To: <1337321651.3403.92.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 May 2012 08:14:11 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ipv6_opt_accepted() returns a bool, and can use const pointers
> 
> ipv6_addr_equal(), ipv6_addr_any(), ipv6_addr_loopback(),
> ipv6_addr_orchid() return a bool.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
