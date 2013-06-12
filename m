From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next] net_sched: psched_ratecfg_precompute()
 improvements
Date: Tue, 11 Jun 2013 22:40:22 -0700 (PDT)
Message-ID: <20130611.224022.805517640452355493.davem@davemloft.net>
References: <1370550451.24311.371.camel@edumazet-glaptop>
	<51B0F323.5010003@candelatech.com>
	<1370552179.24311.375.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: greearb@candelatech.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50138 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752978Ab3FLFkY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Jun 2013 01:40:24 -0400
In-Reply-To: <1370552179.24311.375.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 06 Jun 2013 13:56:19 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> Before allowing 64bits bytes rates, refactor
> psched_ratecfg_precompute() to get better comments
> and increased accuracy.
> 
> rate_bps field is renamed to rate_bytes_ps, as we only
> have to worry about bytes per second.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Cc: Ben Greear <greearb@candelatech.com>

Applied, thanks Eric.
