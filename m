From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: fix unused variables in
 __gnet_stats_copy_basic_cpu()
Date: Tue, 07 Oct 2014 00:12:10 -0400 (EDT)
Message-ID: <20141007.001210.1100027565930307487.davem@davemloft.net>
References: <1412640093-11388-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40871 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750738AbaJGEML (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Oct 2014 00:12:11 -0400
In-Reply-To: <1412640093-11388-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon,  6 Oct 2014 17:01:33 -0700

> Probably not a big deal, but we'd better just use the
> one we get in retry loop.
> 
> Fixes: commit 22e0f8b9322cb1a48b1357e8 ("net: sched: make bstats per cpu and estimator RCU safe")
> Reported-by: Joe Perches <joe@perches.com>
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
