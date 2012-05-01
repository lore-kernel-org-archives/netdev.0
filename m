From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: skb_peek()/skb_peek_tail() cleanups
Date: Tue, 01 May 2012 09:41:27 -0400 (EDT)
Message-ID: <20120501.094127.190023878792795840.davem@davemloft.net>
References: <1335839506.11396.17.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49172 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753735Ab2EANlb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 May 2012 09:41:31 -0400
In-Reply-To: <1335839506.11396.17.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 May 2012 04:31:46 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> remove useless casts and rename variables for less confusion.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, I really need to get back to completing the list_head
conversion :-/
