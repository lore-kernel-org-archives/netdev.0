From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 4/4] net: sched: enable per cpu qstats
Date: Tue, 30 Sep 2014 01:03:11 -0400 (EDT)
Message-ID: <20140930.010311.1475512026355564670.davem@davemloft.net>
References: <20140928185255.1976.56179.stgit@nitbit.x32>
	<20140928185423.1976.31409.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38942 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbaI3FDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 01:03:13 -0400
In-Reply-To: <20140928185423.1976.31409.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 28 Sep 2014 11:54:24 -0700

> After previous patches to simplify qstats the qstats can be
> made per cpu with a packed union in Qdisc struct.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
