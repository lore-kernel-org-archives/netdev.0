From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH v2 2/4] net: sched: cls_u32 add missing
 rcu_assign_pointer and annotation
Date: Tue, 16 Sep 2014 16:00:09 -0400 (EDT)
Message-ID: <20140916.160009.731130539108438214.davem@davemloft.net>
References: <20140916063024.2905.55403.stgit@nitbit.x32>
	<20140916063048.2905.92612.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org, jhs@mojatatu.com
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57694 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753250AbaIPUAL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 16:00:11 -0400
In-Reply-To: <20140916063048.2905.92612.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Mon, 15 Sep 2014 23:30:49 -0700

> Add missing rcu_assign_pointer and missing  annotation for ht_up
> in cls_u32.c
> 
> Caught by kbuild bot,
...
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied.
