From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] pkt_sched: fq: clear time_next_packet for reused flows
Date: Sun, 27 Oct 2013 16:52:35 -0400 (EDT)
Message-ID: <20131027.165235.1972935944831715168.davem@davemloft.net>
References: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53887 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752813Ab3J0Uwg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Oct 2013 16:52:36 -0400
In-Reply-To: <1382612508.7572.53.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 24 Oct 2013 04:01:48 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> When a socket is freed/reallocated, we need to clear time_next_packet
> or else we can inherit a prior value and delay first packets of the
> new flow.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Eric this has been mangled by your email client, please fix.
