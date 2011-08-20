From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: reserve ooo_okay when copying skb header
Date: Sat, 20 Aug 2011 14:21:21 -0700 (PDT)
Message-ID: <20110820.142121.1846760406833271197.davem@davemloft.net>
References: <1313765058-9315-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, therbert@google.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:60562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753989Ab1HTVV1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Aug 2011 17:21:27 -0400
In-Reply-To: <1313765058-9315-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Fri, 19 Aug 2011 22:44:18 +0800

> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

I think you meant "preserve" not "reserve" :-)

I fixed this up and applied your patch, thanks.
