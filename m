From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 1/2] net: introduce
 __netdev_alloc_skb_ip_align
Date: Mon, 11 Jul 2011 20:08:45 -0700 (PDT)
Message-ID: <20110711.200845.1037557897996999858.davem@davemloft.net>
References: <1310421164.2860.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755021Ab1GLDIs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 23:08:48 -0400
In-Reply-To: <1310421164.2860.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 11 Jul 2011 23:52:44 +0200

> RX rings should use GFP_KERNEL allocations if possible, add
> __netdev_alloc_skb_ip_align() helper to ease this.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
