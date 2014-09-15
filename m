From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 5/5] net_sched: clean up tcindex_set_parms()
Date: Mon, 15 Sep 2014 17:52:19 -0400 (EDT)
Message-ID: <20140915.175219.469982809113237924.davem@davemloft.net>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410815210-6693-6-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757119AbaIOVwV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:52:21 -0400
In-Reply-To: <1410815210-6693-6-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 15 Sep 2014 14:06:50 -0700

> We can move the allocation down.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

I'll give John time to review this.
