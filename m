From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 4/5] net_sched: use
 tcindex_filter_result_init()
Date: Mon, 15 Sep 2014 17:51:42 -0400 (EDT)
Message-ID: <20140915.175142.1283156593140343692.davem@davemloft.net>
References: <1410815210-6693-1-git-send-email-xiyou.wangcong@gmail.com>
	<1410815210-6693-5-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40399 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755013AbaIOVvo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:51:44 -0400
In-Reply-To: <1410815210-6693-5-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 15 Sep 2014 14:06:49 -0700

> Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Clearly an equivalent transformation, applied, thanks.
