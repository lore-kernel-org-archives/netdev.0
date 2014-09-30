From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v3 2/4] net: sched: implement qstat helper
 routines
Date: Tue, 30 Sep 2014 01:02:59 -0400 (EDT)
Message-ID: <20140930.010259.1962945200439903978.davem@davemloft.net>
References: <20140928185255.1976.56179.stgit@nitbit.x32>
	<20140928185327.1976.62322.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751865AbaI3FDB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Sep 2014 01:03:01 -0400
In-Reply-To: <20140928185327.1976.62322.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Sun, 28 Sep 2014 11:53:29 -0700

> This adds helpers to manipulate qstats logic and replaces locations
> that touch the counters directly. This simplifies future patches
> to push qstats onto per cpu counters.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
