From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 3/4 net-next] net/ipv6/udp: UDP encapsulation:
 introduce encap_rcv hook into IPv6
Date: Sat, 28 Apr 2012 22:31:45 -0400 (EDT)
Message-ID: <20120428.223145.1635277088589040413.davem@davemloft.net>
References: <20120427182408.GG17021@kvack.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jchapman@katalix.com, netdev@vger.kernel.org
To: bcrl@kvack.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755899Ab2D2Cbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 28 Apr 2012 22:31:50 -0400
In-Reply-To: <20120427182408.GG17021@kvack.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Benjamin LaHaise <bcrl@kvack.org>
Date: Fri, 27 Apr 2012 14:24:08 -0400

> Now that the sematics of udpv6_queue_rcv_skb() match IPv4's
> udp_queue_rcv_skb(), introduce the UDP encap_rcv() hook for IPv6.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

Applied.
