From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: use consume_skb() in place of kfree_skb()
Date: Mon, 04 Jun 2012 11:33:33 -0400 (EDT)
Message-ID: <20120604.113333.623343802213658090.davem@davemloft.net>
References: <1338808639.2760.1802.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40242 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754587Ab2FDPdf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jun 2012 11:33:35 -0400
In-Reply-To: <1338808639.2760.1802.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 04 Jun 2012 13:17:19 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Remove some dropwatch/drop_monitor false positives.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
