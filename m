From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: sched: fix missing doc annotations
Date: Wed, 08 Jun 2016 11:20:53 -0700 (PDT)
Message-ID: <20160608.112053.636712634640568028.davem@davemloft.net>
References: <1465395769.7945.8.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38266 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161132AbcFHSUz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jun 2016 14:20:55 -0400
In-Reply-To: <1465395769.7945.8.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Jun 2016 07:22:49 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> "make htmldocs" complains otherwise:
> 
> .//net/core/gen_stats.c:168: warning: No description found for parameter 'running'
> .//include/linux/netdevice.h:1867: warning: No description found for parameter 'qdisc_running_key'
> 
> Fixes: f9eb8aea2a1e ("net_sched: transform qdisc running bit into a seqcount")
> Fixes: edb09eb17ed8 ("net: sched: do not acquire qdisc spinlock in qdisc/class stats dump")
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Reported-by: kbuild test robot <fengguang.wu@intel.com>

Applied, thanks Eric.
