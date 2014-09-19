From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: do not fake tcp headers in
 tcp_send_rcvq()
Date: Fri, 19 Sep 2014 16:04:40 -0400 (EDT)
Message-ID: <20140919.160440.278963055238455366.davem@davemloft.net>
References: <1410948882.7106.212.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xemul@parallels.com, ncardwell@google.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58745 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932117AbaISUEm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Sep 2014 16:04:42 -0400
In-Reply-To: <1410948882.7106.212.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 17 Sep 2014 03:14:42 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Now we no longer rely on having tcp headers for skbs in receive queue,
> tcp repair do not need to build fake ones.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
