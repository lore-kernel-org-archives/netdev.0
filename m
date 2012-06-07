From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: neighbour: fix neigh_dump_info()
Date: Thu, 07 Jun 2012 13:03:02 -0700 (PDT)
Message-ID: <20120607.130302.879769086035246421.davem@davemloft.net>
References: <ea0a16e085389e68b480c4b0baf05645@visp.net.lb>
	<1339078935.5083.13.camel@edumazet-glaptop>
	<1339081115.5083.21.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: denys@visp.net.lb, netdev@vger.kernel.org, shemminger@vyatta.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45312 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752238Ab2FGUDD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2012 16:03:03 -0400
In-Reply-To: <1339081115.5083.21.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 07 Jun 2012 16:58:35 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> Denys found out "ip neigh" output was truncated to
> about 54 neighbours.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: Denys Fedoryshchenko <denys@visp.net.lb>

Applied.
