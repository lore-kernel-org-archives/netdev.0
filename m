From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: remove skb_sender_cpu_clear()
Date: Tue, 01 Mar 2016 17:36:59 -0500 (EST)
Message-ID: <20160301.173659.500519039303039828.davem@davemloft.net>
References: <1456633194-2510-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42835 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750843AbcCAWhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Mar 2016 17:37:00 -0500
In-Reply-To: <1456633194-2510-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Sat, 27 Feb 2016 20:19:54 -0800

> After commit 52bd2d62ce67 ("net: better skb->sender_cpu and skb->napi_id cohabitation")
> skb_sender_cpu_clear() becomes empty and can be removed.
> 
> Cc: Eric Dumazet <edumazet@google.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, thanks.
