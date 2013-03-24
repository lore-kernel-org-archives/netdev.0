From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] ipv6: implement RFC3168 5.3 (ecn
 protection) for ipv6 fragmentation handling
Date: Sun, 24 Mar 2013 17:17:30 -0400 (EDT)
Message-ID: <20130324.171730.1955202802291261072.davem@davemloft.net>
References: <20130322182444.GA939@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jbrouer@redhat.com,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43868 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754850Ab3CXVRb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:17:31 -0400
In-Reply-To: <20130322182444.GA939@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 22 Mar 2013 19:24:44 +0100

> [PATCH 2/2] ipv6: implement RFC3168 5.3 (ecn protection) for ipv6 fragmentation handling
> 
> This patch also ensures that INET_ECN_CE is propagated if one fragment
> had the codepoint set.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
