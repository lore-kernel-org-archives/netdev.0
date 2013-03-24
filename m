From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] inet: generalize ipv4-only RFC3168 5.3
 ecn fragmentation handling for future use by ipv6
Date: Sun, 24 Mar 2013 17:17:20 -0400 (EDT)
Message-ID: <20130324.171720.923983789492647520.davem@davemloft.net>
References: <20130322182437.GC19365@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eric.dumazet@gmail.com, jbrouer@redhat.com,
	yoshfuji@linux-ipv6.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43854 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754763Ab3CXVRW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Mar 2013 17:17:22 -0400
In-Reply-To: <20130322182437.GC19365@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Fri, 22 Mar 2013 19:24:37 +0100

> This patch just moves some code arround to make the ip4_frag_ecn_table
> and IPFRAG_ECN_* constants accessible from the other reassembly engines. I
> also renamed ip4_frag_ecn_table to ip_frag_ecn_table.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>
> Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Applied.
