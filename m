From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: fix suspicious RCU usage in
 cls_bpf_classify()
Date: Mon, 15 Sep 2014 17:43:41 -0400 (EDT)
Message-ID: <20140915.174341.1435363628142072601.davem@davemloft.net>
References: <1410816110-10354-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, john.fastabend@gmail.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754195AbaIOVnn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Sep 2014 17:43:43 -0400
In-Reply-To: <1410816110-10354-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 15 Sep 2014 14:21:50 -0700

> Fixes: commit 1f947bf151e90ec0baad2948 ("net: sched: rcu'ify cls_bpf")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
