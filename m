From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] ipv6: RCU changes in ipv6_get_mtu() and
 ip6_dst_hoplimit()
Date: Mon, 14 Jun 2010 23:14:24 -0700 (PDT)
Message-ID: <20100614.231424.59689474.davem@davemloft.net>
References: <1276526780.2478.101.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35931
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752446Ab0FOGON (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jun 2010 02:14:13 -0400
In-Reply-To: <1276526780.2478.101.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 14 Jun 2010 16:46:20 +0200

> Use RCU to avoid atomic ops on idev refcnt in ipv6_get_mtu()
> and ip6_dst_hoplimit() 
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
