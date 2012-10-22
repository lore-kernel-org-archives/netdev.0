From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] pkt_sched: use ns_to_ktime() helper
Date: Sun, 21 Oct 2012 22:21:54 -0400 (EDT)
Message-ID: <20121021.222154.1193192830279085767.davem@davemloft.net>
References: <1350729651.13333.570.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932777Ab2JVCVz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Oct 2012 22:21:55 -0400
In-Reply-To: <1350729651.13333.570.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sat, 20 Oct 2012 12:40:51 +0200

> From: Eric Dumazet <edumazet@google.com>
> 
> ns_to_ktime() seems better than ktime_set() + ktime_add_ns()
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied, thanks Eric.
