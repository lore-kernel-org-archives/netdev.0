From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: sched: cls_cgroup need tcf_exts_init in
 all cases
Date: Tue, 16 Sep 2014 16:26:52 -0400 (EDT)
Message-ID: <20140916.162652.1278988289861920607.davem@davemloft.net>
References: <20140916073341.2597.36240.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57920 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753115AbaIPU0y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:26:54 -0400
In-Reply-To: <20140916073341.2597.36240.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Tue, 16 Sep 2014 00:33:42 -0700

> This ensures the tcf_exts_init() is called for all cases.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks.
