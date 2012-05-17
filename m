From: David Miller <davem@davemloft.net>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 16:07:12 -0400 (EDT)
Message-ID: <20120517.160712.1286811473287581500.davem@davemloft.net>
References: <20120517150157.GA19274@1wt.eu>
	<20120517.155503.2294382162578627387.davem@davemloft.net>
	<20120517200404.GO14498@1wt.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: w@1wt.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34542 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932556Ab2EQUHg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 16:07:36 -0400
In-Reply-To: <20120517200404.GO14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willy Tarreau <w@1wt.eu>
Date: Thu, 17 May 2012 22:04:04 +0200

> I'm having the same stall issue again since I applied Eric's build_skb
> patch, but not for all data sizes. So if the same issue is still there,
> it's possible that we're playing hide-and-seek with it. That's rather
> strange.

Ok, a Heisenbug :-)  Let me know when you guys resolve this.
