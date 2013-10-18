From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: rename tcp_tso_segment()
Date: Fri, 18 Oct 2013 13:39:12 -0400 (EDT)
Message-ID: <20131018.133912.867665437265249863.davem@davemloft.net>
References: <1382117777.3284.26.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756970Ab3JRRjN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 13:39:13 -0400
In-Reply-To: <1382117777.3284.26.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 18 Oct 2013 10:36:17 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Rename tcp_tso_segment() to tcp_gso_segment(), to better reflect
> what is going on, and ease grep games.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
