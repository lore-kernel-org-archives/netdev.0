From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: rps: support PPPOE session messages
Date: Thu, 18 Aug 2011 23:24:14 -0700 (PDT)
Message-ID: <20110818.232414.1085583676998639516.davem@davemloft.net>
References: <1313733235-32238-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:35699 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751127Ab1HSGYU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Aug 2011 02:24:20 -0400
In-Reply-To: <1313733235-32238-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 19 Aug 2011 13:53:55 +0800

> Inspect the payload of PPPOE session messages for the 4 tuples to generate
> skb->rxhash.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Also applied, thank you.
