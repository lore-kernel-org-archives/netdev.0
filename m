From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/3] net sched action timestamp improvements
Date: Fri, 17 Jun 2016 21:31:24 -0700 (PDT)
Message-ID: <20160617.213124.1063789508502408050.davem@davemloft.net>
References: <20160607.155405.778592531194331404.davem@davemloft.net>
	<5763DBCF.9080203@mojatatu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, netdev@vger.kernel.org
To: jhs@mojatatu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56780 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750752AbcFREb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Jun 2016 00:31:26 -0400
In-Reply-To: <5763DBCF.9080203@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamal Hadi Salim <jhs@mojatatu.com>
Date: Fri, 17 Jun 2016 07:15:27 -0400

> Ok, mystery solved. Dave, this patch series is missing from current
> net-next.

Then what is:

commit 53eb440f4ada034ea43b295891feec3df0fa7a29
Author: Jamal Hadi Salim <jhs@mojatatu.com>
Date:   Mon Jun 6 06:32:54 2016 -0400

    net sched actions: introduce timestamp for firsttime use
    
    Useful to know when the action was first used for accounting
    (and debugging)
    
    Signed-off-by: Jamal Hadi Salim <jhs@mojatatu.com>
