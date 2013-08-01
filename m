From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2 net-next 2/2] net: rename CONFIG_NET_LL_RX_POLL to
 CONFIG_NET_RX_BUSY_POLL
Date: Thu, 01 Aug 2013 15:12:16 -0700 (PDT)
Message-ID: <20130801.151216.607058460579707146.davem@davemloft.net>
References: <1375326625-21427-1-git-send-email-amwang@redhat.com>
	<1375326625-21427-2-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, eliezer.tamir@linux.intel.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54995 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757529Ab3HAWMQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Aug 2013 18:12:16 -0400
In-Reply-To: <1375326625-21427-2-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Thu,  1 Aug 2013 11:10:25 +0800

> From: Cong Wang <amwang@redhat.com>
> 
> Eliezer renames several *ll_poll to *busy_poll, but forgets
> CONFIG_NET_LL_RX_POLL, so in case of confusion, rename it too.
> 
> Cc: Eliezer Tamir <eliezer.tamir@linux.intel.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

Also applied to net, thanks.
