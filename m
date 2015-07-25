From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net] sch_plug: purge buffered packets during reset
Date: Fri, 24 Jul 2015 22:57:42 -0700 (PDT)
Message-ID: <20150724.225742.1063280397827976150.davem@davemloft.net>
References: <1437521513-16116-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com
To: xiyou.wangcong@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49562 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752101AbbGYFol (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2015 01:44:41 -0400
In-Reply-To: <1437521513-16116-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <xiyou.wangcong@gmail.com>
Date: Tue, 21 Jul 2015 16:31:53 -0700

> Otherwise the skbuff related structures are not correctly
> refcount'ed.
> 
> Cc: Jamal Hadi Salim <jhs@mojatatu.com>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Applied.
