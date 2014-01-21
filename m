From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next 1/6] net_sched: act: fetch hinfo from
 a->ops->hinfo
Date: Tue, 21 Jan 2014 14:43:58 -0800 (PST)
Message-ID: <20140121.144358.1737340726185426734.davem@davemloft.net>
References: <1389987427-14085-1-git-send-email-xiyou.wangcong@gmail.com>
	<1389987427-14085-2-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37757 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754509AbaAUWn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jan 2014 17:43:59 -0500
In-Reply-To: <1389987427-14085-2-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Fri, 17 Jan 2014 11:37:02 -0800

> Every action ops has a pointer to hash info, so we don't need to
> hard-code it in each module.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
