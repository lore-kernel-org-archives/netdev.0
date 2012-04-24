From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: speedup skb_splice_bits()
Date: Mon, 23 Apr 2012 23:35:37 -0400 (EDT)
Message-ID: <20120423.233537.1129327954000074220.davem@davemloft.net>
References: <20120423.230205.418261556142199877.davem@davemloft.net>
	<20120423.230641.256329442020745539.davem@davemloft.net>
	<1335237503.5205.113.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, therbert@google.com, axboe@kernel.dk
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:34972 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756508Ab2DXDfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 23:35:42 -0400
In-Reply-To: <1335237503.5205.113.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 24 Apr 2012 05:18:23 +0200

> linear could be a bool too 

Yep.

> [PATCH] net: make spd_fill_page() linear argument a bool
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks!
