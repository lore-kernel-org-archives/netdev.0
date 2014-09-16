From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next v2] net_sched: fix memory leak in cls_tcindex
Date: Tue, 16 Sep 2014 15:19:42 -0400 (EDT)
Message-ID: <20140916.151942.29097386921779416.davem@davemloft.net>
References: <1410824623-27516-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57311 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754648AbaIPTTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Sep 2014 15:19:44 -0400
In-Reply-To: <1410824623-27516-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 15 Sep 2014 16:43:42 -0700

> Fixes: commit 331b72922c5f58d48fd ("net: sched: RCU cls_tcindex")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
