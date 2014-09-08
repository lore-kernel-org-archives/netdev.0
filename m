From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: fix skb_page_frag_refill() kerneldoc
Date: Mon, 08 Sep 2014 14:12:34 -0700 (PDT)
Message-ID: <20140908.141234.1966982969227010013.davem@davemloft.net>
References: <1410174000.11872.94.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754096AbaIHVMf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Sep 2014 17:12:35 -0400
In-Reply-To: <1410174000.11872.94.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 08 Sep 2014 04:00:00 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> In commit d9b2938aabf7 ("net: attempt a single high order allocation)
> I forgot to update kerneldoc, as @prio parameter was renamed to @gfp
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks.
