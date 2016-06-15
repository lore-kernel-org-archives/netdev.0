From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net_sched: remove internal use of TC_POLICE_*
Date: Wed, 15 Jun 2016 00:06:38 -0700 (PDT)
Message-ID: <20160615.000638.1479592639489365076.davem@davemloft.net>
References: <1465840064-7650-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55013 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750841AbcFOHGk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 03:06:40 -0400
In-Reply-To: <1465840064-7650-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Mon, 13 Jun 2016 10:47:43 -0700

> These should be gone when we removed CONFIG_NET_CLS_POLICE.
> We can not totally remove them since they are exposed
> to userspace.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
