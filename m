From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] sch_prio: update backlog as well
Date: Fri, 03 Jun 2016 19:26:35 -0400 (EDT)
Message-ID: <20160603.192635.47637559783238165.davem@davemloft.net>
References: <1464822920-14205-1-git-send-email-xiyou.wangcong@gmail.com>
	<1464822920-14205-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, stasn77@gmail.com, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751197AbcFCX0h (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2016 19:26:37 -0400
In-Reply-To: <1464822920-14205-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed,  1 Jun 2016 16:15:16 -0700

> We need to update backlog too when we update qlen.
> 
> Joint work with Stas.
> 
> Reported-by: Stas Nichiporovich <stasn77@gmail.com>
> Tested-by: Stas Nichiporovich <stasn77@gmail.com>
> Fixes: 2ccccf5fb43f ("net_sched: update hierarchical backlog too")
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
