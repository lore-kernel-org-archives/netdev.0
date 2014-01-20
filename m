From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: act: remove capab from struct
 tc_action_ops
Date: Sun, 19 Jan 2014 19:58:40 -0800 (PST)
Message-ID: <20140119.195840.446123973040005322.davem@davemloft.net>
References: <1389829770-811-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41099 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752602AbaATD6l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jan 2014 22:58:41 -0500
In-Reply-To: <1389829770-811-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Wed, 15 Jan 2014 15:49:30 -0800

> It is not actually implemented.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied, we shouldn't keep something around which was added more than
a decade ago but never actually used.

If we find a use for it, we can add it back.
