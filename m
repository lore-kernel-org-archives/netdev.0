From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net_sched: sch_plug: plug_qdisc_ops is static
Date: Mon, 13 Feb 2012 16:05:35 -0500 (EST)
Message-ID: <20120213.160535.1022566305378503171.davem@davemloft.net>
References: <1329147645.2494.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:38158 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758156Ab2BMVFi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2012 16:05:38 -0500
In-Reply-To: <1329147645.2494.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Mon, 13 Feb 2012 16:40:45 +0100

> net/sched/sch_plug.c:211:18: warning: symbol 'plug_qdisc_ops' was not
> declared. Should it be static?
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied.
