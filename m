From: David Miller <davem@davemloft.net>
Subject: Re: [net-next PATCH] net: sched: cls_rcvp, complete rcu conversion
Date: Mon, 29 Sep 2014 00:02:45 -0400 (EDT)
Message-ID: <20140929.000245.2257803075331982571.davem@davemloft.net>
References: <20140926170249.27131.97630.stgit@nitbit.x32>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xiyou.wangcong@gmail.com, jhs@mojatatu.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: john.fastabend@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50289 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbaI2ECt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Sep 2014 00:02:49 -0400
In-Reply-To: <20140926170249.27131.97630.stgit@nitbit.x32>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: John Fastabend <john.fastabend@gmail.com>
Date: Fri, 26 Sep 2014 10:02:50 -0700

> This completes the cls_rsvp conversion to RCU safe
> copy, update semantics.
> 
> As a result all cases of tcf_exts_change occur on
> empty lists now.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, thanks John.
